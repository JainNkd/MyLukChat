//
//  ConfirmPinCodeViewController.h
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmPinCodeViewController : UIViewController
{
    IBOutlet UITextField *number;
    NSString *isSignedin;
}

@property(nonatomic, retain) IBOutlet UITextField *number;
- (IBAction)verificationPinCode:(id)sender;

@end
