//
//  BucketInfoStruct.m
//  Zinger
//
//  Created by Tianming on 09/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "BucketInfoStruct.h"

@implementation BucketInfoStruct

-(id) init
{
    if (!arrPhotoIDs)
        arrPhotoIDs = [[NSMutableArray alloc] init];
    
    return self;
}


-(void) initWithJSonData:(NSDictionary *)dict
{
    iBucketID = [[dict objectForKey:@"bucketid"] integerValue];
    strBucketName = [dict objectForKey:@"name"];
    iUserID = [[dict objectForKey:@"userid"] integerValue];
    arrUserIDs = [dict objectForKey:@"suserids"];
    arrGroupIDs = [dict objectForKey:@"sgroupids"];
    
    if (!arrPhotoIDs)
        arrPhotoIDs = [[NSMutableArray alloc] init];
}

-(NSString *) getBucketName
{
    return strBucketName;
}

-(void) setBucketID:(NSString *)strid
{
    iBucketID = [strid integerValue];
}

-(void) setBucketOwnerID:(NSString *)ownerid
{
    iUserID = [ownerid integerValue];
}

-(void) setBucketName:(NSString *)name
{
    if (name && name.length > 0)
        strBucketName = name;
}

-(NSString *) getBucketName:(BOOL)newline
{
    if ([self isMyBucket])
        return strBucketName;
    
    FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:iUserID];
    if (finfo)
    {
        if (newline)
            return [NSString stringWithFormat:@"%@\n(%@)", [finfo getUserName], strBucketName];
        
        return [NSString stringWithFormat:@"%@ : %@", [finfo getUserName], strBucketName];
    }
    else
        return strBucketName;
}

-(NSMutableArray *) getBucketPhotoIDs
{
    return arrPhotoIDs;
}

-(NSInteger) getBucketID
{
    return iBucketID;
}

-(NSString *) getBucketIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iBucketID];
}

-(NSString *) getBucketOwnerName
{
    if ([self isMyBucket])
        return @"Me";
    
    FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:iUserID];
    if (finfo)
        return [finfo getUserName];
    
    return @"Unknown";
}

-(NSString *) getFriendsBucketName
{
    FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:iUserID];
    if (finfo)
        return [NSString stringWithFormat:@"%@\n(%@)", [finfo getFirstName], strBucketName];
    
    return strBucketName;
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSArray *) getBucketUserIDs
{
    return arrUserIDs;
}

-(NSArray *) getBucketGroupIDs
{
    return arrGroupIDs;
}

-(NSString *) getUserIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iUserID];
}

-(NSInteger) getNewPhotoCount
{
    return iNewPhotoCount;
}

-(BOOL) isMyBucket
{
    if ([[AppDelegate sharedInstance].objUserInfo.strUserId integerValue] == iUserID)
        return YES;
    
    return NO;
}

@end
