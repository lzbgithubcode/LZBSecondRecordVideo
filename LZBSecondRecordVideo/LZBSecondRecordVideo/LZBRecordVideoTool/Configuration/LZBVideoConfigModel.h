//
//  LZBVideoConfigModel.h
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/4/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBMediaTypeConfigModel.h"
#import <AVFoundation/AVFoundation.h>

@interface LZBVideoConfigModel : LZBMediaTypeConfigModel
/**
 code编码类型，默认是AVVideoCodecH264
 */
@property (nonatomic, copy) NSString *__nonnull codeType;

/**
 scalingMode缩放模式，默认是AVVideoScalingModeResizeAspectFill
 */
@property (nonatomic, copy) NSString *__nonnull scalingMode;

/**
    设置输出视频的大小，默认是CGZero
 */
@property (nonatomic, assign) CGSize outputVideoSize;


/**
 获取输出视频参数配置

 @param sampleBuffer 视频缓存
 @return 视频字典参数
 */
- (NSDictionary *)getOutVideoFomartWithOptionsUsingSampleBuffer:(CMSampleBufferRef)sampleBuffer;
@end
