//
//  LZBWriterVideoTool.h
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/4/11.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface LZBWriterVideoConfigModel : NSObject

/**
 写入音频配置参数
 */
@property (nonatomic, strong) NSDictionary *writerAudioSetting;
/**
 写入视频配置参数
 */
@property (nonatomic, strong) NSDictionary *writerVideoSetting;
@end


@interface LZBWriterVideoTool : NSObject

/**
 返回写入路径
 */
@property (nonatomic, strong,readonly) NSString *writerPath;

/**
 实例化写入视频、音频编码类
 @param path 媒体存放路径
 @param paramModel 参数配置模型
 @return LZBWriterVideoTool
 */
+ (LZBWriterVideoTool *)writerVideoWithPath:(NSString *)path configParamModel:(LZBWriterVideoConfigModel *)paramModel  sampleBuffer:(CMSampleBufferRef)sampleBuffer;


/**
 初始化写入视频、音频编码类
 @param path 媒体存放路径
 @param paramModel 参数配置模型
 @return LZBWriterVideoTool
 */
- (instancetype)initWithPath:(NSString *)path configParamModel:(LZBWriterVideoConfigModel *)paramModel sampleBuffer:(CMSampleBufferRef)sampleBuffer;


/**
 写入视频数据，设置帧速率
 @param sampleBuffer 写入的数据
 */
- (void)writerVideoDataSampleBuffer:(CMSampleBufferRef)sampleBuffer frameDuration:(CMTime)frameDuration completion:(void (^)(BOOL suceess))completion;

/**
 写入音频数据,设置帧速率
 @param sampleBuffer 写入的数据
 */
- (void)writerAudioDataSampleBuffer:(CMSampleBufferRef)sampleBuffer frameDuration:(CMTime)frameDuration completion:(void (^)(BOOL suceess))completion;

@end
