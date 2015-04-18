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
        self.thumbnail.layer.borderWidth = 2.0f;
        self.thumbnail.layer.borderColor = [UIColor clearColor].CGColor;
        self.thumbnail.layer.masksToBounds = YES;
    }
    else
    {
        self.thumbnail.layer.borderWidth = 2.0f;
        self.thumbnail.layer.borderColor = [UIColor clearColor].CGColor;
        self.thumbnail.layer.masksToBounds = YES;
    }
}

@end
