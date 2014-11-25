//
//  VideoPreviewViewController.h
//  LukChat
//
//  Created by Naveen on 20/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class VideoListViewController;

@interface VideoPreviewViewController : UIViewController<AVCaptureFileOutputRecordingDelegate>
{
    // session for the video capture
    AVCaptureSession *session;
    AVCaptureMovieFileOutput *movieFileOutput;
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureVideoPreviewLayer *previewLayer1;
    
    BOOL isFrontCamaraON;
    
    // file path
    NSString *fileURL;
    
    
}

@property (nonatomic, assign) VideoListViewController *delegate;
@property (nonatomic, assign) int indexOfVideo;

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet UIButton *frontCamraButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;


- (IBAction)cnacelButtonPressed:(UIButton *)sender;

- (IBAction)frontCamaraButtonPressed:(UIButton *)sender;

- (IBAction)saveVideoButtonPressed:(UIButton *)sender;

- (IBAction)startStopRecordingButtonPressed:(id)sender;


@end
