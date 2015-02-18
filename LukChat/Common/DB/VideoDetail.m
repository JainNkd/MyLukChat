//
//  VideoDetail.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 1/9/15.
//  Copyright (c) 2015 aumkii. All rights reserved.
//

#import "VideoDetail.h"
#import "CommonMethods.h"

@implementation VideoDetail
@synthesize toContact,toUserID,fname,lname,userImageUrl,videoTime,videoTitle,fromContact,videoURL,thumnail;

-(VideoDetail*)initWithDict:(NSDictionary*)videoDetailDict
{
    if(self == [super init])
    {
        self.toContact = [[videoDetailDict valueForKey:@"to"] longLongValue];
        self.fromContact = [[videoDetailDict valueForKey:@"from"] longLongValue ];
        self.videoURL = [videoDetailDict valueForKey:@"file"];
        self.videoTime = [videoDetailDict valueForKey:@"time"];
       
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.videoTime doubleValue]];
        self.videoTime = [CommonMethods convertDatetoSting:date];
        
        self.thumnail = [videoDetailDict valueForKey:@"thumbnail"];
        
    }
    return self;
}
@end
