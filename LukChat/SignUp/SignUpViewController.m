//
//  SignUpViewController.m
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "CommonMethods.h"

@interface SignUpViewController ()

@property (retain, nonatomic) UIAlertView *alert;

@end

@implementation SignUpViewController
@synthesize pno,dob,country,nameLabel,birthDate,dateSheet,codeLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    myPickerView = [[CountryPicker alloc] initWithFrame:CGRectMake(0, 150, 170, 160)];
    myPickerView.delegate = self;
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.userInteractionEnabled = YES;
    
    country.inputView = myPickerView;
    myToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, 320, 44)];
    
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(inputAccessoryViewDidFinish)];
  
    [myToolbar setItems:[NSArray arrayWithObject: doneButton] animated:NO];
    country.inputAccessoryView = myToolbar;
    
    //Fetch current country
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    
    NSString *countryName = [locale displayNameForKey: NSLocaleCountryCode value: countryCode];
    NSLog(@"country is %@..%@", countryName,countryCode);
    country.text = countryName;
    codeLabel.text = countryCode;
    
    self.mobileCountryCode.text = [CommonMethods countryPhoneCode:countryCode];
    
    codeLabel.hidden = YES;
    nameLabel.hidden = YES;

    
    pnTab = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:pnTab];
    
    [self.checkBoxButton setImage:[UIImage imageNamed:@"signup-terms-checkbox-normal-view.png"] forState:UIControlStateNormal];
    [self.checkBoxButton setImage:[UIImage imageNamed:@"signup-terms-checkbox-selection.png"] forState:UIControlStateSelected];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)inputAccessoryViewDidFinish{
    //myToolbar.hidden = YES;
    // myPickerView.hidden = YES;
    [self.view endEditing:YES];
    
}

-(void)dismissKeyboard {
    [pno resignFirstResponder];
    [dob resignFirstResponder];
    [self.view addGestureRecognizer:pnTab];
    [pikerView removeFromSuperview];
    pikerView = nil;
    
}
-(void)setBirth{
    
    [self.view removeGestureRecognizer:pnTab];
    
    [pno resignFirstResponder];
    [pikerView removeFromSuperview];
    pikerView = nil;
    
    pikerView = [[UIView alloc]initWithFrame:CGRectMake(0,534, 320,234)];
    [pikerView setBackgroundColor:[UIColor clearColor]];
    
    UIToolbar *controlToolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0,0, pikerView.bounds.size.width, 44)];

    [controlToolBar sizeToFit];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *setButton = [[UIBarButtonItem alloc] initWithTitle:@"Set" style:UIBarButtonItemStyleDone target:self action:@selector(dismissDateSet)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelDateSet)];
    
    [controlToolBar setItems:[NSArray arrayWithObjects:spacer, cancelButton, setButton, nil] animated:NO];
    
    [pikerView addSubview:controlToolBar];

    UIDatePicker *birthDayPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,44, 320, 200)];
    [birthDayPicker setBackgroundColor:[UIColor whiteColor] ];
    [birthDayPicker setDatePickerMode:UIDatePickerModeDate];
    [pikerView addSubview:birthDayPicker];
    
    [self.view addSubview:pikerView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    
    CGRect frame= pikerView.frame;
    pikerView.frame = CGRectMake(0, 334, frame.size.width, frame.size.height);
    
    [UIView commitAnimations];

}

-(void)cancelDateSet{
   
    [self.view addGestureRecognizer:pnTab];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    
    CGRect frame= pikerView.frame;
    pikerView.frame = CGRectMake(0, 568, frame.size.width, frame.size.height);
    
    [UIView commitAnimations];
    [self.view endEditing:YES];
}

-(void)dismissDateSet{
    NSArray *listOfViews = [pikerView subviews];
    
    for(UIView *subView in listOfViews){
        if([subView isKindOfClass:[UIDatePicker class]]){
            self.birthDate = [(UIDatePicker *)subView date];
        }
        
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/YYYY"];
    [dob setText:[dateFormatter stringFromDate:self.birthDate]];

    [self cancelDateSet];
}

- (void)countryPicker:(__unused CountryPicker *)picker didSelectCountryWithName:(NSString *)name code:(NSString *)code
{
    country.text = name;
    nameLabel.text = name;
    codeLabel.text = code;
    self.mobileCountryCode.text = [CommonMethods countryPhoneCode:code];
    
}




-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self setBirth];
    return NO;
}

-(IBAction)clear:(id)sender

{
    country.placeholder=@"";
}

-(IBAction)DoneClicked:(id)sender{
    [pno resignFirstResponder];
}

-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

-(IBAction)textFielddidendediting:(id)sender{
    country.placeholder = @"";
    [sender resignFirstResponder];
    
}



- (IBAction)verifyButtonPressed:(id)sender {
    if (pno.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enter Phone Number"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (dob.text.length <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enter Date of Birth"
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if(!self.checkBoxButton.selected)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Follow terms and conditions."
                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    app.number = pno.text;
    
    NSString *str = pno.text;
    if ([[str substringToIndex:1] isEqualToString:@"0"])  {
        
        str = [str substringFromIndex:1];
        NSLog(@"string is %@",str);
    }
    else{
        NSString *str = pno.text;
        NSLog(@"string is %@",str);
    }
    
    
    int number = (arc4random()%100)+1000; //Generates Number from 1 to 100.
    NSString *string = [NSString stringWithFormat:@"%i", number];
    NSLog(@"random number is %@",string);
    app.pinValue = string;
    
//    //india code
//    cnCode = @"91";
    
    [[NSUserDefaults standardUserDefaults] setValue:string forKey:kMY_VERIFICATION_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@%@",cnCode,str] forKey:kMYPhoneNumber];
    [[NSUserDefaults standardUserDefaults] setValue:dob.text forKey:kMYDOB];
    
    NSURL *targetURL = [NSURL URLWithString:@"https://rest.nexmo.com/sms/json"];
    NSString *postbody = [NSString stringWithFormat:@"api_key=4cc0a6c5&api_secret=041bc169&text=Welcome to Luk! Your verification code is %@&to=%@%@&from=Luk",string,cnCode,str];
    NSData *postData = [postbody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:targetURL];
    [request setHTTPMethod:@"post"];
    //[request setValue:@"application/x-www-form-urlencoded" forKey:@"content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"content-length"];
    [request setHTTPBody:postData];
    
    NSURLResponse *response =nil;
    NSError *errorReturned = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&errorReturned];
    
    if(errorReturned){
        NSLog(@"error");
    }
    else{
        NSError *jsonParsingError = nil;
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments error:&jsonParsingError];
        NSLog(@"json array is %@",jsonArray);
        
        [self performSegueWithIdentifier:@"Confirmation" sender:self];
    }
}

- (IBAction)checkboxButtonPressed:(UIButton *)sender {
    NSLog(@"CheckBox,........");
    self.checkBoxButton.selected = !self.checkBoxButton.selected;

}

- (IBAction)termsAndConditionButtonPressed:(id)sender {
    
     [self performSegueWithIdentifier:@"TermsAndConditions" sender:self];
}
@end
