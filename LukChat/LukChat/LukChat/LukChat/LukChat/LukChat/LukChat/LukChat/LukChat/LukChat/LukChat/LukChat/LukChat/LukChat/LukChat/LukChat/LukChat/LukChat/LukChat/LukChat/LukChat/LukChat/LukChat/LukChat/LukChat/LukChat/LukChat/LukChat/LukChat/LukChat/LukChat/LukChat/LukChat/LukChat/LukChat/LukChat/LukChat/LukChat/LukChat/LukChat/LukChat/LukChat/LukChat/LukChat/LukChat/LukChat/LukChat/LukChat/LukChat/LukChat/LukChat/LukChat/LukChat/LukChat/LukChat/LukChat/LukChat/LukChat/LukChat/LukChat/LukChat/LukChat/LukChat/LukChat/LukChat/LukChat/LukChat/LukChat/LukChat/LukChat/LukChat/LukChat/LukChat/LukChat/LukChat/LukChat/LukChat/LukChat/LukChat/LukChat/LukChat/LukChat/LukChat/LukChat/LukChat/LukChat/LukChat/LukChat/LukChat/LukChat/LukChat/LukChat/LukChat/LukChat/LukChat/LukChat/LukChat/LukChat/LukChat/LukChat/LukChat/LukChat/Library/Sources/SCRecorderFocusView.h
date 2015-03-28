//
//  SCCameraFocusView.h
//  SCAudioVideoRecorder
//
//  Created by Simon CORSIN on 19/12/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@class SCRecorder;

@interface SCRecorderFocusView : UIView

@property (weak, nonatomic) SCRecorder *recorder;
@property (strong, nonatomic) UIImage *outsideFocusTargetImage;
@property (strong, nonatomic) UIImage *insideFocusTargetImage;
@property (assign, nonatomic) CGSize focusTargetSize;

- (void)showFocusAnimation;
- (void)hideFocusAnimation;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
