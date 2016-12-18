//
//  AlbumPhotoStruct.h
//  Zinger
//
//  Created by Tianming on 22/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupInfoStruct : NSObject
{
    NSInteger iOwnUserId;
    NSInteger iGroupID;
    NSString *strGroupName;
    NSMutableArray *arrFriendIds;
}

-(void) initWithJSonData:(NSDictionary *)dict;

-(void) setGroupName:(NSString *)groupname;
-(void) setGroupID:(NSInteger)groupid;

-(NSMutableArray *) getFriendIDs;
-(NSInteger) getGroupID;
-(NSString *) getGrouIDToString;
-(NSString *) getGroupName;
-(NSString *) getGroupNameToShow;
-(NSInteger) getUserID;

@end
