//
//  AlbumPhotoStruct.m
//  Zinger
//
//  Created by Tianming on 22/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "GroupInfoStruct.h"

@implementation GroupInfoStruct

-(id) init
{
    iGroupID = 0;
    strGroupName = @"";
    arrFriendIds = [[NSMutableArray alloc] init];
    iOwnUserId = 0;
    
    return self;
}


-(void) initWithJSonData:(NSDictionary *)dict
{
    iOwnUserId = [[dict objectForKey:@"userid"] integerValue];
    iGroupID = [[dict objectForKey:@"groupid"] integerValue];
    strGroupName = [dict objectForKey:@"name"];
    NSArray *arr = [dict objectForKey:@"users"];
    for (NSString *userid in arr)
        [arrFriendIds addObject:userid];
}

-(void) setGroupName:(NSString *)groupname
{
    strGroupName = groupname;
}

-(void) setGroupID:(NSInteger)groupid
{
    iGroupID = groupid;
}

-(NSMutableArray *) getFriendIDs
{
    return arrFriendIds;
}

-(NSInteger) getGroupID
{
    return iGroupID;
}

-(NSInteger) getUserID
{
    return iOwnUserId;
}

-(NSString *) getGrouIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iGroupID];
}

-(NSString *) getGroupName
{
    return strGroupName;
}

-(NSString *) getGroupNameToShow
{
    return strGroupName;
    
    if (strGroupName.length < 8)
        return strGroupName;
    
    NSMutableString *strResult = [NSMutableString stringWithString:strGroupName];
    [strResult insertString:@"\n" atIndex:8];
    return strResult;
}

@end
