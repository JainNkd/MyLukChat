//
//  VideoPreviewViewController.h
//  LukChat
//
//  Created by Naveen on 20/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoListViewController;

@interface VideoPreviewViewController : UIViewController

@property (nonatomic, copy) NSString *fileUrl;
@property (nonatomic, assign) int indexOfVideo;

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet UIButton *startButton,*cameraModeButton;

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;


- (IBAction)cnacelButtonPressed:(UIButton *)sender;

- (IBAction)frontCamaraButtonPressed:(UIButton *)sender;

- (IBAction)saveVideoButtonPressed:(UIButton *)sender;

- (IBAction)startStopRecordingButtonPressed:(id)sender;


@end
