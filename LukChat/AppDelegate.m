//
//  AppDelegate.m
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "AppDelegate.h"
#import "CameraEngine.h"
#import "TabBarViewController.h"
#import <AddressBook/AddressBook.h>

@implementation AppDelegate

@synthesize number,pinValue,saving;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self checkAndCreateDatabase];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    NSURL *url = [NSURL URLWithString:kServerURL];
    self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [Parse setApplicationId:@"pGx3VxVJ0hAU6TNDrNVo2LboonA5HbmakPRUclGL"
                  clientKey:@"QXf9V4NCjtz3FyQePhEUT7SFCXSfip8Oygyvy8ps"];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact
//                [self getAllContacts:phoneNumber cell:cell indexpath:indexPath];
            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }
        });
    }

    
    return YES;
}

-(void) checkAndCreateDatabase{
	// Check if the SQL database has already been saved to the users phone, if not then copy it over
	BOOL success;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
	// Create a FileManager object, we will use this to check the status
	// of the database and to copy it over if required
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	// Check if the database has already been created in the users filesystem
	success = [fileManager fileExistsAtPath:databasePath];
    
	// If the database already exists then return without doing anything
	if(success)
        return;
    
	// If not then proceed to copy the database from the application to the users filesystem
    
	// Get the path to the database in the application package
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabaseName];
    
	// Copy the database from the package to the users filesystem
	success = [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
    if(!success)
        NSLog(@"Error while copying database");
    
}

-(void)updateMyPhoneNumber {
    
    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
    
    long long int phoneNum = [dbObj getMyPhoneNumber];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",phoneNum] forKey:kMYPhoneNumber];
    
    NSInteger myUserId = [dbObj getMyUserID];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",(long)myUserId] forKey:kMYUSERID];
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
//    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    
//    __block UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
//        if (identifier != UIBackgroundTaskInvalid) {
//            [[UIApplication sharedApplication] endBackgroundTask:identifier];
//            identifier = UIBackgroundTaskInvalid;
//        }
//    }];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        for (int i=0; i < 20; i++) {
////            NSLog(@"%d", i);
//            sleep(1);
//        }
//        if (identifier != UIBackgroundTaskInvalid) {
//            [[UIApplication sharedApplication] endBackgroundTask:identifier];
//            identifier = UIBackgroundTaskInvalid;
//        }
//    });
//    
//    
//    if ([[UIApplication sharedApplication] respondsToSelector:@selector(beginReceivingRemoteControlEvents)]){
//        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    }
//}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
    if (count>0) {
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        
        NSString *userLoggedIn = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
        if([userLoggedIn isEqualToString:@"YES"])
        {
            [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"IS_NOTIFICATION"];
            UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
            navController.navigationBar.hidden = YES;
            NSLog(@"navigation...%@",[navController class]);
            
            UIStoryboard *storyBD = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            TabBarViewController *tabbar = [storyBD instantiateViewControllerWithIdentifier:@"TabBarViewController"];
            
            [navController pushViewController:tabbar animated:NO];
            
            //        [CommonMethods showAlertWithTitle:@"LUK" message:@"New Video Reciceved from LUK"];
        }
    }

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

   
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Push Notfn

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken *******");
    NSLog(@"My token is: %@", deviceToken);
    
    NSString *dToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dToken = [dToken stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    dToken = [dToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"STR: %@",dToken);
    
    [[NSUserDefaults standardUserDefaults] setValue:dToken forKey:kDEVICETOKEN];
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Error in registration. Error: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    [PFPush handlePush:userInfo];
    
    
//    if(application.applicationState != UIApplicationStateBackground)
//        [CommonMethods showAlertWithTitle:@"LUK" message:@"New Video Reciceved from LUK"];
//    NSLog(@"didReceiveRemoteNotification *************");
    
//    application.applicationIconBadgeNumber = 0;
//    NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count+1];
//    NSLog(@"userInfo: %@", userInfo);
    
//    Chat *chatObj = [Chat new];
//    chatObj.fromPhone = [[userInfo valueForKey:kNotificationFROM] longLongValue];
//    chatObj.toPhone = [[[NSUserDefaults standardUserDefaults] objectForKey:kMYPhoneNumber] longLongValue];
//    chatObj.contentType = 1;
//    chatObj.chatTime = [CommonMethods convertDatetoSting:[NSDate date]];
//    chatObj.chatVideo = [userInfo valueForKey:kNotificationFILEPATH];
//    
//    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
//    [dbObj insertChatInfoToDB:chatObj];
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {

    NSLog(@"didReceiveRemoteNotification fetchCompletionHandler **********************");
//    application.applicationIconBadgeNumber = 0;
//    NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
//    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count+1];
    NSLog(@"userInfo background: %@", userInfo);
    
    [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"IS_NOTIFICATION"];
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    navController.navigationBar.hidden = YES;
    NSLog(@"navigation...%@",[navController class]);
    
    UIStoryboard *storyBD = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    TabBarViewController *tabbar = [storyBD instantiateViewControllerWithIdentifier:@"TabBarViewController"];
    [navController pushViewController:tabbar animated:NO];
//    [CommonMethods showAlertWithTitle:@"LUK" message:@"New Video Reciceved from LUK"];
}


@end
