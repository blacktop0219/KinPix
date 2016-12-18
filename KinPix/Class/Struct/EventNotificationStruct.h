//
//  EventNotificationStruct.h
//  Zinger
//
//  Created by Tianming on 25/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventNotificationStruct : NSObject
{
    NSInteger iUserID;
    NSString *strQueueID;
    NSInteger iPhotoCount;
    NSArray *arrPhotoIds;
    NSInteger iTimeSec;
    NSInteger iType;
    NSInteger iBucketID;
    NSString *strFirstName;
    NSString *strLastName;
    NSString *strProfileUrl;
    
    NSInteger iOwnUserID;
    NSString *strOwnFirstname;
    NSString *strOwnLastname;
    BOOL bReadFlag;
}

-(void) initWithJSonData:(NSDictionary *)dict;
-(void) setReaded:(BOOL)flag;

-(NSInteger) getUserID;
-(NSString *) getQueueID;
-(NSInteger) getBucketID;
-(NSString *) getMessage:(FriendInfoStruct *) info;
-(NSInteger) getTimeSec;
-(NSInteger) getPhotoCount;
-(NSString *) getTimeToString;
-(NSArray *) getPhotoIDs;
-(NSString *) getPhotoIDsToString;
-(BOOL) isMyNotification;
-(BOOL) isReaded;
-(BOOL) isBucketViewNotification;

@end
