
#import "DatabaseMethods.h"
#import <sqlite3.h>
#import "Constants.h"

@implementation DatabaseMethods


-(BOOL)openDataBase
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database; //Declare a pointer to sqlite database structure
    const char *dbpath = [databasePath UTF8String]; // Convert NSString to UTF-8
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        //Database opened successfully
        return YES;
    } else {
        //Failed to open database
        return NO;
    }
    return NO;
}


-(BOOL)updateDatabase:(const char *)queryStr
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    BOOL success = '\0';
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, queryStr, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            if(SQLITE_DONE != sqlite3_step(compiledStatement))
            {
                NSLog( @"Error while updating data: '%s'", sqlite3_errmsg(database));
                success=FALSE;
            }
            else
            {
                NSLog(@"Data updated");
                success = TRUE;
            }
            sqlite3_reset(compiledStatement);
        }else
        {
            NSLog( @"Error while updating '%s'", sqlite3_errmsg(database));
            success = FALSE;
        }
        sqlite3_finalize(compiledStatement);
        
    }
    sqlite3_close(database);
    
    return success;
}

-(NSString *)getOutputStringForQuery:(const char *)queryString{
    // Setup the database object
	sqlite3 *database;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
	// Init the animals Array
	NSString *outputString = @"";
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		//const char *sqlStatement = "select * from States";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, queryString, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                
                outputString = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 0)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
        
	}
	sqlite3_close(database);
    
    return outputString;
    
}
-(NSInteger)getOutputIntForQuery:(const char *)queryString{
    // Setup the database object
	sqlite3 *database;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    NSInteger outPutInt = 0;
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
		//const char *sqlStatement = "select * from States";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, queryString, -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                
                outPutInt = sqlite3_column_int(compiledStatement, 0);

			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
        
	}
	sqlite3_close(database);
    
    return outPutInt;
    
}


#pragma mark - get all items

-(Account *)getAccountInfo {
    NSLog(@"Get Account Info from DB");
	// Setup the database object
	sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    Account *accountObj = [[Account alloc] init];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        NSString *quertyStr = @"SELECT * FROM tbl_user ;";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, [quertyStr UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                accountObj.UserId = sqlite3_column_int(compiledStatement, 0);
                accountObj.UserPhone = sqlite3_column_int64(compiledStatement, 1);
                accountObj.UserDOB = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 2)];
                accountObj.UserDevToken = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 3)];
                accountObj.UserLastLogin = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 4)];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return accountObj;
}



-(Account *)getUserDeviceTokenANDLastLogin {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    Account *acctObj = [Account new];
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *compiledstatement;
        NSString *quertyStrGetFav = @"SELECT user_devicetoken,user_lastlogin FROM tbl_user ";
        const char *quertyGetFav = [quertyStrGetFav UTF8String];
        if(sqlite3_prepare_v2(database, quertyGetFav, -1, &compiledstatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledstatement) == SQLITE_ROW) {
                acctObj.UserDevToken = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledstatement, 0)];
                acctObj.UserLastLogin = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledstatement, 1)];
            }
        }
        sqlite3_finalize(compiledstatement);
    }
    sqlite3_close(database);
    
    return acctObj;
}
-(NSInteger)getMyUserID {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    NSInteger myUserId = 0;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *compiledstatement;
        NSString *quertyStrGetFav = @"SELECT user_id FROM tbl_user ";
        const char *quertyGetFav = [quertyStrGetFav UTF8String];
        if(sqlite3_prepare_v2(database, quertyGetFav, -1, &compiledstatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledstatement) == SQLITE_ROW) {
                myUserId = sqlite3_column_int(compiledstatement, 0);
            }
        }
        sqlite3_finalize(compiledstatement);
    }
    sqlite3_close(database);
    
    return myUserId;
}

+(NSString*)getVideoLocalURL:(NSString*)videoID {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    NSString *videoLocalURL = @"";
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *compiledstatement;
        NSString *quertyStrGetFav = [NSString stringWithFormat:@"SELECT merged_video FROM tbl_chats where video_id = '%d' ",[videoID integerValue]];
//        NSString *quertyStrGetFav = @"SELECT merged_video FROM tbl_chats where video_id = %d ",;
        const char *quertyGetFav = [quertyStrGetFav UTF8String];
        if(sqlite3_prepare_v2(database, quertyGetFav, -1, &compiledstatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledstatement) == SQLITE_ROW) {
                videoLocalURL = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledstatement, 0)];
            }
        }
        sqlite3_finalize(compiledstatement);
    }
    sqlite3_close(database);
    
    return videoLocalURL;
}

-(long long int)getMyPhoneNumber {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    long long int myPhoneNum = 0;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *compiledstatement;
        NSString *quertyStrGetFav = @"SELECT user_phone FROM tbl_user ";
        const char *quertyGetFav = [quertyStrGetFav UTF8String];
        if(sqlite3_prepare_v2(database, quertyGetFav, -1, &compiledstatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledstatement) == SQLITE_ROW) {
                myPhoneNum = sqlite3_column_int64(compiledstatement, 0);
            }
        }
        sqlite3_finalize(compiledstatement);
    }
    sqlite3_close(database);
    
    return myPhoneNum;
}

-(BOOL)checkIfContactExists:(long long int)contactNum {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    BOOL isContactExist = NO;
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *compiledstatement;
        NSString *quertyStrGetFav = [NSString stringWithFormat:@"SELECT user_phone FROM tbl_contacts WHERE user_phone = '%lld'",contactNum];
        const char *quertyGetFav = [quertyStrGetFav UTF8String];
        if(sqlite3_prepare_v2(database, quertyGetFav, -1, &compiledstatement, NULL) == SQLITE_OK) {
            while(sqlite3_step(compiledstatement) == SQLITE_ROW) {
                isContactExist = YES;
            }
        }
        sqlite3_finalize(compiledstatement);
    }
    sqlite3_close(database);
    
    return isContactExist;
}

-(NSMutableArray *)getChatHistoryForUser:(long long int)userPhone {
    NSLog(@"Get Chat Info from DB for user: %lld", userPhone);
	// Setup the database object
	sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    NSMutableArray *chatArray = [[NSMutableArray alloc] init];

	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        NSString *quertyStr = [NSString stringWithFormat:@"SELECT * FROM tbl_chats where to_phone = %lld OR from_phone = %lld ORDER BY id;",userPhone,userPhone];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, [quertyStr UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                Chat *chatObj = [Chat new];
                chatObj.chatId = sqlite3_column_int(compiledStatement, 0);
                chatObj.fromPhone = sqlite3_column_int64(compiledStatement, 1);
                chatObj.toPhone = sqlite3_column_int64(compiledStatement, 2);
                chatObj.contentType = sqlite3_column_int(compiledStatement, 3);
                chatObj.chatText = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 4)];
                chatObj.chatVideo = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 5)];
                chatObj.chatTime = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 6)];
                
                [chatArray addObject:chatObj];
                
//                NSLog(@"chatObj.chatId: %d", chatObj.chatId);
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return chatArray;
}

-(NSMutableArray *)getAllLukChatContacts {
    NSLog(@"getAllLukChatContacts");
	// Setup the database object
	sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    NSMutableArray *contactArray = [[NSMutableArray alloc] init];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        NSString *quertyStr = @"SELECT * FROM tbl_contacts WHERE status = '1' ORDER BY user_fname ASC";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, [quertyStr UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                Contact *contactObj = [Contact new];

                contactObj.user_id = sqlite3_column_int(compiledStatement, 0);
                contactObj.user_phone = sqlite3_column_int64(compiledStatement, 1);
                contactObj.user_fname = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 2)];
                contactObj.user_lname = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 3)];
                contactObj.user_dob = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 4)];
                contactObj.user_status = sqlite3_column_int(compiledStatement, 5);
                
                if (!contactObj.user_fname)
                    contactObj.user_fname = @"";
                if (!contactObj.user_lname)
                    contactObj.user_lname = @"";
                if (!contactObj.user_dob)
                    contactObj.user_dob = @"";

                [contactArray addObject:contactObj];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return contactArray;
}

-(NSMutableArray *)getAllOtherContacts {
    NSLog(@"getAllOtherContacts");
	// Setup the database object
	sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    NSMutableArray *contactArray = [[NSMutableArray alloc] init];
    
	// Open the database from the users filessytem
	if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
		// Setup the SQL Statement and compile it for faster access
        NSString *quertyStr = @"SELECT * FROM tbl_contacts WHERE status = '0' ORDER BY user_fname ASC";
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, [quertyStr UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
			// Loop through the results and add them to the feeds array
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
                Contact *contactObj = [Contact new];
                
                contactObj.user_id = sqlite3_column_int(compiledStatement, 0);
                contactObj.user_phone = sqlite3_column_int64(compiledStatement, 1);
                contactObj.user_fname = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 2)];
                contactObj.user_lname = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 3)];
                contactObj.user_dob = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 4)];
                contactObj.user_status = sqlite3_column_int(compiledStatement, 5);
                
                if (!contactObj.user_fname)
                    contactObj.user_fname = @"";
                if (!contactObj.user_lname)
                    contactObj.user_lname = @"";
                if (!contactObj.user_dob)
                    contactObj.user_dob = @"";
                
                [contactArray addObject:contactObj];
			}
		}
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
    
    return contactArray;
}

+(NSMutableArray *)getAllSentVideoContacts {
    NSLog(@"getAllSentVideoContacts");
    // Setup the database object
    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    NSMutableArray *sentVideosArray = [[NSMutableArray alloc] init];
    
    // Open the database from the users filessytem
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        // Setup the SQL Statement and compile it for faster access
        NSString *quertyStr = @"SELECT t2.user_id,t1.to_phone,t1.from_phone,t2.user_fname,t2.user_lname,t1.chat_text, t1.chat_video, t1.chat_time, t1.merged_video FROM tbl_chats t1,tbl_contacts t2 where t1.to_phone = t2.user_phone ORDER BY t1.id DESC";
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, [quertyStr UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                VideoDetail *videoDetialObj = [VideoDetail new];
                
                videoDetialObj.toUserID = sqlite3_column_int(compiledStatement, 0);
                videoDetialObj.toContact = sqlite3_column_int64(compiledStatement, 1);
                videoDetialObj.fromContact = sqlite3_column_int64(compiledStatement, 2);
                videoDetialObj.fname = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 3)];
                videoDetialObj.lname = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 4)];
                videoDetialObj.videoTitle = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 5)];
                videoDetialObj.videoURL = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 6)];
                videoDetialObj.videoTime = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 7)];
                videoDetialObj.mergedVideoURL =  [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 8)];
                
                if (!videoDetialObj.fname)
                    videoDetialObj.fname = @"";
                if (!videoDetialObj.lname)
                    videoDetialObj.lname = @"";
                if (!videoDetialObj.videoTitle)
                    videoDetialObj.videoTitle = @"";
                if (!videoDetialObj.videoURL)
                    videoDetialObj.videoURL = @"";
                if (!videoDetialObj.videoTime)
                    videoDetialObj.videoTime = @"";
                
                [sentVideosArray addObject:videoDetialObj];
            }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    return sentVideosArray;
}


+(NSMutableArray *)getAllCreatedVideos {
    NSLog(@"getAllCreatedVideos");
    // Setup the database object
    sqlite3 *database;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    NSMutableArray *sentVideosArray = [[NSMutableArray alloc] init];
    
    // Open the database from the users filessytem
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {
        // Setup the SQL Statement and compile it for faster access
        NSString *quertyStr = @"SELECT video_title, merged_video_path, time FROM created_videos ORDER BY id DESC";
        sqlite3_stmt *compiledStatement;
        if(sqlite3_prepare_v2(database, [quertyStr UTF8String], -1, &compiledStatement, NULL) == SQLITE_OK) {
            // Loop through the results and add them to the feeds array
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Read the data from the result row
                VideoDetail *videoDetialObj = [VideoDetail new];
                
                videoDetialObj.videoTitle = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 0)];
                videoDetialObj.mergedVideoURL = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 1)];
                videoDetialObj.videoTime =  [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledStatement, 2)];
                
                if (!videoDetialObj.videoTitle)
                    videoDetialObj.videoTitle = @"";
                if (!videoDetialObj.videoTime)
                    videoDetialObj.videoTime = @"";
                
                [sentVideosArray addObject:videoDetialObj];
            }
        }
        // Release the compiled statement from memory
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
    
    return sentVideosArray;
}


#pragma mark - Insert


-(void)insertAccountInfoToDB:(Account *)accountObj {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *statement;
        NSString *querySQL = @"INSERT OR REPLACE INTO tbl_user (user_id, user_phone, user_dob, user_devicetoken, user_lastlogin) VALUES (?,?,?,?,?); ";
        // NSLog(@"query: %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        // preparing a query compiles the query so it can be re-used.
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_int64(statement, 1, accountObj.UserId);
            sqlite3_bind_int64(statement, 2, accountObj.UserPhone);
            sqlite3_bind_text(statement, 3, [accountObj.UserDOB UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 4, [accountObj.UserDevToken UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 5, [accountObj.UserLastLogin UTF8String], -1, SQLITE_STATIC);

            if(SQLITE_DONE != sqlite3_step(statement))
            {
                NSLog( @"Error while inserting Account: '%s'", sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"Account with UserPhone: %lld inserted: ",(long long int)accountObj.UserPhone);
            }
            sqlite3_reset(statement);
        }else
        {
            NSLog( @"Error while inserting Account '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
    
}

-(void)updateAccountInfoToDB:(Account *)accountObj {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        sqlite3_stmt    *statement;
//        NSString *querySQL =[NSString stringWithFormat:@"UPDATE tbl_user set user_id = ?, user_dob =? WHERE user_phone = ?"];
        NSString *querySQL =[NSString stringWithFormat:@"UPDATE tbl_user set user_id = ?, user_dob =? , user_phone = ?"];
        // NSLog(@"query: %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        // preparing a query compiles the query so it can be re-used.
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_int64(statement, 1, accountObj.UserId);
            sqlite3_bind_text(statement, 2, [accountObj.UserDOB UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_int64(statement, 3, accountObj.UserPhone);

            
            if(SQLITE_DONE != sqlite3_step(statement))
            {
                NSLog( @"Error while updating Account: '%s'", sqlite3_errmsg(database));
            }
            else
            {
                NSLog(@"Account with user_phone: %lld updated with ID: %ld ",accountObj.UserPhone,(long)accountObj.UserId);
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%lld",accountObj.UserPhone] forKey:kMYPhoneNumber];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%ld",(long)accountObj.UserId] forKey:kMYUSERID];
            }
            sqlite3_reset(statement);
        }else
        {
            NSLog( @"Error while updating Account '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
    
}

-(void)updateMyPhoneNumberInDB:(long long int)phoneNum {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        
        sqlite3_stmt    *statement;
        NSString *querySQL =[NSString stringWithFormat:@"UPDATE tbl_user set user_phone = ?"];
        // NSLog(@"query: %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        // preparing a query compiles the query so it can be re-used.
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_int64(statement, 1, phoneNum);
            
            
            if(SQLITE_DONE != sqlite3_step(statement))
            {
                NSLog( @"Error while updating Account: '%s'", sqlite3_errmsg(database));
            }
            else
            {
               // NSLog(@"Account with user_phone: %lld updated  ",phoneNum);
            }
            sqlite3_reset(statement);
        }else
        {
            NSLog( @"Error while updating Account '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
    
}



-(void)insertChatInfoToDB:(Chat *)chatObj {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *statement;
        NSString *querySQL = @"INSERT INTO tbl_chats (from_phone , to_phone , content_type , chat_text , chat_video , chat_time, merged_video, video_id ) VALUES (?,?,?,?,?,?,?,?); ";
        // NSLog(@"query: %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        // preparing a query compiles the query so it can be re-used.
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            //sqlite3_bind_int64(statement, 1, chatObj.chatId);
            sqlite3_bind_int64(statement, 1, chatObj.fromPhone);
            sqlite3_bind_int64(statement, 2, chatObj.toPhone);
            sqlite3_bind_int64(statement, 3, chatObj.contentType);
            sqlite3_bind_text(statement, 4, [chatObj.chatText UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 5, [chatObj.chatVideo UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 6, [chatObj.chatTime UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 7, [chatObj.mergedVideo UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_int64(statement, 8, [chatObj.videoID integerValue]);

            if(SQLITE_DONE != sqlite3_step(statement))
            {
                NSLog( @"Error while inserting chatObj: '%s'", sqlite3_errmsg(database));
            }
            else
            {
               // NSLog(@"chatObj with ID: %ld inserted: ",(long)chatObj.chatId);
            }
            sqlite3_reset(statement);
        }else
        {
            NSLog( @"Error while inserting chatObj '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
    
}

-(void)insertCreatedVideoInfoInDB:(Chat *)chatObj {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *statement;
        NSString *querySQL = @"INSERT INTO created_videos (video_title , merged_video_path , time) VALUES (?,?,?); ";
         NSLog(@"query: %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        // preparing a query compiles the query so it can be re-used.
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            
            sqlite3_bind_text(statement, 1, [chatObj.chatText UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 2, [chatObj.mergedVideo UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 3, [chatObj.chatTime UTF8String], -1, SQLITE_STATIC);
            
            if(SQLITE_DONE != sqlite3_step(statement))
            {
                NSLog( @"Error while inserting chatObj: '%s'", sqlite3_errmsg(database));
            }
            else
            {
                // NSLog(@"chatObj with ID: %ld inserted: ",(long)chatObj.chatId);
            }
            sqlite3_reset(statement);
        }else
        {
            NSLog( @"Error while inserting chatObj '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
    
}

-(void)insertContactInfoToDB:(Contact *)contactObj {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        if (!contactObj.user_fname || contactObj.user_fname.length < 1) {
            // 1. Get isFavourite value of the Item
            sqlite3_stmt    *compiledstatement;
            NSString *quertyStrGetFav =[NSString stringWithFormat:@"SELECT user_fname,user_lname FROM tbl_contacts WHERE user_phone = '%lld' ;",contactObj.user_phone];
            const char *quertyGetFav = [quertyStrGetFav UTF8String];
            if(sqlite3_prepare_v2(database, quertyGetFav, -1, &compiledstatement, NULL) == SQLITE_OK) {
                while(sqlite3_step(compiledstatement) == SQLITE_ROW) {
                    contactObj.user_fname = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledstatement, 0)];
                    contactObj.user_lname = [NSString stringWithFormat:@"%s",(const char*)sqlite3_column_text(compiledstatement, 1)];
                }
            }
            sqlite3_finalize(compiledstatement);
        }
        if (!contactObj.user_fname)
            contactObj.user_fname = @"";
        if (!contactObj.user_lname)
            contactObj.user_lname = @"";
        if (!contactObj.user_dob)
            contactObj.user_dob = @"";


        // 2. Insert or update the Item with the above value for isFavourite
        // prep statement
        sqlite3_stmt    *statement;
        NSString *querySQL =[NSString stringWithFormat:@"INSERT INTO tbl_contacts (user_id , user_phone , user_fname , user_lname , user_dob , status ) VALUES (?,?,?,?,?,?)"];
        // NSLog(@"query: %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        // preparing a query compiles the query so it can be re-used.
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_int64(statement, 1, contactObj.user_id);
            sqlite3_bind_int64(statement, 2, contactObj.user_phone);
            sqlite3_bind_text(statement, 3, [contactObj.user_fname UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 4, [contactObj.user_lname UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_text(statement, 5, [contactObj.user_dob UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_int64(statement, 6, contactObj.user_status);
            
            if(SQLITE_DONE != sqlite3_step(statement))
            {
                NSLog( @"Error while inserting Contact: '%s'", sqlite3_errmsg(database));
            }
            else
            {
               // NSLog(@"Contact with user_phone: %lld inserted: ",contactObj.user_phone);
            }
            sqlite3_reset(statement);
        }else
        {
            NSLog( @"Error while inserting Contact '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
    
}

-(void)updateContactInfoToDB:(Contact *)contactObj {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath=  [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
    
    sqlite3 *database;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt    *statement;
        NSString *querySQL =[NSString stringWithFormat:@"UPDATE tbl_contacts set user_id = ?, user_dob =?, status =? WHERE user_phone = ?"];
        // NSLog(@"query: %@", querySQL);
        const char *query_stmt = [querySQL UTF8String];
        
        // preparing a query compiles the query so it can be re-used.
        if(sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            sqlite3_bind_int64(statement, 1, contactObj.user_id);
            sqlite3_bind_text(statement, 2, [contactObj.user_dob UTF8String], -1, SQLITE_STATIC);
            sqlite3_bind_int64(statement, 3, contactObj.user_status);
            sqlite3_bind_int64(statement, 4, contactObj.user_phone);

            
            if(SQLITE_DONE != sqlite3_step(statement))
            {
                NSLog( @"Error while updating Contact: '%s'", sqlite3_errmsg(database));
            }
            else
            {
              //  NSLog(@"Contact with user_phone: %lld updatedwith ID: %d ",contactObj.user_phone,contactObj.user_id);
            }
            sqlite3_reset(statement);
        }else
        {
            NSLog( @"Error while updating Contact '%s'", sqlite3_errmsg(database));
        }
        sqlite3_finalize(statement);
        
    }
    sqlite3_close(database);
    
}

                             
@end
