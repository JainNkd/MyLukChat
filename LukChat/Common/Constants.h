//
//  Constants.h
//  VideoShare
//

#ifndef VideoShare_Constants_h
#define VideoShare_Constants_h



//web services
#define kServerURL @"http://lukchat.com/api"
#define kRegistrationURL @"http://lukchat.com/api/user"
#define kGetUserInfoURL @"http://lukchat.com/api/get_user"
//#define kVideoUploadURL @"http://lukchat.com/api/videos"
#define kShareVideoURL @"http://lukchat.com/api/share"
#define kVideoDownloadURL @"http://lukchat.com/app/webroot/files/"

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

// Push Notification
#define kNotificationFROM @"from-phone"
#define kNotificationTO @"to-phone"
#define kNotificationFILEPATH @"video-path"
#define kNotificationAPS @"aps"


#endif
