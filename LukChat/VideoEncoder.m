//
//  VideoEncoder.m
//  LukChat
//
//  Created by Shafi on 01/12/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "VideoEncoder.h"
#include <architecture/byte_order.h>

@implementation VideoEncoder

@synthesize path = _path;

+ (VideoEncoder*) encoderForPath:(NSString*) path Height:(int) cy width:(int) cx channels: (int) ch samples:(Float64) rate;
{
    VideoEncoder* enc = [VideoEncoder alloc];
    [enc initPath:path Height:cy width:cx channels:ch samples:rate];
    return enc;
}


- (void) initPath:(NSString*)path Height:(int) cy width:(int) cx channels: (int) ch samples:(Float64) rate;
{
    self.path = path;
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    NSURL* url = [NSURL fileURLWithPath:self.path];
    
    _writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              AVVideoCodecH264, AVVideoCodecKey,
                              [NSNumber numberWithInt: cx], AVVideoWidthKey,
                              [NSNumber numberWithInt: cy], AVVideoHeightKey,
                              nil];
    _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    _videoInput.expectsMediaDataInRealTime = YES;
    [_writer addInput:_videoInput];
    
//    settings = [NSDictionary dictionaryWithObjectsAndKeys:
//                [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
//                [ NSNumber numberWithInt: ch], AVNumberOfChannelsKey,
//                [ NSNumber numberWithFloat: rate], AVSampleRateKey,
//                [ NSNumber numberWithInt: 64000 ], AVEncoderBitRateKey,
//                nil];
//    
    NSDictionary* audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInteger:kAudioFormatLinearPCM], AVFormatIDKey,
                                             [NSNumber numberWithFloat:12000.0f], AVSampleRateKey,
                                             [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                             [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                             [NSNumber numberWithBool:0], AVLinearPCMIsFloatKey,
                                             [NSNumber numberWithBool:0], AVLinearPCMIsNonInterleaved,
                                             [NSNumber numberWithBool:NX_BigEndian == NXHostByteOrder()],AVLinearPCMIsBigEndianKey,
                nil];
    _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    _audioInput.expectsMediaDataInRealTime = YES;
    [_writer addInput:_audioInput];
}

- (void) finishWithCompletionHandler:(void (^)(void))handler
{
    [_audioInput markAsFinished];
    [_videoInput markAsFinished];
    [_writer finishWritingWithCompletionHandler: handler];
}

- (BOOL) encodeFrame:(CMSampleBufferRef) sampleBuffer isVideo:(BOOL)bVideo
{
    if (CMSampleBufferDataIsReady(sampleBuffer))
    {
        if (_writer.status == AVAssetWriterStatusUnknown)
        {
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startWriting];
            [_writer startSessionAtSourceTime:startTime];
        }
        if (_writer.status == AVAssetWriterStatusFailed)
        {
            NSLog(@"writer error %@", _writer.error.localizedDescription);
            return NO;
        }
        if (bVideo)
        {
            if (_videoInput.readyForMoreMediaData == YES)
            {
                [_videoInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }
        else
        {
            if (_audioInput.readyForMoreMediaData)
            {
                [_audioInput appendSampleBuffer:sampleBuffer];
                return YES;
            }
        }
    }
    return NO;
}

@end
