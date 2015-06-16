//
//  SignleVideoCell.m
//  LukChat
//
//  Created by Naveen on 16/04/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import "SignleVideoCell.h"

@implementation SignleVideoCell

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if(selected)
    {
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.masksToBounds = YES;
    }
    else
    {
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.masksToBounds = YES;
    }
}

@end
