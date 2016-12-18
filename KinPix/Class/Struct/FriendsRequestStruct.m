//
//  FriendsRequestStruct.m
//  Zinger
//
//  Created by Tianming on 25/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "FriendsRequestStruct.h"

@implementation FriendsRequestStruct

-(id) init
{
    iUserID = 0;
    bMale = YES;
    bCompany = NO;
    return self;
}

-(void) initWithJSonData:(NSDictionary *)dict
{
    //cif_fuserid , ci_firstname firstname, ci_lastname lastname,
    //ci_photo photo, ci_sex sex
    iUserID = [[dict objectForKey:@"userid"] integerValue];
    strFirstName = [dict objectForKey:@"firstname"];
    strLastName = [dict objectForKey:@"lastname"];
    strPhotoUrl = [dict objectForKey:@"photo"];
    NSString *strSex = [dict objectForKey:@"sex"];
    bMale = ![strSex isEqualToString:@"f"];
    bCompany = [[dict objectForKey:@"type"] isEqualToString:@"1"];
}

- (BOOL) isMale
{
    return bMale;
}

- (BOOL) isCompany
{
    return bCompany;
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSString *) getUserIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iUserID];
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
    return [NSString stringWithFormat:@"%@ %@", strFirstName, strLastName];
}


@end
