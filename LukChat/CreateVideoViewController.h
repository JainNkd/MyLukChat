//
//  CreateVideoViewController.h
//  LukChat
//
//  Created by Naveen on 28/03/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateVideoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *createTableView;
@property (weak, nonatomic) IBOutlet UIView *settingView;

- (IBAction)shareButtonClickAction:(UIButton *)sender;


- (IBAction)openSettingBtnAction:(id)sender;

- (IBAction)closeSettingBtnAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

- (IBAction)facebookLoginAction:(UIButton *)sender;

- (IBAction)facebookLououtAction:(UIButton *)sender;



@end
