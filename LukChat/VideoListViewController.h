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

@interface VideoListViewController : UIViewController<UIActionSheetDelegate,UITextFieldDelegate>
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


//Video title Textfield
@property (weak, nonatomic) IBOutlet UITextField *videoTitleTextField;


//Video Record button action Method

@property (weak, nonatomic) IBOutlet UIButton *mergeButton;

- (IBAction)videoRecordButtonPressed:(UIButton *)sender;


//Video Merge button Action

- (IBAction)videoMergeButtonPressed:(UIButton *)sender;

@end
