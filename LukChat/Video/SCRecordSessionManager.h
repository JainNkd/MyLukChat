//
//  SCRecordSessionManager.h
//  SCRecorderExamples
//
//  Created by Simon CORSIN on 15/08/14.
//
//

#import <Foundation/Foundation.h>
#import "SCRecorder.h"

@interface SCRecordSessionManager : NSObject

- (void)saveRecordSession:(SCRecordSession *)recordSession;

- (void)removeRecordSession:(SCRecordSession *)recordSession;

- (BOOL)isSaved:(SCRecordSession *)recordSession;

- (void)removeRecordSessionAtIndex:(NSInteger)index;

- (NSArray *)savedRecordSessions;

+ (SCRecordSessionManager *)sharedInstance;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
