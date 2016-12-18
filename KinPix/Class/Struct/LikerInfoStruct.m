//
//  LikerInfoStruct.m
//  Zinger
//
//  Created by Piao Dev on 20/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "LikerInfoStruct.h"

@implementation LikerInfoStruct

-(id) init
{
    iUserID = 0;
    return self;
}

-(void) initWithJSonData:(NSDictionary *)dict
{
    //cif_fuserid , ci_firstname firstname, ci_lastname lastname,
    //ci_photo photo, ci_sex sex
    iUserID = [[dict objectForKey:@"userid"] integerValue];
    iLikeID = [[dict objectForKey:@"likeid"] integerValue];
    strFirstName = [dict objectForKey:@"firstname"];
    strLastName = [dict objectForKey:@"lastname"];
    strPhotoUrl = [dict objectForKey:@"photo"];
    iTimeSec = [[dict objectForKey:@"time"] integerValue];
}

- (BOOL) isMyLike
{
    if (iUserID == [[AppDelegate sharedInstance].objUserInfo getUserID])
        return YES;
    
    return NO;
}

-(NSInteger) getLikeID
{
    return iLikeID;
}

-(NSString *) getLikeIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iLikeID];
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSString *) getPhotoStringURL
{
    return strPhotoUrl;
}

-(NSURL *) getPhotoURL
{
    return [NSURL URLWithString:strPhotoUrl];
}

-(NSString *) getUserName
{
    if ([[AppDelegate sharedInstance].objUserInfo getUserID] == iUserID)
        return @"Me";
    
    return [NSString stringWithFormat:@"%@ %@", strFirstName, strLastName];
}

-(NSString *) getTimeString
{
    return [Utils getTimeString:iTimeSec];
}
@end
