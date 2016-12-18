//
//  EventNotificationStruct.m
//  Zinger
//
//  Created by Tianming on 25/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "EventNotificationStruct.h"

@implementation EventNotificationStruct


-(void) initWithJSonData:(NSDictionary *)dict
{
    iUserID = [[dict objectForKey:@"userid"] integerValue];
    strQueueID = [dict objectForKey:@"queueid"];
    iTimeSec = [[dict objectForKey:@"diffsec"] integerValue];
    arrPhotoIds = [dict objectForKey:@"photoids"];
    iPhotoCount = [arrPhotoIds count];
    iType = [[dict objectForKey:@"histype"] integerValue];
    bReadFlag = [[dict objectForKey:@"readflg"] integerValue] > 0;
    strFirstName = [dict objectForKey:@"firstname"];
    strLastName = [dict objectForKey:@"lastname"];
    strProfileUrl = [dict objectForKey:@"photo"];
    
    iOwnUserID = [[dict objectForKey:@"ouserid"] integerValue];
    strOwnFirstname = [dict objectForKey:@"ofirstname"];
    strOwnLastname = [dict objectForKey:@"olastname"];
    iBucketID = [[dict objectForKey:@"bucketid"] integerValue];
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSString *) getQueueID
{
    return strQueueID;
}

-(NSString *) getMessage:(FriendInfoStruct *) info
{
    NSString *strMessage;
    BucketInfoStruct *binfo = [[AppDelegate sharedInstance] findBucketInfoByID:iBucketID];
    switch (iType)
    {
        case 1:
            strMessage = [NSString stringWithFormat:@"You have sent a invite to %@ %@.", [info getFirstName], [info getLastName]];
            break;
            
        case 51:
            strMessage = [NSString stringWithFormat:@"You have received a invite from %@ %@.", [info getFirstName], [info getLastName]];
            break;
            
        case 2:
            strMessage = [NSString stringWithFormat:@"You have accepted %@ %@ invite.", [info getFirstName], [info getLastName]];
            break;
            
        case 52:
            strMessage = [NSString stringWithFormat:@"%@ %@ has accepted your invite.", [info getFirstName], [info getLastName]];
            break;
            
        case 3:
            strMessage = [NSString stringWithFormat:@"You have ignored %@ %@ invite.", [info getFirstName], [info getLastName]];
            break;
            
        case 53:
            strMessage = [NSString stringWithFormat:@"%@ %@ has ignored your invite.", [info getFirstName], [info getLastName]];
            break;
            
        case 4:
            strMessage = [NSString stringWithFormat:@"You have removed %@ %@ as a people.", [info getFirstName], [info getLastName]];
            break;
            
        case 54:
            strMessage = [NSString stringWithFormat:@"%@ %@ has removed you as a people.", [info getFirstName], [info getLastName]];
            break;
            
            //----- 101 : photoshared (by me), 	102:like photo			103:comment photo
            //----- 111 : photoshared				112:like photo			113:comment photo
            
        case 101:
            strMessage = [NSString stringWithFormat:@"You have shared %d photos with %@ %@.", (int)iPhotoCount, [info getFirstName], [info getLastName]];
            break;
            
            //----- 101 : photoshared (by me), 	102:like photo			103:comment photo
            //----- 111 : photoshared				112:like photo			113:comment photo
            
        case 102:
            strMessage = [NSString stringWithFormat:@"You have liked %@ %@'s photo.", [info getFirstName], [info getLastName]];
            break;
            
        case 103:
            strMessage = [NSString stringWithFormat:@"You have commented on %@ %@'s photo.", [info getFirstName], [info getLastName]];
            break;
            
            
        case 111:
            strMessage = [NSString stringWithFormat:@"%@ %@ has shared %d photo(s) with you.", [info getFirstName], [info getLastName], (int)iPhotoCount];
            break;
            
        case 112:
            strMessage = [NSString stringWithFormat:@"%@ %@ has liked your photo.", [info getFirstName], [info getLastName]];
            break;
            
        case 115:
            strMessage = [NSString stringWithFormat:@"%@ %@ has commented on a photo in the %@ group album, owned by %@.", [info getFirstName], [info getLastName], [binfo getBucketName], [binfo isMyBucket] ? @"you" : [binfo getBucketOwnerName]];
            break;
            
        case 105:
            strMessage = [NSString stringWithFormat:@"You have commented on a photo in the %@ group album, owned by %@.",  [binfo getBucketName], [binfo isMyBucket] ? @"you" : [binfo getBucketOwnerName]];
            break;
            
        case 114:
            strMessage = [NSString stringWithFormat:@"%@ %@ added %d photo(s) to the %@ group album, owned by %@.", [info getFirstName], [info getLastName], (int)iPhotoCount, [binfo getBucketName], [binfo isMyBucket] ? @"you" : [binfo getBucketOwnerName]];
            break;
            
        case 104:
            strMessage = [NSString stringWithFormat:@"You added %d photo(s) to the %@ group album, owned by %@.", (int)iPhotoCount, [binfo getBucketName], [binfo isMyBucket] ? @"you" : [binfo getBucketOwnerName]];
            break;
            
        case 113:
            if ([[AppDelegate sharedInstance].objUserInfo getUserID] == iOwnUserID)
                strMessage = [NSString stringWithFormat:@"%@ %@ commented on your photo.", [info getFirstName], [info getLastName]];
            else
                strMessage = [NSString stringWithFormat:@"%@ %@ commented on %@ %@'s photo.", [info getFirstName],
                              [info getLastName], strOwnFirstname, strOwnLastname];
            break;
            
        case 120:
            strMessage = [NSString stringWithFormat:@"You added %@ %@ to the %@ group album.", [info getFirstName], [info getLastName], [binfo getBucketName]];
            break;
            
        case 121:
            strMessage = [NSString stringWithFormat:@"%@ %@ added you to the %@ group album.", [info getFirstName], [info getLastName], [binfo getBucketName]];
            break;
    }
    return strMessage;
}

-(BOOL) isMyNotification
{
    if (iType < 50 || (iType > 100 && iType < 110))
        return YES;
    
    return NO;
}

-(BOOL) isBucketViewNotification
{
    if (iType >= 120)
        return YES;
    
    return NO;
}

-(BOOL) isReaded
{
    return bReadFlag;
}

-(void) setReaded:(BOOL)flag
{
    bReadFlag = flag;
}

-(NSInteger) getBucketID
{
    return iBucketID;
}

-(NSArray *) getPhotoIDs
{
    return arrPhotoIds;
}

-(NSString *) getPhotoIDsToString
{
    NSString *str = @"";
    for (NSString *strid in arrPhotoIds) {
        if (str.length < 1)
            str = strid;
        else
            str = [NSString stringWithFormat:@"%@,%@", str, strid];
    }
    return str;
}

-(NSInteger) getTimeSec
{
    return iTimeSec;
}

-(NSInteger) getPhotoCount
{
    return iPhotoCount;
}

-(NSString *) getTimeToString
{
    if (iTimeSec > 0)
        return [Utils getHistoryDateStr:(int)-iTimeSec];
    
    return [Utils getHistoryDateStr:(int)iTimeSec];
}

@end
