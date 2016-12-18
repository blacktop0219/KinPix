//
//  Utils.m
//  FDBK
//
//  Created by QingHou on 10/8/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "Utils.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

#define SEC_YEAR    (3600 * 24 * 365)
#define SEC_MONTH   (3600 * 24 * 30)
#define SEC_DAY     (3600 * 24)
#define SEC_HOUR    3600
#define SEC_MIN     60

@implementation NSDictionary (Extend)

- (NSString *) safeStringForKey: (id)key;
{
    NSString *str = [self objectForKey:key];
    
    if (str != nil)
    {
        return str;
    }
    else {
        return @"";
    }
}

@end

@implementation NSObject (Serialize)

- (NSMutableDictionary *) serializeObjectPropertiesToDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (unsigned int i = 0; i < count; i++)
    {
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding];
        id value = [self valueForKey:name];
        if (value && [value conformsToProtocol:@protocol(NSCoding)])
        {
            
            [result setObject:value forKey:name];
        }
    }
    
    free(properties);
    return result;
}

- (NSMutableDictionary *) serializeObjectPropertiesToDictionaryExceptProperties:(NSArray *)exceptProperties
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    for (unsigned int i = 0; i < count; i++)
    {
        NSString *name = [NSString stringWithCString:property_getName(properties[i]) encoding:NSASCIIStringEncoding];
        if ([exceptProperties indexOfObject:name] == NSNotFound)
        {
            id value = [self valueForKey:name];
            if (value && [value conformsToProtocol:@protocol(NSCoding)])
            {
                
                [result setObject:value forKey:name];
            }
        }
    }
    
    free(properties);
    return result;
}

- (void) deserializeDictionaryToObjectProperties:(NSDictionary *)dict
{
    for (NSString *property in dict)
    {
        if (class_getProperty([self class], [property UTF8String]) != NULL)
        {
            [self setValue:[dict objectForKey:property] forKey:property];
        }
    }
}

- (void) deserializeDictionaryToObjectProperties:(NSDictionary *)dict exceptProperties:(NSArray *)exceptProperties
{
    for (NSString *property in dict)
    {
        if (class_getProperty([self class], [property UTF8String]) != NULL && [exceptProperties indexOfObject:property] == NSNotFound)
        {
            [self setValue:[dict objectForKey:property] forKey:property];
        }
    }
}

@end


@implementation Utils

+(void) findAndAddFriendsInfo:(NSMutableArray *)array friendid:(NSInteger)friendid
{
    FriendInfoStruct *info = [[AppDelegate sharedInstance] findFriendInfo:friendid];
    if (info)
        [array addObject:info];
}


+(void) findAndAddGroupInfo:(NSMutableArray *)array groupid:(NSInteger)groupid
{
    GroupInfoStruct *info = [[AppDelegate sharedInstance] findGroupInfo:groupid];
    if (info)
        [array addObject:info];
}


+(UIImage *) getDefaultProfileImage
{
    return [UIImage imageNamed:@"male"];
}

+(NSString *) generateSecurityKey:(NSString *)udid email:(NSString *)email sec:(NSInteger)sec
{
    NSString *strUDID = @"";
    if (udid)
        strUDID = udid;
    NSString *string = [NSString stringWithFormat:@"%@%@", strUDID, email];
    return [self convertIntoMD5:string];
}

+(NSString *)convertIntoMD5:(NSString *) string{
    const char *cStr = [string UTF8String];
    unsigned char digest[16];
    
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *resultString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [resultString appendFormat:@"%02x", digest[i]];
    return  resultString;
}

+(NSURL *) getPhotoFunctionURL:(NSString *)func
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", URL_PHOTO_MANAGE, func];
    return [NSURL URLWithString:strUrl];
}

+(NSURL *) getUserFunctionURL:(NSString *)func
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", URL_USER_MANAGE, func];
    return [NSURL URLWithString:strUrl];
}

+(NSURL *) getGroupFunctionURL:(NSString *)func
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", URL_GROUP_MANAGE, func];
    return [NSURL URLWithString:strUrl];
}

+(NSURL *) getFriendsFunctionURL:(NSString *)func
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", URL_FRIENDS_MANAGE, func];
    return [NSURL URLWithString:strUrl];
}

+(NSURL *) getEventFunctionURL:(NSString *)func
{
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", URL_EVENT_MANAGE, func];
    return [NSURL URLWithString:strUrl];
}

+ (BOOL)isValidEmailAddress:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkString];
}

+(BOOL) stringIsNumeric:(NSString *) str {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSNumber *number = [formatter numberFromString:str];
    
    return !!number; // If the string is not numeric, number will be nil
}

+(void) copyArray:(NSMutableArray *)src desarray:(NSMutableArray *)dest
{
    if (!src || !dest)
        return;
    
    [dest removeAllObjects];
    for (NSObject *obj in src)
        [dest addObject:obj];
}

+(void) getBackgroundLocalPhotos:(NSMutableArray *) arrBackground
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingString:@"/background/"];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
    
    NSArray *fileArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path  error:nil];
    for (NSString *strPath in fileArray)
    {
        [arrBackground addObject:strPath];
    }
}

+(BOOL) saveBackgroundPhoto:(NSData *) imageData filename:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/background/%@", filename]];
    
    return [imageData writeToFile:path atomically:YES];
}

+(UIImage *) getBackgroundPhoto:(NSString *) strFileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingString:[NSString stringWithFormat:@"/background/%@", strFileName]];
    
    return [UIImage imageWithContentsOfFile:path];
}

+(UIImage*) getThumbImage:(UIImage *)image
{
    CGSize size = image.size;
    float rate = 1;
    if (size.width > KEY_IMAGE_THUMB_WIDTH)
    {
        rate = size.width / KEY_IMAGE_THUMB_WIDTH;
        size.width = KEY_IMAGE_THUMB_WIDTH;
        size.height = size.height / rate;
    }
    else
        return image;
    
    UIGraphicsBeginImageContext( size );
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+(NSString *) generateProfileName
{
    NSInteger interval = [[NSDate date] timeIntervalSince1970];
    NSInteger random = arc4random() % 1000;
    NSInteger random2 = arc4random() % 999;
    
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate]; // Get necessary date components
    
    return [NSString stringWithFormat:@"profile/%d/%03d-%03d_%d.jpg", (int)[components year], (int)random2, (int)interval, (int)random];
}

+(NSData *) getThumbImageData:(UIImage*)image
{
    UIImage *tmp = [self getThumbImage:image];
    NSData *imgData = UIImageJPEGRepresentation(tmp, 1.0);
    if (imgData.length > 300000)
        imgData = UIImageJPEGRepresentation(tmp, 0.2);
    else if (imgData.length > 200000)
        imgData = UIImageJPEGRepresentation(tmp, 0.4);
    else if (imgData.length > 100000)
        imgData = UIImageJPEGRepresentation(tmp, 0.5);
    
    return imgData;
}

+ (NSString *) getStrigDate:(int)secOffset
{
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:secOffset];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];

    return [formatter stringFromDate:date];
}

+ (NSString *) getHistoryDateStr:(int)secOffset{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:secOffset];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm a"];
    
    return [formatter stringFromDate:date];
}

+ (NSString *) getDateStrFromOffset:(int)secOffset{
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:secOffset];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    
    return [formatter stringFromDate:date];
}

+ (NSString *) getStrigFromDate:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    
    return [formatter stringFromDate:date];
}

+ (NSString *) getMonthStrigFromDate:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM, yyyy"];
    
    return [formatter stringFromDate:date];
}

+ (NSString *) getMonthStrigFromDateForDB:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM"];
    
    return [formatter stringFromDate:date];
}

+ (NSString *) getYearStrigFromDat:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    
    return [formatter stringFromDate:date];
}

+(NSString *) getDBDateString:(NSDate *)date startflag:(BOOL)startflag
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (startflag)
        [formatter setDateFormat:@"yyyy-MM-01"];
    else
    {
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:date]; // Get necessary date components
        [comps setMonth:[comps month]+1];
        [comps setDay:0];
        // set last of month
        NSDate *tmonth = [calendar dateFromComponents:comps];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        return [formatter stringFromDate:tmonth];
    }
    
    
    return [formatter stringFromDate:date];
}

+ (NSString *) getStringFromInteger:(NSInteger)value
{
    return [NSString stringWithFormat:@"%d", (int)value];
}

+ (NSString *) getTimeString:(NSInteger) second
{
    int result;
    NSString *strResult;
    if (second > SEC_YEAR)
    {
        result = (int)second / SEC_YEAR;
        if (result > 1)
            strResult = [NSString stringWithFormat:@"%d years ago", result];
        else
            strResult = @"1 year ago";
    }
    else if (second > SEC_MONTH)
    {
        result = (int)second / SEC_MONTH;
        if (result > 1)
            strResult = [NSString stringWithFormat:@"%d months ago", result];
        else
            strResult = @"1 month ago";
    }
    else if (second > SEC_DAY)
    {
        result = (int)second / SEC_DAY;
        if (result > 1)
            strResult = [NSString stringWithFormat:@"%d days ago", result];
        else
            strResult = @"1 day ago";
    }
    else if (second > SEC_HOUR)
    {
        result = (int)second / SEC_HOUR;
        if (result > 1)
            strResult = [NSString stringWithFormat:@"%d hours ago", result];
        else
            strResult = @"1 hour ago";
    }
    else
    {
        result = (int)second / SEC_MIN;
        if (result > 1)
            strResult = [NSString stringWithFormat:@"%d mins ago", result];
        else
            strResult = @"1 min ago";
    }
    
    return strResult;
}

+ (NSDate *) getDateFromString:(NSString*)strDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    
    return [formatter dateFromString:strDate];
}

+ (NSDate *) getMonthFromString:(NSString*)strDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM, yyyy"];
    
    return [formatter dateFromString:strDate];
}

+ (NSString *) getStrDateForFeed:(NSDate*)date isCurTime:(BOOL)isCurTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if(isCurTime == YES)
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    else
        [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:date];
}

+(NSString*) convertDateString:(NSString*)strDate isCurTime:(BOOL)isCurTime
{
    NSDate  *date = [self getDateFromString:strDate];

    return [self getStrDateForFeed:date isCurTime:isCurTime];
}

+(NSString*) getSafePhoneNumber:(NSString*)str;
{
    NSString *strippedNumber = [str stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [str length])];

    return strippedNumber;
}

+(BOOL) isNumberIncluded:(NSString*)str
{
    NSString *string = [self getSafePhoneNumber:str];
    
    if([string length] > 0)
        return YES;
    
    return NO;
}

+(BOOL) validateEmail: (NSString *) str
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];    //  return 0;
    return [emailTest evaluateWithObject:str];
}


+(NSInteger)getDifferenceDays:(NSDate *) startDate toDate:(NSDate *) endDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    
    return components.day;
}

@end
