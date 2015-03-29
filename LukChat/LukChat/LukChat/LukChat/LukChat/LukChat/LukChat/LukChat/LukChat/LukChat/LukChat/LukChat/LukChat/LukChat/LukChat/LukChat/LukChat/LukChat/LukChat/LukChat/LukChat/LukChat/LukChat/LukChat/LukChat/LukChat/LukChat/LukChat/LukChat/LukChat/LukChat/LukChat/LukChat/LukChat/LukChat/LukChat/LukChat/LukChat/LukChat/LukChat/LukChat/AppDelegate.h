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
#import <Parse/Parse.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    NSString *number;
    NSString *pinValue;
    NSString *saving;
    
}



@property (nonatomic, retain)  NSString *number;
@property (nonatomic, retain)  NSString *pinValue;
@property (nonatomic, retain)  NSString *saving;
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, strong) AFHTTPClient *httpClient;

@end