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
#import "NSString+HTML.h"
#import "CommonMethods.h"
#import "Common/ConnectionHandler.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"

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
    
    if(![CommonMethods isWiFiConnected])
    [self uploadVideosInBackground];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)uploadVideosInBackground
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    long long int myPhoneNum = [[[NSUserDefaults standardUserDefaults]valueForKey:kMYPhoneNumber] longLongValue];
    
    if(myPhoneNum>0){
        NSArray *singleVideos = [DatabaseMethods getAllSingleVideos:5];
        if(singleVideos.count > 0)
        {
            for(int i = 0; i<singleVideos.count ; i++){
                VideoDetail *videoDetail = [singleVideos objectAtIndex:i];
                
                
                videoDetail.videoTitle = [videoDetail.videoTitle stringByDecodingHTMLEntities];
                videoDetail.videoTitle = [videoDetail.videoTitle stringByEncodingHTMLEntities];
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setValue:kAPIKeyValue forKey:kAPIKey];
                [dict setValue:kAPISecretValue forKey:kAPISecret];
                [dict setValue:videoDetail.videoTitle forKey:kVideoTITLE];
                [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:kShareFROM];
                NSLog(@"shareVideo: %@",dict);
                
                videoDetail.mergedVideoURL = [NSString stringWithFormat:@"%@/%@", path, videoDetail.mergedVideoURL];
                if(videoDetail.mergedVideoURL.length>0)
                {
                    NSURL * localVideoURL = [NSURL fileURLWithPath:videoDetail.mergedVideoURL];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:videoDetail.mergedVideoURL]) {
                         [self makePOSTVideoShareAtPath:localVideoURL parameters:dict];
                        NSLog(@"upload single video file name  : %@", videoDetail.mergedVideoURL);
                    }
                }
            }
        }
    }
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

//
-(void)makePOSTVideoShareAtPath:(NSURL *)path parameters:(NSDictionary *)parameters {
    
    
    ConnectionHandler *connHandler = [[ConnectionHandler alloc] init];
    if (![connHandler hasConnectivity]) {
        [CommonMethods showAlertWithTitle:@"No Connectivity" message:@"Please check the Internet Connnection"];
        return;
    }
    
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
    
    NSMutableURLRequest *afRequest = [appDelegate.httpClient multipartFormRequestWithMethod:@"POST" path:kUploadSingleVideos parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:videoData name:kShareFILE fileName:@"filename.mov" mimeType:@"video/quicktime"];
                                          [formData appendPartWithFileData:imageData name:kShareThumbnailFILE fileName:@"thumbnail" mimeType:@"image/png"];
                                      }];
    
    afRequest.timeoutInterval = 60.0;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        [DatabaseMethods deleteRecordFromDB:0];
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
         [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
         //delegate
         [self connHandlerClient:nil didFailWithError:error];
     }];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten,NSInteger totalBytesWritten,NSInteger totalBytesExpectedToWrite)
     {
         NSLog(@"Sent %lld of %lld bytes", (long long int)totalBytesWritten,(long long int)totalBytesExpectedToWrite);
     }];
    
    [operation start];
    
}

-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    NSLog(@"Single video uploaded ... : %@",response);
    
    if ([urlPath isEqualToString:kShareVideoURL]) {
        NSLog(@"SUCCESS: ShareVideo");
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        NSDictionary *usersdict = [responseDict objectForKey:@"share"];
        NSInteger statusInt = [[usersdict objectForKey:@"status"] integerValue]; // 1 = INSERTED, 2= UPDATED
        
        
        switch (statusInt) {
            case 1:
            {
                NSLog(@"video uplaod done...!!!");
                //                NSString *videoID = [[[usersdict valueForKey:@"video_id"] valueForKey:@"Video"] valueForKey:@"id"];
                //                [self addMyVideoLog:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kVideoDownloadURL,[usersdict objectForKey:@"filename"]]] videoId:videoID];
                //                [CommonMethods showAlertWithTitle:@"Alert" message:@"Video uploaded successful."];
                //                [self.navigationController popToRootViewControllerAnimated:YES];
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

-(void)connHandlerClient:(ConnectionHandler *)client didFailWithError:(NSError *)error
{
    NSString *string = [error localizedDescription];
    string = [string substringFromIndex:[string length]-3];
    //    [self stopProgressLoader];
    NSLog(@"connHandlerClient:didFailWithError = %@",string);
}


//Generate thumnail image of Video
-(UIImage *)generateThumbImage :(NSURL *)url
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

@end
