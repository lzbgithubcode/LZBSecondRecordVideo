//
//  LZBWriterVideoTool.m
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/4/11.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBWriterVideoTool.h"

@interface LZBWriterVideoTool()
@property (nonatomic, strong) NSString *writerPath;//写入路径
@property (nonatomic, strong) AVAssetWriter *writer;//媒体写入对象
@property (nonatomic, strong) AVAssetWriterInput *videoWriter;//视频写入对象
@property (nonatomic, strong) AVAssetWriterInput *audioWriter;//音频写入对象
@property (nonatomic, assign) CMTime startTime;   //存放开始记录时间
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *videoPixelBufferAdaptor;
@end

@implementation LZBWriterVideoTool

//实例化LZBWriterVideoTool
+ (LZBWriterVideoTool *)writerVideoWithPath:(NSString *)path configParamModel:(LZBWriterVideoConfigModel *)paramModel  sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    return [[LZBWriterVideoTool alloc]initWithPath:path configParamModel:paramModel sampleBuffer:sampleBuffer];
}
//初始化LZBWriterVideoTool
- (instancetype)initWithPath:(NSString *)path configParamModel:(LZBWriterVideoConfigModel *)paramModel sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if(self = [super init])
    {
        self.writerPath = path;
        self.startTime = kCMTimeInvalid;
        //移除之前的路径
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:self.writerPath error:&error];
        //初始化当前的写入对象,必须是文件路径
        NSURL *url = [NSURL fileURLWithPath:self.writerPath];
         //初始化写入媒体类型为MP4类型,url必须是文件路径
        self.writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeMPEG4 error:nil];
        //使其更适合在网络上播放
        self.writer.shouldOptimizeForNetworkUse = YES;
         //初始化视频写入
        if(paramModel.writerVideoSetting !=nil)
        {
            [self initVideoWriterWithParam:paramModel.writerVideoSetting sampleBuffer:sampleBuffer];
        }
        //初始化音频输入
        if(paramModel.writerAudioSetting !=nil)
        {
            [self initAudioWriterWithParam:paramModel.writerAudioSetting sampleBuffer:sampleBuffer];
        }
        
    }
    return self;
}

//初始化视频输入
- (void)initVideoWriterWithParam:(NSDictionary *)paramDictionary  sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //初始化视频写入类,paramDictionary里面应该包括分辨率、编码、视频像素等参数
    self.videoWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:paramDictionary];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.videoWriter.expectsMediaDataInRealTime = YES;
     //将视频输入源加入
    [self.writer addInput:self.videoWriter];
    
    //配置像素合成参数
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
    NSDictionary *pixelBufferAttributes = @{
                                            (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
                                            (id)kCVPixelBufferWidthKey : [NSNumber numberWithInt:dimensions.width],
                                            (id)kCVPixelBufferHeightKey : [NSNumber numberWithInt:dimensions.height]
                                            };
    //像素图片合成器
    self.videoPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.videoWriter sourcePixelBufferAttributes:pixelBufferAttributes];
}

//初始化音频输入
- (void)initAudioWriterWithParam:(NSDictionary *)paramDictionary  sampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //初始化音频写入类,paramDictionary里面应该包括AAC,音频通道、采样率和音频的比特率
    self.audioWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:paramDictionary];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.audioWriter.expectsMediaDataInRealTime = YES;
    //将视频输入源加入
    [self.writer addInput:self.audioWriter];
}

#pragma mark - 写入视频数据
- (void)writerVideoDataSampleBuffer:(CMSampleBufferRef)sampleBuffer frameDuration:(CMTime)frameDuration  completion:(void (^)(BOOL suceess))completion
{
    if(self.videoWriter == nil) return;
    if(!CMSampleBufferDataIsReady(sampleBuffer)) return;
    //获取单帧图片
   CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    //获取真实写入的CMTime
   CMTime time = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
   
    //可以增加滤镜
    
    //写入像素
    [self appendVideoPixelBuffer:imageBuffer atTime:time duration:frameDuration completion:completion];
}

//开始写入数据
- (void)startWriterDataWithstartTime:(CMTime)time
{
    if(CMTIME_IS_INVALID(self.startTime))
      {
        self.startTime = time;
        [self.writer startWriting];
        [self.writer startSessionAtSourceTime:time];
     }
}
//写入像素帧
- (void)appendVideoPixelBuffer:(CVPixelBufferRef)videoPixelBuffer atTime:(CMTime)currentBufferTime duration:(CMTime)pixelduration completion:(void (^)(BOOL suceess))completion
{
    //开始写入视频数据
    [self startWriterDataWithstartTime:currentBufferTime];
    CMTime bufferTimestamp = CMTimeSubtract(currentBufferTime, self.startTime);
    if([self.videoWriter isReadyForMoreMediaData])
    {
       if([self.videoPixelBufferAdaptor appendPixelBuffer:videoPixelBuffer withPresentationTime:bufferTimestamp])
       {
          if(completion)
              completion(YES);
       }
        else
        {
            if(completion)
                completion(NO);
        }
    }
}

#pragma mark - 写入音频数据
- (void)writerAudioDataSampleBuffer:(CMSampleBufferRef)sampleBuffer frameDuration:(CMTime)frameDuration completion:(void (^)(BOOL suceess))completion
{
  
}
@end
