//
//  MergeVideosViewController.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 03/11/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataManager.h"
#import <AVFoundation/AVFoundation.h>

@interface MergeVideosViewController : UIViewController
{
    AVPlayer *player;
}

@property (nonatomic, strong) NSMutableDictionary *videoUploadInProgress;
@property (weak, nonatomic) IBOutlet UIImageView *mergeVideoImg;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL;
@property (weak, nonatomic) IBOutlet UILabel *userNameLBL;

@property (weak, nonatomic) IBOutlet UIView *videoTitleView;
- (IBAction)PlayVideoButtonAction:(UIButton *)sender;

- (IBAction)sendToLukiesButtonPressed:(UIButton *)sender;
@end
