//
//  TabBarViewController.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 15/11/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

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
    return YES;
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
    
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    
    //Set images for Tab Icon
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        
        [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"double-monkey-active@2x.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"double-monkey@2x.png"]];
        
        [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"camera-active@2x.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"camera@2x.png"]];
        
        [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"movie-role-active@2x.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"movie-role@2x.png"]];
        
    } else {
    
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"double-monkey-active@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem1.image = [[UIImage imageNamed:@"double-monkey@2x.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"camera-active@2x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem2.image = [[UIImage imageNamed:@"camera@2x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"movie-role-active@2x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem3.image = [[UIImage imageNamed:@"movie-role@2x.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    
    }
    
    //Defualt selected Tab form all Tabs
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"IS_NOTIFICATION"])
    {
        self.selectedIndex = 2;
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"IS_NOTIFICATION"];
    }
    else
    {
        self.selectedIndex = 1;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
