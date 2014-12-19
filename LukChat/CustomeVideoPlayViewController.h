//
//  CustomeVideoPlayViewController.h
//  LukChat
//
//  Created by Naveen on 21/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CustomeVideoPlayViewController : UIViewController
{
    // session to play the video
    AVPlayer *player;
}

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIView *videoToPlayView;


@property (nonatomic, strong) NSString *videoUrl;


- (IBAction)closeButtonPressed:(UIButton *)sender;

@end
