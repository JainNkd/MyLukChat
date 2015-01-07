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

@interface LukiesViewController ()<ConnectionHandlerDelegate>

@property (retain, nonatomic) NSMutableArray *contacts;
@property (retain, nonatomic) NSMutableArray *appContacts;
@property (retain, nonatomic) NSMutableArray *phoneContacts;

-(void)getAllContacts ;
-(void)updateApplicationContacts;
-(void)loadAppContactsOnTable;


@end

@implementation LukiesViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    
    NSString *countryName = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    
    if([countryName isEqualToString:@"India"]){
        cnCode = [NSString stringWithFormat:@"91"];
    }
    else if([countryName isEqualToString:@"Germany"]){
        cnCode = [NSString stringWithFormat:@"49"];
    }
    
    if(!cnCode)
        cnCode = @"91";
    
    
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
    
    //  self.tblContacts.scrollsToTop = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadAppContactsOnTable];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
            NSLog(@"phone:%@", phoneNumber);
        }
        [_contacts addObject:(__bridge id)(person)];
        
        
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
        //        if([[NSString stringWithFormat:@"%lld",[phNum longLongValue]] hasPrefix:@"91"])
        //        {
        //            NSLog(@"YES:  %@ ",[NSString stringWithFormat:@"%lld",[phNum longLongValue]]);
        //        }
        
        if(phoneNum.length == 10)
            phoneNum = [NSString stringWithFormat:@"%@%@",cnCode,phoneNum];
        
        contObj.user_phone = [phoneNum longLongValue];
        
        if (![dbObj checkIfContactExists:contObj.user_phone]) {
            [dbObj insertContactInfoToDB:contObj];
        }
        // NSLog(@"=============================================");
        
    }
    
    [self loadAppContactsOnTable];
}


-(void)loadAppContactsOnTable {
    NSLog(@"loadAppContactsOnTable ******************");
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
    [self.contactTableView reloadData];
    
    //update Contact Info
    [self updateApplicationContacts];
}


-(void)updateApplicationContacts {
    NSLog(@"updateApplicationContacts ************************");
    for (int i=0; i<[self.appContacts count]; i++) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:kAPIKeyValue forKey:kAPIKey];
        [dict setValue:kAPISecretValue forKey:kAPISecret];
        
        Contact *contObj = [Contact new];
        contObj = [self.appContacts objectAtIndex:i];
        [dict setValue:[NSString stringWithFormat:@"%lld",contObj.user_phone] forKey:@"phone"];
        NSLog(@"updateApplicationContacts : %lld",contObj.user_phone);
        
        ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
        connObj.delegate = self;
        [connObj makePOSTRequestPath:kGetUserInfoURL parameters:dict];
    }
    for (int i=0; i<[self.phoneContacts count]; i++) {
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:kAPIKeyValue forKey:kAPIKey];
        [dict setValue:kAPISecretValue forKey:kAPISecret];
        
        Contact *contObj = [Contact new];
        contObj = [self.phoneContacts objectAtIndex:i];
        [dict setValue:[NSString stringWithFormat:@"%lld",contObj.user_phone] forKey:@"phone"];
        //   NSLog(@"updateOtherContacts : %lld",contObj.user_phone);
        
        ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
        connObj.delegate = self;
        [connObj makePOSTRequestPath:kGetUserInfoURL parameters:dict];
    }
    
}


#pragma mark -

-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    if ([urlPath isEqualToString:kGetUserInfoURL]) {
        //Refresh Contacts List
        
        NSLog(@"loadAppContactsOnTable ******************");
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
        [self.contactTableView reloadData];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    if (section==0) return @"LukChat Contacts";
//    else    return @"My Contacts";
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) return self.appContacts.count;
    else    return self.phoneContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    // Get Row Value
    Contact *contactObj = [Contact new];
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        contactObj = (Contact *)[self.appContacts objectAtIndex:indexPath.row];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        contactObj = (Contact *)[self.phoneContacts objectAtIndex:indexPath.row];
    }
    // Differentiate LukChat Users
//    if (contactObj.user_status == 1)
//        cell.textLabel.textColor = [UIColor greenColor];
//    else
//        cell.textLabel.textColor = [UIColor grayColor];
    // Display Contact Details
    if (contactObj) {
        if (contactObj.user_fname)
            cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",contactObj.user_fname,contactObj.user_lname];
        NSLog(@"username is %@ %@",contactObj.user_fname,contactObj.user_lname);
        if (contactObj.user_phone)
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%lld",contactObj.user_phone];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0)
    {
        Contact *contactObj = (Contact *)[self.appContacts objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",contactObj.user_phone] forKey:kCurrentCHATUserPHONE];
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",contactObj.user_id] forKey:kCurrentCHATUserID];
        
//        ChatViewController *chatVC = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
//        [self.navigationController pushViewController:chatVC animated:YES];
    }
    else    [CommonMethods showAlertWithTitle:@"Invalid User" message:@"User not registered with LukChat"];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
