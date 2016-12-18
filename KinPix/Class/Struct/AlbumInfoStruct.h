//
//  AlbumInfoStruct.h
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlbumInfoStruct : NSObject
{
    NSInteger iAlbumID;
    NSInteger iUserID;
    NSString *strAlbumName;
    NSMutableArray *arrPhotoIDs;
    NSDate *expdate;
    
    BOOL bHasExpiry;
    NSInteger albumType;
    NSString *strExpiryDate;
}

-(void) initWithJSonData:(NSDictionary *)dict;

-(NSString *) getAlbumName;
-(void) setAlbumName:(NSString *)name;
-(void) setAlbumID:(NSString *)strID;

-(NSString *) getExpiryDate;
-(NSMutableArray *) getAlbumPhotos;
-(NSInteger) getAlbumID;
-(NSString *) getAlbumIDToString;
-(NSInteger) getUserID;
-(NSString *) getUserIDToString;
-(BOOL) hasExpire;
-(BOOL) canDelete;
-(BOOL) isInExpireDate:(NSInteger)date;
-(BOOL) isFavoriteAlbum;

@end
