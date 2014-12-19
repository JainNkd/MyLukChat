//
//  GetInputViewController.h
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDataManager.h"

@interface GetInputViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *videoTitle;


@property (weak, nonatomic) IBOutlet UIButton *recordButton;

- (IBAction)recordVideoButtonPressed:(id)sender;

@end
