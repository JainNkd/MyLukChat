
#import <Foundation/Foundation.h>
#import "Reachability.h"

@interface CommonMethods : NSObject

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message;
+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelBtnTitle:(NSString *)cancelTitle otherBtnTitle:(NSString *)otherTitle delegate:(id)sender tag:(NSInteger)alertTag;

+(NSData*)toJSON:(NSDictionary *)dict;
+(NSDate *)convertStringtoDate:(NSString *)dateString;
+(NSString *)convertDatetoSting:(NSDate *)date;
+(NSString *)convertDateofBirthFormat:(NSString *)dob;
+(NSString*)countryPhoneCode:(NSString*)countryCode;

+(BOOL)fileExist:(NSString*)fileName;
+(NSString*)localFileUrl:(NSString*)fileName;

+(BOOL)reachable;
+(BOOL)isWiFiConnected;
+(NSString*)getVideoTitle;
@end



