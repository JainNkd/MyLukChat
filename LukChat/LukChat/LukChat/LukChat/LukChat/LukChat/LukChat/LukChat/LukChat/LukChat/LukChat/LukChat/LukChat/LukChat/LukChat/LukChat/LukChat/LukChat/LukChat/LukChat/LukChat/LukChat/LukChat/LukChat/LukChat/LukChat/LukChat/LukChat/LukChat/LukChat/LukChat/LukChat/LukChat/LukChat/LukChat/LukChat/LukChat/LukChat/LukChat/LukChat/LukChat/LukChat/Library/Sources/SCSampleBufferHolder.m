//
//  SCSampleBufferHolder.m
//  SCRecorder
//
//  Created by Simon CORSIN on 10/09/14.
//  Copyright (c) 2014 rFlex. All rights reserved.
//

#import "SCSampleBufferHolder.h"

@implementation SCSampleBufferHolder

- (void)dealloc {
    if (_sampleBuffer != nil) {
        CFRelease(_sampleBuffer);
    }
}

- (void)setSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (_sampleBuffer != nil) {
        CFRelease(_sampleBuffer);
        _sampleBuffer = nil;
    }
    
    _sampleBuffer = sampleBuffer;
    
    if (sampleBuffer != nil) {
        CFRetain(sampleBuffer);
    }
}

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
