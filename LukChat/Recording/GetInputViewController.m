//
//  GetInputViewController.m
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "GetInputViewController.h"
#import "Constants.h"

@interface GetInputViewController ()

@end

@implementation GetInputViewController
@synthesize videoTitle;

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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Do any additional setup after loading the view.
}


-(void)dismissKeyboard {
    [videoTitle resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

- (IBAction)recordVideoButtonPressed:(id)sender {
    
    NSString *message;
    
    if(videoTitle.text.length>0)
    {
        NSMutableArray *array = (NSMutableArray*)[videoTitle.text componentsSeparatedByString:@" "];
        
        if([array count]>1)
        [array removeObject:@""];
        
        if([array count]<=0)
        {
            message = @"Please enter the valid title";
        }
        else if([array count]>10)
        {
            message = @"You exceed meximum word limit of 10";
        }
        else if ([array count] < 2)
        {
            message = @"You need two recorded video clips to merge the videos.";
        }
        else{
            [[NSUserDefaults standardUserDefaults] setObject:videoTitle.text forKey:VIDEO_TITLE];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IS_INPUT_AVAILABLE];
            
            [self performSegueWithIdentifier:@"VideoList" sender:self];
        }
    }
    else
    {
        message = @"Please enter the valid title";
    }
    
    if(message){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Alert",nil) message:message delegate:nil cancelButtonTitle:@"Accept" otherButtonTitles:nil];
        [alert show];
        return;
    }
}
@end
