//
//  ShareVideosViewController.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 09/11/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"

@interface ShareVideosViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *shareVideosTableViewObj;
@property (nonatomic, retain) MPMoviePlayerViewController *theMovie;



@end
