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
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    for(int i=0 ;i<[titleWords count];i++)
    {
        NSString *tempfile = [NSString stringWithFormat:@"%@/video%d.png", path, i];
        UIButton *buttonObj = [videoTitleButtonsArr objectAtIndex:i];
        UILabel *titleLBLObj = [videoTitleLBLArr objectAtIndex:i];
        
        UIImage *temp = [[UIImage alloc] initWithContentsOfFile:tempfile];
        if (temp) {
            [buttonObj setImage:temp forState:UIControlStateNormal];
            [titleLBLObj setTextColor:[UIColor yellowColor]];
        }
        
        
    }
    
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
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    fileURL = [NSString stringWithFormat:@"%@/video%ld.mov", path,(long)actionSheet.tag];
    
    if(buttonIndex==0)
    {
        [[CameraEngine engine] shutdown];

        VideoPreviewViewController *previewController = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoPreviewViewController"];
        [previewController setIndexOfVideo:(int)actionSheet.tag];
        previewController.fileUrl = fileURL;
        UINavigationController *navBar=[[CustomOrientationNavigationController alloc] initWithRootViewController:previewController];
        
        [self.navigationController presentViewController:navBar animated:NO completion:nil];
    }
    else if(buttonIndex == 1)
    {
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


//Play signle recorded videos
-(void)play:(NSInteger)tag {
    
    NSLog(@"Play. - %ld", (long)tag);
    index = tag;
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    fileURL = [NSString stringWithFormat:@"%@/video%ld.mov", path, (long)tag];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL]) {
        NSLog(@"fileURL : %@", fileURL);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Video file not available." delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles: nil];
        [alert show];
    }
    else{
        
        CustomeVideoPlayViewController *customeVideoPlayObj = [self.storyboard instantiateViewControllerWithIdentifier:@"CustomeVideoPlayViewController"];
        [customeVideoPlayObj setVideoUrl:fileURL];
        
        UINavigationController *navBar=[[CustomOrientationNavigationController alloc] initWithRootViewController:customeVideoPlayObj];
        
        [self.navigationController presentViewController:navBar animated:NO completion:nil];
    }
}


-(IBAction)stopPlaying:(id)sender {
    if (player) {
        // stop the player and close the view
        player.rate = 0;
//        [videoPreviewToPlay setHidden:YES];
    }
}

- (IBAction)videoMergeButtonPressed:(UIButton *)sender {
}
@end
