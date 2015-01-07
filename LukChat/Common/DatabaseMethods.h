
#import <Foundation/Foundation.h>
#import "Chat.h"
#import "Account.h"
#import "Contact.h"


@interface DatabaseMethods : NSObject

-(BOOL)openDataBase;
-(BOOL)updateDatabase:(const char *)queryStr;
-(NSString *)getOutputStringForQuery:(const char *)queryString;
-(NSInteger)getOutputIntForQuery:(const char *)queryString;

-(Account *)getAccountInfo;
-(Account *)getUserDeviceTokenANDLastLogin;
-(NSInteger)getMyUserID ;
-(long long int)getMyPhoneNumber ;
-(BOOL)checkIfContactExists:(long long int)contactNum;

-(NSMutableArray *)getChatHistoryForUser:(long long int)userPhone ;
-(NSMutableArray *)getAllLukChatContacts;
-(NSMutableArray *)getAllOtherContacts;

-(void)insertAccountInfoToDB:(Account *)accountObj ;
-(void)updateAccountInfoToDB:(Account *)accountObj;
-(void)updateMyPhoneNumberInDB:(long long int)phoneNum;
-(void)insertChatInfoToDB:(Chat *)chatObj;
-(void)insertContactInfoToDB:(Contact *)contactObj;
-(void)updateContactInfoToDB:(Contact *)contactObj;

@end
