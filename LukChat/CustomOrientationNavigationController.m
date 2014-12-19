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

- (NSUInteger)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate {
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
