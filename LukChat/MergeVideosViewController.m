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
#import "NSString+HTML.h"
#import "Common/ConnectionHandler.h"
#import "AppDelegate.h"
#import "AFJSONRequestOperation.h"
#import "ConnectionHandler.h"
#import "AFNetworkActivityIndicatorManager.h"

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

-(void)adjustView
{
    if(IS_IPHONE_4_OR_LESS)
    {
        self.videoTitleView.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect videoTitileFrame = self.videoTitleView.frame;
        videoTitileFrame.origin.y = 326;
        self.videoTitleView.frame = videoTitileFrame;
        
        self.sendToLukiesBtn.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect btnframe = CGRectMake(0,386,320,45);
        self.sendToLukiesBtn.frame = btnframe;
    }
    else
    {
        self.sendToLukiesBtn.translatesAutoresizingMaskIntoConstraints = YES;
        CGRect btnframe = CGRectMake(0,444,320,75);
        self.sendToLukiesBtn.frame = btnframe;
    }
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
    
    [self adjustView];
    
    [self.sendToLukiesBtn setBackgroundImage:[UIImage imageNamed:@"screen5-btn-normal.png"] forState:UIControlStateNormal];
    [self.sendToLukiesBtn setBackgroundImage:[UIImage imageNamed:@"screen5-btn-selected.png"] forState:UIControlStateHighlighted];
    [self.sendToLukiesBtn setBackgroundImage:[UIImage imageNamed:@"screen5-btn-selected.png"] forState:UIControlStateSelected];

    
    [self.sendToLukiesBtn setTitle:NSLocalizedString(@"send to your LUKis",nil) forState:UIControlStateNormal];
    [self.sendToLukiesBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:kIsFromMerged];
    NSString *videoTitle =  [CommonMethods getVideoTitle];
    NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:kMyVideoToShare];
    filename = [CommonMethods localFileUrl:filename];
    
    //Insert video merge data in DB
    NSString * timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    
    NSDate *dateObj = [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]];
    
    NSMutableString *monthYearTimeStr = [[NSMutableString alloc]init];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:dateObj];
    
    NSArray *weekdays = [NSArray arrayWithObjects:@"",@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",nil];
    NSInteger day = [components day];
    NSInteger weekday = [components weekday];
    
    if(day<10)
        [monthYearTimeStr appendString:[NSString stringWithFormat:@"0%ld/",(long)day]];
    else
        [monthYearTimeStr appendString:[NSString stringWithFormat:@"%ld/",(long)day]];
    
    [monthYearTimeStr appendString:[weekdays objectAtIndex:weekday]];
    [monthYearTimeStr appendString:@"/"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    [df setDateFormat:@"MMM"];
    [monthYearTimeStr appendString:[df stringFromDate:dateObj]];
    
    [df setDateFormat:@"yy"];
    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@",[df stringFromDate:dateObj]]];
    
    [df setDateFormat:@"hh:mma"];
    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@",[[df stringFromDate:dateObj] lowercaseString]]];
    
    Chat *chatObj = [[Chat alloc] init];
    chatObj.chatText = [videoTitle stringByEncodingHTMLEntities];
    chatObj.chatTime = monthYearTimeStr;
    chatObj.mergedVideo = [[NSUserDefaults standardUserDefaults] valueForKey:kMyVideoToShare];
    //    _chatObj.chatVideo = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,self.videoShareFileName];
    
    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
    [dbObj insertCreatedVideoInfoInDB:chatObj];
    
    
    [self storevideosInDB];
    
    //Update UI
    self.videoTitleLBL.text = [videoTitle stringByDecodingHTMLEntities];
    
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
    
    if([CommonMethods isWiFiConnected])
        [self uploadVideosInBackground];
}

-(void)uploadVideosInBackground
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    long long int myPhoneNum = [[[NSUserDefaults standardUserDefaults]valueForKey:kMYPhoneNumber] longLongValue];
    
    NSString *videoTitle =  [CommonMethods getVideoTitle];
    NSMutableArray *titleWords;
    NSArray *singleVideos;
    if(videoTitle.length>0){
        titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
    }
        if(titleWords.count>0)
        singleVideos  = [DatabaseMethods getAllSingleVideos:[titleWords count]];
        else
        singleVideos  = [DatabaseMethods getAllSingleVideos:5];
        if(singleVideos.count > 0)
        {
            for(int i = 0; i<singleVideos.count ; i++){
                VideoDetail *videoDetail = [singleVideos objectAtIndex:i];
                
                
                videoDetail.videoTitle = [videoDetail.videoTitle stringByDecodingHTMLEntities];
                videoDetail.videoTitle = [videoDetail.videoTitle stringByEncodingHTMLEntities];
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setValue:kAPIKeyValue forKey:kAPIKey];
                [dict setValue:kAPISecretValue forKey:kAPISecret];
                [dict setValue:videoDetail.videoTitle forKey:kVideoTITLE];
                [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:kShareFROM];
                NSLog(@"shareVideo: %@",dict);
                
                videoDetail.mergedVideoURL = [NSString stringWithFormat:@"%@/%@", path, videoDetail.mergedVideoURL];
                if(videoDetail.mergedVideoURL.length>0)
                {
                    NSURL * localVideoURL = [NSURL fileURLWithPath:videoDetail.mergedVideoURL];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:videoDetail.mergedVideoURL]) {
                         [self makePOSTVideoShareAtPath:localVideoURL parameters:dict];
                        NSLog(@"upload single video file name  : %@", videoDetail.mergedVideoURL);
                    }
                }
            }
        }
}

-(void)storevideosInDB
{
    NSString *videoTitle = [CommonMethods getVideoTitle];
    if(videoTitle.length>0){
        NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
        if(titleWords.count>1)
        {
            [titleWords removeObject:@""];
            
            for(int i = 0; i<titleWords.count ; i++){
                videoTitle = [videoTitle stringByDecodingHTMLEntities];
                videoTitle = [videoTitle stringByEncodingHTMLEntities];
                
                NSString *videoWord = [titleWords objectAtIndex:i];
                videoWord = [videoWord stringByDecodingHTMLEntities];
                videoWord = [videoWord stringByEncodingHTMLEntities];
                
                NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
                
                if ([filename rangeOfString:@"Merged"].location != NSNotFound) {
                    Chat* chatObj = [[Chat alloc]init];
                    chatObj.chatText = videoWord;
                    chatObj.mergedVideo = filename;
                    
                    [DatabaseMethods insertSingleVideosInfoInDB:chatObj];
                }
            }
        }
    }
}



-(void)makePOSTVideoShareAtPath:(NSURL *)path parameters:(NSDictionary *)parameters {
    
    ConnectionHandler *connHandler = [[ConnectionHandler alloc] init];
    if (![connHandler hasConnectivity]) {
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"No Connectivity",nil) message:NSLocalizedString(@"Please check the Internet Connnection",nil)];
        return;
    }
    
    NSData *videoData = [NSData dataWithContentsOfURL:path];
    UIImage *imageObj = [self generateThumbImage:path];
    NSData *imageData = UIImagePNGRepresentation(imageObj);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"text/json"];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"text/html"];
    [appDelegate.httpClient setDefaultHeader:@"Content-type" value:@"application/json"];
    [appDelegate.httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableURLRequest *afRequest = [appDelegate.httpClient multipartFormRequestWithMethod:@"POST" path:kUploadSingleVideos parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:videoData name:kShareFILE fileName:@"filename.mov" mimeType:@"video/quicktime"];
                                          [formData appendPartWithFileData:imageData name:kShareThumbnailFILE fileName:@"thumbnail" mimeType:@"image/png"];
                                      }];
    
    afRequest.timeoutInterval = 60.0;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
         [DatabaseMethods deleteRecordFromDB:0];
        NSString *responseString = [operation responseString];
        // if ([path isEqualToString:kShareVideoURL]) {
        // NSLog(@"Request Successful, ShareVideo response '%@'", responseString);
        //        [self parseShareVideoResponse:responseString fromURL:kShareVideoURL ];
        NSLog(@"parseShareVideoResponse : %@ for URL:%@",responseString,kShareVideoURL);
        
        [self connHandlerClient:nil didSucceedWithResponseString:responseString forPath:kShareVideoURL];
        // }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"[AFHTTPRequestOperation Error]: %@", error);
         [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
         //delegate
         [self connHandlerClient:nil didFailWithError:error];
     }];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten,NSInteger totalBytesWritten,NSInteger totalBytesExpectedToWrite)
     {
         NSLog(@"Sent %lld of %lld bytes", (long long int)totalBytesWritten,(long long int)totalBytesExpectedToWrite);
     }];
    
    [operation start];
    
}

-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    NSLog(@"Single video uploaded ... : %@",response);
    
    if ([urlPath isEqualToString:kShareVideoURL]) {
        NSLog(@"SUCCESS: ShareVideo");
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        NSDictionary *usersdict = [responseDict objectForKey:@"share"];
        NSInteger statusInt = [[usersdict objectForKey:@"status"] integerValue]; // 1 = INSERTED, 2= UPDATED
        
        
        switch (statusInt) {
            case 1:
            {
                NSLog(@"video uplaod done...!!!");
                //                NSString *videoID = [[[usersdict valueForKey:@"video_id"] valueForKey:@"Video"] valueForKey:@"id"];
                //                [self addMyVideoLog:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kVideoDownloadURL,[usersdict objectForKey:@"filename"]]] videoId:videoID];
                //                [CommonMethods showAlertWithTitle:@"Alert" message:@"Video uploaded successful."];
                //                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
            }
            case 2:
                [CommonMethods showAlertWithTitle:[usersdict objectForKey:@"message"] message:NSLocalizedString(@"Upload iPhone supported video format with size less than 100MB",nil)];
                break;
            case 3:
                [CommonMethods showAlertWithTitle:[usersdict objectForKey:@"message"] message:NSLocalizedString(@"Make sure the phone number is registered with LukChat",nil)];
                break;
            case 4:
                [CommonMethods showAlertWithTitle:[usersdict objectForKey:@"message"] message:NSLocalizedString(@"Upload Error. Please send again",nil)];
                break;
            default:
                [CommonMethods showAlertWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription]];
                break;
        }
    }
}

-(void)connHandlerClient:(ConnectionHandler *)client didFailWithError:(NSError *)error
{
    NSString *string = [error localizedDescription];
    string = [string substringFromIndex:[string length]-3];
    //    [self stopProgressLoader];
    NSLog(@"connHandlerClient:didFailWithError = %@",string);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [player play];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [player pause];
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
    [self.sendToLukiesBtn setSelected:YES];
    //    [player replaceCurrentItemWithPlayerItem:nil];
    LukiesViewController *lukiesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LukiesViewController"];
    [self.navigationController pushViewController:lukiesVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-(UIImage *)generateThumbImage : (NSString *)filepath
//{
//    NSURL *url = [NSURL fileURLWithPath:filepath];
//
//    AVAsset *asset = [AVAsset assetWithURL:url];
//    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//    CMTime time = [asset duration];
//    time.value = 1000;
//    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
//    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
//
//    return thumbnail;
//}

//Generate thumnail image of Video
-(UIImage *)generateThumbImage :(NSURL *)url
{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.maximumSize = CGSizeMake(320.0f,320.0f);
    CMTime time = [asset duration];
    time.value = 0001;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:thumbnail];
    imageView.frame = CGRectMake(0,0,320,320);
    return imageView.image;
}



//-(void)uploadVideosInBg
//{
//
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//
//    long long int myPhoneNum = [[[NSUserDefaults standardUserDefaults]valueForKey:kMYPhoneNumber] longLongValue];
//
//    NSString *videoTitle =  [CommonMethods getVideoTitle];
//    if(videoTitle.length>0){
//        NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
//        if(titleWords.count>1)
//        {
//            [titleWords removeObject:@""];
//
//
//            for(int i = 0; i<titleWords.count ; i++){
//                videoTitle = [videoTitle stringByDecodingHTMLEntities];
//                videoTitle = [videoTitle stringByEncodingHTMLEntities];
//
//                NSString *videoWord = [titleWords objectAtIndex:i];
//                videoWord = [videoWord stringByDecodingHTMLEntities];
//                videoWord = [videoWord stringByEncodingHTMLEntities];
//                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//                [dict setValue:kAPIKeyValue forKey:kAPIKey];
//                [dict setValue:kAPISecretValue forKey:kAPISecret];
//                [dict setValue:videoWord forKey:kVideoTITLE];
//                [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:kShareFROM];
//                NSLog(@"shareVideo: %@",dict);
//
//                NSString *filename = [[NSUserDefaults standardUserDefaults]valueForKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
//
//                filename = [NSString stringWithFormat:@"%@/%@", path, filename];
//                if(filename.length>0)
//                {
//                    if ([filename rangeOfString:@"Merged"].location != NSNotFound) {
//                        NSURL * localVideoURL = [NSURL fileURLWithPath:filename];
//                        if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
//                            [self makePOSTVideoShareAtPath:localVideoURL parameters:dict];
//                            NSLog(@"upload single video file name  : %@", filename);
//                        }
//                    }
//                }
//
//            }
//        }
//    }
//}
@end
