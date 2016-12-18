//
//  ParseData.m
//  Zinger
//
//  Created by Piao Dev on 14/01/15.
//  Copyright (c) 2015 Piao Dev. All rights reserved.
//

#import "ParseData.h"
#import "LikerInfoStruct.h"

@implementation ParseData


+(void) parsePhotoInfo:(NSArray *) arrparam destination:(NSMutableArray *)destination breqinit:(BOOL)breqinit
{
    if (!arrparam || !destination)
        return;
    
    if (breqinit)
        [destination removeAllObjects];
    
    for (NSDictionary *dict in arrparam)
    {
        PhotoInfoStruct *info = [[PhotoInfoStruct alloc] init];
        [info initWithJsonData:dict];
        [destination addObject:info];
    }
}

+(void) parseLikeInfo:(NSArray *) arrparam destination:(NSMutableArray *)destination breqinit:(BOOL)breqinit
{
    if (!arrparam || !destination)
        return;
    
    if (breqinit)
        [destination removeAllObjects];
    
    for (NSDictionary *dict in arrparam)
    {
        LikerInfoStruct *info = [[LikerInfoStruct alloc] init];
        [info initWithJSonData:dict];
        [destination addObject:info];
    }
}

@end
