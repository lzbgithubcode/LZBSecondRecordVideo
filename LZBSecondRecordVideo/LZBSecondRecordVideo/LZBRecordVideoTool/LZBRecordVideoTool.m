//
//  LZBRecordVideoTool.m
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/3/29.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBRecordVideoTool.h"

#define kLZBRecordVideoToolRecordSessionQueueKey "LZBRecordVideoToolRecordSessionQueue"

#define dispatch_main_handle(x) if(x!=nil) dispatch_async(dispatch_get_main_queue(), x)
@interface LZBRecordVideoTool() <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>
@property (nonatomic, strong)  AVCaptureSession         *captureSession;  //管理数据采集中心协调对象
@property (nonatomic,  copy)   dispatch_queue_t         captureSessionQueue;//录制的队列
@property (nonatomic, strong)  AVCaptureDeviceInput     *backCameraInput;  //后置摄像头输入
@property (nonatomic, strong)  AVCaptureDeviceInput     *frontCameraInput;//前置摄像头输入
@property (nonatomic, strong)  AVCaptureDeviceInput     *audioMicInput;//麦克风输入
@property (nonatomic, strong)  AVCaptureVideoDataOutput *videoOutput;//视频输出
@property (nonatomic, strong)  AVCaptureAudioDataOutput *audioOutput;//音频输出
@property (nonatomic, strong)  AVCaptureConnection      *videoConnection;//视频连接，确定视频录制方向
@property (nonatomic, strong)  AVCaptureVideoPreviewLayer *previewLayer;//捕获到的视频呈现的layer

//状态记录
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL isPaused;

@end

@implementation LZBRecordVideoTool
+ (LZBRecordVideoTool *)sharedRecordVideoTool {
    static LZBRecordVideoTool *_recordVideoTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _recordVideoTool = [[LZBRecordVideoTool alloc]init];
    });
    
    return _recordVideoTool;
}

+(BOOL)isCaputureSessionQueue
{
    return dispatch_get_specific(kLZBRecordVideoToolRecordSessionQueueKey)!=nil;
}

#pragma mark - API
//启动录制功能
- (void)startCaputureFunction
{
    if(self.captureSession == nil) return;
    if(self.captureSession.isRunning) return;
    [self.captureSession startRunning];
    self.isRecording = NO;
    self.isPaused = NO;
    
}
//关闭录制功能
- (void)stopCaputureFunction
{
    if(self.captureSession)
        [self.captureSession stopRunning];
}

//开始录制
- (void)startRecord
{
    //定义block
    __weak typeof(self) weakSelf = self;
    
    void (^startRecordBlock)() = ^{
        if(weakSelf.captureSession == nil) return;
        if(weakSelf.isRecording) return;
        weakSelf.isRecording = YES;
    };
    
   if([LZBRecordVideoTool isCaputureSessionQueue])
   {
       if(startRecordBlock)
           startRecordBlock();
   }
   else
   {
      dispatch_sync(self.captureSessionQueue, startRecordBlock);
   }
}

//停止录制
- (void)stopRecord
{
    [self stopRecordHandler:nil];
}
//停止录制
- (void)stopRecordHandler:(void(^)(UIImage *snapImage))handler
{
    //定义block
    __weak typeof(self) weakSelf = self;
    
    void (^stopRecordBlock)() = ^{
        if(weakSelf.captureSession == nil) return;
        if(!weakSelf.isRecording) return;
        weakSelf.isRecording = NO;
    };
    if([LZBRecordVideoTool isCaputureSessionQueue])
    {
        if(stopRecordBlock)
            stopRecordBlock();
    }
    else
    {
        dispatch_sync(self.captureSessionQueue, stopRecordBlock);
    }
}



//消失的时候移除设备
- (void)dellocRemoveDevice
{
    if(self.captureSession == nil) return;
    //移除输入设备
    for (AVCaptureDeviceInput *input in self.captureSession.inputs)
    {
        [self.captureSession removeInput:input];
    }
    //移除输出设备
    for (AVCaptureOutput *output in self.captureSession.outputs) {
        [self.captureSession removeOutput:output];
    }
    self.previewLayer.session = nil;
    self.captureSession = nil;
}
#pragma mark- handel




#pragma mark- lazy
//捕获到的视频呈现的layer
- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        //通过AVCaptureSession初始化
        AVCaptureVideoPreviewLayer *preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        //设置比例为铺满全屏
        preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer = preview;
    }
    return _previewLayer;
}
//会话
- (AVCaptureSession *)captureSession
{
   if(_captureSession == nil)
   {
       _captureSession = [[AVCaptureSession alloc]init];
       //设置分辨率
       if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
           _captureSession.sessionPreset=AVCaptureSessionPreset1280x720;
       }
       //添加后置摄像头的输入
       if ([_captureSession canAddInput:self.backCameraInput]) {
           [_captureSession addInput:self.backCameraInput];
       }
       
       //添加后置麦克风的输入
       if ([_captureSession canAddInput:self.audioMicInput]) {
           [_captureSession addInput:self.audioMicInput];
       }
       //添加视频输出
       if ([_captureSession canAddOutput:self.videoOutput]) {
           [_captureSession addOutput:self.videoOutput];
       }
       //添加视频输出
       if ([_captureSession canAddOutput:self.audioOutput]) {
           [_captureSession addOutput:self.audioOutput];
       }
       //增加连接
       if([self.videoConnection isVideoOrientationSupported])
       {
           AVCaptureVideoOrientation orientation = AVCaptureVideoOrientationPortrait;
           [self.videoConnection setVideoOrientation:orientation];
       }
   }
    return _captureSession;
}
#pragma mark-lazy-输出
- (AVCaptureVideoDataOutput *)videoOutput
{
  if(_videoOutput == nil)
  {
      _videoOutput = [[AVCaptureVideoDataOutput alloc]init];
      //必须使用串行队列来确保框架以适当的顺序传递给代理
      [_videoOutput setSampleBufferDelegate:self queue:self.captureSessionQueue];
      //缓冲区默认是以相机最有效的格式发出。使用该videoSettings属性来指定自定义输出格式
      _videoOutput.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                    nil];;  //视频像素格式,目前唯一支持的k​CVPixel​Buffer​Pixel​Format​Type​Key
     
  }
    return _videoOutput;
}
//音频输出
- (AVCaptureAudioDataOutput *)audioOutput {
    if (_audioOutput == nil) {
        _audioOutput = [[AVCaptureAudioDataOutput alloc] init];
        //必须使用串行队列来确保框架以适当的顺序传递给代理
        [_audioOutput setSampleBufferDelegate:self queue:self.captureSessionQueue];
    }
    return _audioOutput;
}
// 设置捕获连接的方向,设置AVCaptureVideoDataOutput）中定位图像的方向
- (AVCaptureConnection *)videoConnection
{
  if(_videoConnection == nil)
  {
      _videoConnection = [self.videoOutput connectionWithMediaType:AVMediaTypeVideo];
  }
    return _videoConnection;
}

#pragma mark-lazy-输入
//前置摄像头输入
- (AVCaptureDeviceInput *)frontCameraInput {
    if (_frontCameraInput == nil) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败~");
        }
    }
    return _frontCameraInput;
}
//前置摄像头输入
- (AVCaptureDeviceInput *)backCameraInput {
    if (_backCameraInput == nil) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败~");
        }
    }
    return _backCameraInput;
}

//麦克风输入
- (AVCaptureDeviceInput *)audioMicInput
{
   if(_audioMicInput == nil)
   {
       NSError *error;
       AVCaptureDevice *micDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
       _audioMicInput = [[AVCaptureDeviceInput alloc]initWithDevice:micDevice error:&error];
       if(error)
       {
          NSLog(@"获取麦克风失败~");
       }
   }
    return _audioMicInput;
}

//返回前置摄像头
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

//返回后置摄像头
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

//返回是前置摄像头还是后置摄像头
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    //返回和视频录制相关的所有默认设备
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    //遍历这些设备返回跟position相关的设备
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//录制队列
- (dispatch_queue_t)captureSessionQueue
{
   if(_captureSessionQueue == nil)
   {
       _captureSessionQueue = dispatch_queue_create("com.LZBRecordTool.caputuer", DISPATCH_QUEUE_SERIAL);
       //标记_captureSessionQueue队列
       dispatch_queue_set_specific(_captureSessionQueue, kLZBRecordVideoToolRecordSessionQueueKey,"true", nil);
        //设置_captureSessionQueue在全局队列的优先级
       dispatch_set_target_queue(_captureSessionQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
   }
    return _captureSessionQueue;
}
@end
