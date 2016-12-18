//
//  AlbumInfoStruct.m
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "AlbumInfoStruct.h"

@implementation AlbumInfoStruct

-(id) init
{
    iAlbumID = 0;
    iUserID = 0;
    arrPhotoIDs = [[NSMutableArray alloc] init];
    bHasExpiry = YES;
    albumType = YES;
    strAlbumName = @"";
    expdate = nil;
    
    return self;
}

-(void) initWithJSonData:(NSDictionary *)dict
{
    iAlbumID = [[dict objectForKey:@"albumid"] integerValue];
    strAlbumName = [dict objectForKey:@"name"];
    iUserID = [[dict objectForKey:@"userid"] integerValue];
    strExpiryDate = [dict objectForKey:@"expdate"];
    if (strExpiryDate.length < 5)
        strExpiryDate = [Utils getStrigFromDate:[NSDate date]];
    bHasExpiry = [[dict objectForKey:@"expflag"] integerValue] > 0;
    albumType = [[dict objectForKey:@"albumtype"] integerValue];
}

-(void) setAlbumName:(NSString *)name
{
    strAlbumName = name;
}

-(void) setAlbumID:(NSString *)strID
{
    iAlbumID = [strID integerValue];
}

-(NSString *) getAlbumName
{
    return strAlbumName;
}

-(NSMutableArray *) getAlbumPhotos
{
    return arrPhotoIDs;
}

-(NSInteger) getAlbumID
{
    return iAlbumID;
}

-(NSString *) getAlbumIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iAlbumID];
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSString *) getUserIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iUserID];
}

-(NSString *) getExpiryDate
{
    return strExpiryDate;
}

-(BOOL) hasExpire
{
    return bHasExpiry;
}

-(BOOL) canDelete
{
    if (iUserID != [[AppDelegate sharedInstance].objUserInfo getUserID])
        return NO;
    
    return albumType > 1;
}

-(BOOL) isFavoriteAlbum
{
    if (iUserID != [[AppDelegate sharedInstance].objUserInfo getUserID])
        return YES;
    
    if ([strAlbumName isEqualToString:k_favoriteAlbum])
        return YES;
    
    return NO;
}

-(BOOL) isInExpireDate:(NSInteger)date
{
    if (!bHasExpiry)
        return NO;
    
    if (!expdate)
        expdate = [Utils getDateFromString:strExpiryDate];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *tmpdate = [gregorian dateByAddingComponents:components toDate:expdate options:0];
    if ([tmpdate compare:[NSDate date]] == NSOrderedAscending)
        return YES;
    
    return NO;
}

@end
