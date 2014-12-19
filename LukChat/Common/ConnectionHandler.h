

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@protocol ConnectionHandlerDelegate;

@interface ConnectionHandler : NSObject //<ConnectionHandlerDelegate,CLLocationManagerDelegate>

@property (nonatomic, assign) NSURL *baseUrl;
@property(strong) id<ConnectionHandlerDelegate> delegate;

-(BOOL)hasConnectivity ;
-(void)makePOSTRequestPath:(NSString *)path parameters:(NSDictionary *)parameters;
-(void)makePOSTVideoShareAtPath:(NSURL *)path parameters:(NSDictionary *)parameters;
-(void)parseAccountResponse:(NSString *)responseString fromURL:(NSString *)urlPath;
-(void)saveRegistrationData:(NSDictionary *)parametersDict ;
@end




@protocol ConnectionHandlerDelegate <NSObject>
@optional
-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseString:(NSString *)response forPath:(NSString *)urlPath;
-(void)connHandlerClient:(ConnectionHandler *)client didSucceedWithResponseStatus:(NSUInteger)status;
-(void)connHandlerClient:(ConnectionHandler *)client didFailWithError:(NSError *)error;
@end

