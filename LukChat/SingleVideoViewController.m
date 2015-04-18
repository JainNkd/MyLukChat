//
//  SingleVideoViewController.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 4/15/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import "SingleVideoViewController.h"
#import "Constants.h"
#import "Common/ConnectionHandler.h"
#import "Common/CommonMethods.h"
#import "VideoDetail.h"
#import "SignleVideoCell.h"

#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "UCZProgressView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SingleVideoViewController ()<ConnectionHandlerDelegate>
@property (nonatomic, strong) NSMutableDictionary *videoDownloadsInProgress;
@end

@implementation SingleVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.selectBtn.enabled = NO;
    singleVideosData = [[NSMutableArray alloc]init];
    singleVideoIndex = [[NSUserDefaults standardUserDefaults]integerForKey:@"SingleVideoIndex"];
    
    
    NSString *videoTitle =  [[NSUserDefaults standardUserDefaults] valueForKey:VIDEO_TITLE];
    
    NSMutableArray *titleWords = (NSMutableArray*)[videoTitle componentsSeparatedByString:@" "];
    if(titleWords.count>1)
        [titleWords removeObject:@""];
    
    if(titleWords.count > singleVideoIndex)
        title = [titleWords objectAtIndex:singleVideoIndex];
    
    self.wordLBL.text = title;
    
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [doubleTapGesture setNumberOfTouchesRequired:1];
    
    [self.singleVideoCollectionView addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processSingleTap:)];
    [singleTapGesture setNumberOfTapsRequired:1];
    [singleTapGesture setNumberOfTouchesRequired:1];
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
    
    [self.singleVideoCollectionView addGestureRecognizer:singleTapGesture];
    
    
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    [dict setValue:title forKey:@"key"];
    [dict setValue:[NSString stringWithFormat:@"%d",0] forKey:@"start"];
    [dict setValue:[NSString stringWithFormat:@"%d",10] forKey:@"count"];
    
    ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
    connObj.delegate = self;
    [connObj makePOSTRequestPath:kSearchSingleVideo parameters:dict];
    // Do any additional setup after loading the view.
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


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [singleVideosData count];
}

-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    SignleVideoCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    VideoDetail *videoObj = [singleVideosData objectAtIndex:indexPath.row];
    
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
            [cell.thumbnail setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoObj.thumnail]] placeholderImage:[UIImage imageNamed:@"pic-bgwith-monkey-icon.png"]
                                           success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                                               NSLog(@"Loaded successfully.....%@",[request.URL absoluteString]);// %ld", (long)[response statusCode]);
                                               
                                               NSArray *ary = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                                               NSString *filename = [ary lastObject];
                                               
                                               NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                                               //Add the file name
                                               NSData *pngData = UIImagePNGRepresentation(image);
                                               [pngData writeToFile:filePath atomically:YES];
                                               [self.singleVideoCollectionView reloadData];
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
        cell.tag = indexPath.row;
    }
    return cell;
}

//
-(void)processDoubleTap:(UITapGestureRecognizer*)gesture
{
    CGPoint pointInCollectionView = [gesture locationInView:self.singleVideoCollectionView];
    NSIndexPath *selectedIndexPath = [self.singleVideoCollectionView indexPathForItemAtPoint:pointInCollectionView];
    SignleVideoCell *selectedCell = (SignleVideoCell*)[self.singleVideoCollectionView cellForItemAtIndexPath:selectedIndexPath];
    
    if(selectedCell){
        self.selectBtn.enabled = YES;
        selectedCell.thumbnail.layer.borderWidth = 2.0f;
        selectedCell.thumbnail.layer.borderColor = [UIColor yellowColor].CGColor;
        selectedCell.thumbnail.layer.masksToBounds = YES;
        VideoDetail *videoObj = [singleVideosData objectAtIndex:selectedIndexPath.row];
        selectedVideoURL = videoObj.videoURL;
        NSLog(@"double ..%d ,%d,..%@",selectedIndexPath.row,selectedCell.tag,selectedVideoURL);
    }
    
}

-(void)processSingleTap:(UITapGestureRecognizer*)gesture
{
    CGPoint pointInCollectionView = [gesture locationInView:self.singleVideoCollectionView];
    NSIndexPath *selectedIndexPath = [self.singleVideoCollectionView indexPathForItemAtPoint:pointInCollectionView];
    SignleVideoCell *selectedCell = (SignleVideoCell*)[self.singleVideoCollectionView cellForItemAtIndexPath:selectedIndexPath];

    if(selectedCell){
        [selectedCell setSelected:NO];
        
        self.selectBtn.enabled = NO;
        VideoDetail *videoObj = [singleVideosData objectAtIndex:selectedIndexPath.row];
        AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[selectedIndexPath];
        
        if([CommonMethods fileExist:videoObj.videoURL] && !operation)
        {
            [self playMovie:[CommonMethods localFileUrl:videoObj.videoURL]];
        }
        else
        {
            //        [self setBlurView:cell.blurView flag:YES];
            if([CommonMethods reachable])
            {
                NSString *localURL = [CommonMethods localFileUrl:videoObj.videoURL];
                if(!operation){
                    
                    UCZProgressView *progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,100,100)];
                    progressView.tag = selectedIndexPath.row;
                    progressView.indeterminate = YES;
                    progressView.showsText = YES;
                    progressView.tintColor = [UIColor whiteColor];
                    
                    [selectedCell addSubview:progressView];
                    
                    
                    NSString *urlString = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,videoObj.videoURL];
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request ];
                    
                    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:localURL append:YES];
                    
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"Successfully downloaded file to %@", localURL);
                        [progressView removeFromSuperview];
                        //                [self setBlurView:cell.blurView flag:NO];
                        [self.videoDownloadsInProgress removeObjectForKey:selectedIndexPath];
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                        //                cell.downloadIcon.hidden = NO;
                        //                cell.playIcon.hidden = YES;
                    }];
                    
                    [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
                        
                        // Draw the actual chart.
                        //            dispatch_async(dispatch_get_main_queue()
                        //                           , ^(void) {
                        progressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
                        //                               [cell layoutSubviews];
                        //                           });
                        
                    }];
                    
                    (self.videoDownloadsInProgress)[selectedIndexPath] = operation;
                    [operation start];
                }
            }
            else{
                NSLog(@"No internet connectivity");
            }
        }
        NSLog(@"single  ..%d ,%d",selectedIndexPath.row,selectedCell.tag);
    }
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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //    SignleVideoCell *selectedCell = (SignleVideoCell*)[self.singleVideoCollectionView cellForItemAtIndexPath:indexPath];
    //    [selectedCell setSelected:NO];
}


-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    //    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    NSLog(@"loadAppContactsOnTable ******************");
    if ([urlPath isEqualToString:kSearchSingleVideo]) {
        NSLog(@"SUCCESS: All Data fetched");
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        
        if(error)
            [CommonMethods showAlertWithTitle:@"Error" message:[error localizedDescription]];
        else
        {
            NSArray *singleArrData = (NSArray*)responseDict;
            NSLog(@"log....%@",[singleArrData description]);
            
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

-(void)parseSingleVideoData:(NSArray*)videoData
{
    [singleVideosData removeAllObjects];
    for(NSDictionary* videosDict in videoData)
    {
        NSDictionary *videoData = [videosDict valueForKey:@"videos"];
        VideoDetail *videoDetail = [[VideoDetail alloc]initWithDict:videoData];
        [singleVideosData addObject:videoDetail];
    }
    
    [self.singleVideoCollectionView reloadData];
    
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

- (IBAction)selectButtonPressed:(UIButton *)sender {
    [[NSUserDefaults standardUserDefaults]setValue:selectedVideoURL forKey:[NSString stringWithFormat:@"VIDEO_%d_URL",singleVideoIndex]];
    [[NSUserDefaults standardUserDefaults]synchronize];
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
