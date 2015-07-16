//
//  CreateVideoViewController.h
//  LukChat
//
//  Created by Naveen on 28/03/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface CreateVideoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FBSessionDelegate,FBRequestDelegate>
@property (weak, nonatomic) IBOutlet UITableView *createTableView;
@property (weak, nonatomic) IBOutlet UIView *settingView;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@property (weak, nonatomic) IBOutlet UILabel *settingLBL;


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (IBAction)shareButtonClickAction:(UIButton *)sender;

- (IBAction)openSettingBtnAction:(id)sender;

- (IBAction)closeSettingBtnAction:(id)sender;

- (IBAction)facebookLoginAction:(UIButton *)sender;

- (IBAction)facebookLououtAction:(UIButton *)sender;



@end
