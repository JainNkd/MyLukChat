//
//  MixedVideoViewController.h
//  LukChat
//
//  Created by Naveen Dungarwal on 28/07/16.
//  Copyright © 2016 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCZProgressView.h"
#import "Facebook.h"


@interface MixedVideoViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,FBRequestDelegate,FBSessionDelegate,UIGestureRecognizerDelegate>
{
        NSMutableArray *randomVideosData;
        NSMutableArray *selectedIndexPaths ,*selectedWords;
        NSMutableString *videoTitle;
}
@property (weak, nonatomic) IBOutlet UIButton *twoMonkeyButton;

@property (weak, nonatomic) IBOutlet UILabel *videoTitleLbl;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *VideoCollectionVIew;

@property (weak, nonatomic) IBOutlet UIButton *mergeButton;

@property (weak, nonatomic) IBOutlet UIView *settingView;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *settingLBL;

@property (weak, nonatomic) IBOutlet UIButton *settingBtn;

- (IBAction)mergeButtonPressed:(UIButton *)sender;

- (IBAction)twoMonkeyButtonPressed:(UIButton *)sender;

- (IBAction)openSettingBtnAction:(UIButton *)sender;

- (IBAction)closeSettingBtnAction:(UIButton *)sender;

- (IBAction)facebookLoginAction:(UIButton *)sender;

- (IBAction)facebookLououtAction:(UIButton *)sender;

@end
