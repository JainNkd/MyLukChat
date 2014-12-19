
#import <Foundation/Foundation.h>

@interface Contact : NSObject

@property (nonatomic, assign) NSInteger user_id;
@property (nonatomic, assign) long long int user_phone;

@property (nonatomic, strong) NSString *user_fname;
@property (nonatomic, strong) NSString *user_lname;
@property (nonatomic, strong) NSString *user_dob;

@property (nonatomic, assign) NSInteger user_status;

@end
