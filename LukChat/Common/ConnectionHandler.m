

#import "ConnectionHandler.h"
#import "JSON.h"
#import "AppDelegate.h"
#import "CommonMethods.h"
#import <AdSupport/ASIdentifierManager.h>
#import "DataBaseMethods.h"
#import "AFJSONRequestOperation.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AFHTTPClient.h"
#import "Constants.h"

@implementation ConnectionHandler

@synthesize delegate;


+ (ConnectionHandler *)sharedInstance
{
    // the instance of this class is stored here
    static ConnectionHandler *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
        myInstance.baseUrl = [NSURL URLWithString:kServerURL];
    }
    // return the instance of this class
    return myInstance;
}

-(BOOL)hasConnectivity {
    
    //Reachability * reach = [Reachability reachabilityWithHostName:kServerURL];
    Reachability * reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus  status = [reach currentReachabilityStatus ];
    
   // NSLog(@"hasConnectivity: %u",status);
    if( status == ReachableViaWiFi )
    {
        return YES;
    }
    else if(status == ReachableViaWWAN)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - AFNetwork

-(void)makePOSTRequestPath:(NSString *)path parameters:(NSDictionary *)parameters
{
   // NSLog(@"parameters: %@",parameters);
    
    if (![self hasConnectivity]) {
        [CommonMethods showAlertWithTitle:@"No Connectivity" message:@"Please check the Internet Connnection"];
        return;
    }
    
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"text/json"];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"text/html"];
    [appDelegate.httpClient setDefaultHeader:@"Content-type" value:@"application/json"];

    [appDelegate.httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    [appDelegate.httpClient postPath:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
         
      /*   if (operation.response.statusCode == 200) {//able to get results here */
             NSString *responseString = [operation responseString]; //[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
             //NSLog(@"Request Successful, response '%@'", responseString);
 
         NSError *error;
         NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options: NSJSONReadingMutableContainers
                                                                        error: &error];
         NSDictionary *usersdict = [responseDict objectForKey:@"users"];
         NSInteger statusInt = [[usersdict objectForKey:@"status"] integerValue]; // 1 = INSERTED, 2= UPDATED

             if ([path isEqualToString:kRegistrationURL]) {
                // NSLog(@"Request Successful, RegistrationURL response '%@'", responseString);
                 [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",(long)[[parameters objectForKey:kUserId] integerValue]] forKey:kMYUSERID];
                 [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",[[parameters objectForKey:kUserPhone] longLongValue]] forKey:kMYPhoneNumber];
                 if (statusInt == 1 ) {
                     [self saveRegistrationData:parameters ];
                 }
                 else if (statusInt == 2) {
                     [self.delegate connHandlerClient:self didSucceedWithResponseStatus:2 ];
                 }
              }
             else if ([path isEqualToString:kGetUserInfoURL]) {
                // NSLog(@"Request Successful, GetUserInfo response '%@'", responseString);

                 if (statusInt == 1 || statusInt == 2) {
                     [self parseAccountResponse:responseString fromURL:path ];
                 }
             }
             else if ([path isEqualToString:kShareVideoURL]) {
                // NSLog(@"Request Successful, ShareVideo response '%@'", responseString);
                 
                     [self parseShareVideoResponse:responseString fromURL:path ];
             }
             else if ([path isEqualToString:kReceivedVideosURL]||[path isEqualToString:kAllHistoryURL]) {
//                  NSLog(@"Request Successful, kReceivedVideosURL response '%@'", responseString);
                 
                     [self parseRecievedVideosResponse:responseString fromURL:path ];
             }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"[HTTPClient Error]: %@", error);
         [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
         
         //delegate
         [self.delegate connHandlerClient:self didFailWithError:error];
         
     }];
    
}

-(void)makePOSTVideoShareAtPath:(NSURL *)path parameters:(NSDictionary *)parameters {
    
    if (![self hasConnectivity]) {
        [CommonMethods showAlertWithTitle:@"No Connectivity" message:@"Please check the Internet Connnection"];
        return;
    }
    
    NSData *videoData = [NSData dataWithContentsOfURL:path];
    UIImage *imageObj = [self generateThumbImage:path];
    NSData *imageData = UIImagePNGRepresentation(imageObj);

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"application/json"];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"text/json"];
    [appDelegate.httpClient setDefaultHeader:@"Accept" value:@"text/html"];
    [appDelegate.httpClient setDefaultHeader:@"Content-type" value:@"application/json"];
    [appDelegate.httpClient setParameterEncoding:AFFormURLParameterEncoding];

    NSMutableURLRequest *afRequest = [appDelegate.httpClient multipartFormRequestWithMethod:@"POST" path:kShareVideoURL parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData>formData)
                                      {
                                          [formData appendPartWithFileData:videoData name:kShareFILE fileName:@"filename.mov" mimeType:@"video/quicktime"];
                                          [formData appendPartWithFileData:imageData name:kShareThumbnailFILE fileName:@"thumbnail" mimeType:@"image/png"];
                                      }];
    
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:afRequest];
    
    [operation setUploadProgressBlock:^(NSInteger bytesWritten,NSInteger totalBytesWritten,NSInteger totalBytesExpectedToWrite)
     {
         NSLog(@"Sent %lld of %lld bytes", (long long int)totalBytesWritten,(long long int)totalBytesExpectedToWrite);
     }];
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        NSString *responseString = [operation responseString];
       // if ([path isEqualToString:kShareVideoURL]) {
           // NSLog(@"Request Successful, ShareVideo response '%@'", responseString);
            [self parseShareVideoResponse:responseString fromURL:kShareVideoURL ];
       // }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"[AFHTTPRequestOperation Error]: %@", error);
        [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
        //delegate
        [self.delegate connHandlerClient:self didFailWithError:error];
    }];
    
    [operation start];
    
}

-(UIImage *)generateThumbImage : (NSURL *)url
{
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.maximumSize = CGSizeMake(320.0f,320.0f);
    CMTime time = [asset duration];
    time.value = 0001;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:thumbnail];
    imageView.frame = CGRectMake(0,0,320,320);
    return imageView.image;
}

#pragma mark - Parse data


-(void)parseAccountResponse:(NSString *)responseString fromURL:(NSString *)urlPath{
 //   NSLog(@"parseAccount : %@ for URL:%@",responseString,urlPath);
    NSError *error;
    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData: [responseString dataUsingEncoding:NSUTF8StringEncoding]
                                                         options: NSJSONReadingMutableContainers
                                                           error: &error];

    NSDictionary *respdict = [responseDict objectForKey:@"users"];
    NSDictionary *userDataDict = [respdict objectForKey:@"data"];
    
    Contact *contactObj = [Contact new];
    DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
    contactObj.user_id = [[userDataDict objectForKey:kUserId] integerValue];
    contactObj.user_phone = [[userDataDict objectForKey:kUserPhone] longLongValue];
    contactObj.user_dob = [userDataDict objectForKey:kUserDob];
   // contactObj.user_status = [[userDataDict objectForKey:kUserStatus] integerValue];
    contactObj.user_status = [[respdict objectForKey:kUserStatus] integerValue];

    [dbObj updateContactInfoToDB:contactObj];
    
    [self.delegate connHandlerClient:self didSucceedWithResponseString:responseString forPath:urlPath];
}

-(void)saveRegistrationData:(NSDictionary *)parametersDict {
    
    Account *acctObj = [Account new];
    acctObj.UserId = [[parametersDict objectForKey:kUserId] integerValue];
    acctObj.UserPhone = [[parametersDict objectForKey:kUserPhone] longLongValue];
    acctObj.UserDOB = [parametersDict objectForKey:kUserDob];
    acctObj.UserDevToken = [parametersDict objectForKey:kUserDeviceToken];
    acctObj.UserLastLogin = [parametersDict objectForKey:kUserLastLogin];
    
    if ([[parametersDict objectForKey:kUserPhone] length] > 9 ) {
        
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",acctObj.UserId] forKey:kMYUSERID];
        [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",acctObj.UserPhone] forKey:kMYPhoneNumber];

        DatabaseMethods *dbObj = [[DatabaseMethods alloc] init];
        [dbObj insertAccountInfoToDB:acctObj];

    }

    [self.delegate connHandlerClient:self didSucceedWithResponseStatus:1];
}

-(void)parseVideoUploadResponse:(NSString *)responseString fromURL:(NSString *)urlPath{
    NSLog(@"parseVideoUploadResponse : %@ for URL:%@",responseString,urlPath);
    
    [self.delegate connHandlerClient:self didSucceedWithResponseString:responseString forPath:urlPath];
}

-(void)parseShareVideoResponse:(NSString *)responseString fromURL:(NSString *)urlPath{
       NSLog(@"parseShareVideoResponse : %@ for URL:%@",responseString,urlPath);
    
    [self.delegate connHandlerClient:self didSucceedWithResponseString:responseString forPath:urlPath];
}

-(void)parseRecievedVideosResponse:(NSString *)responseString fromURL:(NSString *)urlPath{
    NSLog(@"parseShareVideoResponse : %@ for URL:%@",responseString,urlPath);
    
    [self.delegate connHandlerClient:self didSucceedWithResponseString:responseString forPath:urlPath];
}


@end
