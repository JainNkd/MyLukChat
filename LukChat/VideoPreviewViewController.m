//
//  VideoPreviewViewController.m
//  LukChat
//
//  Created by Naveen on 20/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "VideoPreviewViewController.h"
#import "VideoListViewController.h"

@interface VideoPreviewViewController ()

@end

@implementation VideoPreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
     [self recordWith:isFrontCamaraON];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



- (IBAction)cnacelButtonPressed:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)frontCamaraButtonPressed:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    isFrontCamaraON = sender.selected;
//    [self recordWith:isFrontCamaraON];
}

- (IBAction)saveVideoButtonPressed:(UIButton *)sender {
    
    if(fileURL.length>0)
    {
    NSLog(@"fileURL : %@", fileURL);
    NSURL *videoURl = [NSURL fileURLWithPath:fileURL];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    
    // extract an image as thumbnail
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *image = [[UIImage alloc] initWithCGImage:imgRef];
    
    // store the thumbnail image in local directory
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *tempfile = [NSString stringWithFormat:@"%@/video%d.png", path, self.indexOfVideo];
    [UIImagePNGRepresentation(image) writeToFile:tempfile atomically:YES];
    
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    
    // store the video into album
    UISaveVideoAtPathToSavedPhotosAlbum(fileURL,nil,nil,nil);
    
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    }
}

- (IBAction)startStopRecordingButtonPressed:(id)sender {
    if (self.startButton.tag == 0) {
        self.startButton.tag = 1;
        [self.startButton setTitle:@"Stop" forState:UIControlStateNormal];
//        [self recordWith:isFrontCamaraON];
        [self startRecording];
    }else {
        self.startButton.tag = 0;
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        if (session) {
            [session stopRunning];
        }
    }
}

-(void)recordWith:(BOOL)frontCamera {
    
    if (session) {
        session = nil;
    }
    
    NSError *error;
    session = [[AVCaptureSession alloc] init];
    
    [session beginConfiguration];
    
    if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [session setSessionPreset:AVCaptureSessionPresetHigh];
    } else {
        [session setSessionPreset:AVCaptureSessionPresetMedium];
    }
    
    AVCaptureDevice *inputDevice = nil;
    if (frontCamera) {
        inputDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
    } else {
        inputDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    
    if ([inputDevice isFocusModeSupported:AVCaptureFocusModeLocked]) {
        
        NSError *error = nil;
        if ([inputDevice lockForConfiguration:&error]) {
            //            CGPoint autoFocusPoint = CGPointMake(0.5f, 0.5f);
            //            [inputDevice setFocusPointOfInterest:autoFocusPoint];
            [inputDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        } else {
            NSLog(@"Error : %@", [error localizedDescription]);
        }
    }
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    if ( [session canAddInput:deviceInput] )
        [session addInput:deviceInput];
    
    //    if (frontCameraEnabled.isOn) {
    //
    //    } else {
    //
    //    }
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:nil];
    if ([session canAddInput:audioInput]) {
        [session addInput:audioInput];
    }
    
    [session commitConfiguration];
    
    previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    NSLog(@"preparing...");
    
    // prepare the layer to show the preview screen while recording the video
    CALayer *rootLayer = [self.previewView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:CGRectMake(0, 0, rootLayer.frame.size.width-20, rootLayer.bounds.size.height-20
                                      )];
    [rootLayer insertSublayer:previewLayer atIndex:0];
    [previewLayer1 addSublayer:previewLayer];
    
    NSLog(@"configured view for preview");
    
    // setup the file
    movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    CMTime maxDuration = CMTimeMake(60, 1);
    movieFileOutput.maxRecordedDuration = maxDuration;
    [session addOutput:movieFileOutput];
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in [movieFileOutput connections]) {
        NSLog(@"%@", connection);
        for ( AVCaptureInputPort *port in [connection inputPorts] )
        {
            NSLog(@"%@", port);
            if ( [[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
            }
        }
    }
    
    if([videoConnection isVideoOrientationSupported]) {
        [videoConnection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    }
    
    // get the path and set tthe file name to recrod
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    fileURL = [NSString stringWithFormat:@"%@/video%d.mov", path, self.indexOfVideo];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL isDirectory:NO]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileURL error:nil];
    }
    [session startRunning];
}

- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

#pragma mark - Capture video

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    if ([error code] == noErr) {
        //
    } else {
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        
        if (value) {
            
            if ([value boolValue]) {
                NSLog(@"Not successful.");
            } else {
                NSLog(@"Successful.");
            }
            
        }
    }
}

-(UIView *)getPreviewView {
    return self.previewView;
}



-(void)startRecording {
    // start the recording..
    [movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:fileURL] recordingDelegate:self];
}


@end
