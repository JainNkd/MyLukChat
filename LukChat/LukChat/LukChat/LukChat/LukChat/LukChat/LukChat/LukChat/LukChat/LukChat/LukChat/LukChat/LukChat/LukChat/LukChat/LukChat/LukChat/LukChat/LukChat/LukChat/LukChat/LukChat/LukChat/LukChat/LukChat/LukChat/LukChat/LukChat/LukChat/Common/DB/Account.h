
#import <Foundation/Foundation.h>

@interface Account : NSObject

@property (nonatomic, assign) NSInteger UserId;
@property (nonatomic, assign) long long int UserPhone;
@property (nonatomic, strong) NSString *UserDOB;
@property (nonatomic, strong) NSString *UserDevToken;
@property (nonatomic, strong) NSString *UserLastLogin;

@end
