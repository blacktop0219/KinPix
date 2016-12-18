//
//  OrderInfoStruct.m
//  KinPix
//
//  Created by Piao Dev on 27/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "OrderInfoStruct.h"

@implementation OrderInfoStruct

-(id) init
{
    iLastPhotoID = 0;
    iUserID = 0;
    strName = @"";
    iBucketID = 0;
    iUnreadCount = 0;
    
    arrPhotos = [[NSMutableArray alloc] init];    
    return self;
}

//photoid, userid, , ,
-(id) initWithJsonData:(NSDictionary *)dict
{
    iLastPhotoID = 0;
    if ([dict objectForKey:@"photoid"] != [NSNull null])
        iLastPhotoID = [[dict objectForKey:@"photoid"] integerValue];
    iUserID = [[dict objectForKey:@"userid"] integerValue];
    strName = [dict objectForKey:@"name"];
    iUnreadCount = [[dict objectForKey:@"unreadcount"] integerValue];
    iBucketID = 0;
    if ([dict objectForKey:@"bucket"] != [NSNull null])
        iBucketID = [[dict objectForKey:@"bucket"] integerValue];
    
    arrPhotos = [[NSMutableArray alloc] init];
    return self;
}


-(BOOL) isMyOrder
{
    return ([[AppDelegate sharedInstance].objUserInfo getUserID] == iUserID);
}

-(BOOL) isBucketOrder
{
    return NO;
    //return iBucketID > 0;
}

-(NSInteger) getUnreadCount
{
    return iUnreadCount;
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSInteger) getBucektID
{
    return iBucketID;
}

-(NSString *) getName
{
    return strName;
}

-(NSString *) getUnreadCountToString
{
    return [NSString stringWithFormat:@"%d", (int)iUnreadCount];
}

-(NSMutableArray *) getOrderPhotos
{
    return arrPhotos;
}

-(void) addOwnPhotos:(NSMutableArray *)array
{
    [arrPhotos removeAllObjects];
    for (PhotoInfoStruct *pinfo in array)
    {
        if ([pinfo getUserID] != iUserID)
            continue;
        
        [arrPhotos addObject:pinfo];
    }
}

@end
