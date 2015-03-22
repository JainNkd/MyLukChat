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
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:@"IS_NOTIFICATION"])
    {
        self.selectedIndex = 2;
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"IS_NOTIFICATION"];
    }
    else
    {
        self.selectedIndex = 1;
        
    }
    [tabBarItem1 setFinishedSelectedImage:[UIImage imageNamed:@"footer-ping-monkey-icon.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"start-screen-footer-icon-monkey.png"]];
    
    [tabBarItem2 setFinishedSelectedImage:[UIImage imageNamed:@"myplan_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"start-screen-footer-icon-video.png"]];
    
    [tabBarItem3 setFinishedSelectedImage:[UIImage imageNamed:@"share-videos-bottom-film-icon.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"start-screen-footer-icon-film.png"]];

    
    // Do any additional setup after loading the view.
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

@end
