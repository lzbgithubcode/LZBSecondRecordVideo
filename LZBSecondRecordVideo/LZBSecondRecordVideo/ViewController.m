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
    BOOL author = [LZBAuthorizationManger checkContactsAuthorization];
     NSLog(@"FUNCTION NAME:%s, LINE:%d \n \n------%d", __FUNCTION__, __LINE__,author);
    
}


@end
