
#import "Contact.h"

@implementation Contact

@synthesize user_id;
@synthesize user_phone;
@synthesize user_fname;
@synthesize user_lname;

@synthesize user_dob;
@synthesize user_status;


-(id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
        self.user_id = 0;
        self.user_phone = 0;

        self.user_fname = @"";
        self.user_lname = @"";
        self.user_dob = @"";
        
        self.user_status = 0;

    }
    return self;
}


@end
