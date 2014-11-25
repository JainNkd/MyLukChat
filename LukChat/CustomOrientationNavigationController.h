//
//  CustomOrientationNavigationController.h
//  Hollister
//
//  Created by Dhananjay on 01/08/14.
//  Copyright (c) 2014 ios Developer. All rights reserved.
//

#import <UIKit/UIKit.h>

// When a NavigationController is set as root view controller or when it is set as present view controller, it is desirable to control the supported device orientations.
@interface CustomOrientationNavigationController : UINavigationController


@property (nonatomic) UIInterfaceOrientationMask supportedOrientations;


// supportedOrientations - orientations supported by this controller
-(id)initWithSupportedOrientations:(UIInterfaceOrientationMask)supportedOrientations;

// supportedOrientations - orientations supported by this controller
-(id)initWithRootViewController:(UIViewController *)rootViewController
      withSupportedOrientations:(UIInterfaceOrientationMask)supportedOrientations;
    
@end
