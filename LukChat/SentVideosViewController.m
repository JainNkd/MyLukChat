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
#import "ConnectionHandler.h"
#import "CommonMethods.h"
#import "Constants.h"
@interface SentVideosViewController ()<ConnectionHandlerDelegate>

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
//    videoDetailsArr = [DatabaseMethods getAllSentVideoContacts];
    
    long long int myPhoneNum = [[[NSUserDefaults standardUserDefaults] valueForKey:kMYPhoneNumber] longLongValue];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kAPIKeyValue forKey:kAPIKey];
    [dict setValue:kAPISecretValue forKey:kAPISecret];
    [dict setValue:[NSString stringWithFormat:@"%lld",myPhoneNum] forKey:@"phone"];
    
    ConnectionHandler *connObj = [[ConnectionHandler alloc] init];
    connObj.delegate = self;
    [connObj makePOSTRequestPath:kSentVideosURL parameters:dict];
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


-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath{
    NSLog(@"connHandlerClient didSucceedWithResponseString : %@",response);
    NSLog(@"loadAppContactsOnTable ******************");
    if ([urlPath isEqualToString:kSentVideosURL]) {
        NSLog(@"SUCCESS: All Data fetched");
        
        NSError *error;
        NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [response dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options: NSJSONReadingMutableContainers
                                                                       error: &error];
        NSDictionary *historydict = [responseDict objectForKey:@"history"];
        NSInteger status = [[historydict objectForKey:@"status"] integerValue];
        NSArray *dataList = [historydict objectForKey:@"sent"];
        
        switch (status) {
            case 0:
            {
                [videoDetailsArr removeAllObjects];
                videoDetailsArr = nil;
                videoDetailsArr = [[NSMutableArray alloc]init];
                for(NSDictionary* datadict in dataList)
                {
                    NSDictionary *videoDict = [datadict objectForKey:@"Video"];
                    VideoDetail *videoDetailObj = [[VideoDetail alloc]initWithDict:videoDict];
                    [videoDetailsArr addObject:videoDetailObj];
                }
                
                if(videoDetailsArr.count > 0)
                [self.sentTableViewObj reloadData];
                else
                    [CommonMethods showAlertWithTitle:@"LUK" message:@"You not sent any video to your friends." cancelBtnTitle:nil otherBtnTitle:@"Accept" delegate:nil tag:0];
                break;
            }
            case -2:
                [CommonMethods showAlertWithTitle:[historydict objectForKey:@"message"] message:@"Make sure the phone number is registered with LukChat"];
                break;
            default:
                [CommonMethods showAlertWithTitle:@"Error" message:[error localizedDescription]];
                break;
        }
    }
}

-(void)connHandlerClient:(ConnectionHandler *)client didFailWithError:(NSError *)error
{
    NSString *string = [error localizedDescription];
    string = [string substringFromIndex:[string length]-3];
    NSLog(@"connHandlerClient:didFailWithError = %@",string);
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
    
    VideoDetail *videoObj = [videoDetailsArr objectAtIndex:(videoDetailsArr.count-(indexPath.row+1))];
    
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
    [cell.videoTitleLBLObj setText:@"Video Title"];//videoObj.videoTitle];
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
