//
//  SCAssetExportSession.h
//  SCRecorder
//
//  Created by Simon CORSIN on 14/05/14.
//  Copyright (c) 2014 rFlex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SCFilterGroup.h"
#import "SCVideoConfiguration.h"
#import "SCAudioConfiguration.h"

@interface SCAssetExportSession : NSObject

/**
 The input asset to use
 */
@property (strong, nonatomic) AVAsset *inputAsset;

/**
 The outputUrl to which the asset will be exported
 */
@property (strong, nonatomic) NSURL *outputUrl;

/**
 The type of file to be written by the export session
 */
@property (strong, nonatomic) NSString *outputFileType;

/**
 If true, the export session will use the GPU for rendering the filters
 */
@property (assign, nonatomic) BOOL useGPUForRenderingFilters;

/**
 Access the configuration for the video.
 */
@property (readonly, nonatomic) SCVideoConfiguration *videoConfiguration;

/**
 Access the configuration for the audio.
 */
@property (readonly, nonatomic) SCAudioConfiguration *audioConfiguration;

// If an error occured during the export, this will contain that error
@property (readonly, nonatomic) NSError *error;

- (id)init;

// Init with the inputAsset
- (id)initWithAsset:(AVAsset*)inputAsset;

// Starts the asynchronous execution of the export session
- (void)exportAsynchronouslyWithCompletionHandler:(void(^)())completionHandler;




//////////////////
// PRIVATE API
////

// These are only exposed for inheritance purpose
@property (readonly, nonatomic) dispatch_queue_t dispatchQueue;
@property (readonly, nonatomic) dispatch_group_t dispatchGroup;
@property (readonly, nonatomic) AVAssetWriterInput *audioInput;
@property (readonly, nonatomic) AVAssetWriterInput *videoInput;

- (void)markInputComplete:(AVAssetWriterInput *)input error:(NSError *)error;
- (BOOL)processSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (BOOL)processPixelBuffer:(CVPixelBufferRef)pixelBuffer presentationTime:(CMTime)presentationTime;
- (void)beginReadWriteOnInput:(AVAssetWriterInput *)input fromOutput:(AVAssetReaderOutput *)output;
- (BOOL)needsInputPixelBufferAdaptor;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
