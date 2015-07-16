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

@interface VideoListViewController : UIViewController<UIActionSheetDelegate,UITextFieldDelegate,UIAlertViewDelegate,FBRequestDelegate,FBSessionDelegate>
{
    NSMutableArray *videoTitleLBLArr, *videoTitleButtonsArr,*lukViewsArr;
    NSString *videoTitle;
    
//    VideoPreviewViewController *previewController;
    
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

@property (weak, nonatomic) IBOutlet UILabel *titleHeaderLBL;

//titleButtons

@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton1;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton2;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton3;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton4;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton5;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton6;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton7;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton8;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton9;
@property (weak, nonatomic) IBOutlet UIButton *videoTitleButton10;



//seperation lines


@property (weak, nonatomic) IBOutlet UIImageView *seperationLine1;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine2;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine3;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine4;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine5;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine6;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine7;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine8;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine9;
@property (weak, nonatomic) IBOutlet UIImageView *seperationLine10;


//Title Labels

@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL1;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL2;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL3;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL4;

@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL5;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL6;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL7;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL8;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL9;
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLBL10;


//Luk views

@property (weak, nonatomic) IBOutlet UIView *lukView1;
@property (weak, nonatomic) IBOutlet UIView *lukView2;
@property (weak, nonatomic) IBOutlet UIView *lukView3;
@property (weak, nonatomic) IBOutlet UIView *lukView4;
@property (weak, nonatomic) IBOutlet UIView *lukView5;
@property (weak, nonatomic) IBOutlet UIView *lukView6;
@property (weak, nonatomic) IBOutlet UIView *lukView7;
@property (weak, nonatomic) IBOutlet UIView *lukView8;
@property (weak, nonatomic) IBOutlet UIView *lukView9;
@property (weak, nonatomic) IBOutlet UIView *lukView10;

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
