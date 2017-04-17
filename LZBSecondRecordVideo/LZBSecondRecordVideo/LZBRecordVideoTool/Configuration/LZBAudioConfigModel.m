//
//  LZBAudioConfigModel.m
//  LZBSecondRecordVideo
//
//  Created by zibin on 2017/4/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "LZBAudioConfigModel.h"

@implementation LZBAudioConfigModel
- (instancetype)init
{
    if(self = [super init])
    {
        self.bitrate = 128000;
        self.formatID = kAudioFormatMPEG4AAC;
        self.chanels =2;
        self.rate =44100;
    }
    return self;
}
- (NSDictionary *)getOutAudioOptionsUsingSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    NSDictionary *options = self.configMedias;
    if (options != nil) {
        return options;
    }
    
    Float64 sampleRate = self.rate;
    int channels = self.chanels;
    unsigned long bitrate = (unsigned long)self.bitrate;
    
    if(sampleBuffer != nil)
    {
        CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
        const AudioStreamBasicDescription *streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription);
            sampleRate = streamBasicDescription->mSampleRate;
            channels = streamBasicDescription->mChannelsPerFrame;
    }
    return @{
             AVFormatIDKey : [NSNumber numberWithInt: self.formatID],
             AVEncoderBitRateKey : [NSNumber numberWithUnsignedLong: bitrate],
             AVNumberOfChannelsKey : [NSNumber numberWithInt: channels],
             AVSampleRateKey : [NSNumber numberWithInt: sampleRate]
             };
}
@end
