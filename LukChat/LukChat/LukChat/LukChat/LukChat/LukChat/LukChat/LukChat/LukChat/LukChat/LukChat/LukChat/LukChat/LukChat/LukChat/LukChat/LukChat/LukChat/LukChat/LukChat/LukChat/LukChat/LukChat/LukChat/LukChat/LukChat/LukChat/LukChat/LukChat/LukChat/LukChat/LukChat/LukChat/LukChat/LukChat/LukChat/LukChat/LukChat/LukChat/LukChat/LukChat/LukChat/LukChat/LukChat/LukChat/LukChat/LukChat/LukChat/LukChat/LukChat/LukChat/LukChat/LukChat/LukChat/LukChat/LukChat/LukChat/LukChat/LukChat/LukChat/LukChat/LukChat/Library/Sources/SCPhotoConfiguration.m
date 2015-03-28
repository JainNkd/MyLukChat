//
//  SCPhotoConfiguration.m
//  SCRecorder
//
//  Created by Simon CORSIN on 24/11/14.
//  Copyright (c) 2014 rFlex. All rights reserved.
//

#import "SCPhotoConfiguration.h"

@implementation SCPhotoConfiguration

- (id)init {
    self = [super init];
    
    if (self) {
        _enabled = YES;
    }
    
    return self;
}

- (void)setOptions:(NSDictionary *)options {
    [self willChangeValueForKey:@"options"];
    
    _options = options;
    
    [self didChangeValueForKey:@"options"];
}

- (NSDictionary *)createOutputSettings {
    if (_options == nil) {
        return @{AVVideoCodecKey : AVVideoCodecJPEG};
    } else {
        return _options;
    }
}

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
