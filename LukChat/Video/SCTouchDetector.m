//
//  SCTouchDetector.m
//  SCVideoRecorder
//
//  Created by Simon CORSIN on 8/6/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import "SCTouchDetector.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation SCTouchDetector

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.state = UIGestureRecognizerStateEnded;
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.enabled) {
        self.State = UIGestureRecognizerStateEnded;
    }
}

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
