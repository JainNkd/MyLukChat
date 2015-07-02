//
//  VideoPreviewViewController.m
//  LukChat
//
//  Created by Naveen on 20/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "VideoPreviewViewController.h"
#import "VideoListViewController.h"
#import "CameraEngine.h"
#import <objc/message.h>

@interface VideoPreviewViewController ()<UIAlertViewDelegate>
{
    BOOL rearCameraMode;
    
    NSTimer *timer;
    int totalSeconds;
    
    BOOL isStartVideo,isSavedVideo;
}
@end

@implementation VideoPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationLandscapeRight);
        }
    }
    return self;
}
-(BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationLandscapeRight );
    }
    rearCameraMode = NO;
    [CameraEngine engine].isFrontCamera = rearCameraMode;
    [[CameraEngine engine] startup];
    self.timerLabel.text = @"00:00:00";
    totalSeconds = 0;

    self.navigationController.navigationBarHidden = YES;
    isStartVideo = NO;
    isSavedVideo = NO;
    [self.view bringSubviewToFront:self.previewView];
    [self startPreview];
    // Do any additional setup after loading the view.
}


- (void) startPreview
{
    AVCaptureVideoPreviewLayer* preview = [[CameraEngine engine] getPreviewLayer];
    [preview removeFromSuperlayer];
    preview.frame = self.previewView.bounds;
    [[preview connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    [self.previewView.layer insertSublayer:preview atIndex:0];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationPortrait);
        }
    }
    
    [UIApplication sharedApplication].statusBarHidden = NO;
}


- (IBAction)cnacelButtonPressed:(UIButton *)sender {
    if (timer.isValid) {
        [timer invalidate];
        timer = nil;
        [[CameraEngine engine] pauseCapture];
        isStartVideo = NO;
    }
    if(![CameraEngine engine].isCapturing || ![CameraEngine engine].isPaused){
        [[CameraEngine engine] shutdown];
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];    }
    else{
        
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LUK", nil)  message:NSLocalizedString(@"Do you want to save video",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
        [alert show];
        alert.tag = 1;

    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 1) {
        [[CameraEngine engine] shutdown];
        
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
    else if (buttonIndex == 1 && alertView.tag == 1){
        isSavedVideo = YES;
        [CameraEngine engine].fileURL = self.fileUrl;
        [[CameraEngine engine] stopCapture];
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}
- (IBAction)frontCamaraButtonPressed:(UIButton *)sender {
    self.timerLabel.text = @"00:00:00";
    totalSeconds = 0;
    isStartVideo = NO;
    isSavedVideo = NO;
    self.startButton.enabled = YES;
    self.startButton.alpha = 1;

    rearCameraMode = [[CameraEngine engine] toggleFrontFacingCamera:rearCameraMode];
}

- (IBAction)saveVideoButtonPressed:(UIButton *)sender {
    if (totalSeconds > 0 ) {
        [timer invalidate];
        timer = nil;
        isSavedVideo = YES;
        [CameraEngine engine].fileURL = self.fileUrl;
        [[CameraEngine engine] stopCapture];
        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LUK",nil) message:NSLocalizedString(@"Please Record a Video",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)startStopRecordingButtonPressed:(id)sender {
    
    if (totalSeconds == 0 || !isStartVideo) {
        [self setTimerTextWithTotalSeconds:totalSeconds];
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
        [[CameraEngine engine] startCapture];
        isStartVideo = YES;
        self.cameraModeButton.hidden = YES;
    }
    else if (totalSeconds > 0 && isStartVideo){
        [timer invalidate];
        timer = nil;
        [[CameraEngine engine] pauseCapture];
        isStartVideo = NO;
        self.startButton.enabled = NO;
        self.startButton.alpha = 0.7;
        self.cameraModeButton.hidden = NO;
    }
}

-(void)setTimerTextWithTotalSeconds:(int)totalSecondss
{
    int remainder = 0;
    
    int hours = totalSecondss / 3600;
    remainder = totalSecondss % 3600;
    
    int minutes = remainder / 60;
    remainder = remainder % 60;
    
    int seconds = remainder;
    
    if (seconds > 10) {
        
        [timer invalidate];
        timer = nil;
        totalSeconds = 0;
        isStartVideo = NO;
        self.startButton.enabled = NO;
        self.startButton.alpha = 0.7;
        [[CameraEngine engine] pauseCapture];
        return;
    }
    
    NSString *strTotalTime = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    
    self.timerLabel.text = strTotalTime;
}

-(void)updateTimer:(NSTimer *)timer
{
    totalSeconds += 1;
    NSLog(@"updateTimer -- %d",totalSeconds);
    [self setTimerTextWithTotalSeconds:totalSeconds];
}

@end
