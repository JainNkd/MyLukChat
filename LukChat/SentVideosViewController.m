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
#import "LukiesViewController.h"
#import "NSString+HTML.h"
#import "AppDelegate.h"

@interface SentVideosViewController ()<ConnectionHandlerDelegate>
{
    NSMutableDictionary *userInfoDict;
    BOOL isShowingVideo;
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
    
    self.settingView.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect frame= self.settingView.frame;
    self.settingView.frame = CGRectMake(self.view.frame.size.width, 0, frame.size.width, frame.size.height);
    
    [self.loginBtn setTitle:NSLocalizedString(@"login to facebook",) forState:UIControlStateNormal];
    [self.logoutBtn setTitle:NSLocalizedString(@"logout from facebook",) forState:UIControlStateNormal];
    self.loginBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:[NSLocalizedString(@"LoginToFacebookFontSize", nil)integerValue]];
    self.logoutBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica Bold" size:[NSLocalizedString(@"LogoutFromFacebookFontSize", nil)integerValue]];
    self.settingLBL.text = NSLocalizedString(@"setting", nil);
    
    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:kIsFromRecieved];
    
    userInfoDict = [[NSMutableDictionary alloc]init];
    
    self.sentTableViewObj.estimatedRowHeight = 110;
    self.sentTableViewObj.rowHeight = UITableViewAutomaticDimension;
    self.sentTableViewObj.allowsMultipleSelectionDuringEditing = NO;
    
    
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    cnCode = [CommonMethods countryPhoneCode:countryCode];
    
    myPhoneNum = [[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] longLongValue];
    // myPhoneNum = 918050636309;
    
    //Local database
    [self reloadHistoryData];
    
    if(![CommonMethods reachable]){
        //        //Local database
        //        [self reloadHistoryData];
    }
    else{
        //Server Web service code
        
        if(!isShowingVideo){
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:kAPIKeyValue forKey:kAPIKey];
            [dict setValue:kAPISecretValue forKey:kAPISecret];
            [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:@"phone"];
            
            ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
            connObj.delegate = self;
            [connObj makePOSTRequestPath:kAllHistoryURL parameters:dict];
        }
        isShowingVideo = NO;
    }
}

-(void)reloadHistoryData
{
    [videoDetailsArr removeAllObjects];
    videoDetailsArr = [DatabaseMethods getAllHistoryVideos];
    [self.sentTableViewObj reloadData];
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
    
    UISwipeGestureRecognizer *swipe1 = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(closeSetting)];
    swipe1.direction = UISwipeGestureRecognizerDirectionRight;
    [self.settingView addGestureRecognizer:swipe1];
}

-(void)closeSetting
{
    [self closeSettingBtnAction:nil];
}



-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    //    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    NSLog(@"loadAppContactsOnTable ******************");
    if([urlPath isEqualToString:kDeleteVideoURL])
    {
        NSLog(@"Video Deleted Success...");
    }
        
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
                for(NSDictionary* datadict in dataList)
                {
                    NSDictionary *videoDict = [datadict objectForKey:@"Video"];
                    VideoDetail *videoDetailObj = [[VideoDetail alloc]initWithDict:videoDict];
                    
                    if(![DatabaseMethods checkIfHistoryVideoExists:[videoDetailObj.videoID integerValue]])
                    {
                        [DatabaseMethods insertHistoryVideoInfoInDB:videoDetailObj];
                    }
                    else if(videoDetailObj.toContact == -1)
                    {
                        [DatabaseMethods updateHistoryVideoInfoDB:videoDetailObj];
                    }
                }
                
                [self reloadHistoryData];
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


//-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
//    //    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
//    NSLog(@"loadAppContactsOnTable ******************");
//    if ([urlPath isEqualToString:kAllHistoryURL]) {
//        NSLog(@"SUCCESS: All Data fetched");
//
//        NSError *error;
//        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
//                                                                     options: NSJSONReadingMutableContainers
//                                                                       error: &error];
//        NSDictionary *historydict = [responseDict objectForKey:@"history"];
//        NSInteger status = [[historydict objectForKey:@"status"] integerValue];
//        NSArray *dataList = [historydict objectForKey:@"all"];
//
//        switch (status) {
//            case 0:
//            {
//                [videoDetailsArr removeAllObjects];
//                videoDetailsArr = nil;
//                videoDetailsArr = [[NSMutableArray alloc]init];
//                for(NSDictionary* datadict in dataList)
//                {
//                    NSDictionary *videoDict = [datadict objectForKey:@"Video"];
//                    VideoDetail *videoDetailObj = [[VideoDetail alloc]initWithDict:videoDict];
//                    [videoDetailsArr addObject:videoDetailObj];
//                }
//
//                if(videoDetailsArr.count > 0)
//                    [self.sentTableViewObj reloadData];
//                else
//                    [CommonMethods showAlertWithTitle:@"LUK" message:@"You not sent any video to your friends." cancelBtnTitle:nil otherBtnTitle:@"Accept" delegate:nil tag:0];
//                break;
//            }
//            case -2:
//                [CommonMethods showAlertWithTitle:[historydict objectForKey:@"message"] message:@"Make sure the phone number is registered with LukChat"];
//                break;
//            default:
//                [CommonMethods showAlertWithTitle:@"Error" message:[error localizedDescription]];
//                break;
//        }
//    }
//}

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
        sentCell.delegate = self;
        [self createSentCellData:videoObj cell:sentCell indexPath:indexPath];
        cell = sentCell;
    }
    else
    {
        RecievedVideoTableViewCell *receivedCell = [tableView dequeueReusableCellWithIdentifier:ReceivedCellIdentifier];
        receivedCell.delegate = self;
        [self createReceivedCellData:videoObj cell:receivedCell indexPath:indexPath];
        cell = receivedCell;
    }
    
    //Progress Indicator
    for(UIView *view in cell.subviews)
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
    videoObj.mergedVideoURL = [DatabaseMethods getVideoLocalURL:videoObj.videoID];
    
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
    
    cell.postedOnFbLBL.hidden = YES;
    cell.fbImage.hidden = YES;
    cell.userNameLBLObj.hidden = NO;
    
    NSString *name;
    if(videoObj.toContact == -1){
        //        name = @"posted on FACEBOOK";
        name = @"";
        cell.postedOnFbLBL.hidden = NO;
        cell.fbImage.hidden = NO;
        cell.userNameLBLObj.hidden = YES;
    }
    else if(videoObj.fname.length > 0)
        name = videoObj.fname;
    else if(videoObj.lname.length > 0)
        name = videoObj.lname;
        else{
        name = [NSString stringWithFormat:@"%lld",videoObj.toContact];
    }
    
    cell.userNameLBLObj.text = name;
    NSString *title = [videoObj.videoTitle stringByDecodingHTMLEntities];
    cell.videoTitleLBLObj.text = title;
    [cell.videoTitleLBLObj sizeToFit];
    
    NSDate *dateObj = [NSDate dateWithTimeIntervalSince1970:[videoObj.videoTime doubleValue]];
    
    NSMutableString *monthYearTimeStr = [[NSMutableString alloc]init];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:dateObj];
    
    NSArray *weekdays = [NSArray arrayWithObjects:@"",@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",nil];
    NSInteger day = [components day];
    NSInteger weekday = [components weekday];
    
    if(day<10)
        cell.dayLBL.text = [NSString stringWithFormat:@"0%ld",(long)day];
    else
        cell.dayLBL.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    [monthYearTimeStr appendString:[weekdays objectAtIndex:weekday]];
    [monthYearTimeStr appendString:@","];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    [df setDateFormat:@"hh:mma"];
    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@",[[df stringFromDate:dateObj] lowercaseString]]];
    cell.dayTimeLBL.text = monthYearTimeStr;
    [monthYearTimeStr setString:@""];
    
    [df setDateFormat:@"MMM"];
    [monthYearTimeStr appendString:[df stringFromDate:dateObj]];
    
    [df setDateFormat:@"yy"];
    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@,",[df stringFromDate:dateObj]]];
    cell.monthYearLBL.text = monthYearTimeStr;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    __block NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:videoObj.thumnailName];
    
     if((videoObj.thumnailName.length == 0) && (videoObj.toContact == -1))
    {
        
        if(videoObj.mergedVideoURL.length>0){
            NSURL *url = [NSURL fileURLWithPath:[CommonMethods localFileUrl:videoObj.mergedVideoURL]];
            UIImage *image =  [SharedAppDelegate generateThumbImage:url];
            [cell.userImageViewObj setImage:image];
        }
    }
    else if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:pngData];
        if(image)
            [cell.userImageViewObj setImage:image];
        else
            [cell.userImageViewObj setImage:[UIImage imageNamed:videoObj.userImageUrl]];
    }
    else
    {
        // using Image for thumbnails
        if([CommonMethods reachable]){
            [cell.userImageViewObj setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoObj.thumnail]] placeholderImage:[UIImage imageNamed:@"luk-iphone-final-lukes-sent-list-pic-dummy.png"]
                                                  success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                                                      NSLog(@"Loaded successfully.....%@",[request.URL absoluteString]);// %ld", (long)[response statusCode]);
                                                      
                                                      NSArray *ary = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                                                      NSString *filename = [ary lastObject];
                                                      
                                                      NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                                                      //Add the file name
                                                      NSData *pngData = UIImagePNGRepresentation(image);
                                                      [pngData writeToFile:filePath atomically:YES];
                                                      [self.sentTableViewObj reloadData];
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                                      NSLog(@"failed loading");//'%@", error);
                                                      [self.sentTableViewObj reloadData];
                                                  }
             ];
        }
        else
        {
            [cell.userImageViewObj setImage:[UIImage imageNamed:videoObj.userImageUrl]];
        }
    }
    
}

-(void)createReceivedCellData:(VideoDetail*)videoObj cell:(RecievedVideoTableViewCell*)cell indexPath:(NSIndexPath*)indexPath
{
    
    cell.shareButton.tag = indexPath.row;
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
    NSString *title = [videoObj.videoTitle stringByDecodingHTMLEntities];
    cell.videoTitleLBLObj.text = title;
    [cell.videoTitleLBLObj sizeToFit];
    
    NSDate *dateObj = [NSDate dateWithTimeIntervalSince1970:[videoObj.videoTime doubleValue]];
    
    NSMutableString *monthYearTimeStr = [[NSMutableString alloc]init];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday fromDate:dateObj];
    
    NSArray *weekdays = [NSArray arrayWithObjects:@"",@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",nil];
    NSInteger day = [components day];
    NSInteger weekday = [components weekday];
    
    if(day < 10)
        cell.dayLBL.text = [NSString stringWithFormat:@"0%ld",(long)day];
    else
        cell.dayLBL.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    [monthYearTimeStr appendString:[weekdays objectAtIndex:weekday]];
    [monthYearTimeStr appendString:@","];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
    
    [df setDateFormat:@"hh:mma"];
    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@",[[df stringFromDate:dateObj] lowercaseString]]];
    cell.dayTimeLBL.text = monthYearTimeStr;
    [monthYearTimeStr setString:@""];
    
    [df setDateFormat:@"MMM"];
    [monthYearTimeStr appendString:[df stringFromDate:dateObj]];
    
    [df setDateFormat:@"yy"];
    [monthYearTimeStr appendString:[NSString stringWithFormat:@" %@,",[df stringFromDate:dateObj]]];
    cell.monthYearLBL.text = monthYearTimeStr;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    __block NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:videoObj.thumnailName];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSData *pngData = [NSData dataWithContentsOfFile:filePath];
        UIImage *image = [UIImage imageWithData:pngData];
        if(image)
            [cell.userImageViewObj setImage:image];
        else
            [cell.userImageViewObj setImage:[UIImage imageNamed:videoObj.userImageUrl]];
    }
    else
    {
        // using Image for thumbnails
        if([CommonMethods reachable]){
            [cell.userImageViewObj setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:videoObj.thumnail]] placeholderImage:[UIImage imageNamed:@"luk-iphone-final-lukes-sent-list-pic-dummy.png"]
                                                  success:^(NSURLRequest *request , NSHTTPURLResponse *response , UIImage *image ){
                                                      NSLog(@"Loaded successfully.....%@",[request.URL absoluteString]);// %ld", (long)[response statusCode]);
                                                      
                                                      NSArray *ary = [[request.URL absoluteString] componentsSeparatedByString:@"/"];
                                                      NSString *filename = [ary lastObject];
                                                      
                                                      NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
                                                      //Add the file name
                                                      NSData *pngData = UIImagePNGRepresentation(image);
                                                      [pngData writeToFile:filePath atomically:YES];
                                                      [self.sentTableViewObj reloadData];
                                                  }
                                                  failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                                      NSLog(@"failed loading");//'%@", error);
                                                      [self.sentTableViewObj reloadData];
                                                  }
             ];
        }
        else
        {
            [cell.userImageViewObj setImage:[UIImage imageNamed:videoObj.userImageUrl]];
        }
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
    
    return 110;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    isShowingVideo = YES;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
    NSLog(@"merge videos...%@",videoObj.mergedVideoURL);
    videoObj.mergedVideoURL = [DatabaseMethods getVideoLocalURL:videoObj.videoID];
    
    AFHTTPRequestOperation *operation = (self.videoDownloadsInProgress)[indexPath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:[CommonMethods localFileUrl:videoObj.mergedVideoURL]] && videoObj.mergedVideoURL.length>0)
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
        if([CommonMethods reachable])
        {
            NSString *localURL = [CommonMethods localFileUrl:videoObj.videoURL];
            if(!operation){
                
                UCZProgressView *progressView;
                if(videoObj.toContact == myPhoneNum)
                    progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,80,80)];
                else
                    progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(240,0,80,80)];
                progressView.tag = indexPath.row;
                progressView.indeterminate = YES;
                progressView.showsText = YES;
                progressView.tintColor = [UIColor whiteColor];
                
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
        else{
            NSLog(@"No internet connectivity");
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


- (IBAction)shareButtonClickedAction:(UIButton *)sender {
    
    NSLog(@"Sharebutton clicked...%ld",(long)sender.tag);
    
    VideoDetail *video = [videoDetailsArr objectAtIndex:sender.tag];
    
    [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:kIsFromRecieved];
    [[NSUserDefaults standardUserDefaults]setValue:video.videoURL forKey:kRecievedVideoShare];
    [[NSUserDefaults standardUserDefaults]setValue:video.videoTitle forKey:kRecievedVideoShareTitle];
    
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
    return NO;
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
        VideoDetail *videoObj = [videoDetailsArr objectAtIndex:popup.tag];
        [DatabaseMethods deleteHistoryVideosDB:[videoObj.videoID integerValue]];
        [videoDetailsArr removeObjectAtIndex:popup.tag];
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:popup.tag inSection:0];
        [self.sentTableViewObj deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                     withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self.sentTableViewObj reloadData];
    }
}

#pragma mark Swipe Delegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    
    swipeSettings.transition = MGSwipeTransitionBorder;
    expansionSettings.buttonIndex = 0;
    
    __weak SentVideosViewController * me = self;
    
    if (direction == MGSwipeDirectionLeftToRight) {
        
    }
    else {
        
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 15;
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"Delete" backgroundColor:[UIColor colorWithRed:1.0 green:59/255.0 blue:50/255.0 alpha:1.0] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            NSIndexPath * indexPath = [me.sentTableViewObj indexPathForCell:sender];
            [me deleteMail:indexPath];
            return NO; //don't autohide to improve delete animation
        }];
        
        
        return @[trash];
    }
    
    return nil;
    
}

-(void) swipeTableCell:(MGSwipeTableCell*) cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive
{
    NSString * str;
    switch (state) {
        case MGSwipeStateNone: str = @"None"; break;
        case MGSwipeStateSwippingLeftToRight: str = @"SwippingLeftToRight"; break;
        case MGSwipeStateSwippingRightToLeft: str = @"SwippingRightToLeft"; break;
        case MGSwipeStateExpandingLeftToRight: str = @"ExpandingLeftToRight"; break;
        case MGSwipeStateExpandingRightToLeft: str = @"ExpandingRightToLeft"; break;
    }
    NSLog(@"Swipe state: %@ ::: Gesture: %@", str, gestureIsActive ? @"Active" : @"Ended");
}

-(void) deleteMail:(NSIndexPath *) indexPath
{
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
    [DatabaseMethods deleteHistoryVideosDB:[videoObj.videoID integerValue]];
    [videoDetailsArr removeObjectAtIndex:indexPath.row];
    [self.sentTableViewObj deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationFade];
    [self deleteVideoFromServer:videoObj];
}


-(void)deleteVideoFromServer:(VideoDetail*)videoDetails
{
    NSString *type;
    if(myPhoneNum == videoDetails.fromContact)
        type = @"sender";
    else
        type = @"receiver";
    if(videoDetails.videoID.length>0){
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:@"phone"];
    [dict setValue:type forKey:@"type"];
    [dict setValue:videoDetails.videoID forKey:@"video_id"];
    NSLog(@"delete dict....%@",dict);
    
    ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
    connObj.delegate = self;
    [connObj makePOSTRequestPath:kDeleteVideoURL parameters:dict];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
