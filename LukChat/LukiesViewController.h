//
//  LukiesViewController.h
//  LukChat
//
//  Created by Naveen on 06/01/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LukiesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSString *cnCode;
}

@property (weak, nonatomic) IBOutlet UITableView *contactTableView;

@end
