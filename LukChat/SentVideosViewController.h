//
//  SentVideosViewController.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 30/10/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"
#import "FXBlurView.h"
#import "UCZProgressView.h"

@interface SentVideosViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *videoDetailsArr;
    NSString *cnCode;
    long long int myPhoneNum;
}

@property(nonatomic,strong) NSMutableArray *videoDetailsArr;
@property (weak, nonatomic) IBOutlet UITableView *sentTableViewObj;
@end
