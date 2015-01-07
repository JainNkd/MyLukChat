//
//  SCEditVideoViewController.h
//  SCRecorderExamples
//
//  Created by Simon CORSIN on 22/07/14.
//
//

#import <UIKit/UIKit.h>
#import "SCVideoPlayerView.h"
#import "SCRecordSession.h"

@interface SCEditVideoViewController : UIViewController

@property (strong, nonatomic) SCRecordSession *recordSession;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)deletePressed:(id)sender;
@property (weak, nonatomic) IBOutlet SCVideoPlayerView *videoPlayerView;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
