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
#import <AssetsLibrary/AssetsLibrary.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

//照相机设置
#define cameraSetting   @"prefs:root=Privacy&path=CAMERA"

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
                        //回到主线程
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
    //iOS8.0之后
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
                    isAvalible = NO;  //回到主线程
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

// 检测通讯录是否授权
+ (BOOL)checkContactsAuthorization
{
    __block BOOL isAvalible = NO;
    __weak __typeof__(self) weakSelf = self;
    //iOS9.0之前
    if([[UIDevice currentDevice].systemVersion floatValue] <= __IPHONE_9_0)
    {
        ABAuthorizationStatus authorStatus = ABAddressBookGetAuthorizationStatus();
        switch (authorStatus) {
            case kABAuthorizationStatusAuthorized:
                isAvalible = YES;
                break;
            case kABAuthorizationStatusDenied:
            {
                [self showWithMessage:@"此功能需要您授权本App打开相册\n设置方法:打开手机设置->隐私->通讯录"];
                isAvalible = NO;
            }
                break;
            case kABAuthorizationStatusNotDetermined:
            {
                __block ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
                if (addressBook != NULL)
                {
                    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                        isAvalible = granted;
                        if (!granted) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [weakSelf checkContactsAuthorization];
                            });
                        }
                        if (addressBook) {
                            CFRelease(addressBook);
                            addressBook = NULL;
                        }
                    });
                }
            }
                break;
            case kABAuthorizationStatusRestricted:
                isAvalible = NO;
                break;
            default:
                break;
        }
    }
    else//iOS9.0之后
    {
        CNAuthorizationStatus authStatus = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (authStatus) {
            case CNAuthorizationStatusAuthorized:
                isAvalible = YES;
                break;
            case CNAuthorizationStatusDenied:
            {
                [self showWithMessage:@"此功能需要您授权本App打开相册\n设置方法:打开手机设置->隐私->通讯录"];
                isAvalible = NO;
            }
                break;
            case CNAuthorizationStatusNotDetermined:
            {
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    isAvalible = granted;
                    if (!granted) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf checkContactsAuthorization];
                        });
                    }
                }];
            }
                break;
            case CNAuthorizationStatusRestricted:
                isAvalible = NO;
                break;
        }
    }
    

    return isAvalible;
}


#pragma mark - 弹框
//弹框提示
+ (void)showWithMessage:(NSString *)tipString
{
    UIAlertView *alter = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:tipString delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alter show];
}

//引导到设置页面去设置
+ (void)gotoSetting
{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication]openURL:url];
    }
}
@end
