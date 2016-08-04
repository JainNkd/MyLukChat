//
//  MixedVideoViewController.m
//  LukChat
//
//  Created by Naveen Dungarwal on 28/07/16.
//  Copyright © 2016 Markus Haass Mac Mini. All rights reserved.
//

#import "MixedVideoViewController.h"
#import "Constants.h"
#import "Common/ConnectionHandler.h"
#import "Common/CommonMethods.h"
#import "VideoDetail.h"
#import "MixedVideoCell.h"
#import "VideoListViewController.h"
#import "VideoPlayCell.h"
#import "AppDelegate.h"
#import "MergeVideosViewController.h"

#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MixedVideoViewController ()<ConnectionHandlerDelegate>
{
    UCZProgressView *progressView;
    BOOL isVideoPlayStart;
    int playVideoIndex;
    NSString *fileName;
}
@property (nonatomic, strong) NSMutableDictionary *videoDownloadsInProgress;

@end

@implementation MixedVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISwipeGestureRecognizer *swipe1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeSetting)];
    swipe1.direction = UISwipeGestureRecognizerDirectionRight;
    [self.settingView addGestureRecognizer:swipe1];
    
    self.navigationController.navigationBarHidden = YES;
    
    randomVideosData     = [[NSMutableArray alloc]init];
    selectedIndexPaths   = [[NSMutableArray alloc]init];
    selectedWords        = [[NSMutableArray alloc]init];
    videoTitle           = [[NSMutableString alloc]init];
    
    //Set merge button
    [self.mergeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mergeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.mergeButton setTitle:NSLocalizedString(@"send to friends", nil) forState:UIControlStateNormal];
    
    //Selction videos from selected add gesture for this
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [singleTapGesture setNumberOfTouchesRequired:1];
    
    [self.collectionView addGestureRecognizer:singleTapGesture];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    isVideoPlayStart = NO;
    playVideoIndex = 0;
    [self refreshVideoData];
    [self fetchRandomVideoFromserver];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self refreshVideoData];
}
//Refresh Video Data
-(void)refreshVideoData
{
    [randomVideosData removeAllObjects];
    [selectedIndexPaths removeAllObjects];
    [selectedWords removeAllObjects];
    
    [self.mergeButton setEnabled:NO];
    [videoTitle setString:@""];
    self.videoTitleLbl.text = @"";
    [self.collectionView reloadData];
    [self.VideoCollectionVIew reloadData];
    [self.videoDownloadsInProgress removeAllObjects];
    
}

//create Video title
-(void)createVideoTitle
{
    [self.videoDownloadsInProgress removeAllObjects];
    [videoTitle setString:@""];
    for(int i=0; i<[selectedWords count]; i++)
    {
        VideoDetail *videoDetailObj = [selectedWords objectAtIndex:i];
        [videoTitle appendString:[NSString stringWithFormat:@"%@ ",videoDetailObj.videoTitle]];
    }
    
    if(selectedWords.count>=2)
        [self.mergeButton setEnabled:YES];
    else
        [self.mergeButton setEnabled:NO];
    
    self.videoTitleLbl.text = videoTitle;
    [self.VideoCollectionVIew reloadData];
    
    if(selectedWords.count >=2)
    [self performSelector:@selector(startVideoPlay) withObject:nil afterDelay:0.50];
}
#pragma Screen Rotation Support Methods
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


#pragma Collection View all delegate methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count;
    if(collectionView.tag==1)
        count = [selectedWords count];
    else
        count = [randomVideosData count];
    return count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //Random Collectionview
    if(collectionView.tag==0){
        static NSString *cellIdentifier = @"Cell";
        
        MixedVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        
        if([selectedIndexPaths containsObject:indexPath])
            [cell setSelected:YES];
        else
            [cell setSelected:NO];
        
        if(randomVideosData.count> indexPath.row){
            
            VideoDetail *videoObj = [randomVideosData objectAtIndex:indexPath.row];
            
            cell.title.text = videoObj.videoTitle;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            __block NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:videoObj.thumnailName];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                UIImage *image = [UIImage imageWithData:pngData];
                if(image)
                    [cell.thumbnail setImage:image];
                else
                    [cell.thumbnail setImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]];
            }
            else
            {
                // using Image for thumbnails
                if([CommonMethods reachable]){
                    if(videoObj.thumnail.length>0){
                        [cell.thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoObj.thumnail]] placeholderImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]
                                                       success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                                                           NSLog(@"Loaded successfully.....%@",[request.URL absoluteString]);// %ld", (long)[response statusCode]);
                                                           
                                                           NSArray *ary = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                                                           NSString *filename = [ary lastObject];
                                                           
                                                           NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                                                           //Add the file name
                                                           NSData *pngData = UIImagePNGRepresentation(image);
                                                           if(pngData && filename.length>0){
                                                               [pngData writeToFile:filePath atomically:YES];
                                                               [self.collectionView reloadData];
                                                           }
                                                       }
                                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                                           NSLog(@"failed loading");//'%@", error);
                                                           //                                                      [self.sentTableViewObj reloadData];
                                                       }
                         ];
                    }
                    else
                    {
                        [cell.thumbnail setImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]];
                    }
                }
                else
                {
                    [cell.thumbnail setImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]];
                }
                cell.tag = indexPath.row;
            }
        }
        else{
            [cell.thumbnail setImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]];
        }
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"VideoPlayCell";
        VideoPlayCell *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if(selectedWords.count> indexPath.row){
            
            VideoDetail *videoObj = [selectedWords objectAtIndex:indexPath.row];
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            __block NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:videoObj.thumnailName];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
            {
                NSData *pngData = [NSData dataWithContentsOfFile:filePath];
                UIImage *image = [UIImage imageWithData:pngData];
                if(image)
                    [cell1.thumbnail setImage:image];
                else
                    [cell1.thumbnail setImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]];
            }
            else
            {
                // using Image for thumbnails
                if([CommonMethods reachable]){
                    if(videoObj.thumnail.length>0){
                        [cell1.thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoObj.thumnail]] placeholderImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]
                                                        success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                                                            NSLog(@"Loaded successfully.....%@",[request.URL absoluteString]);// %ld", (long)[response statusCode]);
                                                            
                                                            NSArray *ary = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                                                            NSString *filename = [ary lastObject];
                                                            
                                                            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                                                            //Add the file name
                                                            NSData *pngData = UIImagePNGRepresentation(image);
                                                            if(pngData && filename.length>0){
                                                                [pngData writeToFile:filePath atomically:YES];
                                                                [self.VideoCollectionVIew reloadData];
                                                            }
                                                        }
                                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                                            NSLog(@"failed loading");//'%@", error);
                                                            //                                                      [self.sentTableViewObj reloadData];
                                                        }
                         ];
                    }
                    else
                    {
                        [cell1.thumbnail setImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]];
                    }
                }
                else
                {
                    [cell1.thumbnail setImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]];
                }
                cell1.tag = indexPath.row;
            }
        }
        else{
            [cell1.thumbnail setImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]];
        }
        
        //Progress Indicator
        for(UIView *view in cell1.subviews)
        {
            if([view isKindOfClass:[UCZProgressView class]])
            {
                
                UCZProgressView *cellProgressView = (UCZProgressView*)view;
                [cellProgressView removeFromSuperview];
            }
        }
        
        //download and play videos
        if(randomVideosData.count> indexPath.row){
            if(cell1){
                VideoDetail *videoObj = [selectedWords objectAtIndex:indexPath.row];
                AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[indexPath];
                
                if([CommonMethods fileExist:videoObj.videoURL] && !operation)
                {
                    //                    // prepare the video asset from recorded file
                    //                    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[CommonMethods localFileUrl:videoObj.videoURL]] options:nil];
                    //                    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
                    //                    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                    //
                    //                    // prepare the layer to show the video
                    //                    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                    //                    playerLayer.frame = cell1.thumbnail.frame;
                    //                    [cell1.layer addSublayer:playerLayer];
                    //                    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                    //
                    //                    [player play];
                }
                else
                {
                    //        [self setBlurView:cell.blurView flag:YES];
                    if([CommonMethods reachable])
                    {
                        NSString *localURL = [CommonMethods localFileUrl:videoObj.videoURL];
                        if(!operation){
                            
                            UCZProgressView *progressViewObj = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,39,39)];
                            progressViewObj.tag = indexPath.row;
                            progressViewObj.indeterminate = YES;
                            progressViewObj.showsText = YES;
                            progressViewObj.tintColor = [UIColor whiteColor];
                            progressViewObj.radius = 10;
                            
                            [cell1 addSubview:progressViewObj];
                            
                            
                            NSString *urlString = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,videoObj.videoURL];
                            
                            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request ];
                            
                            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:localURL append:YES];
                            
                            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSLog(@"Successfully downloaded file to %@", localURL);
                                [progressViewObj removeFromSuperview];
                                //                [self setBlurView:cell.blurView flag:NO];
                                [self.videoDownloadsInProgress removeObjectForKey:indexPath];
                                
                                isVideoPlayStart = NO;
                                [self startVideoPlay];
                                
                                //                                VideoPlayCell *selectedCellObj = (VideoPlayCell*)[self.VideoCollectionVIew cellForItemAtIndexPath:indexPath];
                                
                                
                                //                         prepare the video asset from recorded file
                                //                                AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:localURL] options:nil];
                                //                                AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
                                //                                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                                //
                                //                                // prepare the layer to show the video
                                //                                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                                //                                playerLayer.frame = selectedCellObj.thumbnail.frame;
                                //                                [selectedCellObj.layer addSublayer:playerLayer];
                                //                                player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                                //
                                //                                [player play];
                                
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"Error: %@", error);
                                //                cell.downloadIcon.hidden = NO;
                                //                cell.playIcon.hidden = YES;
                            }];
                            
                            [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
                                
                                // Draw the actual chart.
                                //            dispatch_async(dispatch_get_main_queue()
                                //                           , ^(void) {
                                progressViewObj.progress = (float)totalBytesRead / totalBytesExpectedToRead;
                                //                               [cell layoutSubviews];
                                //                           });
                                
                            }];
                            
                            (self.videoDownloadsInProgress)[indexPath] = operation;
                            [operation start];
                        }
                    }
                    else{
                        NSLog(@"No internet connectivity");
                    }
                }
                NSLog(@"single  .selectedCell.%ld ,selectedCell %ld",(long)indexPath.row,(long)cell1.tag);
            }
        }
        
        return cell1;
    }
}

//Start Play vudeos
-(void)startVideoPlay
{
    if(selectedWords.count >= 2 && !isVideoPlayStart)
    {
        isVideoPlayStart = YES;
        NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForItem:playVideoIndex inSection:0];
        VideoPlayCell *selectedCell = (VideoPlayCell*)[self.VideoCollectionVIew cellForItemAtIndexPath:[NSIndexPath indexPathForItem:playVideoIndex inSection:0]];
        
        if(selectedWords.count> selectedIndexPath.row){
            if(selectedCell){
                VideoDetail *videoObj = [selectedWords objectAtIndex:selectedIndexPath.row];
                AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[selectedIndexPath];
                
                if([CommonMethods fileExist:videoObj.videoURL] && !operation)
                {
                    //            [self playMovie:[CommonMethods localFileUrl:videoObj.videoURL]];
                    // prepare the video asset from recorded file
                    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[CommonMethods localFileUrl:videoObj.videoURL]] options:nil];
                    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
                    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
                    
                    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemFailedToPlaying:) name:AVPlayerItemFailedToPlayToEndTimeErrorKey object:playerItem];
                    
//                    [selectedCell setSelected:YES];
                    
                    // prepare the layer to show the video
                    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                    playerLayer.frame = selectedCell.thumbnail.frame;
                    [selectedCell.layer addSublayer:playerLayer];
                    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                    
                    [player play];
                }
                else
                {
                    isVideoPlayStart = NO;
                    playVideoIndex++;
                    if(playVideoIndex>= selectedWords.count)
                        playVideoIndex = 0;
                    [self startVideoPlay];
                }
            }
        }
    }
}


-(void)itemDidFinishPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    NSLog(@"play done//////////////////////////////");
    isVideoPlayStart = NO;
    playVideoIndex++;
    if(playVideoIndex>= selectedWords.count)
        playVideoIndex = 0;
    [self startVideoPlay];
}

-(void)itemFailedToPlaying:(NSNotification *) notification {
    // Will be called when AVPlayer finishes playing playerItem
    NSLog(@"play fial //////////////////////////////");
    isVideoPlayStart = NO;
    playVideoIndex++;
    if(playVideoIndex>= selectedWords.count)
        playVideoIndex = 0;
    [self startVideoPlay];
}


#pragma server related all methods
//Fetch data from server
-(void)fetchRandomVideoFromserver
{
    [self startProgressLoader];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    //    [dict setValue:titleWord forKey:@"key"];
    [dict setValue:@"random" forKey:@"order_by"];
    [dict setValue:[NSString stringWithFormat:@"%d",0] forKey:@"start"];
    [dict setValue:[NSString stringWithFormat:@"%d",15] forKey:@"count"];
    
    ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
    connObj.delegate = self;
    [connObj makePOSTRequestPath:kSearchSingleVideo parameters:dict];
}

// Server request handler
-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    //    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
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
            //            NSLog(@"log....%@",[singleArrData description]);
            
            [self parseSingleVideoData:singleArrData];
        }
    }
}


-(void)connHandlerClient:(ConnectionHandler *)client didFailWithError:(NSError *)error
{
    NSString *string = [error localizedDescription];
    string = [string substringFromIndex:[string length]-3];
    NSLog(@"connHandlerClient:didFailWithError = %@",string);
}

//Parsing Json Response
-(void)parseSingleVideoData:(NSArray*)videoData
{
    [self stopProgressLoader];
    [randomVideosData removeAllObjects];
    for(NSDictionary* videosDict in videoData)
    {
        if([videosDict isKindOfClass:[NSDictionary class]]){
            NSDictionary *videoData = [videosDict valueForKey:@"videos"];
            VideoDetail *videoDetail = [[VideoDetail alloc]initWithDict:videoData];
            [randomVideosData addObject:videoDetail];
        }
    }
    
    [self.collectionView reloadData];
    
}


//Handle transaction between viewcontroller
- (IBAction)mergeButtonPressed:(UIButton *)sender {
    int i= 0 ;
    
    for(VideoDetail *videoData in selectedWords)
    {
        NSLog(@"Title..%@...%d",videoData.videoTitle,i);
        NSString *videoURL = videoData.videoURL;
        [[NSUserDefaults standardUserDefaults]setValue:videoData.videoURL forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",i]];
        
        if([CommonMethods fileExist:videoURL]){
            i++;
            continue;
        }
        else{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[indexPath];
            NSLog(@"videoURL....%@",videoURL);
            if([CommonMethods fileExist:videoURL] && !operation)
            {
                i++;
                continue;
            }
        }
    }
    
    if(i==[selectedWords count])
        [self mergedVideo];
    else
        [self downloadVidoes];
}

-(void)mergedVideo
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSMutableArray *videofilesArr = [[NSMutableArray alloc] init];
    
    for (int i=0; i < selectedWords.count; i++) {
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
    [[NSUserDefaults standardUserDefaults] setObject:self.videoTitleLbl.text forKey:VIDEO_TITLE];
    MergeVideosViewController *mergeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MergeVideosViewController"];
    
    [self.navigationController pushViewController:mergeVC animated:YES];
}


//Download default vidoes
-(void)downloadVidoes
{
    int i= 0 ;
    
    UCZProgressView *progressView1;
    for(VideoDetail *videoDetail in selectedWords)
    {
        NSLog(@"Title..%@...%d",videoDetail.videoTitle,i);
        NSString *videoURL = videoDetail.videoURL;
        
        if([CommonMethods fileExist:videoURL]){
            i++;
            continue;
        }
        else{
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[indexPath];
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
                    if(!progressView1){
                        progressView1 = [[UCZProgressView alloc]initWithFrame:self.view.bounds];
                        progressView1.tag = i;
                        progressView1.indeterminate = YES;
                        progressView1.showsText = YES;
                        progressView1.tintColor = [UIColor whiteColor];
                        [self.view addSubview:progressView1];
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
                                [progressView1 removeFromSuperview];
                                [self mergeButtonPressed:nil];
                            }
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"Error: %@", error);
                            if([self.videoDownloadsInProgress allKeys].count==0)
                            {
                                [progressView removeFromSuperview];
                            }
                            
                        }];
                        

                        (self.videoDownloadsInProgress)[indexPath] = operation;
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





- (IBAction)twoMonkeyButtonPressed:(UIButton *)sender {
    VideoListViewController *videoListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoListViewController"];
    [self.navigationController pushViewController:videoListVC animated:YES];
}

- (IBAction)settingButtonPressed:(UIButton *)sender {
}

#pragma  Single Tap action handler
//Single Tap handler
-(void)processSingleTap:(UITapGestureRecognizer*)gesture
{
    CGPoint pointInCollectionView = [gesture locationInView:self.collectionView];
    NSIndexPath *selectedIndexPath = [self.collectionView indexPathForItemAtPoint:pointInCollectionView];
    MixedVideoCell *selectedCell = (MixedVideoCell*)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
    
    if(randomVideosData.count> selectedIndexPath.row){
        VideoDetail *videoObj = [randomVideosData objectAtIndex:selectedIndexPath.row];
        
        if(selectedIndexPaths.count<8 || [selectedIndexPaths containsObject:selectedIndexPath]){
            if([selectedCell isSelected]){
                NSInteger index = [selectedIndexPaths indexOfObject:selectedIndexPath];
                NSLog(@"deselected index...%ld",(long)index);
                if(index<8){
                    [selectedCell setSelected:NO];
                    [selectedIndexPaths removeObject:selectedIndexPath];
                    [self.videoDownloadsInProgress removeObjectForKey:[NSIndexPath indexPathForItem:index inSection:0]];
                    [selectedWords removeObjectAtIndex:index];
                }
            }
            else{
                if(videoObj){
                    [selectedCell setSelected:YES];
                    [selectedIndexPaths addObject:selectedIndexPath];
                    [selectedWords addObject:videoObj];
                }
            }
            
            [self createVideoTitle];
        }
        else
        {
            [CommonMethods showAlertWithTitle:nil message:NSLocalizedString(@"You reached max video selection limit",nil)];
        }
    }
    
    //self.selectBtn.enabled = NO;
    
    //    if(randomVideosData.count> selectedIndexPath.row){
    //        if(selectedCell){
    //            VideoDetail *videoObj = [randomVideosData objectAtIndex:selectedIndexPath.row];
    //            AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[selectedIndexPath];
    //
    //            if([CommonMethods fileExist:videoObj.videoURL] && !operation)
    //            {
    //                //            [self playMovie:[CommonMethods localFileUrl:videoObj.videoURL]];
    //                // prepare the video asset from recorded file
    //                AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:[CommonMethods localFileUrl:videoObj.videoURL]] options:nil];
    //                AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
    //                AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    //
    //                // prepare the layer to show the video
    //                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    //                playerLayer.frame = selectedCell.thumbnail.frame;
    //                [selectedCell.layer addSublayer:playerLayer];
    //                player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    //
    //                [player play];
    //            }
    //            else
    //            {
    //                //        [self setBlurView:cell.blurView flag:YES];
    //                if([CommonMethods reachable])
    //                {
    //                    NSString *localURL = [CommonMethods localFileUrl:videoObj.videoURL];
    //                    if(!operation){
    //
    //                        UCZProgressView *progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,100,100)];
    //                        progressView.tag = selectedIndexPath.row;
    //                        progressView.indeterminate = YES;
    //                        progressView.showsText = YES;
    //                        progressView.tintColor = [UIColor whiteColor];
    //
    //                        [selectedCell addSubview:progressView];
    //
    //
    //                        NSString *urlString = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,videoObj.videoURL];
    //
    //                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    //                        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request ];
    //
    //                        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:localURL append:YES];
    //
    //                        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    //                            NSLog(@"Successfully downloaded file to %@", localURL);
    //                            [progressView removeFromSuperview];
    //                            //                [self setBlurView:cell.blurView flag:NO];
    //                            [self.videoDownloadsInProgress removeObjectForKey:selectedIndexPath];
    //
    //                            MixedVideoCell *selectedCellObj = (MixedVideoCell*)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
    //
    //
    //                            //                         prepare the video asset from recorded file
    //                            AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:localURL] options:nil];
    //                            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
    //                            AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    //
    //                            // prepare the layer to show the video
    //                            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    //                            playerLayer.frame = selectedCellObj.thumbnail.frame;
    //                            [selectedCellObj.layer addSublayer:playerLayer];
    //                            player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    //
    //                            [player play];
    //
    //                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //                            NSLog(@"Error: %@", error);
    //                            //                cell.downloadIcon.hidden = NO;
    //                            //                cell.playIcon.hidden = YES;
    //                        }];
    //
    //                        [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
    //
    //                            // Draw the actual chart.
    //                            //            dispatch_async(dispatch_get_main_queue()
    //                            //                           , ^(void) {
    //                            progressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
    //                            //                               [cell layoutSubviews];
    //                            //                           });
    //
    //                        }];
    //
    //                        (self.videoDownloadsInProgress)[selectedIndexPath] = operation;
    //                        [operation start];
    //                    }
    //                }
    //                else{
    //                    NSLog(@"No internet connectivity");
    //                }
    //            }
    //            NSLog(@"single  .selectedCell.%ld ,selectedCell %ld",(long)selectedIndexPath.row,(long)selectedCell.tag);
    //        }
    //    }
}


#pragma Loadding view
-(void)startProgressLoader
{
    progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,322)];
    progressView.indeterminate = YES;
    progressView.showsText = NO;
    progressView.backgroundColor = [UIColor clearColor];
    progressView.opaque = 0.5;
    progressView.alpha = 0.5;
    [self.collectionView addSubview:progressView];
    
}

-(void)stopProgressLoader
{
    [progressView removeFromSuperview];
}

#pragma Setting page action hendler

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


-(void)closeSetting
{
    [self closeSettingBtnAction:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end