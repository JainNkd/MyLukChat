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
#import "NSString+HTML.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

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
    // During startup (-viewDidLoad or in storyboard) do:
    self.createTableView.allowsMultipleSelectionDuringEditing = NO;
    
    UISwipeGestureRecognizer *swipe1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeSetting)];
    swipe1.direction = UISwipeGestureRecognizerDirectionRight;
    [self.settingView addGestureRecognizer:swipe1];
    // Do any additional setup after loading the view.
}


-(void)closeSetting
{
    [self closeSettingBtnAction:nil];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.settingView.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame= self.settingView.frame;
    self.settingView.frame = CGRectMake(self.view.frame.size.width, 0, frame.size.width, frame.size.height);
    
    [self.loginBtn setTitle:NSLocalizedString(@"login to facebook",) forState:UIControlStateNormal];
    [self.logoutBtn setTitle:NSLocalizedString(@"logout from facebook",) forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:[NSLocalizedString(@"LoginToFacebookFontSize", nil)integerValue]];
    self.logoutBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:[NSLocalizedString(@"LogoutFromFacebookFontSize", nil)integerValue]];
    
    self.settingLBL.text = NSLocalizedString(@"setting", nil);

    
    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:kIsFromCreated];
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
    cell.videoTitle.text = [videoObj.videoTitle stringByDecodingHTMLEntities];
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
    
    [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:kIsFromCreated];
    [[NSUserDefaults standardUserDefaults]setValue:video.mergedVideoURL forKey:kCreatedVideoShare];
    [[NSUserDefaults standardUserDefaults]setValue:video.videoTitle forKey:kCreatedVideoShareTitle];
    
    LukiesViewController *lukiesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LukiesViewController"];
    [self.navigationController pushViewController:lukiesVC animated:YES];

}


//Facebook Methods

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


//==================== facebook delegate methods.
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


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self confirmationDialog:indexPath.row];
    }
}

-(void)confirmationDialog:(NSInteger)index
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"LUK \n Are you sure you want to delete this LUK." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil, nil];
    
    actionSheet.tag = index;
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0)
    {
        VideoDetail *videoObj = [createdVideos objectAtIndex:popup.tag];
        [DatabaseMethods deleteCreatedVideosDB:[videoObj.videoID integerValue]];
        [createdVideos removeObjectAtIndex:popup.tag];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:popup.tag inSection:0];
        [self.createTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.createTableView reloadData];
    }
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
