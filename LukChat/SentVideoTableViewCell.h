//
//  SentVideoTableViewCell.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface SentVideoTableViewCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageViewObj;

@property (weak, nonatomic) IBOutlet UILabel *userNameLBLObj;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBLObj;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLBLObj;

@property (weak, nonatomic) IBOutlet UILabel *dayLBL;

@property (weak, nonatomic) IBOutlet UILabel *monthYearLBL;

@property (weak, nonatomic) IBOutlet UILabel *dayTimeLBL;

@property (weak, nonatomic) IBOutlet UILabel *postedOnFbLBL;
@property (weak, nonatomic) IBOutlet UIImageView *fbImage;
@end
