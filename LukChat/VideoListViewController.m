//
//  VideoListViewController.m
//  LukChat
//
//  Created by Administrator on 16/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "VideoListViewController.h"
#import "CustomOrientationNavigationController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <objc/message.h>
#import "CameraEngine.h"
#import "MergeVideosViewController.h"
#import "SCRecorderViewController.h"
#import "Constants.h"
#import "SingleVideoViewController.h"
#import "CommonMethods.h"

@interface VideoListViewController ()

@end

@implementation VideoListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Added Sweipe Gesture to reset text box
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(resetTextBox)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    //Added Tap Gesture to remove keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.titleHeaderLBL.hidden = YES;
    [self initUIArrays];
    // Do any additional setup after loading the view.
}

-(void)dismissKeyboard
{
    [self.videoTitleTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.mergeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mergeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationPortrait);
    }
    
    BOOL isfromMerged = [[NSUserDefaults standardUserDefaults]boolForKey:kIsFromMerged];
    if(isfromMerged)
    {
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:kIsFromMerged];
        [self resetTextBox];
    }
    else{
        videoTitle = [CommonMethods getVideoTitle];
        self.videoTitleTextField.text = videoTitle;
        NSLog(@"videoTitle..%@..",videoTitle);
        if(videoTitle.length>0){
            NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
            if(titleWords.count>1)
                [titleWords removeObject:@""];
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            currentLUKIndex = titleWords.count-1;
            for(int i=0 ;i<[titleWords count];i++)
            {
                NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
                
                
                NSString *tempfile = [NSString stringWithFormat:@"%@/%@", path, filename];
                
                
                UIButton *buttonObj = [videoTitleButtonsArr objectAtIndex:i];
                UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
                NSLog(@"tempfile....%@",tempfile);
                UIImage *temp = [[UIImage alloc] initWithContentsOfFile:tempfile];
                if (temp) {
                    [buttonObj setImage:temp forState:UIControlStateNormal];
                    [titleLBLObj setTextColor:[UIColor yellowColor]];
                }
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:tempfile])
                {
                    UIImage *image = [self generateThumbImage:tempfile];
                    
                    if(image)
                        [buttonObj setImage:image forState:UIControlStateNormal];
                    [titleLBLObj setTextColor:[UIColor yellowColor]];
                }
            }
            
            NSMutableArray *videofiles = [[NSMutableArray alloc] init];
            
            if(titleWords.count>1)
                [titleWords removeObject:@""];
            
            for (int i=0; i < titleWords.count; i++) {
                NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
                filename = [NSString stringWithFormat:@"%@/%@", path, filename];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
                    [videofiles addObject:filename];
                    // NSLog(@"filename : %@", filename);
                }
            }
            
            
            if (!videofiles || [videofiles count] < 2) {
                self.mergeButton.enabled = NO;
            }
            else{
                self.mergeButton.enabled = YES;
            }
        }
        else
        {
            self.mergeButton.enabled = NO;
        }
    }
   
}


-(void)initUIArrays
{
    videoTitleButtonsArr = [[NSMutableArray alloc]init];
    videoTitleLBLArr = [[NSMutableArray alloc]init];
    lukViewsArr = [[NSMutableArray alloc]init];
    
    [lukViewsArr addObject:self.lukView1];
    [lukViewsArr addObject:self.lukView2];
    [lukViewsArr addObject:self.lukView3];
    [lukViewsArr addObject:self.lukView4];
    [lukViewsArr addObject:self.lukView5];
    [lukViewsArr addObject:self.lukView6];
    [lukViewsArr addObject:self.lukView7];
    [lukViewsArr addObject:self.lukView8];
    [lukViewsArr addObject:self.lukView9];
    [lukViewsArr addObject:self.lukView10];
    
    [videoTitleButtonsArr addObject:self.videoTitleButton1];
    [videoTitleButtonsArr addObject:self.videoTitleButton2];
    [videoTitleButtonsArr addObject:self.videoTitleButton3];
    [videoTitleButtonsArr addObject:self.videoTitleButton4];
    [videoTitleButtonsArr addObject:self.videoTitleButton5];
    [videoTitleButtonsArr addObject:self.videoTitleButton6];
    [videoTitleButtonsArr addObject:self.videoTitleButton7];
    [videoTitleButtonsArr addObject:self.videoTitleButton8];
    [videoTitleButtonsArr addObject:self.videoTitleButton9];
    [videoTitleButtonsArr addObject:self.videoTitleButton10];
    
    
    [videoTitleLBLArr addObject:self.videoTitleLBL1];
    [videoTitleLBLArr addObject:self.videoTitleLBL2];
    [videoTitleLBLArr addObject:self.videoTitleLBL3];
    [videoTitleLBLArr addObject:self.videoTitleLBL4];
    [videoTitleLBLArr addObject:self.videoTitleLBL5];
    [videoTitleLBLArr addObject:self.videoTitleLBL6];
    [videoTitleLBLArr addObject:self.videoTitleLBL7];
    [videoTitleLBLArr addObject:self.videoTitleLBL8];
    [videoTitleLBLArr addObject:self.videoTitleLBL9];
    [videoTitleLBLArr addObject:self.videoTitleLBL10];
    
    videoTitle = [CommonMethods getVideoTitle];
    NSMutableArray *titleWords;
    if(videoTitle.length>0){
        titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
        if(titleWords.count>1)
            [titleWords removeObject:@""];
    }else
    {
        titleWords = [[NSMutableArray alloc]init];
    }
    
    self.titleHeaderLBL.text = videoTitle;
    
    for(int i=0 ;i<10;i++)
    {
        if(i<[titleWords count])
        {
            UIView *lukView = [lukViewsArr objectAtIndex:i];
            UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
            titleLBLObj.text = [titleWords objectAtIndex:i];
            lukView.hidden = NO;
            [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
            NSLog(@"NO");
        }
        else
        {
            UIView *lukView = [lukViewsArr objectAtIndex:i];
            lukView.hidden = YES;
        }
    }
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

-(void)resetTextBox
{
    self.mergeButton.enabled = NO;
    isRecordingStart = NO;
    currentLUKIndex = -1;
    [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:VIDEO_TITLE];
    self.videoTitleTextField.text = @"";
    for(int i=0 ;i<10;i++)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
        
        UIView *lukView = [lukViewsArr objectAtIndex:i];
        lukView.hidden = YES;
    }
}

- (IBAction)videoRecordButtonPressed:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Option" delegate:self cancelButtonTitle:CANCEL_BUTTON destructiveButtonTitle:nil otherButtonTitles:@"Record", @"Load",@"Play", nil];
    [actionSheet setTag:sender.tag];
    [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    isRecordingStart = YES;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",(int)actionSheet.tag]];
    
    
    fileURL = [NSString stringWithFormat:@"%@/%@", path,filename];
    
    if(buttonIndex==0)
    {
        SCRecorderViewController *previewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPreviewViewController"];
        
        [previewController setIndexOfVideo:(int)actionSheet.tag];
        UINavigationController *navBar=[[CustomOrientationNavigationController alloc] initWithRootViewController:previewController];
        
        [self.navigationController presentViewController:navBar animated:NO completion:nil];
    }
    else if(buttonIndex == 1)
    {
        [[NSUserDefaults standardUserDefaults]setInteger:actionSheet.tag forKey:@"SingleVideoIndex"];
        SingleVideoViewController *singleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleVideoViewController"];
        [self.navigationController presentViewController:singleVC animated:YES completion:nil];
    }
    else if (buttonIndex == 2)
    {
        NSLog(@"fileURL.....%@",fileURL);
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL]) {
            [self playMovie:fileURL];
        }
        
    }
    
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

-(void)playMovie: (NSString *) path{
    
    NSURL *url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    theMovie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    //    theMovie.moviePlayer.initialPlaybackTime = self.startTime;
    //    theMovie.moviePlayer.endPlaybackTime = self.stopTime;
    [theMovie.moviePlayer play];
}

- (void)movieFinishedCallBack:(NSNotification *) aNotification {
    MPMoviePlayerController *mPlayer = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:mPlayer];
    [mPlayer stop];
    
    //    [CommonMethods showAlertWithTitle:@"Send to Friend" message:@"" cancelBtnTitle:@"Cancel" otherBtnTitle:@"Send" delegate:self tag:101];
}




-(IBAction)stopPlaying:(id)sender {
    if (player) {
        // stop the player and close the view
        player.rate = 0;
        //        [videoPreviewToPlay setHidden:YES];
    }
}

- (IBAction)videoMergeButtonPressed:(UIButton *)sender {
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray *videofiles = [[NSMutableArray alloc] init];
    
    videoTitle = [CommonMethods getVideoTitle];
    
    NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
    if(titleWords.count>1)
        [titleWords removeObject:@""];
    
    for (int i=0; i < titleWords.count; i++) {
        NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
        
        filename = [NSString stringWithFormat:@"%@/%@", path, filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
            [videofiles addObject:filename];
            NSLog(@"filename : %@", filename);
        }
    }
    
    
    if (!videofiles || [videofiles count] < 2) {
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You need two recorded video clips to merge the videos." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Accept", nil];
        //        [alert show];
        return;
    }
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
    fileName = [NSString stringWithFormat:@"%@mergedvideo.mov",timestamp];
    NSString *mergedFile = [NSString stringWithFormat:@"%@/%@", docPath,fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:mergedFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:mergedFile error:nil];
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack *audioCompositionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTime nextVideoStartTime = kCMTimeZero;
    
    NSLog(@"Files : %@", videofiles);
    
    
    for (int i=0; i < [videofiles count]; i++) {
        NSURL *url = [NSURL fileURLWithPath:[videofiles objectAtIndex:i]];
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
        CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, [videoAsset duration]);
        
        AVAssetTrack *clipVideoTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [videoAsset duration]) ofTrack:clipVideoTrack atTime:nextVideoStartTime error:nil];
        
        if ([[videoAsset tracksWithMediaType:AVMediaTypeAudio] count] > 0) {
            AVAssetTrack *clipAudioTrack = [[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
            [audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [videoAsset duration]) ofTrack:clipAudioTrack atTime:nextVideoStartTime error:nil];
        }
        
        nextVideoStartTime = CMTimeAdd(nextVideoStartTime, timeRange.duration);
    }
    
    NSURL *mergedVideoURL = [NSURL fileURLWithPath:mergedFile];
    AVAssetExportSession *assetSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    assetSession.outputURL = mergedVideoURL;
    assetSession.outputFileType = AVFileTypeQuickTimeMovie;
    assetSession.shouldOptimizeForNetworkUse = YES;
    [assetSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:assetSession path:mergedFile];
        });
    }];
}

-(void)exportDidFinish:(AVAssetExportSession*)assetSession path:(NSString*)outputVideoPath {
    NSURL *outputURL = assetSession.outputURL;
    NSLog(@"merged video file path : %@", outputVideoPath);
    UISaveVideoAtPathToSavedPhotosAlbum(outputVideoPath,nil,nil,nil);
    NSData *videoData = [NSData dataWithContentsOfURL:outputURL];
    [videoData writeToFile:outputVideoPath atomically:YES];
    
    [[NSUserDefaults standardUserDefaults] setValue:fileName forKey:kMyVideoToShare];
    
    MergeVideosViewController *mergeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MergeVideosViewController"];
    
    [self.navigationController pushViewController:mergeVC animated:YES];
}


//Generate thumnail images
-(UIImage *)generateThumbImage : (NSString *)filepath
{
    NSURL *url = [NSURL fileURLWithPath:filepath];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 0001;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

//Textfield Delgate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"textField1...%@...text..%@..",textField.text,string);
    
    NSMutableArray *array;
    NSString *textViewStr = textField.text;
    
    if(string.length == 0)
    {
        if ([textViewStr length] > 0) {
            textViewStr = [textViewStr substringToIndex:[textViewStr length] - 1];
            NSLog(@"textField2...%@...text..%@..",textViewStr,string);
        } else {
            //no characters to delete... attempting to do so will result in a crash
        }
    }
    else
    {
        textViewStr = [NSString stringWithFormat:@"%@%@",textViewStr,string];
        NSLog(@"textField3...%@...text..%@..",textViewStr,string);
    }
    
    
    textViewStr = [textViewStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(textViewStr.length>0){
        array = (NSMutableArray*)[textViewStr componentsSeparatedByString:@" "];
        if([array count]>1)
            [array removeObject:@""];
    }
    
    if ( [string isEqualToString:@""]) {//When detect backspace when have one character.
        if(isRecordingStart){
            return NO;
        }
        else{
            [self resetLUK:[array count]];
            currentLUKIndex = [array count];
        }
    }
    else{
        if([string isEqualToString:@" "])//When user enter one character.
        {
            NSLog(@"textView...%@..",textViewStr);
            if(textViewStr.length>0){
                
                if([array count] > 0 && [array count] < 11){
                    [[NSUserDefaults standardUserDefaults] setObject:textViewStr forKey:VIDEO_TITLE];
                    if(currentLUKIndex != [array count]){
                        [self animateView:[array count]wordText:[array lastObject]];
                        currentLUKIndex = [array count];
                    }
                }
                
                if([array count] > 10)
                {
                    //            message = @"You exceed meximum word limit of 10";
                    NSLog(@"1 You exceed meximum word limit of 10");
                    return NO;
                }
            }
        }
        else
        {
            if([array count] > 10)
            {
                NSLog(@"2 You exceed meximum word limit of 10");
                return NO;
                
            }
        }
    }
    return YES;
}

//Show look with animation
-(void)animateView:(NSInteger)viewIndex wordText:(NSString*)wordText
{
    UIView *lukView = [lukViewsArr objectAtIndex:viewIndex-1];
    UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:viewIndex-1];
    titleLBLObj.text = wordText;
    lukView.hidden = NO;
    lukView.alpha = 0.0f;
    lukView.transform = CGAffineTransformMakeScale(0.3,0.3);
    [UIView beginAnimations:@"fadeInNewView" context:NULL];
    [UIView setAnimationDuration:.5];
    lukView.transform = CGAffineTransformMakeScale(1,1);
    lukView.alpha = 1.0f;
    [UIView commitAnimations];
}

//Reset Luk
-(void)resetLUK:(NSInteger)lukCount
{
    lukCount = 10-lukCount;
    
    for(NSInteger i = 9; lukCount>0;lukCount--,i--)
    {
        
        UIView *view = [lukViewsArr objectAtIndex:i];
        view.hidden = YES;
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
