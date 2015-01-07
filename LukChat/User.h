//
//  User.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 01/11/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
    NSInteger userID;
    NSString *name,*videoTitle,*userImageUrl,*videoTime;
}

@property(nonatomic,strong)NSString *name,*videoTitle,*userImageUrl,*videoTime;
@property(nonatomic,assign)NSInteger userID;

-(NSArray*)userDetails;
@end
