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
@end

@implementation LZBWriterVideoTool

//实例化LZBWriterVideoTool
+ (LZBWriterVideoTool *)writerVideoWithPath:(NSString *)path configParamModel:(LZBWriterVideoConfigModel *)paramModel
{
    return [[LZBWriterVideoTool alloc]initWithPath:path configParamModel:paramModel];
}
//初始化LZBWriterVideoTool
- (instancetype)initWithPath:(NSString *)path configParamModel:(LZBWriterVideoConfigModel *)paramModel
{
    if(self = [super init])
    {
        self.writerPath = path;
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
            [self initVideoWriterWithParam:paramModel.writerVideoSetting];
        }
        //初始化音频输入
        if(paramModel.writerAudioSetting !=nil)
        {
            [self initAudioWriterWithParam:paramModel.writerAudioSetting];
        }
        
    }
    return self;
}

//初始化视频输入
- (void)initVideoWriterWithParam:(NSDictionary *)paramDictionary
{
    //初始化视频写入类,paramDictionary里面应该包括分辨率、编码、视频像素等参数
    self.videoWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:paramDictionary];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.videoWriter.expectsMediaDataInRealTime = YES;
     //将视频输入源加入
    [self.writer addInput:self.videoWriter];
}

//初始化音频输入
- (void)initAudioWriterWithParam:(NSDictionary *)paramDictionary
{
    //初始化音频写入类,paramDictionary里面应该包括AAC,音频通道、采样率和音频的比特率
    self.audioWriter = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:paramDictionary];
    //表明输入是否应该调整其处理为实时数据源的数据
    self.audioWriter.expectsMediaDataInRealTime = YES;
    //将视频输入源加入
    [self.writer addInput:self.audioWriter];
}

//写入视频数据
- (void)writerVideoDataSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if(self.videoWriter == nil) return;
}

//写入音频数据
- (void)writerAudioDataSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
  
}
@end
