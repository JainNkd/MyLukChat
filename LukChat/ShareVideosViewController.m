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

@interface ShareVideosViewController ()<ConnectionHandlerDelegate>
{
    NSMutableArray *receivedVideoList;
    BOOL isShowingVideo;
}

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
    receivedVideoList = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
}


-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    NSLog(@"loadAppContactsOnTable ******************");
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
                    [CommonMethods showAlertWithTitle:@"LUK" message:@"You not received any video from your friends." cancelBtnTitle:nil otherBtnTitle:@"Accept" delegate:nil tag:0];
               
                break;
            }
            case -2:
                [CommonMethods showAlertWithTitle:[historydict objectForKey:@"message"] message:@"Make sure the phone number is registered with LukChat"];
                break;
            default:
                [CommonMethods showAlertWithTitle:@"Error" message:[error localizedDescription]];
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
    static NSString *CellIdentifier = @"Cell";
    
    ShareVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[ShareVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    VideoDetail *videoDetailObj = [receivedVideoList objectAtIndex:(receivedVideoList.count-(indexPath.row+1))];
    cell.videoSenderLbl.text = [NSString stringWithFormat:@"%lld",videoDetailObj.fromContact];
    cell.videoTitleLbl.text = @"Welcome To LukChat";
    cell.shareButton.hidden = YES;
    cell.videoButton.hidden = YES;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    isShowingVideo = YES;
   VideoDetail *videoDetailObj = [receivedVideoList objectAtIndex:(receivedVideoList.count-(indexPath.row+1))];
    [self playMovie:videoDetailObj.videoURL];
    
}

-(void)playMovie: (NSString *) path{
    
    // path = [path stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    
    path = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,path];
    NSURL *url = [NSURL URLWithString:path];
    NSLog(@"video URL : %@",url);
    _theMovie = [[MPMoviePlayerViewController alloc] init];
    _theMovie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    [_theMovie.moviePlayer setContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:_theMovie];
    [_theMovie.moviePlayer play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieDidExitFullscreen:)
                                                 name:MPMoviePlayerDidExitFullscreenNotification
                                               object:nil];
    
}

- (void) movieDidExitFullscreen:(NSNotification*)notification
{
    NSLog(@"movieDidExitFullscreen");
    [self dismissMoviePlayerViewControllerAnimated];
    [_theMovie.moviePlayer stop];
    [_theMovie.moviePlayer setFullscreen:NO animated:NO];
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

@end
