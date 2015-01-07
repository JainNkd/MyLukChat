//
//  MergeVideosViewController.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 03/11/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "MergeVideosViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "LukiesViewController.h"
 

@interface MergeVideosViewController ()

@end

@implementation MergeVideosViewController

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
    return NO;
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
    NSString *videoTitle =  [[NSUserDefaults standardUserDefaults] valueForKey:VIDEO_TITLE];
    NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:@"MERGE_FILE"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename])
    {
        UIImage *image = [self generateThumbImage:filename];
        
        if(image)
            [self.mergeVideoImg setImage:image];
    }
    
    self.videoTitleLBL.text = videoTitle;
    
    
    
    // Do any additional setup after loading the view.
}

-(UIImage *)generateThumbImage : (NSString *)filepath
{
    NSURL *url = [NSURL fileURLWithPath:filepath];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = 1000;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

-(void)playMovie: (NSString *) path{
    
    NSURL *url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    theMovie.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallBack:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
   
    [theMovie.moviePlayer play];
}

- (void)movieFinishedCallBack:(NSNotification *) aNotification {
    MPMoviePlayerController *mPlayer = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:mPlayer];
    [mPlayer stop];
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

- (IBAction)PlayVideoButtonAction:(UIButton *)sender {
    NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:@"MERGE_FILE"];
    [self playMovie:filename];
}

- (IBAction)sendToLukiesButtonPressed:(UIButton *)sender {
    
    LukiesViewController *lukiesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LukiesViewController"];
    [self.navigationController pushViewController:lukiesVC animated:YES];
}
@end
