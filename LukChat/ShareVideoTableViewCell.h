//
//  ShareVideoTableViewCell.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 09/11/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface ShareVideoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *videoImg;

@property (weak, nonatomic) IBOutlet UILabel *videoTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *videoSenderLbl;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;


@property (weak, nonatomic) IBOutlet UIImageView *downloadIcon;

@property (weak, nonatomic) IBOutlet FXBlurView *blurView;
@property (weak, nonatomic) IBOutlet UIImageView *playIcon;
@end
