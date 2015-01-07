//
//  User.m
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 01/11/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize userID,userImageUrl,name,videoTime,videoTitle;

-(NSArray*)userDetails
{
    User *user1 = [self initWithDetails:@"Markus" image:@"luk-iphone-final-lukes-sent-list-pic-markus.png" videoTitle:@"I wish you a happy holiday" videoTime:@"6.40pm" userId:1];
    
    User *user2 = [self initWithDetails:@"Manikandan" image:@"luk-iphone-final-lukes-sent-list-pic-mani.png" videoTitle:@"Happy birthday raj" videoTime:@"6.40pm" userId:2];
    
    User *user3 = [self initWithDetails:@"Rajkumar" image:@"luk-iphone-final-lukes-sent-list-rajkumar.png" videoTitle:@"Thank you so much" videoTime:@"6.40pm" userId:1];
    
    User *user4 = [self initWithDetails:@"Sekar" image:@"luk-iphone-final-lukes-sent-list-pic.png" videoTitle:@"Friendship day wishes guys" videoTime:@"6.40pm" userId:1];
    
    User *user5 = [self initWithDetails:@"Andreas" image:@"luk-iphone-final-lukes-sent-list-andreas.png" videoTitle:@"Hi my team happy weakend" videoTime:@"6.40pm" userId:1];
    
    
    User *user6 = [self initWithDetails:@"Naveen" image:@"luk-iphone-final-lukes-sent-list-pic-dummy.png" videoTitle:@"Welcome to LukChat guys" videoTime:@"6.40pm" userId:1];
    
    NSArray *userDataArr = [[NSArray alloc]initWithObjects:user1,user2,user3,user4,user5,user6, nil];
    
    return userDataArr;
}

-(User*)initWithDetails:(NSString*)nameObj image:(NSString*)imageName videoTitle:(NSString*)videoTitleObj videoTime:(NSString*)videoTimeObj userId:(NSInteger)userIDObj
{
    User* userObj = [[User alloc]init];
    userObj.userID = 1;
    userObj.userImageUrl = imageName;
    userObj.videoTime = videoTimeObj;
    userObj.videoTitle = videoTitleObj;
    userObj.name = nameObj;
    
    return userObj;
}
@end
