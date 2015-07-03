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
    
    if(IS_IPHONE_4_OR_LESS){
    self.signupView.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect signupFrame = self.signupView.frame;
        signupFrame.origin.y = 100;
        self.signupView.frame = signupFrame;
    
    }
    
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
    
    //UI SET UP
    [self.checkBoxButton setImage:[UIImage imageNamed:@"signup-terms-checkbox-normal-view.png"] forState:UIControlStateNormal];
    [self.checkBoxButton setImage:[UIImage imageNamed:@"signup-terms-checkbox-selection.png"] forState:UIControlStateSelected];
    
    country.placeholder = NSLocalizedString(@"Country", nil);
    pno.placeholder = NSLocalizedString(@"Phone number", nil);
    dob.placeholder = NSLocalizedString(@"Date of birth", nil);
    
//    self.termsAndConditionsLBL.text = NSLocalizedString(@"terms and conditions", nil);
    
    self.iAgreeTextLBL.text = NSLocalizedString(@"I agree in terms and conditions", nil);
    [self.iAgreeTextLBL setFont:[UIFont systemFontOfSize:[NSLocalizedString(@"IAgreeFontSize", nil)integerValue]]];
    
    self.tAndCLineLBL.translatesAutoresizingMaskIntoConstraints = YES;
    self.tAndCBtn.translatesAutoresizingMaskIntoConstraints = YES;
    CGFloat tAndCOrigix = [NSLocalizedString(@"tAndcX",nil) floatValue];
    CGFloat tAndCOrigiy = [NSLocalizedString(@"tAndcY",nil) floatValue];
    CGFloat tAndCOrigiWidth = [NSLocalizedString(@"tAndcWidth",nil) floatValue];
    [self.tAndCLineLBL setFrame:CGRectMake(tAndCOrigix, tAndCOrigiy, tAndCOrigiWidth,1)];
    
    [self.tAndCBtn setFrame:CGRectMake(tAndCOrigix, tAndCOrigiy-20, tAndCOrigiWidth,30)];

    [self.verufyBtn setTitle:NSLocalizedString(@"verify", nil) forState:UIControlStateNormal];

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
    
    NSDate *today = [NSDate date]; // get the current date
    NSCalendar* cal = [NSCalendar currentCalendar]; // get current calender
    NSDateComponents* dateOnlyToday = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit ) fromDate:today];
    [dateOnlyToday setYear:([dateOnlyToday year] - 1)];
    NSDate *nextYear = [cal dateFromComponents:dateOnlyToday];
    
    [birthDayPicker setDate:nextYear];
    [birthDayPicker setMaximumDate:today];
    [pikerView addSubview:birthDayPicker];
    
    [self.view addSubview:pikerView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5];
    
    CGRect frame= pikerView.frame;
    if(IS_IPHONE_4_OR_LESS)
    pikerView.frame = CGRectMake(0, 334-50, frame.size.width, frame.size.height);
    else
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",nil) message:NSLocalizedString(@"Enter Phone Number",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (dob.text.length <= 0) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Enter Date of Birth"
//                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//        [alert show];
//        return;
    }
    
    if(!self.checkBoxButton.selected)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Alert",nil) message:NSLocalizedString(@"Follow terms and conditions.",nil)
                                                       delegate:self cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if(![CommonMethods reachable])
    {
        [CommonMethods showAlertWithTitle:NSLocalizedString(@"No Connectivity",nil) message:NSLocalizedString(@"Please check the Internet Connnection",nil)];
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
    
    cnCode = self.mobileCountryCode.text;
    
    int number = (arc4random()%1000)+1000; //Generates Number from 1 to 1000.
    NSString *string = [NSString stringWithFormat:@"%i", number];
    NSLog(@"random number is %@",string);
    app.pinValue = string;
    
    [[NSUserDefaults standardUserDefaults] setValue:string forKey:kMY_VERIFICATION_CODE];
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@%@",cnCode,str] forKey:kMYPhoneNumber];
    [[NSUserDefaults standardUserDefaults] setValue:dob.text forKey:kMYDOB];
    
    NSURL *targetURL = [NSURL URLWithString:@"https://rest.nexmo.com/sms/json"];
    NSString *postbody = [NSString stringWithFormat:@"api_key=4cc0a6c5&api_secret=041bc169&text=Welcome to Luk! Your verification code is %@&to=%@%@&from=Luk",string,cnCode,str];
    NSData *postData = [postbody dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:targetURL];
    [request setHTTPMethod:@"post"];
    [request setValue:postLength forHTTPHeaderField:@"content-length"];
    [request setHTTPBody:postData];
    
    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    
    // Create url connection and fire request
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:backgroundQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               
                               if (error)
                               {
                                   NSLog(@"error%@",[error localizedDescription]);
                                   dispatch_async(dispatch_get_main_queue()
                                                  , ^(void) {
                                   [CommonMethods showAlertWithTitle:NSLocalizedString(@"Error",nil) message:[error localizedDescription]];
                                                      });
                               }
                               else
                               {
                                   NSError *jsonParsingError = nil;
                                   id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                                   
                                   if (jsonParsingError) {
                                       NSLog(@"JSON ERROR: %@", [jsonParsingError localizedDescription]);
                                   } else {
                                       NSDictionary * jsonDict = (NSDictionary*)object;
                                       NSLog(@"json array is %@",[jsonDict description]);
                                       dispatch_async(dispatch_get_main_queue()
                                                      , ^(void) {
                                                          [self performSegueWithIdentifier:@"Confirmation" sender:self];
                                                      });
                                       
                                   }
                                   
                               }
                           }];
}

- (IBAction)checkboxButtonPressed:(UIButton *)sender {
    NSLog(@"CheckBox,........");
    self.checkBoxButton.selected = !self.checkBoxButton.selected;
    
}

- (IBAction)termsAndConditionButtonPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"TermsAndConditions" sender:self];
}
@end
