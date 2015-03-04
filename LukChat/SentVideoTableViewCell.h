//
//  SentVideoTableViewCell.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SentVideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageViewObj;

@property (weak, nonatomic) IBOutlet UILabel *userNameLBLObj;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBLObj;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLBLObj;

@end
