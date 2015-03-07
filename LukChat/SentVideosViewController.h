//
//  SentVideosViewController.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SentVideosViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *videoDetailsArr;
    NSString *cnCode;
}

@property(nonatomic,strong) NSMutableArray *videoDetailsArr;
@property (weak, nonatomic) IBOutlet UITableView *sentTableViewObj;
@end
