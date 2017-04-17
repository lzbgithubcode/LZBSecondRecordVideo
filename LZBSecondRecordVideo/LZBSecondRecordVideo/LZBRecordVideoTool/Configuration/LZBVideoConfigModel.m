//
//  LZBVideoConfigModel.m
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/4/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBVideoConfigModel.h"

@implementation LZBVideoConfigModel
- (instancetype)init
{
  if(self = [super init])
  {
      self.codeType = AVVideoCodecH264;
      self.scalingMode = AVVideoScalingModeResizeAspectFill;
      self.outputVideoSize =CGSizeZero;
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
    CGSize outputSize = self.outputVideoSize;
    if (CGSizeEqualToSize(outputSize, CGSizeZero)) {
        outputSize = videoSize;
    }
    
    NSMutableDictionary *compressionProperties = [[NSMutableDictionary alloc]init];
    //视频尺寸*比率，10.1相当于AVCaptureSessionPresetHigh，数值越大，显示越精细
    [compressionProperties setObject: [NSNumber numberWithInt:outputSize.height*outputSize.width*7.5] forKey:AVVideoAverageBitRateKey];
    
    [compressionProperties setObject:@NO forKey:AVVideoAllowFrameReorderingKey];
    [compressionProperties setObject:@30 forKey:AVVideoExpectedSourceFrameRateKey];
    
    return @{
             AVVideoCodecKey : self.codeType,
             AVVideoScalingModeKey : self.scalingMode,
             AVVideoWidthKey : [NSNumber numberWithInteger:outputSize.width],
             AVVideoHeightKey : [NSNumber numberWithInteger:outputSize.height],
             AVVideoCompressionPropertiesKey : compressionProperties
             };
    
}
@end
