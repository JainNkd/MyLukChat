//
//  SentVideosViewController.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "SentVideosViewController.h"
#import "SentVideoTableViewCell.h"
#import "RecievedVideoTableViewCell.h"
#import "VideoDetail.h"
#import "DatabaseMethods.h"
#import "ConnectionHandler.h"
#import "CommonMethods.h"
#import "Constants.h"
#import <AddressBook/AddressBook.h>

@interface SentVideosViewController ()<ConnectionHandlerDelegate>
{
    NSMutableDictionary *userInfoDict;
}
@property (nonatomic, strong) NSMutableDictionary *videoDownloadsInProgress;
@end

@implementation SentVideosViewController

@synthesize sentTableViewObj,videoDetailsArr;
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
    userInfoDict = [[NSMutableDictionary alloc]init];
    
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    cnCode = [CommonMethods countryPhoneCode:countryCode];
    
    [self.sentTableViewObj reloadData];

    //Local database
    videoDetailsArr = [DatabaseMethods getAllSentVideoContacts];
    if(videoDetailsArr.count == 0)
        [CommonMethods showAlertWithTitle:@"LUK" message:@"You not sent any video to your friends." cancelBtnTitle:nil otherBtnTitle:@"Accept" delegate:nil tag:0];
    
//Server Web service code
    
    myPhoneNum = [[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] longLongValue];
    
//    myPhoneNum = 918050636309;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:@"phone"];
    
//    ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
//    connObj.delegate = self;
//    [connObj makePOSTRequestPath:kAllHistoryURL parameters:dict];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.videoDownloadsInProgress = [NSMutableDictionary dictionary];
//    self.sentTableViewObj.estimatedRowHeight = 90.0;
//    self.sentTableViewObj.rowHeight = UITableViewAutomaticDimension;

}


-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
//    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    NSLog(@"loadAppContactsOnTable ******************");
    if ([urlPath isEqualToString:kAllHistoryURL]) {
        NSLog(@"SUCCESS: All Data fetched");
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        NSDictionary *historydict = [responseDict objectForKey:@"history"];
        NSInteger status = [[historydict objectForKey:@"status"] integerValue];
        NSArray *dataList = [historydict objectForKey:@"all"];
        
        switch (status) {
            case 0:
            {
                [videoDetailsArr removeAllObjects];
                videoDetailsArr = nil;
                videoDetailsArr = [[NSMutableArray alloc]init];
                for(NSDictionary* datadict in dataList)
                {
                    NSDictionary *videoDict = [datadict objectForKey:@"Video"];
                    VideoDetail *videoDetailObj = [[VideoDetail alloc]initWithDict:videoDict];
                    [videoDetailsArr addObject:videoDetailObj];
                }
                
                if(videoDetailsArr.count > 0)
                [self.sentTableViewObj reloadData];
                else
                    [CommonMethods showAlertWithTitle:@"LUK" message:@"You not sent any video to your friends." cancelBtnTitle:nil otherBtnTitle:@"Accept" delegate:nil tag:0];
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


//Tableview delegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videoDetailsArr count];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SentCellIdentifier = @"SentCell";
    static NSString *ReceivedCellIdentifier = @"ReceivedCell";
    
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
    
    UITableViewCell *cell;
    if(videoObj.fromContact ==  myPhoneNum){
    SentVideoTableViewCell *sentCell = [tableView dequeueReusableCellWithIdentifier:SentCellIdentifier];
    [self createSentCellData:videoObj cell:sentCell indexPath:indexPath];
        cell = sentCell;
    }
    else
    {
    RecievedVideoTableViewCell *receivedCell = [tableView dequeueReusableCellWithIdentifier:ReceivedCellIdentifier];
        [self createReceivedCellData:videoObj cell:receivedCell indexPath:indexPath];
        cell = receivedCell;
    }
    
    
//    if(videoObj.userProfileImage)
//        [cell.userImageViewObj setImage:videoObj.userProfileImage];
//    else
//    {
//        [cell.userImageViewObj setImage:[UIImage imageNamed:videoObj.userImageUrl]];
//        
//        // Request authorization to Address Book
//        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
//        
//        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
//            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
//                if (granted) {
//                    // First time access has been granted, add the contact
//                    [self getAllContacts:phoneNumber cell:cell indexpath:indexPath];
//                } else {
//                    // User denied access
//                    // Display an alert telling user the contact could not be added
//                }
//            });
//        }
//        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
//            // The user has previously given access, add the contact
//            [self getAllContacts:phoneNumber cell:cell indexpath:indexPath];
//        }
//        else {
//            // The user has previously denied access
//            // Send an alert telling user to change privacy setting in settings app
//        }
//        
//    }
    
    return cell;

}

-(void)createSentCellData:(VideoDetail*)videoObj cell:(SentVideoTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSString *phoneNumber = [NSString stringWithFormat:@"%lld",videoObj.toContact];
    VideoDetail *videoUserInfo = [userInfoDict valueForKey:phoneNumber];
    if(videoUserInfo){
        
        videoObj.fname = videoUserInfo.fname;
        videoObj.lname = videoUserInfo.lname;
        //        if(videoUserInfo.userProfileImage)
        //            videoObj.userProfileImage = videoUserInfo.userProfileImage;
        //        else
        //            videoObj.userProfileImage = [UIImage imageNamed:videoUserInfo.userImageUrl];
    }
    else
    {
        [cell.userImageViewObj setImage:[UIImage imageNamed:videoObj.userImageUrl]];
        
        // Request authorization to Address Book
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    // First time access has been granted, add the contact
                    [self getAllContacts:phoneNumber cell:cell indexpath:indexPath];
                } else {
                    // User denied access
                    // Display an alert telling user the contact could not be added
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add the contact
            [self getAllContacts:phoneNumber cell:cell indexpath:indexPath];
        }
        else {
            // The user has previously denied access
            // Send an alert telling user to change privacy setting in settings app
        }
        
    }
    
    NSString *name;
    if(videoObj.fname.length > 0)
        name = videoObj.fname;
    else if(videoObj.lname.length > 0)
        name = videoObj.lname;
    else
        name = [NSString stringWithFormat:@"%lld",videoObj.toContact];
    
    
    cell.userNameLBLObj.text = name;
    cell.videoTitleLBLObj.text = videoObj.videoTitle;
    [cell.videoTitleLBLObj sizeToFit];
    cell.videoTimeLBLObj.text = videoObj.videoTime;
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    __block NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:videoObj.thumnailName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:pngData];
        [cell.userImageViewObj setImage:image];
    }
    else
    {
        // using Image for thumbnails
        [cell.userImageViewObj setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoObj.thumnail]] placeholderImage:[UIImage imageNamed:@"luk-iphone-final-lukes-sent-list-pic-dummy.png"]
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

}

-(void)createReceivedCellData:(VideoDetail*)videoObj cell:(RecievedVideoTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    NSString *phoneNumber = [NSString stringWithFormat:@"%lld",videoObj.fromContact];
    VideoDetail *videoUserInfo = [userInfoDict valueForKey:phoneNumber];
    if(videoUserInfo){
        
        videoObj.fname = videoUserInfo.fname;
        videoObj.lname = videoUserInfo.lname;
        //        if(videoUserInfo.userProfileImage)
        //            videoObj.userProfileImage = videoUserInfo.userProfileImage;
        //        else
        //            videoObj.userProfileImage = [UIImage imageNamed:videoUserInfo.userImageUrl];
    }
    else
    {
        [cell.userImageViewObj setImage:[UIImage imageNamed:videoObj.userImageUrl]];
        
        // Request authorization to Address Book
        ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    // First time access has been granted, add the contact
                    [self getAllContacts:phoneNumber cell:cell indexpath:indexPath];
                } else {
                    // User denied access
                    // Display an alert telling user the contact could not be added
                }
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add the contact
            [self getAllContacts:phoneNumber cell:cell indexpath:indexPath];
        }
        else {
            // The user has previously denied access
            // Send an alert telling user to change privacy setting in settings app
        }
        
    }
    
    NSString *name;
    if(videoObj.fname.length > 0)
        name = videoObj.fname;
    else if(videoObj.lname.length > 0)
        name = videoObj.lname;
    else
        name = [NSString stringWithFormat:@"%lld",videoObj.fromContact];
    
    
    cell.userNameLBLObj.text = name;
    cell.videoTitleLBLObj.text = videoObj.videoTitle;
    [cell.videoTitleLBLObj sizeToFit];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    __block NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:videoObj.thumnailName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:pngData];
        [cell.userImageViewObj setImage:image];
    }
    else
    {
        // using Image for thumbnails
        [cell.userImageViewObj setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoObj.thumnail]] placeholderImage:[UIImage imageNamed:@"luk-iphone-final-lukes-sent-list-pic-dummy.png"]
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
    
}


//Fetch Images and user information from addressbook
-(void)getAllContacts:(NSString*)phoneNo cell:(UITableViewCell*)cell indexpath:(NSIndexPath*)indexPath{
    
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
//    videoObj.userProfileImage = [UIImage imageNamed:videoObj.userImageUrl];
    
    if(cnCode.length==0)
        cnCode = @"49";
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    for(int i = 0; i < numberOfPeople; i++) {
        
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        // NSLog(@"Name:%@ %@", firstName, lastName);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        NSString *phoneNumber = @"";
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            
            phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            
            NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
            phoneNumber = [[phoneNumber componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
            phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if(phoneNumber.length == 10)
                phoneNumber = [NSString stringWithFormat:@"%@%@",cnCode,phoneNumber];
            
            
            //        NSLog(@"phonemunber...%@....phoneN0....%@",phoneNumber,phoneNo);
            if([phoneNumber isEqualToString:phoneNo])
            {
//                NSData *contactImageData = (__bridge NSData*)ABPersonCopyImageData(person);
                
//                if(contactImageData)
//                    cell.userImageViewObj.image = [[UIImage alloc] initWithData:contactImageData];
                if(videoObj.fromContact == myPhoneNum)
                {
                    SentVideoTableViewCell *cell = (SentVideoTableViewCell*)cell;
                    cell.userNameLBLObj.text = firstName;
                }
                else
                {
                    RecievedVideoTableViewCell *cell = (RecievedVideoTableViewCell*)cell;
                    cell.userNameLBLObj.text = firstName;
                }
                videoObj.fname = firstName;
                videoObj.lname = lastName;
//                videoObj.userProfileImage = [[UIImage alloc] initWithData:contactImageData];
                
                (userInfoDict)[phoneNo] = videoObj;
                
                //            [videoDetailsArr replaceObjectAtIndex:index withObject:videoObj];
                break;
                break;
            }

//            NSLog(@"phone:%@", phoneNumber);
        }
    }
    
    (userInfoDict)[phoneNo] = videoObj;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
    NSLog(@"merge videos...%@",videoObj.mergedVideoURL);
    
    AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[indexPath];
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:videoObj.mergedVideoURL])
    {
        [self playMovie:[CommonMethods localFileUrl:videoObj.mergedVideoURL]];
    }
    else if([CommonMethods fileExist:videoObj.videoURL] && !operation)
    {
        [self playMovie:[CommonMethods localFileUrl:videoObj.videoURL]];
    }
    else
    {
//        [self setBlurView:cell.blurView flag:YES];
        NSString *localURL = [CommonMethods localFileUrl:videoObj.videoURL];
        if(!operation){
            
            UCZProgressView *progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,100,100)];
            progressView.tag = indexPath.row;
            progressView.indeterminate = YES;
            progressView.showsText = YES;
            [cell addSubview:progressView];
            
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,videoObj.videoURL];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request ];
            
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:localURL append:YES];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"Successfully downloaded file to %@", localURL);
                [progressView removeFromSuperview];
//                [self setBlurView:cell.blurView flag:NO];
                [self.videoDownloadsInProgress removeObjectForKey:indexPath];
                
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
            
            (self.videoDownloadsInProgress)[indexPath] = operation;
            [operation start];
        }
    }
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
