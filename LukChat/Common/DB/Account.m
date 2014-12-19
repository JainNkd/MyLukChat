
#import "Account.h"

@implementation Account

@synthesize UserId;
@synthesize UserPhone;
@synthesize UserDOB;
@synthesize UserDevToken;
@synthesize UserLastLogin;

-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        self.UserId = 0;
        self.UserPhone = 0;
        self.UserDOB = @"";
        self.UserDevToken = @"";
        self.UserLastLogin = @"";
    }
    return self;
}


@end
