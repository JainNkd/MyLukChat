//
//  CreateVideoViewController.h
//  LukChat
//
//  Created by Naveen on 28/03/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreateVideoViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *createTableView;

- (IBAction)shareButtonClickAction:(UIButton *)sender;
@end
