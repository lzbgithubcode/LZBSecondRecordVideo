//
//  LZBAuthorizationManger.m
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/3/30.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBAuthorizationManger.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>

@implementation LZBAuthorizationManger
/**
 检测录制视频的相机是否授权
 */
+ (BOOL)checkVideoCameraAuthorization
{
    __block BOOL isAvalible = NO;
    __weak __typeof__(self) weakSelf = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized: //授权
            isAvalible = YES;
            break;
        case AVAuthorizationStatusDenied:   //拒绝，弹框
            {
                [self showWithMessage:@"此功能需要您授权本App打开相机\n设置方法:打开手机设置->隐私->相机"];
                isAvalible = NO;
            }
            break;
        case AVAuthorizationStatusNotDetermined:   //没有决定，第一次启动默认弹框
        {
            //点击弹框授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                isAvalible = granted;
                if(!granted)  //如果不允许
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf checkVideoCameraAuthorization];
                    });
                }
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:  //受限制，家长控制器
            isAvalible = NO;
            break;
    }
    return isAvalible;
}

/**
 检测录制视频的麦克风是否授权
 */
+ (BOOL)checkVideoMicrophoneAudioAuthorization
{
     __block BOOL isAvalible = NO;
     __weak __typeof__(self) weakSelf = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusAuthorized: //授权
            isAvalible = YES;
            break;
        case AVAuthorizationStatusDenied:   //拒绝，弹框
            {
                [self showWithMessage:@"此功能需要您授权本App打开麦克风\n设置方法:打开手机设置->隐私->麦克风"];
                isAvalible = NO;
            }
            break;
        case AVAuthorizationStatusNotDetermined:   //没有决定，第一次启动
            {
                //点击弹框授权
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                    isAvalible = granted;
                    if(!granted)  //如果不允许
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf checkVideoMicrophoneAudioAuthorization];
                        });
                    }
                }];
            }
            break;
        case AVAuthorizationStatusRestricted:  //受限制，家长控制器
           isAvalible = NO;
            break;
    }
    return isAvalible;
}
/**
 检测相册是否授权
 */
+ (BOOL)checkVideoPhotoAuthorization
{
    __block BOOL isAvalible = NO;
    __weak __typeof__(self) weakSelf = self;
    PHAuthorizationStatus photoStatus =  [PHPhotoLibrary authorizationStatus];
    switch (photoStatus) {
        case PHAuthorizationStatusAuthorized:
            isAvalible = YES;
            break;
        case PHAuthorizationStatusDenied:
            {
              [self showWithMessage:@"此功能需要您授权本App打开相册\n设置方法:打开手机设置->隐私->相册"];
               isAvalible = NO;
            }
            break;
        case PHAuthorizationStatusNotDetermined:
            {
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status == PHAuthorizationStatusAuthorized) {
                         isAvalible = YES;
                    }else{
                         isAvalible = NO;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf checkVideoPhotoAuthorization];
                        });
                    }
                }];
                
            }
            break;
        case PHAuthorizationStatusRestricted:
             isAvalible = NO;
            break;
        default:
            break;
    }
    return isAvalible;
};


#pragma mark - 弹框
+ (void)showWithMessage:(NSString *)tipString
{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:tipString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alter show];
}
@end
