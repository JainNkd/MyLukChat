//
//  SentVideosViewController.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "SentVideosViewController.h"
#import "SentVideoTableViewCell.h"
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
    
    videoDetailsArr = [DatabaseMethods getAllSentVideoContacts];
    if(videoDetailsArr.count == 0)
        [CommonMethods showAlertWithTitle:@"LUK" message:@"You not sent any video to your friends." cancelBtnTitle:nil otherBtnTitle:@"Accept" delegate:nil tag:0];
    
//Server Web service code
    
//    long long int myPhoneNum = [[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] longLongValue];
    
//    myPhoneNum = 918050636309;
    
//    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
//    [dict setValue:kAPIKeyValue forKey:kAPIKey];
//    [dict setValue:kAPISecretValue forKey:kAPISecret];
//    [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:@"phone"];
    
//    ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
//    connObj.delegate = self;
//    [connObj makePOSTRequestPath:kSentVideosURL parameters:dict];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.sentTableViewObj.estimatedRowHeight = 90.0;
//    self.sentTableViewObj.rowHeight = UITableViewAutomaticDimension;

}


-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
//    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    NSLog(@"loadAppContactsOnTable ******************");
    if ([urlPath isEqualToString:kSentVideosURL]) {
        NSLog(@"SUCCESS: All Data fetched");
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        NSDictionary *historydict = [responseDict objectForKey:@"history"];
        NSInteger status = [[historydict objectForKey:@"status"] integerValue];
        NSArray *dataList = [historydict objectForKey:@"sent"];
        
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
    static NSString *CellIdentifier = @"Cell";
    
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
    NSString *phoneNumber = [NSString stringWithFormat:@"%lld",videoObj.toContact];
    
    SentVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SentVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    VideoDetail *videoUserInfo = [userInfoDict valueForKey:phoneNumber];
    if(videoUserInfo){
        
        videoObj.fname = videoUserInfo.fname;
        videoObj.lname = videoUserInfo.lname;
        if(videoUserInfo.userProfileImage)
            videoObj.userProfileImage = videoUserInfo.userProfileImage;
        else
            videoObj.userProfileImage = [UIImage imageNamed:videoUserInfo.userImageUrl];
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
    
    if(videoObj.userProfileImage)
        [cell.userImageViewObj setImage:videoObj.userProfileImage];
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
    
    return cell;

}

//Fetch Images and user information from addressbook
-(void)getAllContacts:(NSString*)phoneNo cell:(SentVideoTableViewCell*)cell indexpath:(NSIndexPath*)indexPath{
    
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
    videoObj.userProfileImage = [UIImage imageNamed:videoObj.userImageUrl];
    
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
                NSData *contactImageData = (__bridge NSData*)ABPersonCopyImageData(person);
                
                if(contactImageData)
                    cell.userImageViewObj.image = [[UIImage alloc] initWithData:contactImageData];
                cell.userNameLBLObj.text = firstName;
                
                videoObj.fname = firstName;
                videoObj.lname = lastName;
                videoObj.userProfileImage = [[UIImage alloc] initWithData:contactImageData];
                
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
    return 85;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
    NSLog(@"merge videos...%@",videoObj.mergedVideoURL);
    

    [self playMovie:[CommonMethods localFileUrl:videoObj.mergedVideoURL]];
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
