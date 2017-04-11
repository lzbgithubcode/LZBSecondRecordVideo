//
//  LZBRecordVideoTool.h
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/3/29.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LZBRecordVideoTool : NSObject

/**
  设置最大的录制时间
 */
@property (nonatomic, assign) CMTime maxRecordDuration;

/**
   是否正在录制
 */
@property (nonatomic, assign, readonly) BOOL isRecording;
/**
   是否暂停
 */
@property (nonatomic, assign, readonly) BOOL isPaused;


//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer;

//启动录制功能
- (void)startCaputureFunction;

//关闭录制功能
- (void)stopCaputureFunction;

//开始录制
- (void)startRecord;

//停止录制
- (void)stopRecord;

//暂停录制
- (void)pauseRecord;

//继续录制
- (void)resumeRecord;



//消失的时候移除设备
- (void)dellocRemoveDevice;
@end
