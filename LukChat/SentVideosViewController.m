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
    
    [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:kIsFromRecieved];
    
    userInfoDict = [[NSMutableDictionary alloc]init];
    
    self.sentTableViewObj.estimatedRowHeight = 130;
    self.sentTableViewObj.rowHeight = UITableViewAutomaticDimension;
    
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    cnCode = [CommonMethods countryPhoneCode:countryCode];
    
    myPhoneNum = [[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] longLongValue];
    //        myPhoneNum = 491712223746;
    
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
                for(NSDictionary* datadict in dataList)
                {
                    NSDictionary *videoDict = [datadict objectForKey:@"Video"];
                    VideoDetail *videoDetailObj = [[VideoDetail alloc]initWithDict:videoDict];
                    
                    if(![DatabaseMethods checkIfHistoryVideoExists:[videoDetailObj.videoID integerValue]])
                    {
                        [DatabaseMethods insertHistoryVideoInfoInDB:videoDetailObj];
                    }
                }
                
                [self reloadHistoryData];
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
        [self createSentCellData:videoObj cell:sentCell indexPath:indexPath];
        cell = sentCell;
    }
    else
    {
        RecievedVideoTableViewCell *receivedCell = [tableView dequeueReusableCellWithIdentifier:ReceivedCellIdentifier];
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
    
    NSString *title = [videoObj.videoTitle stringByDecodingHTMLEntities];
    cell.userNameLBLObj.text = name;
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
    
    return 130;
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
                    progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,100,100)];
                else
                    progressView = [[UCZProgressView alloc]initWithFrame:CGRectMake(220,0,100,100)];
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

- (IBAction)shareButtonClickedAction:(UIButton *)sender {
    
    NSLog(@"Sharebutton clicked...%d",sender.tag);
    
    VideoDetail *video = [videoDetailsArr objectAtIndex:sender.tag];
    
    [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:kIsFromRecieved];
    [[NSUserDefaults standardUserDefaults]setValue:video.videoURL forKey:kRecievedVideoShare];
    [[NSUserDefaults standardUserDefaults]setValue:video.videoTitle forKey:kRecievedVideoShareTitle];
    
    LukiesViewController *lukiesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"LukiesViewController"];
    [self.navigationController pushViewController:lukiesVC animated:YES];
}
@end
