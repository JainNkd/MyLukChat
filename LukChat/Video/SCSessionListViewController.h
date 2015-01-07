//
//  SCSessionListViewController.h
//  SCRecorderExamples
//
//  Created by Simon CORSIN on 14/08/14.
//
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface SCSessionListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) SCRecorder *recorder;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
