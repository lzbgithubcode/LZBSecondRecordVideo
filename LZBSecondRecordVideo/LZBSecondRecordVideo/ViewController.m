//
//  ViewController.m
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/3/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ViewController.h"
#import "LZBAuthorizationManger.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [LZBAuthorizationManger checkVideoCameraAuthorization];
    [LZBAuthorizationManger checkVideoMicrophoneAudioAuthorization];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
