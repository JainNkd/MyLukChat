//
//  VideoEncoder.h
//  LukChat
//
//  Created by Shafi on 01/12/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVAssetWriter.h"
#import "AVFoundation/AVAssetWriterInput.h"
#import "AVFoundation/AVMediaFormat.h"
#import "AVFoundation/AVVideoSettings.h"
#import "AVFoundation/AVAudioSettings.h"


@interface VideoEncoder : NSObject
{
    AVAssetWriter* _writer;
    AVAssetWriterInput* _videoInput;
    AVAssetWriterInput* _audioInput;
    NSString* _path;
}

@property NSString* path;

+ (VideoEncoder*) encoderForPath:(NSString*) path Height:(int) cy width:(int) cx channels: (int) ch samples:(Float64) rate;

- (void) initPath:(NSString*)path Height:(int) cy width:(int) cx channels: (int) ch samples:(Float64) rate;
- (void) finishWithCompletionHandler:(void (^)(void))handler;
- (BOOL) encodeFrame:(CMSampleBufferRef) sampleBuffer isVideo:(BOOL) bVideo;


@end
