//
//  CustomOrientationNavigationController.m
//  Hollister
//
//  Created by Dhananjay on 01/08/14.
//  Copyright (c) 2014 ios Developer. All rights reserved.
//

#import "CustomOrientationNavigationController.h"

@interface CustomOrientationNavigationController ()

@end

@implementation CustomOrientationNavigationController


-(id)initWithSupportedOrientations:(UIInterfaceOrientationMask)supportedOrientations {
    self = [super init];
    
    if (self) {
        self.supportedOrientations = supportedOrientations;
    }
    
    return self;
}

-(id)initWithRootViewController:(UIViewController *)rootViewController
      withSupportedOrientations:(UIInterfaceOrientationMask)supportedOrientations {
    self = [super initWithRootViewController:rootViewController];

    if (self) {
        self.supportedOrientations = supportedOrientations;
    }
    
    return self;
}


-(NSUInteger)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

@end
