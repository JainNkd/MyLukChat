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
#import "LukCell.h"

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"
#import "UIView+WebCacheOperation.h"


#import "UCZProgressView.h"

#import "Common/ConnectionHandler.h"

#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"




@interface VideoListViewController ()<ConnectionHandlerDelegate>
{
    NSMutableArray *sections;
    NSInteger videoCount;
}
@property (nonatomic, strong) NSMutableDictionary *videoDownloadsInProgress;
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
    
    //    [self fetchRandomVideoFromserver:@"LUK"];
    
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
    
    
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [doubleTapGesture setNumberOfTouchesRequired:1];
    
    [self.collectionView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [singleTapGesture setNumberOfTouchesRequired:1];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    [self.collectionView addGestureRecognizer:singleTapGesture];
    
    sections = [[NSMutableArray alloc] initWithCapacity:videoCount];
    videofiles = [[NSMutableArray alloc] initWithCapacity:videoCount];
    [videofiles removeAllObjects];
    for(int i=0 ;i<10;i++)
    {
        [videofiles addObject:@"NO"];
    }
    self.titleHeaderLBL.hidden = YES;
    self.videoDownloadsInProgress = [[NSMutableDictionary alloc]init];
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
    
    //Set LUK count based on device
    if(IS_IPHONE_4_OR_LESS)
    {
        videoCount = 8;
    }
    else
    {
        videoCount = 10;
    }
    
    //Setting View UI set UP
    self.settingView.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame= self.settingView.frame;
    self.settingView.frame = CGRectMake(self.view.frame.size.width, 0, frame.size.width, frame.size.height);
    
    [self.loginBtn setTitle:NSLocalizedString(@"login to facebook",) forState:UIControlStateNormal];
    [self.logoutBtn setTitle:NSLocalizedString(@"logout from facebook",) forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:[NSLocalizedString(@"LoginToFacebookFontSize", nil)integerValue]];
    self.logoutBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:[NSLocalizedString(@"LogoutFromFacebookFontSize", nil)integerValue]];
    
    self.settingLBL.text = NSLocalizedString(@"setting", nil);
    
    //Merge button UI setup
    [self.mergeButton setTitle:NSLocalizedString(@"merge",nil) forState:UIControlStateNormal];
    [self.mergeButton setBackgroundImage:[UIImage imageNamed:@"merge_bg@2x.png"] forState:UIControlStateNormal];
    [self.mergeButton setBackgroundImage:[UIImage imageNamed:@"merge_bg@2x.png"] forState:UIControlStateDisabled];
    [self.mergeButton setBackgroundImage:[UIImage imageNamed:@"button-bg-merge-select@2x.png"] forState:UIControlStateSelected];
    [self.mergeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [self.mergeButton setTitle:NSLocalizedString(@"press the monkeys",nil) forState:UIControlStateDisabled];
    [self.mergeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
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
            
            [sections removeAllObjects];
            [sections addObjectsFromArray:titleWords];
            currentLUKIndex = titleWords.count;
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSMutableArray *videofilesExist = [[NSMutableArray alloc]init];
            
            for (int i=0; i < titleWords.count; i++) {
                NSString *fileNameStr = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
                NSString *pathWithfilename = [NSString stringWithFormat:@"%@/%@", path, fileNameStr];
                if(fileNameStr)
                    [videofiles replaceObjectAtIndex:i withObject:fileNameStr];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:pathWithfilename]) {
                    [videofilesExist addObject:fileNameStr];
                }
            }
            
            //            if(videofilesExist.count>0)
            //                isRecordingStart = YES;
            
            //            if (!videofilesExist || [videofilesExist count] < 2) {
            //                self.mergeButton.enabled = NO;
            //            }
            //            else{
            //                self.mergeButton.enabled = YES;
            //            }
            //            if(titleWords.count>0)
            //                isRecordingStart = YES;
            
            if(titleWords.count<2)
                self.mergeButton.enabled = NO;
            else
                self.mergeButton.enabled = YES;
            
        }
        else
        {
            self.mergeButton.enabled = NO;
        }
    }
    
    [self.collectionView reloadData];
    
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
    int i= 0 ;
    videoTitle = [CommonMethods getVideoTitle];
    
    NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
    if(titleWords.count>1)
        [titleWords removeObject:@""];
    for(NSString*title in titleWords)
    {
        NSLog(@"Title..%@...%d",title,i);
        NSString *videoURL = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
        
        if([videoURL isEqualToString:@"NO"])
        {
            i++;
            continue;
        }
        else{
            AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[videoURL];
            NSLog(@"videoURL....%@",videoURL);
            if([CommonMethods fileExist:videoURL] && !operation)
            {
                i++;
                continue;
            }
        }
    }
    
    if(i==[titleWords count])
        [self mergedVideo];
    else
        [self downloadVidoes];
}

-(void)mergedVideo
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray *videofilesArr = [[NSMutableArray alloc] init];
    
    videoTitle = [CommonMethods getVideoTitle];
    
    NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
    if(titleWords.count>1)
        [titleWords removeObject:@""];
    
    for (int i=0; i < titleWords.count; i++) {
        NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
        
        filename = [NSString stringWithFormat:@"%@/%@", path, filename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
            [videofilesArr addObject:filename];
            //            NSLog(@"filename : %@", filename);
        }
    }
    
    if ([videofilesArr count] < 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You need two recorded video clips to merge the videos." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Accept", nil];
        [alert show];
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
    
    NSLog(@"Files : %@", videofilesArr);
    
    
    for (int i=0; i < [videofilesArr count]; i++) {
        NSURL *url = [NSURL fileURLWithPath:[videofilesArr objectAtIndex:i]];
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

//==========================================================================================================
//Textfield Delgate methods

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@".....%@...%d,,,,,%d",string,range.length,range.location);
//    NSLog(@"textField1...%@...text..%@..%lu",textField.text,string,(unsigned long)range.location);
    
    NSMutableArray *array;
    NSString *textViewStr;
    
    NSMutableString *textViewStr1 = [NSMutableString stringWithString:textField.text];
    
    if(string.length == 0)
    {
        if ([textViewStr1 length] > 0) {
            //            textViewStr = [textViewStr substringToIndex:[textViewStr length] - 1];
            [textViewStr1 deleteCharactersInRange:range];
//            NSLog(@"textField2...%@...text..%@..",textViewStr1,string);
        } else {
            //no characters to delete... attempting to do so will result in a crash
        }
    }
    else
    {
        //        textViewStr = [NSString stringWithFormat:@"%@%@",textViewStr,string];
        [textViewStr1 insertString:string atIndex:range.location];
//        NSLog(@"textField3...%@...text..%@..",textViewStr1,string);
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
            if(currentLUKIndex != [array count]-1)
                [self resetLUK:array ];
            //            currentLUKIndex = [array count];
        }
    }
    else{
        if([string isEqualToString:@" "])//When user enter one character.
        {
            NSLog(@"animateView textView...%@..",textViewStr);
            if(textViewStr.length>0){
                
                if([array count] > 0 && [array count] < (videoCount+1)){
                    //                    [[NSUserDefaults standardUserDefaults] setObject:textViewStr forKey:VIDEO_TITLE];
                    if(currentLUKIndex != [array count]){
                        [self animateView:array range:range];
                        currentLUKIndex = [array count];
                    }
                    else
                    {
                        if(currentLUKIndex == [array count])
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
            if(currentLUKIndex == [array count]-1)
            {
                
            }
            else if(currentLUKIndex <=  [array count]){
                [self resetLUK:array];
            }
        }
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//==========================================================================================================
//Show look with animation
//This method is called when 1. edit luk 2.add new luk
-(void)animateView:(NSArray*)titleArray range:(NSRange)range
{
    NSLog(@"Step121");
    //    isRecordingStart = YES;
    [sections removeAllObjects];
    [sections addObjectsFromArray:titleArray];
    
    
    if(titleArray.count<2)
        self.mergeButton.enabled = NO;
    else
        self.mergeButton.enabled = YES;
    
    NSLog(@"range..%lu ,%lu",(unsigned long)self.videoTitleTextField.text.length,(unsigned long)range.location);
    if(self.videoTitleTextField.text.length == range.location){
        
        NSInteger viewIndex = [titleArray count];
        NSIndexPath *newindex = [NSIndexPath indexPathForItem:viewIndex-1 inSection:0];
        [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:[NSString stringWithFormat:@"VIDEO_%ld_URL",(long)newindex.row]];
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:[NSString stringWithFormat:@"VIDEO_%d_NOT",(int)newindex.row]];
        [videofiles replaceObjectAtIndex:newindex.row withObject:@"NO"];
        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:newindex]];
        
    }
    else
    {
        [self.collectionView reloadData];
    }
}

-(void)resetTextBox
{
    self.mergeButton.enabled = NO;
    isRecordingStart = NO;
    currentLUKIndex = 0;
    [[NSUserDefaults standardUserDefaults]setValue:@"" forKey:@"videoTitle"];
    self.videoTitleTextField.text = @"";
    [videofiles removeAllObjects];
    for(int i=0 ;i<10;i++)
    {
        [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:[NSString stringWithFormat:@"VIDEO_%d_NOT",i]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [videofiles addObject:@"NO"];
    }
    [sections removeAllObjects];
    [self.collectionView reloadData];
}

-(void)resetLUK:(NSArray*)array
{
        NSLog(@"Step122");
    //    isRecordingStart= YES;
            NSLog(@"currentLUKIndex...%d",currentLUKIndex);
    if(currentLUKIndex == 0)
        return;
    
    currentLUKIndex = array.count;
    [sections removeAllObjects];
    [sections addObjectsFromArray:array];
    
    if(array.count<2)
        self.mergeButton.enabled = NO;
    else
        self.mergeButton.enabled = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.collectionView reloadData];
    });
    
}

//==========================================================================================================
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

//==========================================================================================================
//facebook delegate methods.
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

//==========================================================================================================
//Collection view delegate methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [sections count];
}

//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//
//    NSLog(@"cell selected...%@",[sections objectAtIndex:indexPath.item]);
//}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"tempfile indexPath....%@",indexPath);
    LukCell *cell = (LukCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    if(!cell.progressView){
        cell.progressView = [[UCZProgressView alloc]initWithFrame: cell.loadingWheelView.frame];
        cell.progressView.indeterminate = YES;
        cell.progressView.showsText = YES;
        cell.progressView.backgroundColor = [UIColor blackColor];
        cell.progressView.opaque = 0.5;
        cell.progressView.alpha = 0.5;
        [cell.loadingWheelView addSubview:cell.progressView];
    }
    
    BOOL isVideoFind = [[NSUserDefaults standardUserDefaults]boolForKey:[NSString stringWithFormat:@"VIDEO_%d_NOT",indexPath.row]];
    
    NSLog(@"stepppp...%d",isVideoFind);
    
    if(isVideoFind)
        cell.loadingWheelView.hidden = YES;
    else
        cell.loadingWheelView.hidden = NO;
    
    if(sections.count>indexPath.row){
        cell.label.text = [sections objectAtIndex:indexPath.item];
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%ld_URL",(long)indexPath.row]];
        
        NSString *tempfile = [NSString stringWithFormat:@"%@/%@", path, filename];
        NSLog(@"Video URL --= %@",tempfile);
        
        NSString *imageFilePath;
        NSString *imageName;
//        cell.loadingWheelView.hidden = NO;
        cell.progressView.indeterminate = YES;
        
        if(filename.length>2)
        {
            imageFilePath = filename;
            imageFilePath = [filename stringByReplacingOccurrencesOfString:@".mp4" withString:@".png"];
            imageName = imageFilePath;
            imageName = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,imageName];
            imageFilePath = [NSString stringWithFormat:@"%@/%@", path, imageFilePath];
            NSLog(@"imageFilePath URL --= %@",imageFilePath);
        }
        
        UIImage *temp = [[UIImage alloc] initWithContentsOfFile:tempfile];
        if (temp) {
            [cell.imageView setImage:temp];
            [cell.label setTextColor:[UIColor yellowColor]];
        }
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempfile])
        {
            UIImage *image = [self generateThumbImage:tempfile];
            
            if(image)
            {
                [cell.imageView setImage:image];
                [cell.label setTextColor:[UIColor yellowColor]];
                cell.loadingWheelView.hidden = YES;
            }
        }
        else if(imageFilePath.length>0)
        {
            if([[NSFileManager defaultManager] fileExistsAtPath:imageFilePath])
            {
                cell.loadingWheelView.hidden = YES;
                NSData *pngData = [NSData dataWithContentsOfFile:imageFilePath];
                UIImage *image = [UIImage imageWithData:pngData];
                if(image)
                {
                    [cell.imageView setImage:image];
                    [cell.label setTextColor:[UIColor yellowColor]];
                    cell.loadingWheelView.hidden = YES;
                }
                else{
                    [cell.imageView setImage:[UIImage imageNamed:@"screen4-smilemonkey-icon.png"]];
                }
            }
            else
            {
                // using Image for thumbnails
                if([CommonMethods reachable]){
                    if(imageName.length>0){
                        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"screen4-smilemonkey-icon.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error==nil)
                            {
                                NSLog(@"Loaded successfully.....%@",[imageURL absoluteString]);// %ld", (long)[response statusCode]);
                                
                                dispatch_async(dispatch_get_main_queue(), ^(void) {
                                    cell.progressView.hidden = YES;
//                                    if(image){
//                                        cell.imageView.image = image;
//                                    }
                                    NSArray *ary = [[imageURL absoluteString] componentsSeparatedByString:@"/"];
                                    NSString *filename = [ary lastObject];
                                    
                                    NSString *filePath = [path stringByAppendingPathComponent:filename];
                                    //Add the file name
                                    NSData *pngData = UIImagePNGRepresentation(image);
                                    if(pngData && filename.length>0){
                                        [pngData writeToFile:filePath atomically:YES];
                                        [self.collectionView reloadData];
                                    }
                                });
                            }else{
                            NSLog(@"failed loading");//'%@", error);
                            //                                                      [self.sentTableViewObj reloadData];
                        }
                        }];
                    }
                    else
                    {
                        [cell.imageView setImage:[UIImage imageNamed:@"screen4-smilemonkey-icon.png"]];
                    }
                }
                else
                {
                    [cell.imageView setImage:[UIImage imageNamed:@"screen4-smilemonkey-icon.png"]];
                }
            }
        }
        else
        {
            [cell.imageView setImage:[UIImage imageNamed:@"screen4-smilemonkey-icon.png"]];
            [cell.label setTextColor:[UIColor whiteColor]];
            cell.progressView.hidden = NO;
        }
        if([filename isEqualToString:@"NO"] && !isVideoFind)
        {
            [self fetchRandomVideoFromserver:cell.label.text];
        }
    }
    return cell;
}


- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    
    NSLog(@"fromindex...%ld.....toindex...%ld",fromIndexPath.item,toIndexPath.item);
    NSString *wordText = [sections objectAtIndex:fromIndexPath.item];
    [sections removeObjectAtIndex:fromIndexPath.item];
    [sections insertObject:wordText atIndex:toIndexPath.item];
    
    NSString *videoName = [videofiles objectAtIndex:fromIndexPath.item];
    [videofiles removeObjectAtIndex:fromIndexPath.item];
    [videofiles insertObject:videoName atIndex:toIndexPath.item];
    
    int i=0;
    NSMutableString *string = [[NSMutableString alloc]init];
    for(NSString* appendStr in sections){
        [string appendString:appendStr];
        [string appendString:@" "];
        NSString *videoName = [videofiles objectAtIndex:i];
        [[NSUserDefaults standardUserDefaults]setValue:videoName forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
        [[NSUserDefaults standardUserDefaults]synchronize];
        i++;
    }
    self.videoTitleTextField.text = string;
    [[NSUserDefaults standardUserDefaults]setValue:string forKey:VIDEO_TITLE];
    
    
    NSLog(@"Data sections ....%@",sections);
    NSLog(@"video name  sections ....%@",videofiles);
}


-(void)processSingleTap:(UITapGestureRecognizer*)gesture
{
    [self.videoTitleTextField resignFirstResponder];
    isRecordingStart = YES;
    CGPoint pointInCollectionView = [gesture locationInView:self.collectionView];
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:pointInCollectionView];
    LukCell *selectedCell = (LukCell*)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
    if(selectedCell){
        NSLog(@"processSingleTap index path..%@",selectedIndexPath);
        
        //Code for load screen
        [[NSUserDefaults standardUserDefaults]setInteger:selectedIndexPath.row forKey:@"SingleVideoIndex"];
        SingleVideoViewController *singleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleVideoViewController"];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:singleVC];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
        
    }
    else
        NSLog(@"processSingleTap not selected...!!!");
}

-(void)processDoubleTap:(UITapGestureRecognizer*)gesture
{
    [self.videoTitleTextField resignFirstResponder];
    isRecordingStart = YES;
    CGPoint pointInCollectionView = [gesture locationInView:self.collectionView];
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:pointInCollectionView];
    LukCell *selectedCell = (LukCell*)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
    if(selectedCell){
        //Get Video Local Path
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        
        NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",(int)selectedIndexPath.row]];
        
        fileURL = [NSString stringWithFormat:@"%@/%@", path,filename];
        NSLog(@"fileURL.....%@",fileURL);
        
        //If video available then play
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL]) {
            [self playMovie:fileURL];
        }
        else
        {
            //Go to Load Screen
            [[NSUserDefaults standardUserDefaults]setInteger:selectedIndexPath.row forKey:@"SingleVideoIndex"];
            SingleVideoViewController *singleVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleVideoViewController"];
            [self.navigationController presentViewController:singleVC animated:YES completion:nil];
        }
        
    }else
        NSLog(@"processDoubleTap not selected...!!!");
}


-(void)fetchRandomVideoFromserver:(NSString*)titleWord
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    [dict setValue:titleWord forKey:@"key"];
    [dict setValue:@"random" forKey:@"order_by"];
    [dict setValue:[NSString stringWithFormat:@"%d",0] forKey:@"start"];
    [dict setValue:[NSString stringWithFormat:@"%d",1] forKey:@"count"];
    
    ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
    connObj.delegate = self;
    [connObj makePOSTRequestPath:kSearchSingleVideo parameters:dict];
}

-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    NSLog(@"loadAppContactsOnTable ******************");
    if ([urlPath isEqualToString:kSearchSingleVideo]) {
        NSLog(@"SUCCESS: All Data fetched");
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        
        if(error)
            [CommonMethods showAlertWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription]];
        else
        {
            NSArray *singleArrData = (NSArray*)responseDict;
            NSLog(@"log....%@",[singleArrData description]);
            
            dispatch_async(dispatch_get_main_queue(),^{
                [self parseSingleVideoData:singleArrData];
            });
        }
    }
}


-(void)connHandlerClient:(ConnectionHandler *)client didFailWithError:(NSError *)error
{
    NSString *string = [error localizedDescription];
    string = [string substringFromIndex:[string length]-3];
    NSLog(@"connHandlerClient:didFailWithError = %@",string);
}

-(void)parseSingleVideoData:(NSArray*)videoData
{
    NSLog(@"STEP1");
    BOOL isFound = FALSE;
    
    if(videoData.count>0)
    {
        id data = [videoData objectAtIndex:0];
        if([data isKindOfClass:[NSString class]])
        {
            videoTitle = [CommonMethods getVideoTitle];
            if(videoTitle.length>0){
                NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
                if(titleWords.count>1)
                    [titleWords removeObject:@""];
                
                int fileIndex = 0;
                for(NSString *word in titleWords){
                    if ([word caseInsensitiveCompare:data] == NSOrderedSame)
                    {
                            NSLog(@"STEP31");
                        
                            [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",fileIndex]];
                           [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:[NSString stringWithFormat:@"VIDEO_%d_NOT",fileIndex]];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                            isFound = true;
                    }
                    fileIndex++;
                }
                
            }
        }
        else{
            for(NSDictionary* videosDict in videoData)
            {
                NSLog(@"STEP2");
                NSDictionary *videoData = [videosDict valueForKey:@"videos"];
                VideoDetail *videoDetail = [[VideoDetail alloc]initWithDict:videoData];
                videoTitle = [CommonMethods getVideoTitle];
                if(videoTitle.length>0){
                    NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
                    if(titleWords.count>1)
                        [titleWords removeObject:@""];
                    
                    int fileIndex = 0;
                    for(NSString *word in titleWords){
                        if ([word caseInsensitiveCompare:videoDetail.videoTitle] == NSOrderedSame)
                        {
                            NSString *fileNameStr = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",fileIndex]];
                            [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:[NSString stringWithFormat:@"VIDEO_%d_NOT",fileIndex]];
                            NSLog(@"fileNameStr......%@",fileNameStr);
                            
                            if(fileNameStr.length == 2){
                                NSLog(@"STEP3");
                                [[NSUserDefaults standardUserDefaults]setValue:videoDetail.videoURL forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",fileIndex]];
                                [[NSUserDefaults standardUserDefaults]synchronize];
                                isFound = TRUE;
                                break;
                            }
                        }
                        fileIndex++;
                    }
                    
                }
            }
        }
    }
    
//    dispatch_async(dispatch_get_main_queue(),^
//                   {
//                       if(isFound){
//                           NSLog(@"Step4   %d",currentLUKIndex);
                           [self performSelector:@selector(reloadTableData) withObject:nil afterDelay:0.25f];
//                       }
//                   });
}

-(void)reloadTableData
{
    [self.collectionView reloadData];
}

-(void)reloadData
{
    NSString* string = @" ";
    NSMutableArray *array;
    NSString *textViewStr = self.videoTitleTextField.text;
    textViewStr = [textViewStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [[NSUserDefaults standardUserDefaults] setObject:textViewStr forKey:VIDEO_TITLE];
    if(textViewStr.length>0){
        array = (NSMutableArray*)[textViewStr componentsSeparatedByString:@" "];
        if([array count]>1)
            [array removeObject:@""];
    }
    
    if ( [string isEqualToString:@""]) {//When detect backspace when have one character.
        if(isRecordingStart){
            return ;
        }
        else{
            //            [self resetLUK:[array count]];
            if(currentLUKIndex != [array count]-1)
                [self resetLUK:array ];
            //            currentLUKIndex = [array count];
        }
    }
    else{
        if([string isEqualToString:@" "])//When user enter one character.
        {
            NSLog(@"animateView textView...%@..",textViewStr);
            if(textViewStr.length>0){
                
                if([array count] > 0 && [array count] < (videoCount+1)){
                    //                    [[NSUserDefaults standardUserDefaults] setObject:textViewStr forKey:VIDEO_TITLE];
                    if(currentLUKIndex != [array count]){
//                        [self animateView:array range:range];
                        currentLUKIndex = [array count];
                    }
                    else
                    {
                        if(currentLUKIndex == [array count])
                            [self resetLUK:array];
                    }
                    
                }
                
                if([array count] > videoCount)
                {
                    //            message = @"You exceed meximum word limit of 10";
                    NSLog(@"1 You exceed meximum word limit of 10");
                    return ;
                }
            }
        }
        else
        {
            if([array count] > videoCount)
            {
                NSLog(@"2 You exceed meximum word limit of 10");
                return ;
                
            }
            if(currentLUKIndex == [array count]-1)
            {
                
            }
            else if(currentLUKIndex <=  [array count]){
                [self resetLUK:array];
            }
        }
    }
}
//Download default vidoes
-(void)downloadVidoes
{
    int i= 0 ;
    videoTitle = [CommonMethods getVideoTitle];
    
    NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
    if(titleWords.count>1)
        [titleWords removeObject:@""];
    
    UCZProgressView *progressView;
    for(NSString*title in titleWords)
    {
        NSLog(@"Title..%@...%d",title,i);
        NSString *videoURL = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
        if([videoURL isEqualToString:@"NO"])
        {
            i++;
            continue;
        }
        else{
            AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[videoURL];
            NSLog(@"videoURL....%@",videoURL);
            if([CommonMethods fileExist:videoURL] && !operation)
            {
                i++;
                continue;
            }
            else
            {
                if([CommonMethods reachable])
                {
                    if(!progressView){
                        progressView = [[UCZProgressView alloc]initWithFrame:self.view.bounds];
                        progressView.tag = i;
                        progressView.indeterminate = YES;
                        progressView.showsText = YES;
                        progressView.tintColor = [UIColor whiteColor];
                        [self.view addSubview:progressView];
                    }
                    NSString *localURL = [CommonMethods localFileUrl:videoURL];
                    if(!operation){
                        NSString *urlString = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,videoURL];
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request ];
                        
                        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:localURL append:YES];
                        
                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            NSLog(@"Successfully downloaded file to %@,.%@", localURL,operation.request.URL.absoluteString);
                            
                            NSArray *ary = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                            NSString *filename = [ary lastObject];
                            NSLog(@"self.videoDownloadsInProgress....%@",self.videoDownloadsInProgress);
                            [self.videoDownloadsInProgress removeObjectForKey:filename];
                            NSLog(@"self.videoDownloadsInProgress....%@",self.videoDownloadsInProgress);
                            if([self.videoDownloadsInProgress allKeys].count==0)
                            {
                                [progressView removeFromSuperview];
                                [self videoMergeButtonPressed:nil];
                            }
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error: %@", error);
                            if([self.videoDownloadsInProgress allKeys].count==0)
                            {
                                [progressView removeFromSuperview];
                            }
                            
                        }];
                        
                        [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
                            
                            // Draw the actual chart.
                            //            dispatch_async(dispatch_get_main_queue()
                            //                           , ^(void) {
                            //                        progressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
                            //                               [cell layoutSubviews];
                            //                           });
                            
                        }];
                        
                        (self.videoDownloadsInProgress)[videoURL] = operation;
                        NSLog(@"self.videoDownloadsInProgress....%@ video URL:%@",self.videoDownloadsInProgress,videoURL);
                        [operation start];
                    }
                }
                else{
                    NSLog(@"No internet connectivity");
                }
            }
        }
        i++;
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
