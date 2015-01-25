//
//  SentVideosViewController.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "SentVideosViewController.h"
#import "SentVideoTableViewCell.h"
#import "VideoDetail.h"
#import "DatabaseMethods.h"
@interface SentVideosViewController ()

@end

@implementation SentVideosViewController
@synthesize sentTableViewObj,videoDetailsArr;
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //userDetailsArr = [[NSMutableArray alloc]initWithArray:[[User alloc]userDetails]];
    videoDetailsArr = [DatabaseMethods getAllSentVideoContacts];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // [self.sentTableViewObj reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sentTableViewObj.estimatedRowHeight = 50.0;
    self.sentTableViewObj.rowHeight = UITableViewAutomaticDimension;

}

//Tableview delegate methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [videoDetailsArr count];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:indexPath.row];
    
    SentVideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SentVideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(videoObj.userImageUrl.length == 0)
        videoObj.userImageUrl = @"luk-iphone-final-lukes-sent-list-pic-dummy.png";
    
    NSString *name;
    if(videoObj.fname.length > 0)
        name = videoObj.fname;
    else if(videoObj.lname.length > 0)
        name = videoObj.lname;
    else
        name = [NSString stringWithFormat:@"%lld",videoObj.toContact];
    
    
        
    [cell.userImageViewObj setImage:[UIImage imageNamed:videoObj.userImageUrl]];
    [cell.userNameLBLObj setText:name];
    [cell.videoTitleLBLObj setText:@"fjhj jhjh jhk hj jjhj kjjhk  ghgjh jth ngbbn nmn "];//videoObj.videoTitle];
    [cell.videoTitleLBLObj sizeToFit];
    [cell.videoTimeLBLObj setText:videoObj.videoTime];
    return cell;
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
