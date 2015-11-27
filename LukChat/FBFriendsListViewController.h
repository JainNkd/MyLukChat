//
//  FBFriendsListViewController.h
//  LukChat
//
//  Created by Naveen Kumar on 11/4/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@interface FBFriendsListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,FBSessionDelegate, FBRequestDelegate>

@property (weak, nonatomic) IBOutlet UIButton *postToOwnFBWallBtn;
@property (weak, nonatomic) IBOutlet UIButton *postToFrndFBWallBtn;

@property (weak, nonatomic) IBOutlet UITableView *fbFriednsTableView;


- (IBAction)postToOwnWall:(UIButton *)sender;

- (IBAction)postToFriendsWall:(UIButton *)sender;
@end
