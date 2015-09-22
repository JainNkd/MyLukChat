//
//  SentVideosViewController.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "FXBlurView.h"
#import "UCZProgressView.h"
#import "Facebook.h"

#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"

@interface SentVideosViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FBSessionDelegate,FBRequestDelegate,UIActionSheetDelegate,MGSwipeTableCellDelegate>
{
    NSMutableArray *videoDetailsArr;
    NSString *cnCode;
    long long int myPhoneNum;
}

- (IBAction)shareButtonClickedAction:(UIButton *)sender;
@property(nonatomic,strong) NSMutableArray *videoDetailsArr;
@property (weak, nonatomic) IBOutlet UITableView *sentTableViewObj;



@property (weak, nonatomic) IBOutlet UIView *settingView;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *settingLBL;


- (IBAction)openSettingBtnAction:(id)sender;

- (IBAction)closeSettingBtnAction:(id)sender;

- (IBAction)facebookLoginAction:(UIButton *)sender;

- (IBAction)facebookLououtAction:(UIButton *)sender;

@end
