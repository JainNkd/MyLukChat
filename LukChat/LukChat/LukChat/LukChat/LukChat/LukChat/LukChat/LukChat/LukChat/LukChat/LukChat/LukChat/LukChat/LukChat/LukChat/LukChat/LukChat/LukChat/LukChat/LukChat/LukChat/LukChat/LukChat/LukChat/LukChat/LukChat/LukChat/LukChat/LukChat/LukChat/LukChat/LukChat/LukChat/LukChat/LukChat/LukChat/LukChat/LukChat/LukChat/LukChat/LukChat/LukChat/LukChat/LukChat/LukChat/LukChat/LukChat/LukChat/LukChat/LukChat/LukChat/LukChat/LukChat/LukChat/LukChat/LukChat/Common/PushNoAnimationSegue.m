//
//  PushNoAnimationSegue.m
//  TabbarApplication
//
//  Created by Naveen Kumar Dungarwal on 11/13/14.
//  Copyright (c) 2014 Naveen Kumar Dungarwal. All rights reserved.
//

#import "PushNoAnimationSegue.h"

@implementation PushNoAnimationSegue

-(void) perform{
    [[[self sourceViewController] navigationController] pushViewController:[self   destinationViewController] animated:NO];
}

@end
