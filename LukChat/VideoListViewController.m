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
    
    [self initUIArrays];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        objc_msgSend([UIDevice currentDevice], @selector(setOrientation:),    UIInterfaceOrientationPortrait);
    }
    
    videoTitle =  [[NSUserDefaults standardUserDefaults] valueForKey:VIDEO_TITLE];
    
    NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
    if(titleWords.count>1)
        [titleWords removeObject:@""];
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    
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
    
}

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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initUIArrays
{
    videoTitle =  [[NSUserDefaults standardUserDefaults] valueForKey:VIDEO_TITLE];
    
    NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
    if(titleWords.count>1)
        [titleWords removeObject:@""];
    
    self.titleHeaderLBL.text = videoTitle;
    
    videoTitleButtonsArr = [[NSMutableArray alloc]init];
    videoTitleLBLArr = [[NSMutableArray alloc]init];
    seperationLineArr = [[NSMutableArray alloc]init];
    
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
    
    [seperationLineArr addObject:self.seperationLine1];
    [seperationLineArr addObject:self.seperationLine2];
    [seperationLineArr addObject:self.seperationLine3];
    [seperationLineArr addObject:self.seperationLine4];
    [seperationLineArr addObject:self.seperationLine5];
    [seperationLineArr addObject:self.seperationLine6];
    [seperationLineArr addObject:self.seperationLine7];
    [seperationLineArr addObject:self.seperationLine8];
    [seperationLineArr addObject:self.seperationLine9];
    [seperationLineArr addObject:self.seperationLine10];
    
    
    for(int i=0 ;i<10;i++)
    {
        if(i<[titleWords count])
        {
            UIButton *buttonObj = [videoTitleButtonsArr objectAtIndex:i];
            UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
            UIImageView *seperationLine = [seperationLineArr objectAtIndex:i];
            
            buttonObj.hidden = NO;
            titleLBLObj.hidden = NO;
            seperationLine.hidden = NO;
            
            titleLBLObj.text = [titleWords objectAtIndex:i];
            
            [[NSUserDefaults standardUserDefaults]setValue:@"NO" forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
            NSLog(@"NO");
        }
        
        else
        {
            UIButton *buttonObj = [videoTitleButtonsArr objectAtIndex:i];
            UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
            UIImageView *seperationLine = [seperationLineArr objectAtIndex:i];
            
            buttonObj.hidden = YES;
            titleLBLObj.hidden = YES;
            seperationLine.hidden = YES;
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

- (IBAction)videoRecordButtonPressed:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Option" delegate:self cancelButtonTitle:CANCEL_BUTTON destructiveButtonTitle:nil otherButtonTitles:@"Record", @"Play", nil];
    [actionSheet setTag:sender.tag];
    [actionSheet showFromRect:sender.frame inView:self.view animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
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
        NSLog(@"fileURL.....%@",fileURL);
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL]) {
            [self playMovie:fileURL];
        }
        
        
        //        [self play:actionSheet.tag];
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
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray *videofiles = [[NSMutableArray alloc] init];
    
    videoTitle =  [[NSUserDefaults standardUserDefaults] valueForKey:VIDEO_TITLE];
    
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You need two recorded video clips to merge the videos." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        return;
    }
    
    NSString *mergedFile = [NSString stringWithFormat:@"%@/mergedvideo.mov", path];
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
    
   [[NSUserDefaults standardUserDefaults] setValue:outputVideoPath forKey:kMyVideoToShare];
     MergeVideosViewController *mergeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MergeVideosViewController"];
    
    [self.navigationController pushViewController:mergeVC animated:YES];
//    [self playMovie:outputVideoPath];
}
@end
