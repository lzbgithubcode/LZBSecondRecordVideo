//
//  LZBVideoConfigModel.m
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/4/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBVideoConfigModel.h"

#define outputVideoSizeWidth 720
#define outputVideoSizeHeight 1280

@implementation LZBVideoConfigModel
- (instancetype)init
{
  if(self = [super init])
  {
      self.codeType = AVVideoCodecH264;
      self.scalingMode = AVVideoScalingModeResizeAspectFill;
      self.outputVideoSize =CGSizeMake(outputVideoSizeWidth, outputVideoSizeHeight);
  }
    return self;
}

- (NSDictionary *)getOutVideoFomartWithOptionsUsingSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //获取当个帧图片大小
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    return [self createAssetWriterOptionsWithVideoSize:CGSizeMake(width, height)];
}

- (NSDictionary *)createAssetWriterOptionsWithVideoSize:(CGSize)videoSize
{
    NSDictionary *options = self.configMedias;
    if (options != nil) {
        return options;
    }
    CGSize outputSize = CGSizeZero;
    
    if(!CGSizeEqualToSize(videoSize, CGSizeZero))
        outputSize = videoSize;
    
    if(!CGSizeEqualToSize(self.outputVideoSize, CGSizeZero))
        outputSize = self.outputVideoSize;
    
   
  
    NSMutableDictionary *compressionProperties = [[NSMutableDictionary alloc]init];
    //视频尺寸*比率，10.1相当于AVCaptureSessionPresetHigh，数值越大，显示越精细
    [compressionProperties setObject: [NSNumber numberWithInt:outputSize.height*outputSize.width*7.5] forKey:AVVideoAverageBitRateKey];
    
    [compressionProperties setObject:@NO forKey:AVVideoAllowFrameReorderingKey];
    [compressionProperties setObject:@30 forKey:AVVideoExpectedSourceFrameRateKey];
    
    //录制视频的一些配置，分辨率，编码方式等等
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.codeType, AVVideoCodecKey,
                              self.scalingMode, AVVideoScalingModeKey,
                              compressionProperties, AVVideoCompressionPropertiesKey,
                              [NSNumber numberWithInteger: outputSize.width], AVVideoWidthKey,
                              [NSNumber numberWithInteger: outputSize.height], AVVideoHeightKey,
                              
                              nil];
    return settings;
    
}
@end
