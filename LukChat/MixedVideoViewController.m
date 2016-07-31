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

#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "UCZProgressView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MixedVideoViewController ()<ConnectionHandlerDelegate>
@property (nonatomic, strong) NSMutableDictionary *videoDownloadsInProgress;

@end

@implementation MixedVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    randomVideosData     = [[NSMutableArray alloc]init];
    selectedIndexPaths   = [[NSMutableArray alloc]init];
    selectedWords        = [[NSMutableArray alloc]init];
    videoTitle           = [[NSMutableString alloc]init];
    
    [self refreshVideoData];
    
    //Selction videos from selected add gesture for this
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [singleTapGesture setNumberOfTouchesRequired:1];
    
    [self.collectionView addGestureRecognizer:singleTapGesture];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self fetchRandomVideoFromserver];
}

//Refresh Video Data
-(void)refreshVideoData
{
    [selectedIndexPaths removeAllObjects];
    [selectedWords removeAllObjects];
    [videoTitle setString:@""];
    
//    for(int i=0; i<8; i++)
//    {
//        [selectedWords addObject:@"NO"];
//    }
}

//create Video title
-(void)createVideoTitle
{
    [videoTitle setString:@""];
    for(int i=0; i<[selectedWords count]; i++)
    {
       VideoDetail *videoDetailObj = [selectedWords objectAtIndex:i];
       [videoTitle appendString:[NSString stringWithFormat:@"%@ ",videoDetailObj.videoTitle]];
    }
    self.videoTitleLbl.text = videoTitle;
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
    NSInteger count = [randomVideosData count];
    return count;
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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
        [cell.thumbnail setImage:[UIImage imageNamed:@""]];
    }
    return cell;
}





#pragma server related all methods
//Fetch data from server
-(void)fetchRandomVideoFromserver
{
    
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
                [selectedCell setSelected:NO];
                NSInteger index = [selectedIndexPaths indexOfObject:selectedIndexPath];
                NSLog(@"deselected index...%ld",(long)index);
                [selectedIndexPaths removeObject:selectedIndexPath];
                [selectedWords removeObjectAtIndex:index];
            }
            else{
                [selectedCell setSelected:YES];
                [selectedIndexPaths addObject:selectedIndexPath];
                [selectedWords addObject:videoObj];
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
- (IBAction)twoMonkeyButtonPressed:(UIButton *)sender {
    VideoListViewController *videoListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoListViewController"];
    [self.navigationController pushViewController:videoListVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
