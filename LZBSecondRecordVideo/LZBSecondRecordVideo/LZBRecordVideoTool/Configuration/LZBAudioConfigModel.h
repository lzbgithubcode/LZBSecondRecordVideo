//
//  LZBAudioConfigModel.h
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/4/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBMediaTypeConfigModel.h"
#import <AVFoundation/AVFoundation.h>

@interface LZBAudioConfigModel : LZBMediaTypeConfigModel
/**
  设置音频的比特率，默认是128000
 */
@property (nonatomic, assign) UInt64 bitrate;

/**
 设置音频的格式,默认是kAudioFormatMPEG4AAC
 */
@property (nonatomic, assign) int formatID;

/**
 设置音频通道,默认是2
 */
@property (nonatomic, assign) int chanels;
/**
 设置音频采样频率,默认是44100
 */
@property (nonatomic, assign) int rate;


/**
 获取音频输出配置参数

 @param sampleBuffer 音频缓存
 @return 字典参数
 */
- (NSDictionary *)getOutAudioOptionsUsingSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
