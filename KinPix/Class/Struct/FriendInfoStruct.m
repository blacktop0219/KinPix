//
//  FriendInfoStruct.m
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "FriendInfoStruct.h"

@implementation FriendInfoStruct

-(id) init
{
    iUserID = 0;
    strFirstName = strLastName = @"";
    strPhotoUrl = @"";
    return self;
}

-(void) initWithJSonData:(NSDictionary *)dict
{
//    cif_fuserid fuserid, cif_tuserid tuserid, type, companyname,
//    firstname, lastname, photo, sex
    strFirstName = [dict objectForKey:@"firstname"];
    strLastName = [dict objectForKey:@"lastname"];
    strPhotoUrl = [dict objectForKey:@"photo"];
    iUserID = [[dict objectForKey:@"userid"] integerValue];        
}

-(void) setUserID:(NSInteger)userid
{
    iUserID = userid;
}

-(void) setFirstName:(NSString *)firstname
{
    strFirstName = firstname;
}

-(void) setLastName:(NSString *)lastname
{
    strLastName = lastname;
}

-(void) setPhotoURL:(NSString *)photo;
{
    strPhotoUrl = photo;
}

-(void) setNewPhotoCount:(NSInteger)photocount
{
    iNewPhotoCount = photocount;
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSString *) getUserIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iUserID];
}

-(NSString *) getFirstName
{
    return strFirstName;
}

-(NSString *) getLastName
{
    return strLastName;
}

-(NSString *) getPhotoStringURL
{
    return strPhotoUrl;
}

-(NSURL *) getPhotoURL
{
    return [NSURL URLWithString:strPhotoUrl];
}


-(NSInteger) getNewPhotoCount
{
    return iNewPhotoCount;
}

-(NSArray *) getPhotoIDs
{
    return arrPhotoIds;
}

-(NSArray *) getAlbumIds
{
    return arrAlbumIds;
}

-(NSString *) getUserName
{
    return [NSString stringWithFormat:@"%@ %@", strFirstName, strLastName];
}
@end
