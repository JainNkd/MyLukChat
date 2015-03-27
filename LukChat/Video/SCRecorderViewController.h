//
//  VRViewController.h
//  VideoRecorder
//
//  Created by Simon CORSIN on 8/3/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface SCRecorderViewController : UIViewController<SCRecorderDelegate, UIImagePickerControllerDelegate,UIAlertViewDelegate>

//@property (weak, nonatomic) IBOutlet UIView *recordView;
//@property (weak, nonatomic) IBOutlet UIButton *stopButton;
//@property (weak, nonatomic) IBOutlet UIButton *retakeButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIView *downBar;
//@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseCamera;
//@property (weak, nonatomic) IBOutlet UIButton *flashModeButton;
@property (weak, nonatomic) IBOutlet UIButton *ghostModeButton;

@property (weak, nonatomic) IBOutlet UIButton *startRecordButtom;
@property (weak, nonatomic) IBOutlet UIButton *pauseRecordButton;
@property (weak, nonatomic) IBOutlet UIImageView *timerMonkeyIcon;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

//- (IBAction)switchCameraMode:(id)sender;
//- (IBAction)switchFlash:(id)sender;
//- (IBAction)switchGhostMode:(id)sender;

@property(nonatomic,assign)int indexOfVideo;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
