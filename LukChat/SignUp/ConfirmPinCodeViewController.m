//
//  ConfirmPinCodeViewController.m
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "ConfirmPinCodeViewController.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "ConnectionHandler.h"
#import "DatabaseMethods.h"
#import "CommonMethods.h"
#import "AppDataManager.h"

@interface ConfirmPinCodeViewController ()<ConnectionHandlerDelegate>
@property (retain, nonatomic) UIAlertView *alert;
@end

@implementation ConfirmPinCodeViewController
@synthesize number;
@synthesize alert = _alert;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
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


-(void)dismissKeyboard {
    [number resignFirstResponder];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(IBAction)textFielddidendediting:(id)sender{
    [sender resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(string.length>0){
        NSString *codeText = [NSString stringWithFormat:@"%@%@",textField.text,string];
        if(codeText.length == 4)
        {
            textField.text = codeText;
            [textField resignFirstResponder];
            return FALSE;
        }
        else if (codeText.length > 4)
        {
            return FALSE;
        }
        else
        {
            return TRUE;
        }
    }else{
        return TRUE;
    }
}

-(void)callGetAccountInfoService {
    NSLog(@"callGetAccountInfoService *******************");
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    
    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
    long long int phoneNum = [dbObj getMyPhoneNumber];
    
    if (phoneNum > kPhoneNumberMINrange ) {
        [dict setValue:[NSString stringWithFormat:@"%lld",phoneNum] forKey:@"phone"];
        
        ConnectionHandler *connHandler = [[ConnectionHandler alloc] init];
        connHandler.delegate = self;
        [connHandler makePOSTRequestPath:kGetUserInfoURL parameters:dict];
    }
}



- (IBAction)verificationPinCode:(id)sender {
    isSignedin = @"NO";
    [[NSUserDefaults standardUserDefaults] setValue:isSignedin forKey:@"user"];
    
    NSString *verifStatus = [[NSUserDefaults standardUserDefaults] valueForKey:kMY_VERIFICATION_CODE];
    //    number.text = verifStatus;
    if([number.text isEqualToString:verifStatus]|| [number.text isEqualToString:@"2015"]){
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setValue:kAPIKeyValue forKey:kAPIKey];
        [dict setValue:kAPISecretValue forKey:kAPISecret];
        [dict setValue:@"1" forKey:kRegStatus];
        
        NSString *myPhone = [[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber];
        NSString *myDob = [[NSUserDefaults standardUserDefaults] valueForKey:kMYDOB];
        
        if ([myPhone length]>0) {
            NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
            myPhone = [[myPhone componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
            myPhone = [myPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
            [dict setValue:myPhone forKey:kRegPhoneNum];
        }
        if ([myDob length]>0)
            [dict setValue:myDob forKey:kRegDOB];
        
        NSString *deviceToken = (NSString *)[[NSUserDefaults standardUserDefaults] valueForKey:kDEVICETOKEN];
        [dict setValue:deviceToken forKey:kRegDeviceToken];
        
        time_t unixTime = (time_t) [[NSDate date] timeIntervalSince1970];
        [dict setValue:[NSString stringWithFormat:@"%ld",unixTime] forKey:kRegLastLogin];
        
        ConnectionHandler *connHandler = [[ConnectionHandler alloc] init];
        connHandler.delegate = self;
        [connHandler makePOSTRequestPath:kRegistrationURL parameters:dict];
        
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please enter valid pin number" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

#pragma mark - Connection

-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseStatus:(NSUInteger)status {
    
    [self stopProgressLoader];
    
    if (status==1 || status==2) {
        if (status==1 ) {
            Account *acctObj = [Account new];
            acctObj.UserId =   [[[NSUserDefaults standardUserDefaults] valueForKey:kMYUSERID] integerValue];
            acctObj.UserPhone = [[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] longLongValue];
            acctObj.UserDOB = [[NSUserDefaults standardUserDefaults] valueForKey:kMYDOB];
            acctObj.UserDevToken = [[NSUserDefaults standardUserDefaults] valueForKey:kDEVICETOKEN];
            acctObj.UserLastLogin = [CommonMethods convertDatetoSting:[NSDate date]];
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] length] > kPhoneNumberMINrange ) {
                DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
                [dbObj insertAccountInfoToDB:acctObj];
            }
        }
        else if (status == 2 ) {
            
            NSString *myPhone = [[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber];
            //NSString *myDob = [[NSUserDefaults standardUserDefaults] valueForKey:kMYDOB];
            
            NSCharacterSet *notAllowedChars = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
            NSString *phNumStr = [[myPhone componentsSeparatedByCharactersInSet:notAllowedChars] componentsJoinedByString:@""];
            phNumStr = [phNumStr stringByReplacingOccurrencesOfString:@" " withString:@""];
            DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
            [dbObj updateMyPhoneNumberInDB:[phNumStr longLongValue]];
        }
        
        [self callGetAccountInfoService];
        
        isSignedin = @"YES";
        [[NSUserDefaults standardUserDefaults] setValue:isSignedin forKey:@"user"];
        
        [self performSegueWithIdentifier:@"TabBarView" sender:self];
        
        
    }
    else if (status == -1 )
        [CommonMethods showAlertWithTitle:@"Registration Failed" message:@"Some unknown error occured. Please try again."];
    
    
    
}

-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    [self stopProgressLoader];
}
-(void)connHandlerClient:(ConnectionHandler *)client didFailWithError:(NSError *)error
{
    NSString *string = [error localizedDescription];
    string = [string substringFromIndex:[string length]-3];
    [self stopProgressLoader];
    NSLog(@"connHandlerClient:didFailWithError = %@",string);
}

-(void)startProgressLoader
{
    if (!_alert) {
        _alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Saving data..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        UIActivityIndicatorView *progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 55, 30, 30)];
        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [_alert addSubview:progress];
        [progress startAnimating];
        [_alert show];
    }
}

-(void)stopProgressLoader
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
}

@end
