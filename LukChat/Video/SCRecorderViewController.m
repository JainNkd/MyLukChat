//
//  VRViewController.m
//  VideoRecorder
//
//  Created by Simon CORSIN on 8/3/13.
//  Copyright (c) 2013 SCorsin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCTouchDetector.h"
#import "SCRecorderViewController.h"
#import "SCAudioTools.h"
#import "SCVideoPlayerViewController.h"
#import "SCRecorderFocusView.h"
#import "SCImageDisplayerViewController.h"
#import "SCRecorder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "SCSessionListViewController.h"
#import "SCRecordSessionManager.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Constants.h"

#define kVideoPreset AVCaptureSessionPresetHigh

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface SCRecorderViewController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
    BOOL isVideoSaved;
}

@property (strong, nonatomic) SCRecorderFocusView *focusView;
@end

////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation SCRecorderViewController

@synthesize indexOfVideo;
#pragma mark - UIViewController

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_7_0

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        //            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationLandscapeRight);
        //        }
    }
    return self;
}

-(void)resetCameraView
{
    if(IS_IPHONE_4_OR_LESS)
    {
        self.topView.translatesAutoresizingMaskIntoConstraints = YES;
        self.bottomView.translatesAutoresizingMaskIntoConstraints =YES;
        self.bgMonkeyImg.translatesAutoresizingMaskIntoConstraints=YES;
        self.previewView.translatesAutoresizingMaskIntoConstraints = YES;
        self.cancelButton.translatesAutoresizingMaskIntoConstraints =YES;
        self.saveButton.translatesAutoresizingMaskIntoConstraints = YES;
        self.startRecordButtom.translatesAutoresizingMaskIntoConstraints=YES;
        self.pauseRecordButton.translatesAutoresizingMaskIntoConstraints =YES;
        
        CGRect topViewFrame = self.topView.frame;
        topViewFrame.size.height = 75;
        self.topView.frame = topViewFrame;
        
        CGRect bottomFrame = self.bottomView.frame;
        bottomFrame.origin.y = 395;
        self.bottomView.frame = bottomFrame;
        
        CGRect previewViewFrame = self.previewView.frame;
        previewViewFrame.size.height = self.view.bounds.size.height;
        self.previewView.frame = previewViewFrame;
        
        CGRect cancleBtnFrame = self.cancelButton.frame;
        cancleBtnFrame.origin.y = 416;
        self.cancelButton.frame = cancleBtnFrame;
        
        CGRect saveBtnFrame = self.saveButton.frame;
        saveBtnFrame.origin.y = 416;
        self.saveButton.frame = saveBtnFrame;
        
        CGRect bgBtnFrame = self.bgMonkeyImg.frame;
        bgBtnFrame.origin.y  = 398;
        self.bgMonkeyImg.frame = bgBtnFrame;
        
        CGRect startBtnFrame = self.startRecordButtom.frame;
        startBtnFrame.origin.y = 413;
        self.startRecordButtom.frame = startBtnFrame;
        
        CGRect stopButton = self.pauseRecordButton.frame;
        stopButton.origin.y = 413;
        self.pauseRecordButton.frame = stopButton;
    }
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Left cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self resetCameraView];
    
    //    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
    //        objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationLandscapeRight );
    //    }
    
    isVideoSaved = NO;
    
    _ghostImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _ghostImageView.contentMode = UIViewContentModeScaleAspectFill;
    _ghostImageView.alpha = 0.2;
    _ghostImageView.userInteractionEnabled = NO;
    _ghostImageView.hidden = YES;
    
    [self.view insertSubview:_ghostImageView aboveSubview:self.previewView];
    
    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = AVCaptureSessionPresetHigh;
    _recorder.maxRecordDuration = CMTimeMake(10, 1);
    
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = YES;
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    [self.reverseCamera addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.startRecordButtom addTarget:self action:@selector(startRecordTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.pauseRecordButton addTarget:self action:@selector(pauseRecordTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    self.pauseRecordButton.hidden = YES;
    
    [self.saveButton addTarget:self action:@selector(saveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //    [self.recordView addGestureRecognizer:[[SCTouchDetector alloc] initWithTarget:self action:@selector(handleTouchDetected:)]];
    
    
    self.loadingView.hidden = YES;
    
    self.focusView = [[SCRecorderFocusView alloc] initWithFrame:previewView.bounds];
    self.focusView.recorder = _recorder;
    [previewView addSubview:self.focusView];
    
    self.focusView.outsideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    self.focusView.insideFocusTargetImage = [UIImage imageNamed:@"capture_flip"];
    
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSError *error = nil;
        NSLog(@"%@", error);
        
        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
    
}


- (void)recorder:(SCRecorder *)recorder didReconfigureAudioInput:(NSError *)audioInputError {
    NSLog(@"Reconfigured audio input: %@", audioInputError);
}

- (void)recorder:(SCRecorder *)recorder didReconfigureVideoInput:(NSError *)videoInputError {
    NSLog(@"Reconfigured video input: %@", videoInputError);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self prepareCamera];
    
    self.navigationController.navigationBarHidden = YES;
    [self updateTimeRecordedLabel];
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//
////    [_recorder previewViewFrameChanged];
//}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunningSession];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_recorder endRunningSession];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    //    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
    //        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
    //            objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationPortrait);
    //        }
    //    }
    
    //    [UIApplication sharedApplication].statusBarHidden = NO;
}

// Focus
- (void)recorderDidStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

- (void)recorderDidEndFocus:(SCRecorder *)recorder {
    [self.focusView hideFocusAnimation];
}

- (void)recorderWillStartFocus:(SCRecorder *)recorder {
    [self.focusView showFocusAnimation];
}

#pragma mark - Handle

- (void)showAlertViewWithTitle:(NSString*)title message:(NSString*) message {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (void)showVideo {
    [self performSegueWithIdentifier:@"Video" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[SCVideoPlayerViewController class]]) {
        SCVideoPlayerViewController *videoPlayer = segue.destinationViewController;
        videoPlayer.recordSession = _recordSession;
    } else if ([segue.destinationViewController isKindOfClass:[SCImageDisplayerViewController class]]) {
        SCImageDisplayerViewController *imageDisplayer = segue.destinationViewController;
        imageDisplayer.photo = _photo;
        _photo = nil;
    } else if ([segue.destinationViewController isKindOfClass:[SCSessionListViewController class]]) {
        SCSessionListViewController *sessionListVC = segue.destinationViewController;
        
        sessionListVC.recorder = _recorder;
    }
}

- (void)showPhoto:(UIImage *)photo {
    _photo = photo;
    [self performSegueWithIdentifier:@"Photo" sender:self];
}

- (void) handleReverseCameraTapped:(id)sender {
    [_recorder switchCaptureDevices];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *url = info[UIImagePickerControllerMediaURL];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [_recorder.recordSession addSegment:url];
    _recordSession = [SCRecordSession recordSession];
    [_recordSession addSegment:url];
    
    //    [self showVideo];
}

#warning save buttton addthis code
//- (void) handleStopButtonTapped:(id)sender {
//    [_recorder pause:^{
//        [self saveAndShowSession:_recorder.recordSession];
//    }];
//}

- (void)saveAndShowSession:(SCRecordSession *)recordSession {
    [[SCRecordSessionManager sharedInstance] saveRecordSession:recordSession];
    
    _recordSession = recordSession;
    //    [self showVideo];
}

//- (void) handleRetakeButtonTapped:(id)sender {
//    SCRecordSession *recordSession = _recorder.recordSession;
//
//    if (recordSession != nil) {
//        _recorder.recordSession = nil;
//
//        // If the recordSession was saved, we don't want to completely destroy it
//        if ([[SCRecordSessionManager sharedInstance] isSaved:recordSession]) {
//            [recordSession endRecordSegment:nil];
//        } else {
//            [recordSession cancelSession:nil];
//        }
//    }
//
//	[self prepareCamera];
//    [self updateTimeRecordedLabel];
//}

//- (IBAction)switchCameraMode:(id)sender {
//    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.recordView.alpha = 1.0;
//            self.retakeButton.alpha = 1.0;
//            self.stopButton.alpha = 1.0;
//        } completion:^(BOOL finished) {
//			_recorder.sessionPreset = kVideoPreset;
//            [self.switchCameraModeButton setTitle:@"Switch Photo" forState:UIControlStateNormal];
//            [self.flashModeButton setTitle:@"Flash : Off" forState:UIControlStateNormal];
//            _recorder.flashMode = SCFlashModeOff;
//        }];
//    } else {
//        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            self.recordView.alpha = 0.0;
//            self.retakeButton.alpha = 0.0;
//            self.stopButton.alpha = 0.0;
//        } completion:^(BOOL finished) {
//			_recorder.sessionPreset = AVCaptureSessionPresetPhoto;
//            [self.switchCameraModeButton setTitle:@"Switch Video" forState:UIControlStateNormal];
//            [self.flashModeButton setTitle:@"Flash : Auto" forState:UIControlStateNormal];
//            _recorder.flashMode = SCFlashModeAuto;
//        }];
//    }
//}

//- (IBAction)switchFlash:(id)sender {
//    NSString *flashModeString = nil;
//    if ([_recorder.sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
//        switch (_recorder.flashMode) {
//            case SCFlashModeAuto:
//                flashModeString = @"Flash : Off";
//                _recorder.flashMode = SCFlashModeOff;
//                break;
//            case SCFlashModeOff:
//                flashModeString = @"Flash : On";
//                _recorder.flashMode = SCFlashModeOn;
//                break;
//            case SCFlashModeOn:
//                flashModeString = @"Flash : Light";
//                _recorder.flashMode = SCFlashModeLight;
//                break;
//            case SCFlashModeLight:
//                flashModeString = @"Flash : Auto";
//                _recorder.flashMode = SCFlashModeAuto;
//                break;
//            default:
//                break;
//        }
//    } else {
//        switch (_recorder.flashMode) {
//            case SCFlashModeOff:
//                flashModeString = @"Flash : On";
//                _recorder.flashMode = SCFlashModeLight;
//                break;
//            case SCFlashModeLight:
//                flashModeString = @"Flash : Off";
//                _recorder.flashMode = SCFlashModeOff;
//                break;
//            default:
//                break;
//        }
//    }
//
//    [self.flashModeButton setTitle:flashModeString forState:UIControlStateNormal];
//}

- (void) prepareCamera {
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        
        _recorder.recordSession = session;
    }
}

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession {
    self.timerMonkeyIcon.image = [UIImage imageNamed:@"camerapage-icon-running-indication-white.png"];
    self.startRecordButtom.enabled = NO;
    self.pauseRecordButton.enabled = NO;
    [self saveAndShowSession:recordSession];
}

- (void)recorder:(SCRecorder *)recorder didInitializeAudioInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized audio in record session");
    } else {
        NSLog(@"Failed to initialize audio in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didInitializeVideoInRecordSession:(SCRecordSession *)recordSession error:(NSError *)error {
    if (error == nil) {
        NSLog(@"Initialized video in record session");
    } else {
        NSLog(@"Failed to initialize video in record session: %@", error.localizedDescription);
    }
}

- (void)recorder:(SCRecorder *)recorder didBeginRecordSegment:(SCRecordSession *)recordSession error:(NSError *)error {
    NSLog(@"Began record segment: %@", error);
}

- (void)recorder:(SCRecorder *)recorder didEndRecordSegment:(SCRecordSession *)recordSession segmentIndex:(NSInteger)segmentIndex error:(NSError *)error {
    NSLog(@"End record segment %d at %@: %@", (int)segmentIndex, segmentIndex >= 0 ? [recordSession.recordSegments objectAtIndex:segmentIndex] : nil, error);
    
    [self saveAndShowSession:recordSession];
    
}

- (void)updateTimeRecordedLabel {
    CMTime currentTime = kCMTimeZero;
    
    if (_recorder.recordSession != nil) {
        currentTime = _recorder.recordSession.currentRecordDuration;
    }
    
    if(CMTimeGetSeconds(currentTime) < 10)
    {
        self.timeRecordedLabel.text = [[NSString stringWithFormat:@"0%.2f", CMTimeGetSeconds(currentTime)] stringByReplacingOccurrencesOfString:@"." withString:@":"];
    }
    else
    {
        self.timeRecordedLabel.text = [NSString stringWithFormat:@"10:00"];
    }
    
}

- (void)recorder:(SCRecorder *)recorder didAppendVideoSampleBuffer:(SCRecordSession *)recordSession {
    [self updateTimeRecordedLabel];
    //    _recordSession = recordSession;
    
}

- (void)handleTouchDetected:(SCTouchDetector*)touchDetector {
    if (touchDetector.state == UIGestureRecognizerStateBegan) {
        _ghostImageView.hidden = YES;
        [_recorder record];
    } else if (touchDetector.state == UIGestureRecognizerStateEnded) {
        [_recorder pause];
        [self updateGhostImage];
    }
}

-(void)startRecordTapped:(UIButton*)sender
{
    self.reverseCamera.enabled = NO;
    self.timerMonkeyIcon.image = [UIImage imageNamed:@"camerapage-icon-running-indication.png"];
    sender.hidden = YES;
    //show pause button
    self.pauseRecordButton.hidden = NO;
    
    _ghostImageView.hidden = YES;
    [_recorder record];
}

-(void)pauseRecordTapped:(UIButton*)sender
{
    self.timerMonkeyIcon.image = [UIImage imageNamed:@"camerapage-icon-running-indication-white.png"];
    sender.hidden = YES;
    //show start recording button
    self.startRecordButtom.hidden = NO;
    [_recorder pause];
    [self updateGhostImage];
}

-(void)cancelButtonTapped:(UIButton*)sender
{
    
    self.startRecordButtom.enabled = NO;
    self.pauseRecordButton.enabled = NO;
    
    if(_recorder.isRecording)//runing video
    {
        [_recorder pause:^{
            [self saveSessionForCancel:_recorder.recordSession];
        }];
    }
    else
    {
        if(isVideoSaved){
//            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            [self goToFirstView];
        }
        else{
            if(_recordSession){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LUK", nil)  message:NSLocalizedString(@"Do you want to save video",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
                [alert show];
                alert.tag = 1;
            }
            else
            {
//                [self goToFirstView];
                [self dismissViewControllerAnimated:NO completion:nil];
            }
        }
    }
}

-(void)saveSessionForCancel:(SCRecordSession *)recordSession {
    [self saveAndShowSession:recordSession];
    
    if(isVideoSaved){
//        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [self goToFirstView];
    }
    else{
        if(_recordSession){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LUK", nil)  message:NSLocalizedString(@"Do you want to save video",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"No",nil) otherButtonTitles:NSLocalizedString(@"Yes",nil), nil];
            [alert show];
            alert.tag = 1;
        }
        else
        {
//            [self.navigationController dismissViewControllerAnimated:NO completion:nil];
            [self goToFirstView];
        }
    }
}

-(void)goToFirstView{
//    UIViewController *vc = [self parentViewController];
         UIViewController *vc = [self presentingViewController]; //ios 5 or later
    [self dismissViewControllerAnimated:NO completion:nil];
    [vc dismissViewControllerAnimated:YES completion:nil];
}


-(void)saveButtonTapped:(UIButton*)sender
{
    //1. 10 second complete
    //2. runing video
    //3. pause video
    
    if(_recorder.isRecording)//runing video
    {
        [_recorder pause:^{
            [self saveSession:_recorder.recordSession];
        }];
    }
    else{
        [self saveToCameraRoll];
    }
    
}

-(void)saveSession:(SCRecordSession *)recordSession {
    [self saveAndShowSession:recordSession];
    [self saveToCameraRoll];
    //[self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 1) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else if (buttonIndex == 1 && alertView.tag == 1){
        [self saveToCameraRoll];
        //[self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (void)saveToCameraRoll {
    
    if(_recordSession)
    {
        self.startRecordButtom.enabled = NO;
        self.pauseRecordButton.enabled = NO;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LUK",nil) message:NSLocalizedString(@"Please Record a Video",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    isVideoSaved = YES;
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    void(^completionHandler)(NSURL *url, NSError *error) = ^(NSURL *url, NSError *error) {
        if (error == nil) {
            NSLog(@"url.path....%@",url.path);
            
            //Add watermark=====================
            
            [self addWaterMark];
            
            //==================================
            
            //            UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        } else {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    };
    
    [_recordSession mergeRecordSegmentsUsingPreset:AVAssetExportPresetHighestQuality completionHandler:completionHandler];
    
}

-(void)addWaterMark
{
    NSString *filename = [NSString stringWithFormat:@"%@SCVideo-Merged.mp4", _recordSession.identifier];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/%@", filename];
    
    
    NSURL *videoURL = [NSURL fileURLWithPath:destinationPath];
    
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableCompositionTrack *compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *clipAudioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    //If you need audio as well add the Asset Track for audio here
    
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:clipVideoTrack atTime:kCMTimeZero error:nil];
    [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:clipAudioTrack atTime:kCMTimeZero error:nil];
    
    [compositionVideoTrack setPreferredTransform:[[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform]];
    
    CGSize sizeOfVideo=[videoAsset naturalSize];
    NSLog(@"size width %F, height %f",sizeOfVideo.width,sizeOfVideo.height);
    
    
    // 1 - set up the overlay
    CALayer *overlayLayer = [CALayer layer];
    UIImage *overlayImage = nil;
    overlayImage = [UIImage imageNamed:@"watermark.png"];
    
    [overlayLayer setContents:(id)[overlayImage CGImage]];
    overlayLayer.frame = CGRectMake(0, 0,  sizeOfVideo.width, sizeOfVideo.height);
    [overlayLayer setMasksToBounds:YES];
    
    CALayer *parentLayer=[CALayer layer];
    CALayer *videoLayer=[CALayer layer];
    parentLayer.frame=CGRectMake(0, 0, sizeOfVideo.width, sizeOfVideo.height);
    videoLayer.frame=CGRectMake(0,0, sizeOfVideo.width, sizeOfVideo.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:overlayLayer];

    
    NSLog(@"Framerate.....,%d,%lld",videoAsset.duration.timescale,videoAsset.duration.value);
    AVMutableVideoComposition *videoComposition=[AVMutableVideoComposition videoComposition] ;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderSize=sizeOfVideo;
    videoComposition.animationTool=[AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [mixComposition duration]);
    AVAssetTrack *videoTrack = [[mixComposition tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    AVMutableVideoCompositionLayerInstruction* layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    
    NSLog(@"destinationPath...%@",destinationPath);
    [self removeFile:[NSURL fileURLWithPath:destinationPath]];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    exportSession.videoComposition=videoComposition;
    
    exportSession.outputURL = [NSURL fileURLWithPath:destinationPath];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status)
        {
            case AVAssetExportSessionStatusCompleted:
                NSLog(@"Export OK");
                if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(destinationPath)) {
                    UISaveVideoAtPathToSavedPhotosAlbum(destinationPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                }
                break;
            case AVAssetExportSessionStatusFailed:
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exportSession.error);
                break;
            case AVAssetExportSessionStatusCancelled:
                NSLog(@"Export Cancelled");
                break;
        }
    }];
}

- (void)removeFile:(NSURL *)fileUrl {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:fileUrl.path error:&error];
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo {
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    NSLog(@"videoPath..%@.....%@",videoPath,contextInfo);
    if (error == nil) {
        
        NSString *filename = [NSString stringWithFormat:@"%@SCVideo-Merged.mp4", _recordSession.identifier];
        NSLog(@"videoId....%@....%@",filename,[NSString stringWithFormat:@"VIDEO_%d_URL",indexOfVideo]);
        
        // save video in default
        [[NSUserDefaults standardUserDefaults]setValue:filename forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",indexOfVideo]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
//        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
        [self goToFirstView];
        //        [[[UIAlertView alloc] initWithTitle:@"Saved to camera roll" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Failed to save" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

//- (IBAction)capturePhoto:(id)sender {
//    [_recorder capturePhoto:^(NSError *error, UIImage *image) {
//        if (image != nil) {
//            [self showPhoto:image];
//        } else {
//            [self showAlertViewWithTitle:@"Failed to capture photo" message:error.localizedDescription];
//        }
//    }];
//}

- (void)updateGhostImage {
    _ghostImageView.image = [_recorder snapshotOfLastAppendedVideoBuffer];
    _ghostImageView.hidden = !_ghostModeButton.selected;
}

//- (IBAction)switchGhostMode:(id)sender {
//    _ghostModeButton.selected = !_ghostModeButton.selected;
//    _ghostImageView.hidden = !_ghostModeButton.selected;
//}

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net
