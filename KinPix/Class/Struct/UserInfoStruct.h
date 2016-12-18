//
//  UserInfo.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoStruct : NSObject

@property (strong, nonatomic) NSString *strFirstName;
@property (strong, nonatomic) NSString *strLastName;
@property (strong, nonatomic) NSString *strCity;
@property (strong, nonatomic) NSString *strState;
@property (strong, nonatomic) NSString *strCountry;
@property (strong, nonatomic) NSString *strEmail;
@property (strong, nonatomic) NSString *strPhotoUrl;
@property (strong, nonatomic) NSString *strPinCode;
@property (strong, nonatomic) NSString *strUserId;
@property (strong, nonatomic) NSString *strPassword;
@property (strong, nonatomic) NSString *strSecurityKey;

@property (nonatomic) BOOL bShowedTerm;
@property (nonatomic) BOOL bShowedPrivacy;
@property (nonatomic) BOOL bShowFriendNotif;
@property (nonatomic) BOOL bShowPhotoNotif;
@property (nonatomic) NSInteger iUserID;
@property (nonatomic) NSInteger iFilterType;


-(void) initWithJsonData:(NSDictionary *)dict;
-(void) initWithLoginInfo:(NSString *)email password:(NSString *)password;

-(NSInteger) getUserID;
-(BOOL) isLogined;
-(BOOL) isFirstLogin;
-(void) refreshFlag;
-(NSURL *) getPhotoURL;

@end
