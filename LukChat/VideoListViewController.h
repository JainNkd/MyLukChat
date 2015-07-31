//
//  VideoListViewController.h
//  LukChat
//
//  Created by Administrator on 16/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataManager.h"
#import "VideoPreviewViewController.h"
#import "CustomeVideoPlayViewController.h"
#import "Facebook.h"

#import "UICollectionView+Draggable.h"

@interface VideoListViewController : UIViewController<UICollectionViewDataSource_Draggable, UICollectionViewDelegate,UIActionSheetDelegate,UITextFieldDelegate,UIAlertViewDelegate,FBRequestDelegate,FBSessionDelegate>
{
    NSString *videoTitle;
    
    // session to play the video
    AVPlayer *player;
    // file path
    NSString *fileURL;
    
    // index of the video
    NSInteger index;
    NSString *fileName;
    
    //TextView releated
    NSInteger currentLUKIndex;
    BOOL isRecordingStart;
    
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UILabel *titleHeaderLBL;

@property (weak, nonatomic) IBOutlet UIView *settingView;

//Video title Textfield
@property (weak, nonatomic) IBOutlet UITextField *videoTitleTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *settingLBL;


//Video Record button action Method

@property (weak, nonatomic) IBOutlet UIButton *mergeButton;
- (IBAction)openSettingBtnAction:(UIButton *)sender;

- (IBAction)videoRecordButtonPressed:(UIButton *)sender;

- (IBAction)closeSettingBtnAction:(UIButton *)sender;

- (IBAction)facebookLoginAction:(UIButton *)sender;

- (IBAction)facebookLououtAction:(UIButton *)sender;

//Video Merge button Action

- (IBAction)videoMergeButtonPressed:(UIButton *)sender;

@end
