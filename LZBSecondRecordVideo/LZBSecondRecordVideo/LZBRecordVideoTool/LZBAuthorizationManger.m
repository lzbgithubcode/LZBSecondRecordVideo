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
#import <CoreLocation/CoreLocation.h>
typedef NS_ENUM(NSInteger,LZBAppSettingType)
{
     LZBAppSettingType_None,  //没有
      //iOS10.0之后没有用，直接跳转到设置页面可以获取权限
     LZBAppSettingType_Camera,  //照相机
     LZBAppSettingType_Photos,  //相片库
     LZBAppSettingType_Microphone,  //麦克风
     LZBAppSettingType_Contact,  //通讯录
    
};

//iOS10.0之后默认只能跳转到设置页面,系统会自动跳转到设备对应权限的页面
NSString *LZBAppSettingTypeValue[] =
{
    [LZBAppSettingType_None] = @"",
     //iOS10.0之后没有用，直接跳转到设置页面可以获取权限
    [LZBAppSettingType_Camera] = @"Prefs:root=General&path=CAMERA",
    [LZBAppSettingType_Photos] = @"Prefs:root=Photos",
    [LZBAppSettingType_Microphone] = @"Prefs:root=Privacy&path=MICROPHONE",
    [LZBAppSettingType_Contact] = @"Prefs:root=Privacy&path=CONTACTS",
};

@interface LZBAuthorizationManger()<CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManger;
@end

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
                        [weakSelf gotoSettingPrivacyWithType:LZBAppSettingType_None];
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
                             [weakSelf gotoSettingPrivacyWithType:LZBAppSettingType_None];
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
                        [weakSelf gotoSettingPrivacyWithType:LZBAppSettingType_None];
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
                                 [weakSelf gotoSettingPrivacyWithType:LZBAppSettingType_None];
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
                             [weakSelf gotoSettingPrivacyWithType:LZBAppSettingType_None];
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

+ (BOOL)checkLocationAuthorization
{
    __block BOOL isAvalible = NO;
   if(![CLLocationManager locationServicesEnabled])
       return NO;
   CLAuthorizationStatus locationStatus =  [CLLocationManager authorizationStatus];
    switch (locationStatus) {
        case kCLAuthorizationStatusAuthorizedAlways:
            isAvalible = NO;
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            isAvalible = NO;
        }
            break;
        case kCLAuthorizationStatusRestricted:
            isAvalible = NO;
            break;
        case kCLAuthorizationStatusDenied:
        {
            [self showWithMessage:@"此功能需要您授权本App打开相册\n设置方法:打开手机设置->隐私->位置信息"];
            isAvalible = NO;
        }
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            isAvalible = YES;
            break;
            
        default:
            break;
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


/**
   跳转到设置权限界面
 */
+ (void)gotoSettingPrivacyWithType:(LZBAppSettingType)type
{
    NSString *jumpString =LZBAppSettingTypeValue[type];
    if(jumpString.length == 0)
    {
        [self gotoSetting];
        return;
    }
    NSURL *url = [NSURL URLWithString:jumpString];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication]openURL:url];
    }
}

- (CLLocationManager *)locationManger
{
  if(_locationManger == nil)
  {
      _locationManger = [[CLLocationManager alloc]init];
      _locationManger.delegate = self;
      // 最小距离
      _locationManger.distanceFilter = 50.f;
      _locationManger.desiredAccuracy = kCLLocationAccuracyBest;
  }
    return _locationManger;
}

@end
