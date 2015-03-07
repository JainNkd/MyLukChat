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
#import "Constants.h"
#import "CommonMethods.h"

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
    NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:kMyVideoToShare];
    filename = [CommonMethods localFileUrl:filename];
    
    self.videoTitleLBL.text = videoTitle;
    
    // prepare the video asset from recorded file
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:filename] options:nil];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    
    // prepare the layer to show the video
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.mergeVideoImg.frame;
    [self.view.layer addSublayer:playerLayer];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)playMovie{
    [player seekToTime:kCMTimeZero];
    [player play];
}


-(void)itemDidFinishPlaying:(NSNotification *) notification {
    
    AVPlayer *av = [notification object];
    [av seekToTime:kCMTimeZero];
}

- (IBAction)PlayVideoButtonAction:(UIButton *)sender {
    [self.view bringSubviewToFront:sender];
    [self playMovie];
}

- (IBAction)sendToLukiesButtonPressed:(UIButton *)sender {
    
//    [player replaceCurrentItemWithPlayerItem:nil];
    [player pause];
    LukiesViewController *lukiesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LukiesViewController"];
    [self.navigationController pushViewController:lukiesVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
