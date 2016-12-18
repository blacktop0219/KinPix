//
//  Utils.h
//  FDBK
//
//  Created by QingHou on 10/8/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "FriendInfoStruct.h"
#import "ParseData.h"

#define NOTIF_KEY_USER_LOGIN @"userlogin"

@interface NSDictionary (Extend)
- (NSString *) safeStringForKey: (id)key;
@end

@interface NSObject (Serialize)

- (NSMutableDictionary *) serializeObjectPropertiesToDictionary;
- (NSMutableDictionary *) serializeObjectPropertiesToDictionaryExceptProperties:(NSArray *)exceptProperties;
- (void) deserializeDictionaryToObjectProperties:(NSDictionary *)dict;
- (void) deserializeDictionaryToObjectProperties:(NSDictionary *)dict exceptProperties:(NSArray *)exceptProperties;
@end

@interface Utils : NSObject

// Find And Default Info
+(void) findAndAddFriendsInfo:(NSMutableArray *)array friendid:(NSInteger)friendid;
+(void) findAndAddGroupInfo:(NSMutableArray *)array groupid:(NSInteger)groupid;

// Site relations
+(UIImage *) getDefaultProfileImage;
+(NSString *) generateSecurityKey:(NSString *)udid email:(NSString *)email sec:(NSInteger)sec;

+(NSURL *) getPhotoFunctionURL:(NSString *)func;
+(NSURL *) getUserFunctionURL:(NSString *)func;
+(NSURL *) getGroupFunctionURL:(NSString *)func;
+(NSURL *) getFriendsFunctionURL:(NSString *)func;
+(NSURL *) getEventFunctionURL:(NSString *)func;

// Other functions
+ (BOOL)isValidEmailAddress:(NSString *)emailAddress;
+(BOOL) stringIsNumeric:(NSString *) str;
+(void) copyArray:(NSMutableArray *)src desarray:(NSMutableArray *)dest;
+(void) getBackgroundLocalPhotos:(NSMutableArray *) arrBackground;
+(BOOL) saveBackgroundPhoto:(NSData *) imageData filename:(NSString *)filename;
+(UIImage *) getBackgroundPhoto:(NSString *) strFileName;
+(UIImage *) getThumbImage:(UIImage*)image;
+(NSData *) getThumbImageData:(UIImage*)image;
+(NSString *) generateProfileName;

+ (NSString *) getStrigDate:(int)secOffset;
+ (NSString *) getHistoryDateStr:(int)secOffset;
+ (NSString *) getDateStrFromOffset:(int)secOffset;
+ (NSString *) getStrigFromDate:(NSDate*)date;
+ (NSString *) getMonthStrigFromDate:(NSDate*)date;
+ (NSString *) getMonthStrigFromDateForDB:(NSDate*)date;
+ (NSString *) getYearStrigFromDat:(NSDate*)date;
+ (NSString *) getTimeString:(NSInteger) second;
+ (NSString *) getStringFromInteger:(NSInteger)value;

+ (NSDate *) getDateFromString:(NSString*)strDate;
+ (NSDate *) getMonthFromString:(NSString*)strDate;

+ (NSString *) getStrDateForFeed:(NSDate*)date isCurTime:(BOOL)isCurTime;
+ (NSString*) convertDateString:(NSString*)strDate isCurTime:(BOOL)isCurTime;
+ (NSInteger)getDifferenceDays:(NSDate *) startDate toDate:(NSDate *) endDate;

+(NSString*) getSafePhoneNumber:(NSString*)str;
+(BOOL) isNumberIncluded:(NSString*)str;
+(BOOL) validateEmail: (NSString *) str;

@end
