//
//  SCImageViewDisPlayViewController.h
//  SCAudioVideoRecorder
//
//  Created by 曾 宪华 on 13-11-5.
//  Copyright (c) 2013年 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCSwipeableFilterView.h"

@interface SCImageDisplayerViewController : UIViewController

@property (nonatomic, strong) UIImage *photo;
@property (weak, nonatomic) IBOutlet SCSwipeableFilterView *filterSwitcherView;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
