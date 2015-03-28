//
//  CameraEngine.h
//  LukChat
//
//  Created by Shafi on 01/12/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVCaptureSession.h"
#import "AVFoundation/AVCaptureOutput.h"
#import "AVFoundation/AVCaptureDevice.h"
#import "AVFoundation/AVCaptureInput.h"
#import "AVFoundation/AVCaptureVideoPreviewLayer.h"
#import "AVFoundation/AVMediaFormat.h"

@interface CameraEngine : NSObject

+ (CameraEngine*) engine;
- (void) startup;
- (void) shutdown;
- (AVCaptureVideoPreviewLayer*) getPreviewLayer;

- (void) startCapture;
- (void) pauseCapture;
- (void) stopCapture;
- (void) resumeCapture;
- (BOOL)toggleFrontFacingCamera:(BOOL)isUsingFrontFacingCamera;

@property (nonatomic, copy) NSString *fileURL;
@property (atomic, readwrite) BOOL isCapturing;
@property (atomic, readwrite) BOOL isPaused;
@property (nonatomic, readwrite) BOOL isFrontCamera;
@end
