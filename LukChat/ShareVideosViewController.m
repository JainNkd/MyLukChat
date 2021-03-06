//
//  ShareVideosViewController.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 09/11/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "ShareVideosViewController.h"
#import "ShareVideoTableViewCell.h"
#import "Common/ConnectionHandler.h"
#import "Constants.h"
#import "CommonMethods.h"
#import "VideoDetail.h"
#import "UCZProgressView.h"
#import "FXBlurView.h"

@interface ShareVideosViewController ()<ConnectionHandlerDelegate>
{
    NSMutableArray *receivedVideoList;
    BOOL isShowingVideo;
    UIActivityIndicatorView *loadingWheel;
}

@property (nonatomic, strong) NSMutableDictionary *videoDownloadsInProgress,*videoProgessIndicators;
@end

@implementation ShareVideosViewController
@synthesize shareVideosTableViewObj;
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!isShowingVideo){
        
        [self.shareVideosTableViewObj reloadData];
        [loadingWheel startAnimating];
        long long int myPhoneNum = [[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] longLongValue];

        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:kAPIKeyValue forKey:kAPIKey];
        [dict setValue:kAPISecretValue forKey:kAPISecret];
        [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:@"phone"];
        
        ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
        connObj.delegate = self;
        [connObj makePOSTRequestPath:kReceivedVideosURL parameters:dict];
    }
    isShowingVideo = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.videoDownloadsInProgress = [NSMutableDictionary dictionary];
    self.videoProgessIndicators = [NSMutableDictionary dictionary];
    
    receivedVideoList = [[NSMutableArray alloc]init];
    
    loadingWheel = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingWheel.center = CGPointMake(160, 240);
    [self.view addSubview:loadingWheel];
    // Do any additional setup after loading the view.
}


// -------------------------------------------------------------------------------
//	terminateAllDownloads
// -------------------------------------------------------------------------------
- (void)terminateAllDownloads
{
    // terminate all pending download connections
     [self.videoDownloadsInProgress removeAllObjects];
     [self.videoProgessIndicators removeAllObjects];
}

// -------------------------------------------------------------------------------
//	dealloc
//  If this view controller is going away, we need to cancel all outstanding downloads.
// -------------------------------------------------------------------------------
- (void)dealloc
{
    // terminate all pending download connections
    [self terminateAllDownloads];
}

// -------------------------------------------------------------------------------
//	didReceiveMemoryWarning
// -------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    [self terminateAllDownloads];
}

-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    NSLog(@"loadAppContactsOnTable ******************");
    [loadingWheel stopAnimating];
    if ([urlPath isEqualToString:kReceivedVideosURL]) {
        NSLog(@"SUCCESS: All Data fetched");
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        NSDictionary *historydict = [responseDict objectForKey:@"history"];
        NSInteger status = [[historydict objectForKey:@"status"] integerValue];
        NSArray *dataList = [historydict objectForKey:@"received"];
        
        switch (status) {
            case 0:
            {
                [receivedVideoList removeAllObjects];
                receivedVideoList = nil;
                receivedVideoList = [[NSMutableArray alloc]init];
                for(NSDictionary* datadict in dataList)
                {
                    NSDictionary *videoDict = [datadict objectForKey:@"Video"];
                    VideoDetail *videoDetailObj = [[VideoDetail alloc]initWithDict:videoDict];
                    [receivedVideoList addObject:videoDetailObj];
                }
                
                if(receivedVideoList.count > 0)
                    [self.shareVideosTableViewObj reloadData];
                else
                    [CommonMethods showAlertWithTitle:NSLocalizedString(@"LUK",nil) message:NSLocalizedString(@"You not received any video from your friends.",nil) cancelBtnTitle:nil otherBtnTitle:NSLocalizedString(@"Accept",nil) delegate:nil tag:0];
                
                break;
            }
            case -2:
                [CommonMethods showAlertWithTitle:[historydict objectForKey:@"Message"] message:NSLocalizedString(@"Make sure the phone number is registered with LukChat",nil)];
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
    NSLog(@"connHandlerClient:didFailWithError = %@",string);
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [receivedVideoList count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShareCell";
    
    VideoDetail *videoDetailObj = [receivedVideoList objectAtIndex:indexPath.row];
    
    ShareVideoTableViewCell *cell = (ShareVideoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[ShareVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    __block NSString *documentsDirectory = [paths objectAtIndex:0];
     NSString *filePath = [documentsDirectory stringByAppendingPathComponent:videoDetailObj.thumnailName];

    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:pngData];
        [cell.videoImg setImage:image];
    }
    else
    {
    // using Image for thumbnails
    [cell.videoImg setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoDetailObj.thumnail]]
                         placeholderImage:[UIImage imageNamed:@"share-videos-1st-pic.png"]
                                  success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                                      NSLog(@"Loaded successfully.....%@",[request.URL absoluteString]);// %ld", (long)[response statusCode]);
                                      
                                      NSArray *ary = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                                      NSString *filename = [ary lastObject];
                                      
                                      NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                                      //Add the file name
                                      NSData *pngData = UIImagePNGRepresentation(image);
                                      [pngData writeToFile:filePath atomically:YES];
                                  }
                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                      NSLog(@"failed loading");//'%@", error);
                                  }
     ];
    }
    
    //Set Text for video cell
    cell.videoSenderLbl.text = [NSString stringWithFormat:@"%lld",videoDetailObj.fromContact];
    cell.videoTitleLbl.text = videoDetailObj.videoTitle;
    cell.shareButton.hidden = YES;
    cell.videoButton.hidden = YES;
    
    NSLog(@"indexPath row...%ld......VIDEO..%@",(long)indexPath.row,videoDetailObj.videoURL);
    
    //Progress Indicator
    for(UIView *view in cell.blurView.subviews)
    {
        if([view isKindOfClass:[UCZProgressView class]])
        {
            UCZProgressView *progressView = (UCZProgressView*)view;
            if(progressView.tag == indexPath.row)
               progressView.hidden = NO;
            else
               progressView.hidden = YES;
        }
    }
        
    AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[indexPath];
    
    if([CommonMethods fileExist:videoDetailObj.videoURL] && !operation){
        cell.downloadIcon.hidden = YES;
        cell.playIcon.hidden = NO;
        [self setBlurView:cell.blurView flag:NO];
        
        NSLog(@"this play called 1");
       
    }
    else
    {
        if(operation)
        {
            [self setBlurView:cell.blurView flag:YES];
            cell.downloadIcon.hidden = YES;
            cell.playIcon.hidden = YES;
        }
        else{
            
        cell.downloadIcon.hidden = NO;
        cell.playIcon.hidden = YES;
        [self setBlurView:cell.blurView flag:YES];
    }
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isShowingVideo = YES;
    
    NSLog(@"indexpath row selected...%ld",(long)indexPath.row);
    VideoDetail *videoDetailObj = [receivedVideoList objectAtIndex:indexPath.row];
    ShareVideoTableViewCell *cell = (ShareVideoTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString *localURL = [CommonMethods localFileUrl:videoDetailObj.videoURL];
    
    AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[indexPath];
    
    if ([CommonMethods fileExist:videoDetailObj.videoURL] && !operation) {
        
        [self playMovie:localURL];
    }
    else
    {
        cell.playIcon.hidden = YES;
        cell.downloadIcon.hidden = YES;
        [self setBlurView:cell.blurView flag:YES];
        
        if(!operation){
    
           UCZProgressView *progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,320,320)];
            progressView.tag = indexPath.row;
            progressView.indeterminate = YES;
            progressView.showsText = YES;
            [cell.blurView addSubview:progressView];

            
        NSString *urlString = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,videoDetailObj.videoURL];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request ];
        
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:localURL append:YES];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"Successfully downloaded file to %@", localURL);
            
            

            [progressView removeFromSuperview];
            cell.downloadIcon.hidden = YES;
            cell.playIcon.hidden = NO;
            [self setBlurView:cell.blurView flag:NO];
            [self.videoDownloadsInProgress removeObjectForKey:indexPath];
    
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            cell.downloadIcon.hidden = NO;
             cell.playIcon.hidden = YES;
        }];
        
        [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
            
            // Draw the actual chart.
//            dispatch_async(dispatch_get_main_queue()
//                           , ^(void) {
                               progressView.progress = (float)totalBytesRead / totalBytesExpectedToRead;
//                               [cell layoutSubviews];
//                           });
         
        }];
        
        (self.videoDownloadsInProgress)[indexPath] = operation;
        [operation start];
        }
    }
}


-(void)playMovie: (NSString *) path{
    
    // path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    //    path = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,path];
    //    NSURL *url = [NSURL URLWithString:path];
    //    NSLog(@"video URL : %@",url);
    //    _theMovie = [[MPMoviePlayerViewController alloc] init];
    //    _theMovie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    //    [_theMovie.moviePlayer setContentURL:url];
    //    [self presentMoviePlayerViewControllerAnimated:_theMovie];
    //    [_theMovie.moviePlayer play];
    //
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(movieDidExitFullscreen:)
    //                                                 name:MPMoviePlayerDidExitFullscreenNotification
    //                                               object:nil];
    
    NSURL *url = [NSURL fileURLWithPath:path];
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    theMovie.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
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
    
}

- (void) movieDidExitFullscreen:(NSNotification*)notification
{
    NSLog(@"movieDidExitFullscreen");
    [self dismissMoviePlayerViewControllerAnimated];
    [_theMovie.moviePlayer stop];
    [_theMovie.moviePlayer setFullscreen:NO animated:NO];
}

-(void)setBlurView:(FXBlurView*)blurView flag:(BOOL)flag
{
   if(flag)
   {
        [UIView animateWithDuration:0.1 animations:^{
            blurView.blurRadius = 20;
            blurView.hidden = NO;
        }];
   }
    else
    {
        [UIView animateWithDuration:0.1 animations:^{
            blurView.blurRadius = 0;
            blurView.hidden = YES;
        }];
    }

}
#pragma mark - UIScrollViewDelegate

//// -------------------------------------------------------------------------------
////	scrollViewDidEndDragging:willDecelerate:
////  Load images for all onscreen rows when scrolling is finished.
//// -------------------------------------------------------------------------------
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (decelerate)
//    {
//        [self loadVideosForOnscreenRows];
//    }
//}
//
//// -------------------------------------------------------------------------------
////	scrollViewDidEndDecelerating:scrollView
////  When scrolling stops, proceed to load the app icons that are on screen.
//// -------------------------------------------------------------------------------
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    [self loadVideosForOnscreenRows];
//}
//
//
//-(void)loadVideosForOnscreenRows
//{
//    if (receivedVideoList.count > 0)
//    {
//        
//        NSArray *visiblePaths = [self.shareVideosTableViewObj indexPathsForVisibleRows];
//        for (NSIndexPath *indexPath in visiblePaths)
//        {
//            VideoDetail *videoDetailObj = [receivedVideoList objectAtIndex:(receivedVideoList.count-(indexPath.row+1))];
//            AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[indexPath];
//            ShareVideoTableViewCell *cell = (ShareVideoTableViewCell*)[shareVideosTableViewObj cellForRowAtIndexPath:indexPath];
//            
//            if ([CommonMethods fileExist:videoDetailObj.videoURL] && !operation)
//                // Avoid the app icon download if the app already has an icon
//            {
//                cell.proccessView.hidden = YES;
//                [cell layoutSubviews];
//            }
//            else
//            {
//                cell.proccessView.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
//                cell.proccessView.showsText = YES;
//                cell.proccessView.indeterminate = NO;
//            }
//        }
//    }
//}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




#warning using Webview images
//    cell.videoWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0,0,320,320)];
//cell.videoWebView.allowsInlineMediaPlayback=YES;
//cell.videoWebView.mediaPlaybackRequiresUserAction=NO;
//cell.videoWebView.mediaPlaybackAllowsAirPlay=YES;
////            youTubeWebView.delegate=self;
//
//cell.videoWebView.scrollView.bounces=NO;
//
////    NSString *linkObj=@"http://www.youtube.com/v/1iBIcJFRLBA";//@"http://www.youtube.com/v/6MaSTM769Gk";
//
////    cell.videoWebView.userInteractionEnabled = false;
//
//
//NSString *linkObj = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,videoDetailObj.videoURL];
//NSLog(@"linkObj1_________________%@",linkObj);
//NSString *embedHTML = @"\
//<html><head>\
//<style type=\"text/css\">\
//body {\
//background-color: transparent;color: white;}\\</style>\\</head><body style=\"margin:0\">\\<embed webkit-playsinline id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \\width=\"320\" height=\"320\"></embed>\\</body></html>";
//
//NSString *html = [NSString stringWithFormat:embedHTML, linkObj];
//[cell.videoWebView loadHTMLString:html baseURL:nil];
////    [cell.videoImg addSubview:cell.videoWebView];


#warning using AVFOUNDATION
//    NSString *linkObj = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,videoDetailObj.videoURL];
//
//    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:linkObj]];
//    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//    CMTime time = CMTimeMake(1, 1);
//    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
//    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//    CGImageRelease(imageRef);
//
//    [cell.videoImg setImage:thumbnail];
//

@end
