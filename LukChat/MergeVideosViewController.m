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
#import "Chat.h"
#import "DatabaseMethods.h"

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
    
    //Insert video merge data in DB
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    
    NSDate *dateObj = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    
    NSMutableString *monthYearTimeStr = [[NSMutableString alloc]init];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:dateObj];
    
    NSArray *weekdays = [NSArray arrayWithObjects:@"",@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Saturday",nil];
    NSInteger day = [components day];
    NSInteger weekday = [components weekday];
    
    [monthYearTimeStr appendString:[NSString stringWithFormat:@"%ld/",(long)day]];
    [monthYearTimeStr appendString:[weekdays objectAtIndex:weekday]];
    [monthYearTimeStr appendString:@"/"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale currentLocale]];
    
    [df setDateFormat:@"MMM"];
    [monthYearTimeStr appendString:[df stringFromDate:dateObj]];
    
    [df setDateFormat:@"yy"];
    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@",[df stringFromDate:dateObj]]];
    
    [df setDateFormat:@"hh:mma"];
    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@",[df stringFromDate:dateObj]]];
    
    Chat *chatObj = [[Chat alloc] init];
    chatObj.chatText = videoTitle;
    chatObj.chatTime = monthYearTimeStr;
    chatObj.mergedVideo = [[NSUserDefaults standardUserDefaults] valueForKey:kMyVideoToShare];
    //    _chatObj.chatVideo = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,self.videoShareFileName];
    
    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
    [dbObj insertCreatedVideoInfoInDB:chatObj];
    
    
    //Update UI
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
