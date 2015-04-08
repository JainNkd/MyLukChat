//
//  RecievedVideoTableViewCell.h
//  LukChat
//
//  Created by Naveen on 28/03/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecievedVideoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageViewObj;

@property (weak, nonatomic) IBOutlet UILabel *userNameLBLObj;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBLObj;

@property (weak, nonatomic) IBOutlet UILabel *dayLBL;

@property (weak, nonatomic) IBOutlet UILabel *monthYearLBL;

@property (weak, nonatomic) IBOutlet UILabel *dayTimeLBL;

@end
