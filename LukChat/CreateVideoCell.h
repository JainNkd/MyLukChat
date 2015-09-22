//
//  CreateVideoCell.h
//  LukChat
//
//  Created by Naveen on 28/03/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@interface CreateVideoCell : MGSwipeTableCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail1;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail2;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail3;

@property (weak, nonatomic) IBOutlet UIView *titleView;

@property (weak, nonatomic) IBOutlet UILabel *videoTitle;

@property (weak, nonatomic) IBOutlet UILabel *dayLbl;
@property (weak, nonatomic) IBOutlet UILabel *dayTextLbl;
@property (weak, nonatomic) IBOutlet UILabel *monthYearTimeLbl;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;


@end
