//
//  SignUpViewController.h
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountryPicker.h"

@interface SignUpViewController : UIViewController<CountryPickerDelegate,UIActionSheetDelegate,UITextFieldDelegate>{
    IBOutlet UITextField *pno;
    IBOutlet UITextField *dob;
    IBOutlet UITextField *country;
  
    
    NSDate *birthDate;
    UIActionSheet *dateSheet;
    
    NSString *cnCode;
    CountryPicker *myPickerView;
    UIToolbar *myToolbar;
}
@property (weak, nonatomic) IBOutlet UILabel *mobileCountryCode;

@property (nonatomic, retain) IBOutlet UITextField *pno;
@property (nonatomic, retain) IBOutlet UITextField *dob;
@property (nonatomic, strong) IBOutlet UILabel *codeLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UITextField *country;
@property (nonatomic, retain) NSDate *birthDate;
@property (nonatomic, retain) UIActionSheet *dateSheet;

@property (weak, nonatomic) IBOutlet UIButton *checkBoxButton;




-(void)setBirth;
-(void)dismissDateSet;
-(void)cancelDateSet;

- (IBAction)verifyButtonPressed:(id)sender;
- (IBAction)checkboxButtonPressed:(UIButton *)sender;
- (IBAction)termsAndConditionButtonPressed:(id)sender;

@end
