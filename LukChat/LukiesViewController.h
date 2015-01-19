//
//  LukiesViewController.h
//  LukChat
//
//  Created by Naveen on 06/01/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"

@interface LukiesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSString *cnCode;
    long long int myPhoneNum;
    UIAlertView *alert;
    Chat* chatObj;
    
    BOOL isFiltered;
    
    NSArray *indexTitles,*tableSectionTitles;
    
    NSMutableDictionary* filteredTableData;
    UISearchDisplayController *searchDisplayController;
}

@property (weak, nonatomic) IBOutlet UITableView *contactTableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *sendTolukiesBtn;

- (IBAction)sendToLukiesButtonPressed:(UIButton *)sender;
@end
