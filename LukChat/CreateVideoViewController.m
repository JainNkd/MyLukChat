//
//  CreateVideoViewController.m
//  LukChat
//
//  Created by Naveen on 28/03/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import "CreateVideoViewController.h"
#import "DatabaseMethods.h"
#import "CreateVideoCell.h"
#import "CommonMethods.h"
#import "VideoDetail.h"
#import "LukiesViewController.h"
#import "Constants.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface CreateVideoViewController ()
{
    NSMutableArray* createdVideos;
}

@end

@implementation CreateVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
        self.createTableView.estimatedRowHeight = 280;
        self.createTableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    createdVideos = [DatabaseMethods getAllCreatedVideos];
    [self.createTableView reloadData];
    
}


//Tableview delegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [createdVideos count];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CreateVideoCell";
    
    VideoDetail *videoObj = [createdVideos objectAtIndex:indexPath.row];
    
    CreateVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
        cell = [[CreateVideoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    if(videoObj.thumbnail1)
    {
        cell.thumbnail1.image = videoObj.thumbnail1;
         cell.thumbnail2.image = videoObj.thumbnail2;
         cell.thumbnail3.image = videoObj.thumbnail3;
    }
    else {
    NSURL *videoURL = [NSURL fileURLWithPath:[CommonMethods localFileUrl:videoObj.mergedVideoURL] ];
    
//    MPMoviePlayerViewController *videoVC = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    
    //Find time duration of video
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    CMTime time = [asset duration];
    
    CGFloat videoDuration = time.value/time.timescale;
    
    CGFloat frame1 = (videoDuration*0.33)*time.timescale;
    CGFloat frame2 = (videoDuration*0.66)*time.timescale;
    CGFloat frame3 = (videoDuration*0.99)*time.timescale;
    
    cell.thumbnail1.image = [self generateThumbImage:asset timeValue:frame1];
    cell.thumbnail2.image = [self generateThumbImage:asset timeValue:frame2];
    cell.thumbnail3.image = [self generateThumbImage:asset timeValue:frame3];
        
        videoObj.thumbnail1 = cell.thumbnail1.image;
        videoObj.thumbnail2 = cell.thumbnail2.image;
        videoObj.thumbnail3 = cell.thumbnail3.image;
        
        [createdVideos replaceObjectAtIndex:indexPath.row withObject:videoObj];
//    
//    cell.thumbnail1.image = [videoVC.moviePlayer thumbnailImageAtTime:frame1 timeOption:MPMovieTimeOptionExact];
//    cell.thumbnail2.image = [videoVC.moviePlayer thumbnailImageAtTime:frame2 timeOption:MPMovieTimeOptionExact];
//    cell.thumbnail3.image = [videoVC.moviePlayer thumbnailImageAtTime:frame3 timeOption:MPMovieTimeOptionExact];
    }
    cell.videoTitle.text = videoObj.videoTitle;
    [cell.videoTitle sizeToFit];
    cell.shareButton.tag = indexPath.row;
    
//    NSDate *dateObj = [NSDate dateWithTimeIntervalSince1970:[videoObj.videoTime doubleValue]/1000];
//    
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:dateObj];
//
//    NSArray *weekdays = [NSArray arrayWithObjects:@"",@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Saturday",nil];
//    NSInteger day = [components day];
//    NSInteger weekday = [components weekday];
//    
//    cell.dayLbl.text = [NSString stringWithFormat:@"%d",day];
//    cell.dayTextLbl.text = [weekdays objectAtIndex:weekday];
//    
//    
//    NSMutableString *monthYearTimeStr = [[NSMutableString alloc]init];
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//
//    [df setDateFormat:@"MMM"];
//    [monthYearTimeStr appendString:[df stringFromDate:dateObj]];
//    
//    [df setDateFormat:@"yy"];
//    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@",[df stringFromDate:dateObj]]];
//
//    [df setDateFormat:@"HH:MM a"];
//    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@",[df stringFromDate:dateObj]]];
//    
//    cell.monthYearTimeLbl.text = monthYearTimeStr;
    
    NSArray *dateArr = [videoObj.videoTime componentsSeparatedByString:@"/"];
    cell.dayLbl.text = [dateArr objectAtIndex:0];
    cell.dayTextLbl.text = [dateArr objectAtIndex:1];
    cell.monthYearTimeLbl.text = [dateArr objectAtIndex:2];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoDetail *video = [createdVideos objectAtIndex:indexPath.row];
    [self playMovie:[CommonMethods localFileUrl:video.mergedVideoURL]];
}

-(UIImage *)generateThumbImage : (AVAsset *)asset timeValue:(CGFloat)value
{

    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    CMTime time = [asset duration];
    time.value = value;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

-(void)playMovie: (NSString *) path{

    NSURL *url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    theMovie.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
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

- (IBAction)shareButtonClickAction:(UIButton *)sender
{
    VideoDetail *video = [createdVideos objectAtIndex:sender.tag];
    
    [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:kIsFeomCreated];
    [[NSUserDefaults standardUserDefaults]setValue:video.mergedVideoURL forKey:kCreatedVideoShare];
    
    LukiesViewController *lukiesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LukiesViewController"];
    [self.navigationController pushViewController:lukiesVC animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
