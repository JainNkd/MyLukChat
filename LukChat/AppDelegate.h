//
//  AppDelegate.h
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPClient.h"
#import "CommonMethods.h"
#import "Constants.h"
#import "DatabaseMethods.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "LukiesViewController.h"
#import "Facebook.h"

#import <AudioToolbox/AudioToolbox.h>
#import "JCNotificationCenter.h"
#import "JCNotificationBannerPresenterSmokeStyle.h"
#import "JCNotificationBannerPresenterIOSStyle.h"
#import "JCNotificationBannerPresenterIOS7Style.h"

//#import "Facebook.h"

#define SharedAppDelegate ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate,FBSessionDelegate, FBRequestDelegate> {
    
    NSString *number;
    NSString *pinValue;
    NSString *saving;
    Facebook *facebook;
    
}
@property (readwrite, nonatomic, assign) SystemSoundID localNotificationSound;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic,strong) LukiesViewController *lukVC;
@property (nonatomic, retain)  NSString *number;
@property (nonatomic, retain)  NSString *pinValue;
@property (nonatomic, retain)  NSString *saving;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) AFHTTPClient *httpClient;

-(void)uploadFBShareVideosInBG;

@end
