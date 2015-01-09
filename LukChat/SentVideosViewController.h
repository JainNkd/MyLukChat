//
//  SentVideosViewController.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SentVideosViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *videoDetailsArr;
}

@property(nonatomic,strong) NSMutableArray *videoDetailsArr;
@property (weak, nonatomic) IBOutlet UITableView *sentTableViewObj;
@end
