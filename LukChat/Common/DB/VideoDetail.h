//
//  VideoDetail.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 1/9/15.
//  Copyright (c) 2015 aumkii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoDetail : NSObject
{
    NSInteger toUserID;
    long long int fromContact,toContact;
    NSString *fname,*lname,*videoTitle,*userImageUrl,*videoTime,*videoURL,*thumnail,*mergedVideoURL,*thumnailName;
    UIImage *userProfileImage,*thumbnail1,*thumbnail2,*thumbnail3;
}

@property(nonatomic,strong)NSString *fname,*lname,*videoTitle,*userImageUrl,*videoTime,*videoURL,*thumnail,*mergedVideoURL,*thumnailName;
@property(nonatomic,assign)NSInteger toUserID;
@property (nonatomic, assign) long long int fromContact,toContact;
@property(nonatomic,strong)UIImage *userProfileImage,*thumbnail1,*thumbnail2,*thumbnail3;

-(VideoDetail*)initWithDict:(NSDictionary*)videoDetailDict;
@end
