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

@interface SentVideosViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *videoDetailsArr;
    NSString *cnCode;
    long long int myPhoneNum;
}

- (IBAction)shareButtonClickedAction:(UIButton *)sender;
@property(nonatomic,strong) NSMutableArray *videoDetailsArr;
@property (weak, nonatomic) IBOutlet UITableView *sentTableViewObj;



@property (weak, nonatomic) IBOutlet UIView *settingView;

- (IBAction)openSettingBtnAction:(id)sender;

- (IBAction)closeSettingBtnAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

- (IBAction)facebookLoginAction:(UIButton *)sender;

- (IBAction)facebookLououtAction:(UIButton *)sender;

@end
