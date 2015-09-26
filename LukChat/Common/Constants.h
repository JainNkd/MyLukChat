//
//  Constants.h
//  VideoShare
//

#ifndef VideoShare_Constants_h
#define VideoShare_Constants_h

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)



//web services
#define kServerURL @"http://lukchat.com/api"
#define kRegistrationURL @"http://lukchat.com/api/user"
#define kGetUserInfoURL @"http://lukchat.com/api/get_user"
//#define kVideoUploadURL @"http://lukchat.com/api/videos"
#define kShareVideoURL @"http://lukchat.com/api/share"
#define kVideoDownloadURL @"http://lukchat.com/app/webroot/files/"
#define kUploadSingleVideos @"http://lukchat.com/api/share"

#define kSentVideosURL @"http://lukchat.com/api/history/sent"
#define kAllHistoryURL @"http://lukchat.com/api/history/all"
#define kSearchSingleVideo @"http://lukchat.com/api/search"
#define kDeleteVideoURL @"http://lukchat.com/api/deletevideo"

#define kReceivedVideosURL @"http://lukchat.com/api/history/received"

// TEMP: test tag
#define VIDEO_TITLE                      @"videoTitle"

//API
#define kAPIKey @"api_key"
#define kAPISecret @"api_secret"

// API Values
#define kAPIKeyValue @"AiK58j67"
#define kAPISecretValue @"a#9rJkmbOea90-"

//
#define kPhoneNumberMINrange 7

// DB Table names
#define kDatabaseName @"VideoShare.sqlite"
#define kTableContacts @"Contacts"
#define kTableUserInfo @"UserInfo"


//UserDefaults
#define kDEVICETOKEN @"DEVICETOKEN"
#define kMYUSERID @"MY_USER_ID"
#define kMYPhoneNumber @"MY_PHONE_NUMBER"
#define kMYDOB @"MY_DOB"
#define kMY_VERIFICATION_CODE @"USER_VERIFICATION_CODE"
#define kCurrentCHATUserID @"CURRENT_CHAT_USER_ID"
#define kCurrentCHATUserPHONE @"CURRENT_CHAT_USER_PHONE"

#define kMyVideoToShare @"VIDEO_TO_SHARE"
#define kCreatedVideoShare @"SHARE_CREATED_VIDEO"
#define kRecievedVideoShare @"SHARE_RECIEVED_VIDEO"

#define kIsFromCreated @"IS_FROM_CREATED"
#define kIsFromRecieved @"IS_FROM_RECIEVED"
#define kIsFromMerged @"IS_FROM_MERGED"

#define kCreatedVideoShareTitle @"CREATED_VIDEO_TITLE"
#define kRecievedVideoShareTitle @"RECIEVED_VIDEO_TITLE"

// Connection Handler
#define kUsers @"users"
#define kUserData @"data"
#define kUserId @"id"
#define kUserPhone @"phone"
#define kUserDob @"dob"
#define kUserDeviceToken @"devicetoken"
#define kUserLastLogin @"lastlogin"
#define kUserStatus @"status"
#define kUserFname @"fname"
#define kUserLname @"lname"

// Registration
#define kRegId @"id"
#define kRegPhoneNum @"phone"
#define kRegDOB @"dob"
#define kRegDeviceToken @"devicetoken"
#define kRegLastLogin @"lastlogin"
#define kRegStatus @"status"

// Video Upload
#define kVideoUploadFrom @"phone"
#define kVideoUploadFile @"file"


// Video Share
#define kShareFROM @"from"
#define kShareTO @"to"
#define kShareFILE @"file"
#define kShareThumbnailFILE @"thumbnail"
#define kVideoTITLE @"caption"
#define kShareReceivedFile @"vfile"

// Push Notification
#define kNotificationFROM @"from-phone"
#define kNotificationTO @"to-phone"
#define kNotificationFILEPATH @"video-path"
#define kNotificationAPS @"aps"


#endif
