
#import "CommonMethods.h"
#import "DataBaseMethods.h"

@implementation CommonMethods

#define kNewActivityAlertKey @"ShowNewActivityAlert"



#pragma mark - Alerts

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}

+(void)showAlertWithTitle:(NSString *)title message:(NSString *)message cancelBtnTitle:(NSString *)cancelTitle otherBtnTitle:(NSString *)otherTitle delegate:(id)sender tag:(NSInteger)alertTag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:sender cancelButtonTitle:cancelTitle otherButtonTitles:otherTitle,nil];
    alert.tag = alertTag;
    
    [alert show];
    //return alert;
}

#pragma mark - Data Conversions

+(NSData*)toJSON:(NSDictionary *)dict
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:dict
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}


+(NSDate *)convertStringtoDate:(NSString *)dateString
{
    //dateString = 2013-12-24 18:00:00
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // this is imporant - we set our input date format to match our input string
    // if format doesn't match you'll get nil from your string, so be careful
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//@"yyyy-MM-dd HH:mm:ss"];
    // voila!
    NSDate *dateFromString = [dateFormatter dateFromString:dateString];
    NSLog(@"dateFromString %@", dateFromString);
    return dateFromString;
}

+(NSString *)convertDatetoSting:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSLog(@"date: %@", strDate);
    return strDate;
}

+(NSString *)convertDateofBirthFormat:(NSString *)dob {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd-MMM-yyyy"];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
// [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    NSDate *dateFromString = [dateFormatter dateFromString:dob];

    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSString *strDate = [dateFormatter stringFromDate:dateFromString];
    return strDate;
}


@end

