//
//  UserInfo.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "UserInfoStruct.h"

@implementation UserInfoStruct

- (id) init

{
    if(self = [super init])
    {
        [self initVariable];
    }
    
    return self;
}

-(void) initVariable
{
    self.strFirstName = @"";
    self.strLastName = @"";
    self.strCity = @"";
    self.strState = @"";
    self.strCountry = @"";
    self.strEmail = @"";
    self.strPinCode = @"";
    self.strUserId = @"";
    self.strPassword = @"";
    self.strPhotoUrl = @"";
    self.bShowedTerm = NO;
    self.bShowedPrivacy = NO;
    self.iUserID = 0;
    self.strSecurityKey = @"";
}

-(void) initWithLoginInfo:(NSString *)email password:(NSString *)password
{
    self.strEmail = email;
    self.strPassword = password;
    self.iUserID = 0;
    self.iFilterType = 1;
}

-(void) initWithJsonData:(NSDictionary *)dict
{
    if (!dict)
    {
        [self initVariable];
        return;
    }
    
    self.strFirstName = [dict objectForKey:@"firstname"];
    self.strLastName = [dict objectForKey:@"lastname"];
    self.strCity = [dict objectForKey:@"city"];
    self.strState = [dict objectForKey:@"state"];
    self.strCountry = [dict objectForKey:@"country"];
    self.strEmail = [dict objectForKey:@"email"];
    self.strPhotoUrl = [dict objectForKey:@"photo"];
    self.strPinCode = [dict objectForKey:@"pincode"];
    self.strUserId = [dict objectForKey:@"userid"];
    self.bShowedPrivacy = [[dict objectForKey:@"vprivacy"] integerValue] == 1;
    self.bShowedTerm = [[dict objectForKey:@"vterm"] integerValue] == 1;
    self.iUserID = [self.strUserId integerValue];
    self.bShowFriendNotif = [[dict objectForKey:@"photonoti"] integerValue] == 1;
    self.bShowPhotoNotif = [[dict objectForKey:@"friendnoti"] integerValue] == 1;
    self.bShowPhotoNotif = [[dict objectForKey:@"friendnoti"] integerValue] == 1;
    self.iFilterType = [[dict objectForKey:@"filtermode"] integerValue];
    
    self.strSecurityKey = [dict objectForKey:@"key"];
}

-(BOOL) isLogined
{
    return self.iUserID > 0;
}

-(BOOL) isFirstLogin
{
    return self.iFilterType < 1;
}

-(NSURL *) getPhotoURL
{
    return [NSURL URLWithString:self.strPhotoUrl];
}

-(void)refreshFlag
{
    self.iFilterType = 1;
}

-(NSInteger) getUserID
{
    return [self.strUserId integerValue];
}

@end
