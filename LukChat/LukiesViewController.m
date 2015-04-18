//
//  LukiesViewController.m
//  LukChat
//
//  Created by Naveen on 06/01/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import "LukiesViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ConnectionHandler.h"
#import "DatabaseMethods.h"
#import "Constants.h"
#import "CommonMethods.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AppDelegate.h"
#import "UCZProgressView.h"
#import "NSString+HTML.h"


@interface LukiesViewController ()<ConnectionHandlerDelegate>

@property (strong, nonatomic) NSMutableArray *contacts;
@property (strong, nonatomic) NSMutableArray *appContacts;
@property (strong, nonatomic) NSMutableArray *phoneContacts;

-(void)getAllContacts ;
-(void)updateApplicationContacts;
-(void)loadAppContactsOnTable;


@end

@implementation LukiesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self tableviewInitialisation];
    
    myPhoneNum = [[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] longLongValue];
    
    NSString *countryCode = [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode];
    cnCode = [CommonMethods countryPhoneCode:countryCode];
    
    if(cnCode.length == 0)
        cnCode = @"49";
    
    self.sendTolukiesBtn.enabled = NO;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadAppLukies];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self loadAppContactsOnTable];
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
                [self getAllContacts];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        [self getAllContacts];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
    
}

//Filter data
-(void)updateTableData:(NSString*)searchString
{
    filteredTableData = [[NSMutableDictionary alloc] init];
    
    for (Contact *contactObj in self.appContacts)
    {
        bool isMatch = false;
        if(searchString.length == 0)
        {
            // If our search string is empty, everything is a match
            isMatch = true;
        }
        else
        {
            NSLog(@"This is it: %@",contactObj.user_fname);
            
            // If we have a search string, check to see if it matches the food's name or description
            NSRange nameRange = [contactObj.user_fname rangeOfString:searchString options:(NSAnchoredSearch|NSCaseInsensitiveSearch)];
            NSLog(@"This is it: %@",contactObj.user_fname);
            
            if(nameRange.location != NSNotFound)
                isMatch = true;
        }
        
        
        // If we have a match...
        if(isMatch)
        {
            // Find the first letter of the food's name. This will be its gropu
            if(contactObj.user_fname.length>0){
            NSString* firstLetter = [contactObj.user_fname substringToIndex:1];
            
            NSLog(@"This is it: %@",firstLetter);
            
            // Check to see if we already have an array for this group
            NSMutableArray* arrayForLetter = (NSMutableArray*)[filteredTableData objectForKey:firstLetter];
            if(arrayForLetter == nil)
            {
                // If we don't, create one, and add it to our dictionary
                arrayForLetter = [[NSMutableArray alloc] init];
                [filteredTableData setValue:arrayForLetter forKey:firstLetter];
                NSLog(@"This is it: %@",filteredTableData);
            }
            
            // Finally, add the food to this group's array
            [arrayForLetter addObject:contactObj];
            }
        }
    }
    
    // Make a copy of our dictionary's keys, and sort them
    tableSectionTitles = [[filteredTableData allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    // Finally, refresh the table
    [self.contactTableView reloadData];
}


#pragma mark -

-(void)getAllContacts {
    if (_contacts) {
        [_contacts removeAllObjects];
        _contacts = nil;
    }
    _contacts = [[NSMutableArray alloc] init];
    
    CFErrorRef *error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    
    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
    
    for(int i = 0; i < numberOfPeople; i++) {
        
        ABRecordRef person = CFArrayGetValueAtIndex( allPeople, i );
        
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        // NSLog(@"Name:%@ %@", firstName, lastName);
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        
        NSString *phoneNumber = @"";
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); i++) {
            phoneNumber = (__bridge_transfer NSString *) ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            //            NSLog(@"phone:%@", phoneNumber);
            
            NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
            NSString *phNum = [[phoneNumber componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
            phNum = [phNum stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            Contact *contObj = [[Contact alloc] init];
            contObj.user_id = i+1;   //////// dummy
            contObj.user_fname = firstName;
            contObj.user_lname = lastName;
            contObj.user_phone = [phNum longLongValue];
            
            //changes for country code
            NSString *phoneNum = [NSString stringWithFormat:@"%lld",[phNum longLongValue]];
            
            if(phoneNum.length == 10)
                phoneNum = [NSString stringWithFormat:@"%@%@",cnCode,phoneNum];
            
            contObj.user_phone = [phoneNum longLongValue];
            
            if(contObj.user_phone>0){
                if (![dbObj checkIfContactExists:contObj.user_phone]) {
                    [dbObj insertContactInfoToDB:contObj];
                }
            }
        }
        
        [_contacts addObject:(__bridge id)(person)];
        // NSLog(@"=============================================");
        
    }
    [self loadAppContactsOnTable];
}


-(void)loadAppContactsOnTable {
    NSLog(@"loadAppContactsOnTable ******************");
    [self reloadAppLukies];
    
    //update Contact Info
    [self updateApplicationContacts];
}


-(void)updateApplicationContacts {
    NSLog(@"updateApplicationContacts ************************");
    
    //    for (int i=0; i<[self.appContacts count]; i++) {
    //
    //        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    //        [dict setValue:kAPIKeyValue forKey:kAPIKey];
    //        [dict setValue:kAPISecretValue forKey:kAPISecret];
    //
    //        Contact *contObj = [Contact new];
    //        contObj = [self.appContacts objectAtIndex:i];
    //        [dict setValue:[NSString stringWithFormat:@"%lld",contObj.user_phone] forKey:@"phone"];
    //        NSLog(@"updateApplicationContacts : %lld",contObj.user_phone);
    //
    //        ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
    //        connObj.delegate = self;
    //        [connObj makePOSTRequestPath:kGetUserInfoURL parameters:dict];
    //    }
    for (int i=0; i<[self.phoneContacts count]; i++) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:kAPIKeyValue forKey:kAPIKey];
        [dict setValue:kAPISecretValue forKey:kAPISecret];
        
        
        Contact *contObj = [Contact new];
        if(self.phoneContacts.count > i){
            contObj = [self.phoneContacts objectAtIndex:i];
            if(contObj.user_phone>0){
                [dict setValue:[NSString stringWithFormat:@"%lld",contObj.user_phone] forKey:@"phone"];
                //   NSLog(@"updateOtherContacts : %lld",contObj.user_phone);
                
                if(dict){
                ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
                connObj.delegate = self;
                [connObj makePOSTRequestPath:kGetUserInfoURL parameters:dict];
                }
            }
        }
    }
    
}


#pragma mark -

-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    if ([urlPath isEqualToString:kGetUserInfoURL]) {
        //Refresh Contacts List
        [self reloadAppLukies];
    }
    if ([urlPath isEqualToString:kShareVideoURL]) {
        NSLog(@"SUCCESS: ShareVideo");
        [self stopProgressLoader];
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        NSDictionary *usersdict = [responseDict objectForKey:@"share"];
        NSInteger statusInt = [[usersdict objectForKey:@"status"] integerValue]; // 1 = INSERTED, 2= UPDATED
        
        
        switch (statusInt) {
            case 1:
            {
                NSString *videoID = [[[usersdict valueForKey:@"video_id"] valueForKey:@"Video"] valueForKey:@"id"];
                [self addMyVideoLog:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kVideoDownloadURL,[usersdict objectForKey:@"filename"]]] videoId:videoID];
                [CommonMethods showAlertWithTitle:@"Alert" message:@"Video uploaded successful."];
                [self.navigationController popToRootViewControllerAnimated:YES];
                break;
            }
            case 2:
                [CommonMethods showAlertWithTitle:[usersdict objectForKey:@"message"] message:@"Upload iPhone supported video format with size less than 100MB"];
                break;
            case 3:
                [CommonMethods showAlertWithTitle:[usersdict objectForKey:@"message"] message:@"Make sure the phone number is registered with LukChat"];
                break;
            case 4:
                [CommonMethods showAlertWithTitle:[usersdict objectForKey:@"message"] message:@"Upload Error. Please send again"];
                break;
            default:
                [CommonMethods showAlertWithTitle:@"Error" message:[error localizedDescription]];
                break;
        }
    }
}

-(void)reloadAppLukies
{
    //LukChat Contacts
    if (self.appContacts) {
        [self.appContacts removeAllObjects];
        self.appContacts = nil;
    }
    self.appContacts = [[NSMutableArray alloc] init];
    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
    self.appContacts = [dbObj getAllLukChatContacts];
    
    //Non-Lukchat Contacts
    if (self.phoneContacts) {
        [self.phoneContacts removeAllObjects];
        self.phoneContacts = nil;
    }
    self.phoneContacts = [[NSMutableArray alloc] init];
    self.phoneContacts = [dbObj getAllOtherContacts];
    
    //Refresh Contacts List
    [self updateTableData:@""];
}

#pragma mark - Table View

//Show index bar at right side
-(void)tableviewInitialisation
{
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    //To change index bar color
    self.contactTableView.sectionIndexBackgroundColor = [UIColor whiteColor];
    self.contactTableView.sectionIndexColor = [UIColor blackColor];
    self.contactTableView.separatorColor=[UIColor clearColor];
    
    [self.contactTableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [tableSectionTitles count];;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    if (section==0) return self.appContacts.count;
    //    else    return self.phoneContacts.count;
    NSString* letter = [tableSectionTitles objectAtIndex:section];
    NSArray* arrayForLetter = (NSArray*)[filteredTableData objectForKey:letter];
    //    NSLog(@"%@",letter);
    return arrayForLetter.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    static NSString *CellIdentifier = @"Cell";
    //    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    if(cell == nil)
    //        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    //
    //    // Get Row Value
    //    Contact *contactObj = [Contact new];
    //    if (indexPath.section == 0) {
    //        contactObj = (Contact *)[self.appContacts objectAtIndex:indexPath.row];
    //    } else {
    //        contactObj = (Contact *)[self.phoneContacts objectAtIndex:indexPath.row];
    //    }
    // Display Contact Details
    //    if (contactObj) {
    //        if (contactObj.user_fname)
    //            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contactObj.user_fname,contactObj.user_lname];
    //        NSLog(@"username is %@ %@",contactObj.user_fname,contactObj.user_lname);
    //        if (contactObj.user_phone)
    //            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lld",contactObj.user_phone];
    //    }
    //    return cell;
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString* letter = [tableSectionTitles objectAtIndex:indexPath.section];
    NSArray* arrayForLetter = (NSArray*)[filteredTableData objectForKey:letter];
    Contact *contactObj = (Contact*)[arrayForLetter objectAtIndex:indexPath.row];
    
    // Display Contact Details
    if (contactObj) {
        if (contactObj.user_fname)
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contactObj.user_fname,contactObj.user_lname];
        //        NSLog(@"username is %@ %@",contactObj.user_fname,contactObj.user_lname);
        if (contactObj.user_phone)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lld",contactObj.user_phone];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString* letter = [tableSectionTitles objectAtIndex:indexPath.section];
    NSArray* arrayForLetter = (NSArray*)[filteredTableData objectForKey:letter];
    
    Contact *contactObj = (Contact *)[arrayForLetter objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",contactObj.user_phone] forKey:kCurrentCHATUserPHONE];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",(long)contactObj.user_id] forKey:kCurrentCHATUserID];
    
    self.sendTolukiesBtn.enabled = YES;
    
    //        ChatViewController *chatVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    //        [self.navigationController pushViewController:chatVC animated:YES];
    //    }
    //    else    [CommonMethods showAlertWithTitle:@"Invalid User" message:@"User not registered with LukChat"];
}

//For showing side index bar
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [tableSectionTitles indexOfObject:title];
}

//Show headders
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
//Setting Header background color in TableView
- (UIView *)tableView:(UITableView *)tableViewobj viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contactTableView.bounds.size.width, 24)];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10,2,200, 20)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.font=[UIFont boldSystemFontOfSize:14.0f];
    label.text=[tableSectionTitles objectAtIndex:section];
    [headerView addSubview:label];
    return headerView;
}

//Setting Title Index for searchDisplayController
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [tableSectionTitles objectAtIndex:section];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Share video code...

- (IBAction)sendToLukiesButtonPressed:(UIButton *)sender {
    
    NSString *urlStr;
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:kIsFromCreated])
    {
        urlStr =  [[NSUserDefaults standardUserDefaults] valueForKey:kCreatedVideoShare];
    }
    else if([[NSUserDefaults standardUserDefaults]boolForKey:kIsFromRecieved])
    {
        urlStr =  [[NSUserDefaults standardUserDefaults] valueForKey:kRecievedVideoShare];
    }
    else{
        urlStr =  [[NSUserDefaults standardUserDefaults] valueForKey:kMyVideoToShare];
    }
    
    urlStr = [CommonMethods localFileUrl:urlStr];
    if (urlStr && [[NSUserDefaults standardUserDefaults]boolForKey:kIsFromRecieved])
    {
        [self sentRecievedVideos];
    }
    else if (urlStr) {
        [self shareVideo:[NSURL fileURLWithPath:urlStr]];
    }
    else
        [CommonMethods showAlertWithTitle:@"LUK" message:@"No Video available to share." cancelBtnTitle:@"Accept"otherBtnTitle:nil delegate:nil tag:0];
}

//Share received video to friends
-(void)sentRecievedVideos
{
    NSString *videoTitle = [[NSUserDefaults standardUserDefaults] valueForKey:kRecievedVideoShareTitle];
    videoTitle = [videoTitle stringByDecodingHTMLEntities];
    NSString *videoUrl = [[NSUserDefaults standardUserDefaults]valueForKey:kRecievedVideoShare];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    [dict setValue:[videoTitle stringByEncodingHTMLEntities] forKey:kVideoTITLE];
    [dict setValue:videoUrl forKey:kShareReceivedFile];
    [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:kShareFROM];
    [dict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentCHATUserPHONE] forKey:kShareTO];
    NSLog(@"shareVideo: %@",dict);
    
    if([CommonMethods reachable])
    {
        UCZProgressView *progressView = [[UCZProgressView alloc]initWithFrame:self.view.frame];
        progressView.indeterminate = YES;
        progressView.showsText = YES;
        progressView.backgroundColor = [UIColor blackColor];
        progressView.opaque = 0.5;
        progressView.alpha = 0.5;
        [self.view addSubview:progressView];
        
    }
    ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
    connObj.delegate = self;
    [connObj makePOSTRequestPath:kShareVideoURL parameters:dict];
    
}

-(void)shareVideo:(NSURL *)videoURL {
    NSString *videoTitle;
    if([[NSUserDefaults standardUserDefaults]boolForKey:kIsFromCreated])
    {
        videoTitle = [[NSUserDefaults standardUserDefaults] valueForKey:kCreatedVideoShareTitle];
    }
    else if([[NSUserDefaults standardUserDefaults]boolForKey:kIsFromRecieved])
    {
        videoTitle = [[NSUserDefaults standardUserDefaults] valueForKey:kRecievedVideoShareTitle];
    }
    else{
        videoTitle = [[NSUserDefaults standardUserDefaults] valueForKey:VIDEO_TITLE];
    }
    
    videoTitle = [videoTitle stringByDecodingHTMLEntities];
    videoTitle = [videoTitle stringByEncodingHTMLEntities];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    [dict setValue:videoTitle forKey:kVideoTITLE];
    [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:kShareFROM];
    [dict setValue:[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentCHATUserPHONE] forKey:kShareTO];
    NSLog(@"shareVideo: %@",dict);
    
    if([CommonMethods reachable])
        [self makePOSTVideoShareAtPath:videoURL parameters:dict];
}

-(void)makePOSTVideoShareAtPath:(NSURL *)path parameters:(NSDictionary *)parameters {
    
    ConnectionHandler *connHandler = [[ConnectionHandler alloc] init];
    if (![connHandler hasConnectivity]) {
        [CommonMethods showAlertWithTitle:@"No Connectivity" message:@"Please check the Internet Connnection"];
        return;
    }
    
    UCZProgressView *progressView = [[UCZProgressView alloc]initWithFrame:self.view.frame];
    progressView.indeterminate = YES;
    progressView.showsText = YES;
    progressView.backgroundColor = [UIColor blackColor];
    progressView.opaque = 0.5;
    progressView.alpha = 0.5;
    [self.view addSubview:progressView];
    
    NSData *videoData = [NSData dataWithContentsOfURL:path];
    UIImage *imageObj = [self generateThumbImage:path];
    NSData *imageData = UIImagePNGRepresentation(imageObj);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"text/json"];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"text/html"];
    [appDelegate.httpClient setDefaultHeader:@"Content-type" value:@"application/json"];
    [appDelegate.httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSMutableURLRequest *afRequest = [appDelegate.httpClient multipartFormRequestWithMethod:@"POST" path:kShareVideoURL parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:videoData name:kShareFILE fileName:@"filename.mov" mimeType:@"video/quicktime"];
                                          [formData appendPartWithFileData:imageData name:kShareThumbnailFILE fileName:@"thumbnail" mimeType:@"image/png"];
                                      }];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [progressView removeFromSuperview];
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        NSString *responseString = [operation responseString];
        // if ([path isEqualToString:kShareVideoURL]) {
        // NSLog(@"Request Successful, ShareVideo response '%@'", responseString);
        //        [self parseShareVideoResponse:responseString fromURL:kShareVideoURL ];
        NSLog(@"parseShareVideoResponse : %@ for URL:%@",responseString,kShareVideoURL);
        
        [self connHandlerClient:nil didSucceedWithResponseString:responseString forPath:kShareVideoURL];
        // }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"[AFHTTPRequestOperation Error]: %@", error);
         [progressView removeFromSuperview];
         [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
         //delegate
         [self connHandlerClient:nil didFailWithError:error];
     }];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten,NSInteger totalBytesWritten,NSInteger totalBytesExpectedToWrite)
     {
         NSLog(@"Sent %lld of %lld bytes", (long long int)totalBytesWritten,(long long int)totalBytesExpectedToWrite);
         progressView.progress = (float)totalBytesWritten / totalBytesExpectedToWrite;
     }];
    
    [operation start];
    //    [appDelegate.httpClient enqueueHTTPRequestOperation:operation];
    
}

//Generate thumnail image of Video
-(UIImage *)generateThumbImage : (NSURL *)url
{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.maximumSize = CGSizeMake(320.0f,320.0f);
    CMTime time = [asset duration];
    time.value = 0001;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:thumbnail];
    imageView.frame = CGRectMake(0,0,320,320);
    return imageView.image;
}


-(void)startProgressLoader
{
    if (!alert) {
        alert = [[UIAlertView alloc] initWithTitle:@"" message:@"SharingVideo" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 55, 30, 30)];
        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [alert addSubview:progress];
        [progress startAnimating];
        [alert show];
    }
}

-(void)stopProgressLoader
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
    alert = nil;
}

#pragma mark - Connection



-(void)connHandlerClient:(ConnectionHandler *)client didFailWithError:(NSError *)error
{
    NSString *string = [error localizedDescription];
    string = [string substringFromIndex:[string length]-3];
    //    [self stopProgressLoader];
    NSLog(@"connHandlerClient:didFailWithError = %@",string);
}


- (void)addMyVideoLog:(NSURL *)video videoId:(NSString*)videoID{
    NSLog(@"addMyVideoLog: %@",video);
    
    
    if (!chatObj) {
        chatObj = [[Chat alloc] init];
    }
    
    NSString *videoTitle,*mergedVideoUrl;
    if([[NSUserDefaults standardUserDefaults]boolForKey:kIsFromCreated])
    {
        mergedVideoUrl = [[NSUserDefaults standardUserDefaults] valueForKey:kCreatedVideoShare];
        videoTitle = [[NSUserDefaults standardUserDefaults] valueForKey:kCreatedVideoShareTitle];
    }
    else if([[NSUserDefaults standardUserDefaults]boolForKey:kIsFromRecieved])
    {
        //        mergedVideoUrl = [[NSUserDefaults standardUserDefaults] valueForKey:kRecievedVideoShare];
        mergedVideoUrl = @"";
        videoTitle = [[NSUserDefaults standardUserDefaults] valueForKey:kRecievedVideoShareTitle];
    }
    else{
        videoTitle = [[NSUserDefaults standardUserDefaults] valueForKey:VIDEO_TITLE];
        mergedVideoUrl = [[NSUserDefaults standardUserDefaults] valueForKey:kMyVideoToShare];
    }
    
    chatObj.videoID = videoID;
    chatObj.fromPhone = myPhoneNum;
    chatObj.toPhone = [[[NSUserDefaults standardUserDefaults] valueForKey:kCurrentCHATUserPHONE] longLongValue];
    chatObj.contentType = 1;
    chatObj.chatText = videoTitle;
    chatObj.chatVideo = [video absoluteString];
    chatObj.chatTime = [CommonMethods convertDatetoSting:[NSDate date]];
    chatObj.mergedVideo = mergedVideoUrl;
    //    _chatObj.chatVideo = [NSString stringWithFormat:@"%@%@",kVideoDownloadURL,self.videoShareFileName];
    
    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
    [dbObj insertChatInfoToDB:chatObj];
    
}


@end
