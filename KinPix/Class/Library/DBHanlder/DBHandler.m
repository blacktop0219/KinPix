//
//  ContentsModel.m
//  SentisApp
//
//  Created by IThelp on 11/1/12.
//  Copyright (c) 2012 IThelp. All rights reserved.
//

#define strDocumentPath [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define strResourcePath [[NSBundle mainBundle] resourcePath]
#define DATABASE_NAME	@"zinger.sqlite"

#import "DBHandler.h"
#import "FriendInfoStruct.h"

@implementation DBHandler

- (id)init
{
    self = [super init];
    return self;
    
}

-(sqlite3 *) openDatabase
{
    NSString *dbPath = [NSString stringWithFormat:@"%@/%@", strDocumentPath,DATABASE_NAME];
    sqlite3 *database = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbPath])
    {
        if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "CREATE TABLE IF NOT EXISTS tbl_friends (cip_id INTEGER PRIMARY KEY, ci_firstname TEXT, ci_lastname TEXT, ci_profile TEXT, ci_company TEXT, ci_maleflag INTEGER, ci_companyflag INTEGER)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
            {
                sqlite3_close(database);
                return nil;
            }
        }
        else
        {
            if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK)
                return database;
        }
    }
    
    return nil;
}


-(void)insertFriendsList:(NSMutableArray *)list replace:(BOOL)replace
{
    if (replace)
        [self deleteAllFriends];
    
	sqlite3_stmt *stmt = nil;
    sqlite3 *database = [self openDatabase];
    if (database)
    {
		const char *sql = "INSERT INTO tbl_friends(cip_id, ci_firstname, ci_lastname, ci_profile, ci_company, ci_maleflag, ci_companyflag) VALUES(?, ?, ?, ?, ?, ?, ?)";
		if(sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) == SQLITE_OK)
        {
            sqlite3_exec(database, "BEGIN TRANSACTION", NULL, NULL, NULL);
            for (int i = 0; i < list.count; i++)
            {
                FriendInfoStruct *obj = [list objectAtIndex:i];
                sqlite3_bind_int(stmt, 1, (int)[obj getUserID]);
                sqlite3_bind_text(stmt, 2, [[obj getFirstName] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(stmt, 3, [[obj getLastName] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(stmt, 4, [[obj getProfilePhoto] UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_step(stmt);
                
                sqlite3_clear_bindings(stmt);
                sqlite3_reset(stmt);
            }
            
            sqlite3_exec(database, "END TRANSACTION", NULL, NULL, NULL);
            sqlite3_finalize(stmt);
        }
        
        sqlite3_close(database);
	}
}

- (void) deleteAllFriends
{
    sqlite3 *database = [self openDatabase];
    if (database)
    {
        char *errMsg;
        const char *sql_stmt = "DELETE FROM tbl_friends;";
        sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg);
        sqlite3_close(database);
    }
}


-(NSMutableArray *)getFriendsList:(NSString *)strKeyword
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    sqlite3_stmt *stmt = nil;
    sqlite3 *database = [self openDatabase];
	if (database)
    {
		const char *sql = "SELECT cip_id, ci_firstname, ci_lastname, ci_profile, ci_company, ci_maleflag, ci_companyflag FROM tbl_friends";
		if(sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) == SQLITE_OK)
        {
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
				FriendInfoStruct *obj = [[FriendInfoStruct alloc] init];
                [obj setUserID:sqlite3_column_int(stmt, 0)];
				[obj setFirstName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 1)]];
                [obj setLastName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 2)]];
                [obj setPhotoName:[NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, 3)]];
                [array addObject:obj];
            }
		}
        
        sqlite3_finalize(stmt);
        sqlite3_close(database);
	}
    
    return array;
}


@end
