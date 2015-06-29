//
//  ViewController.m
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "ViewController.h"
#import "SignUpViewController.h"
#import "LukiesViewController.h"
#import "CommonMethods.h"
#import "Constants.h"
@interface ViewController ()

@end

@implementation ViewController

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
    self.navigationController.navigationBarHidden = YES;
    
    if(IS_IPHONE_4_OR_LESS)
    {
        [self.bgImage setImage:[UIImage imageNamed:@"iphone4-screen-1.png"]];
    }
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(tapPressedOnStartScreen:) withObject:nil afterDelay:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapPressedOnStartScreen:(id)sender {
    NSLog(@"Welcome to application");
    
    if(sender){}
    else{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *saving = [defaults objectForKey:@"user"];
    [defaults synchronize];
    NSLog(@"savvvvvve is %@",saving);
    
    if(![saving  isEqualToString: @"YES"]){
        [self performSegueWithIdentifier:@"TabBarView" sender:self];
        
    }
    else{
        //sign screen
        [self performSegueWithIdentifier:@"SignUp" sender:self];
    }
    }
}


@end
