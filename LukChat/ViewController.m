//
//  ViewController.m
//  LukChat
//
//  Created by Administrator on 26/07/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "ViewController.h"
#import "SignUpViewController.h"
#import "GetInputViewController.h"
#import "LukiesViewController.h"

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
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapPressedOnStartScreen:(id)sender {
    NSLog(@"Welcome to application");
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *saving = [defaults objectForKey:@"user"];
    [defaults synchronize];
    NSLog(@"savvvvvve is %@",saving);

//    if([saving  isEqualToString: @"YES"]){
//        GetInputViewController *gitVC = [self.storyboard instantiateViewControllerWithIdentifier:@"GetInputViewController"];
//        [self.navigationController pushViewController:gitVC animated:YES];
//
//    }
//    else{
//       [self performSegueWithIdentifier:@"SignUp" sender:self];
//    }
    
    LukiesViewController *lukie = [self.storyboard instantiateViewControllerWithIdentifier:@"LukiesViewController"];
    [self.navigationController pushViewController:lukie animated:YES];
    
//    if([saving  isEqualToString: @"YES"]){
//        [self performSegueWithIdentifier:@"TabBarView" sender:self];
//       
//    }
//    else{
//        //sign screen
//        [self performSegueWithIdentifier:@"SignUp" sender:self];
//    }
}


@end
