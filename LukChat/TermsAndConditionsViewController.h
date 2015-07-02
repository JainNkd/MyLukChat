//
//  TermsAndConditionsViewController.h
//  LukChat
//
//  Created by Administrator on 15/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsAndConditionsViewController : UIViewController<UIWebViewDelegate>
- (IBAction)backButtonPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
