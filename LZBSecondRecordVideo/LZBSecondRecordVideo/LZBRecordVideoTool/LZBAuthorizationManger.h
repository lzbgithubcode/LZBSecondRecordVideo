//
//  LZBAuthorizationManger.h
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/3/30.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LZBAuthorizationManger : NSObject

/**
  检测录制视频的相机是否授权
 */
+ (BOOL)checkVideoCameraAuthorization;

/**
  检测录制视频的麦克风是否授权
 */
+ (BOOL)checkVideoMicrophoneAudioAuthorization;

/**
   检测相册是否授权
 */
+ (BOOL)checkVideoPhotoAuthorization;

/**
    检测通讯录是否授权
 */
+ (BOOL)checkContactsAuthorization;

/**
    检测位置定位是否授权
 */
+ (BOOL)checkLocationAuthorization;
@end
