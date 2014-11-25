
#import <Foundation/Foundation.h>

@interface Chat : NSObject

@property (nonatomic, assign) NSInteger chatId;
@property (nonatomic, assign) long long int fromPhone;
@property (nonatomic, assign) long long int toPhone;
@property (nonatomic, assign) NSInteger contentType;

@property (nonatomic, strong) NSString *chatText;
@property (nonatomic, strong) NSString *chatVideo;
@property (nonatomic, strong) NSString *chatTime;


@end
