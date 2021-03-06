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
 输出音频配置参数
 */
@property (nonatomic, strong) NSDictionary *outputAudioSetting;
/**
 输出视频配置参数
 */
@property (nonatomic, strong) NSDictionary *outputVideoSetting;
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
+ (LZBWriterVideoTool *)writerVideoWithPath:(NSString *)path configParamModel:(LZBWriterVideoConfigModel *)paramModel  sampleBuffer:(CMSampleBufferRef)sampleBuffer failCallBack:(void(^)(NSError *error))failBlock;


/**
 初始化写入视频、音频编码类
 @param path 媒体存放路径
 @param paramModel 参数配置模型
 @return LZBWriterVideoTool
 */
- (instancetype)initWithPath:(NSString *)path configParamModel:(LZBWriterVideoConfigModel *)paramModel sampleBuffer:(CMSampleBufferRef)sampleBuffer failCallBack:(void(^)(NSError *error))failBlock;


/**
 写入视频数据，设置帧速率
 @param sampleBuffer 写入的数据
 */
- (void)writerVideoDataSampleBuffer:(CMSampleBufferRef)sampleBuffer frameDuration:(CMTime)frameDuration completion:(void (^)(BOOL suceess))completion;

/**
 写入音频数据,设置帧速率
 @param sampleBuffer 写入的数据
 */
- (void)writerAudioDataSampleBuffer:(CMSampleBufferRef)sampleBuffer completion:(void (^)(BOOL suceess))completion;


- (void)finishRecording;

- (void)finishRecordingWithCompletionHandler:(void (^)(void))handler;

@end
