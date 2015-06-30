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

//#import "Facebook.h"

#define SharedAppDelegate ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate,FBSessionDelegate, FBRequestDelegate> {
    
    NSString *number;
    NSString *pinValue;
    NSString *saving;
    Facebook *facebook;
    
}

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic,strong) LukiesViewController *lukVC;
@property (nonatomic, retain)  NSString *number;
@property (nonatomic, retain)  NSString *pinValue;
@property (nonatomic, retain)  NSString *saving;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) AFHTTPClient *httpClient;

@end
