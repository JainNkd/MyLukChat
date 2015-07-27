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
#import "Constants.h"
#import "AppDelegate.h"

@interface VideoListViewController ()
{
    NSInteger videoCount;
}
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
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(confirmationToResetTextBox)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipe];
    
    UISwipeGestureRecognizer *swipe1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeSetting)];
    swipe1.direction = UISwipeGestureRecognizerDirectionRight;
    [self.settingView addGestureRecognizer:swipe1];
    
    //Added Tap Gesture to remove keyboard
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.titleHeaderLBL.hidden = YES;
    [self initUIArrays];
    // Do any additional setup after loading the view.
}

-(void)closeSetting
{
    [self closeSettingBtnAction:nil];
}

-(void)confirmationToResetTextBox
{
    NSString *textBoxText = [CommonMethods getVideoTitle];
    if (textBoxText.length>0) {
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"",nil) message:NSLocalizedString(@"Are you sure you want to clear the text?",nil) cancelBtnTitle:NSLocalizedString(@"Cancel",nil) otherBtnTitle:NSLocalizedString(@"OK",nil) delegate:self tag:1];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [self resetTextBox];
    }
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}
-(void)dismissKeyboard
{
    [self.videoTitleTextField resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.settingView.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame= self.settingView.frame;
    self.settingView.frame = CGRectMake(self.view.frame.size.width, 0, frame.size.width, frame.size.height);
    
    [self.loginBtn setTitle:NSLocalizedString(@"login to facebook",) forState:UIControlStateNormal];
    [self.logoutBtn setTitle:NSLocalizedString(@"logout from facebook",) forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:[NSLocalizedString(@"LoginToFacebookFontSize", nil)integerValue]];
    self.logoutBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:[NSLocalizedString(@"LogoutFromFacebookFontSize", nil)integerValue]];
    
    self.settingLBL.text = NSLocalizedString(@"setting", nil);
    
    if(IS_IPHONE_4_OR_LESS)
    {
        videoCount = 8;
    }
    else
    {
        videoCount = 10;
    }
    
    [self.mergeButton setTitle:NSLocalizedString(@"merge",nil) forState:UIControlStateNormal];
    [self.mergeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.mergeButton setTitle:NSLocalizedString(@"press the monkeys",nil) forState:UIControlStateDisabled];
    [self.mergeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.mergeButton setBackgroundImage:[UIImage imageNamed:@"merge_bg@2x.png"] forState:UIControlStateNormal];
    [self.mergeButton setBackgroundImage:[UIImage imageNamed:@"merge_bg@2x.png"] forState:UIControlStateDisabled];
    [self.mergeButton setBackgroundImage:[UIImage imageNamed:@"button-bg-merge-select@2x.png"] forState:UIControlStateSelected];
    
    self.videoTitleTextField.placeholder = NSLocalizedString(@"Write your LUK", nil);
    
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
    
    [self.seperationLine1 removeFromSuperview];
    [self.seperationLine2 removeFromSuperview];
    [self.seperationLine3 removeFromSuperview];
    [self.seperationLine4 removeFromSuperview];
    [self.seperationLine5 removeFromSuperview];
    [self.seperationLine6 removeFromSuperview];
    [self.seperationLine7 removeFromSuperview];
    [self.seperationLine8 removeFromSuperview];
    [self.seperationLine9 removeFromSuperview];
    [self.seperationLine10 removeFromSuperview];
    
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
        UIView *lukView = [lukViewsArr objectAtIndex:i];
        lukView.tag = i;
        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapOnce:)];
        UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapTwice:)];
        
        
        tapOnce.numberOfTapsRequired = 1;
        tapTwice.numberOfTapsRequired = 2;
        
        //stops tapOnce from overriding tapTwice
        [tapOnce requireGestureRecognizerToFail:tapTwice];
        
        //then need to add the gesture recogniser to a view - this will be the view that recognises the gesture
        [lukView addGestureRecognizer:tapOnce]; //remove the other button action which calls method `button`
        [lukView addGestureRecognizer:tapTwice];
        
        if(i<[titleWords count])
        {
            
            UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
            titleLBLObj.text = [titleWords objectAtIndex:i];
            lukView.hidden = NO;
            [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
            NSLog(@"NO");
        }
        else
        {
            lukView.hidden = YES;
        }
    }
}
-(void)tapOnce:(UIGestureRecognizer*)sender
{
    UIView *view = sender.view; //cast pointer to the derived class if needed
    NSLog(@"single tap..%ld.",(long)view.tag);
    
    isRecordingStart = YES;
    
    //Code for load screen
    [[NSUserDefaults standardUserDefaults]setInteger:view.tag forKey:@"SingleVideoIndex"];
    SingleVideoViewController *singleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleVideoViewController"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:singleVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    //    [self.navigationController pushViewController:singleVC animated:YES];
}

-(void)tapTwice:(UIGestureRecognizer*)sender
{
    isRecordingStart = YES;
    
    UIView *view = sender.view; //cast pointer to the derived class if needed
    NSLog(@"tapTwice tap..%ld.",(long)view.tag);
    
    //Get Video Local Path
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",(int)view.tag]];
    
    fileURL = [NSString stringWithFormat:@"%@/%@", path,filename];
    NSLog(@"fileURL.....%@",fileURL);
    
    //If video available then play
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL]) {
        [self playMovie:fileURL];
    }
    else
    {
        //Go to Load Screen
        [[NSUserDefaults standardUserDefaults]setInteger:view.tag forKey:@"SingleVideoIndex"];
        SingleVideoViewController *singleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleVideoViewController"];
        [self.navigationController presentViewController:singleVC animated:YES completion:nil];
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
        UIButton *lukBtn = [videoTitleButtonsArr objectAtIndex:i];
        UILabel *lbl = [videoTitleLBLArr objectAtIndex:i];
        [lbl setTextColor:[UIColor whiteColor]];
        [lukBtn setImage:[UIImage imageNamed: @"screen4-smilemonkey-icon.png"] forState:UIControlStateNormal];
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
    NSLog(@"textField1...%@...text..%@..%lu",textField.text,string,(unsigned long)range.location);
    
    NSMutableArray *array;
    NSString *textViewStr;
    
    NSMutableString *textViewStr1 = [NSMutableString stringWithString:textField.text];
    
    if(string.length == 0)
    {
        if ([textViewStr1 length] > 0) {
            //            textViewStr = [textViewStr substringToIndex:[textViewStr length] - 1];
            [textViewStr1 deleteCharactersInRange:range];
            NSLog(@"textField2...%@...text..%@..",textViewStr1,string);
        } else {
            //no characters to delete... attempting to do so will result in a crash
        }
    }
    else
    {
        //        textViewStr = [NSString stringWithFormat:@"%@%@",textViewStr,string];
        [textViewStr1 insertString:string atIndex:range.location];
        NSLog(@"textField3...%@...text..%@..",textViewStr1,string);
    }
    
    textViewStr = textViewStr1;
    textViewStr = [textViewStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setObject:textViewStr forKey:VIDEO_TITLE];
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
            //            [self resetLUK:[array count]];
            if(currentLUKIndex != [array count]-2)
                [self resetLUK:array ];
            //            currentLUKIndex = [array count];
        }
    }
    else{
        if([string isEqualToString:@" "])//When user enter one character.
        {
            NSLog(@"textView...%@..",textViewStr);
            if(textViewStr.length>0){
                
                if([array count] > 0 && [array count] < (videoCount+1)){
                    //                    [[NSUserDefaults standardUserDefaults] setObject:textViewStr forKey:VIDEO_TITLE];
                    if(currentLUKIndex != [array count]){
                        [self animateView:array range:range];
                        currentLUKIndex = [array count]-1;
                    }
                    else
                    {
                        if(currentLUKIndex == [array count]-1)
                            [self resetLUK:array];
                    }
                    
                }
                
                if([array count] > videoCount)
                {
                    //            message = @"You exceed meximum word limit of 10";
                    NSLog(@"1 You exceed meximum word limit of 10");
                    return NO;
                }
            }
        }
        else
        {
            if([array count] > videoCount)
            {
                NSLog(@"2 You exceed meximum word limit of 10");
                return NO;
                
            }
            if(currentLUKIndex == [array count]-2)
            {}
            else if(currentLUKIndex <  [array count]){
                [self resetLUK:array];
            }
        }
    }
    return YES;
}

//Show look with animation
-(void)animateView:(NSArray*)titleArray range:(NSRange)range
{
    NSLog(@"length..%lu ,%lu",(unsigned long)self.videoTitleTextField.text.length,(unsigned long)range.location);
    if(self.videoTitleTextField.text.length == range.location){
        
        for(NSInteger i = 0; i<10;i++)
        {
            UIView *view = [lukViewsArr objectAtIndex:i];
            UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
            if(i<titleArray.count-1){
                
                titleLBLObj.text = [titleArray objectAtIndex:i];
                view.hidden = NO;
            }
        }
        
        NSInteger viewIndex = [titleArray count];
        NSString *wordText = [titleArray lastObject];
        UIView *lukView = [lukViewsArr objectAtIndex:viewIndex-1];
        UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:viewIndex-1];
        //    [lukBtn setImage:[UIImage imageNamed: @"screen4-smilemonkey-icon.png"] forState:UIControlStateNormal];
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
    else
    {
        for(NSInteger i = 0; i<10;i++)
        {
            UIView *view = [lukViewsArr objectAtIndex:i];
            UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
            if(i<titleArray.count){
                
                titleLBLObj.text = [titleArray objectAtIndex:i];
                view.hidden = NO;
            }
        }
    }
    
    
   
}

//Reset Luk
//-(void)resetLUK:(NSInteger)lukCount
//{
//    lukCount = 10-lukCount;
//
//    for(NSInteger i = 9; lukCount>0;lukCount--,i--)
//    {
//
//        UIView *view = [lukViewsArr objectAtIndex:i];
//        view.hidden = YES;
//    }
//}

-(void)resetLUK:(NSArray*)array
{
    //    lukCount = 10-lukCount;
    
    //    NSLog(@"videoTitle..%@..",titleStr);
    //    if(titleStr.length>0){
    //        NSMutableArray *titleWords = (NSMutableArray*)[titleStr componentsSeparatedByString:@" "];
    //        if(titleWords.count>1)
    //            [titleWords removeObject:@""];
    
    currentLUKIndex = array.count-1;
    
    for(NSInteger i = 0; i<10;i++)
    {
        UIView *view = [lukViewsArr objectAtIndex:i];
        UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
        if(i<array.count){
            
            titleLBLObj.text = [array objectAtIndex:i];
            view.hidden = NO;
        }
        else
        {
            view.hidden = YES;
        }
    }
    //    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//Facebook Methods

- (IBAction)openSettingBtnAction:(id)sender {
    
    BOOL isUserLogin = [[NSUserDefaults standardUserDefaults]boolForKey:@"FB_LOGIN"];
    NSString *name = [[NSUserDefaults standardUserDefaults]valueForKey:@"FB_NAME"];
    if(name.length>0)
        self.nameLabel.text = name;
    else
        self.nameLabel.text = @"";
    
    self.loginBtn.hidden = isUserLogin;
    self.logoutBtn.hidden = !isUserLogin;
    
    self.settingView.translatesAutoresizingMaskIntoConstraints  = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    
    CGRect frame= self.settingView.frame;
    if(IS_IPHONE_4_OR_LESS)
        self.settingView.frame = CGRectMake(80, 0, frame.size.width, frame.size.height);
    else
        self.settingView.frame = CGRectMake(80, 0, frame.size.width, frame.size.height);
    [UIView commitAnimations];
}

- (IBAction)closeSettingBtnAction:(id)sender {
    self.settingView.translatesAutoresizingMaskIntoConstraints  = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    
    CGRect frame= self.settingView.frame;
    if(IS_IPHONE_4_OR_LESS)
        self.settingView.frame = CGRectMake(self.view.frame.size.width, 0, frame.size.width, frame.size.height);
    else
        self.settingView.frame = CGRectMake(self.view.frame.size.width, 0, frame.size.width, frame.size.height);
    [UIView commitAnimations];
    
}

- (IBAction)facebookLoginAction:(UIButton *)sender
{
    NSArray* permissions = [[NSArray alloc] initWithObjects:
                            @"publish_actions", nil];
    [SharedAppDelegate.facebook authorize:permissions delegate:self];
}

- (IBAction)facebookLououtAction:(UIButton *)sender
{
    [SharedAppDelegate.facebook logout:self];
}


//==================== facebook delegate methods.
- (void)fbDidLogin {
    [self getUserFBProfileData];
    NSLog(@"User login in faceook");
}


-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"FB_LOGIN"];
    [CommonMethods showAlertWithTitle:NSLocalizedString(@"Error",nil) message:NSLocalizedString(@"Something is wrong with your facebook account.",nil)];
}
-(void)fbDidLogout
{
    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"FB_LOGIN"];
    [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"FB_NAME"];
    self.loginBtn.hidden = NO;
    self.logoutBtn.hidden = YES;
    self.nameLabel.text = @"";
    NSLog(@"facebook logout");

}

-(void)getUserFBProfileData
{
    //Get fb server data List Request to server
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me?fields=id,name&access_token=%@",SharedAppDelegate.facebook.accessToken]]];
    
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    // Create url connection and fire request
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:backgroundQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   //                                   [GMDCircleLoader hideFromView:self.view animated:YES];
                               });
                               
                               if (error)
                               {
                                   NSLog(@"error%@",[error localizedDescription]);
                                   dispatch_async(dispatch_get_main_queue()
                                                  , ^(void) {
                                                      [CommonMethods showAlertWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription] cancelBtnTitle:NSLocalizedString(@"Accept",nil) otherBtnTitle:nil delegate:nil tag:0];
                                                  });
                               }
                               else
                               {
                                   NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"result....%@",result);
                                   
                                   NSError *jsonParsingError = nil;
                                   id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                                   
                                   if (jsonParsingError) {
                                       NSLog(@"JSON ERROR: %@", [jsonParsingError localizedDescription]);
                                   } else {
                                       NSDictionary *responseDict = (NSDictionary*)object;
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           NSString*name = [responseDict valueForKey:@"name"];
                                           if(name.length>0){
                                               [[NSUserDefaults standardUserDefaults]setValue:name forKey:@"FB_NAME"];
                                               [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"FB_LOGIN"];
                                               self.nameLabel.text = name;
                                               self.loginBtn.hidden = YES;
                                               self.logoutBtn.hidden = NO;
                                           }
                                       });
                                   }
                               }
                           }];
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
