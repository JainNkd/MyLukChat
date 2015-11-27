//
//  FBFriendCell.m
//  LukChat
//
//  Created by Naveen Kumar on 11/4/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import "FBFriendCell.h"
#import "CommonMethods.h"
@implementation FBFriendCell

- (void)awakeFromNib {
    // Initialization code
    
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.layer.borderWidth = 1;
    self.profileImage.layer.cornerRadius = 19;
    [self.profileImage clipsToBounds];
    self.backgroundImage.image = [UIImage imageNamed:@""];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if(selected)
    {
        self.backgroundImage.image = [UIImage imageNamed:@"name-layover-bg.png"];
        self.name.textColor = [UIColor colorWithRed:241.0/255.0 green:0.0/255.0 blue:119/255.0 alpha:1.0];
    }
    else
    {
        self.name.textColor = [UIColor whiteColor];
        self.backgroundImage.image = [UIImage imageNamed:@""];
    }

    // Configure the view for the selected state
}

@end
