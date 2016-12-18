//
//  BucketInfoStruct.h
//  Zinger
//
//  Created by Tianming on 09/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BucketInfoStruct : NSObject
{
    NSInteger iBucketID;
    NSInteger iUserID;
    NSInteger iNewPhotoCount;
    NSString *strBucketName;
    NSMutableArray *arrPhotoIDs;
    NSArray *arrUserIDs;
    NSArray *arrGroupIDs;
}

-(void) initWithJSonData:(NSDictionary *)dict;

-(NSString *) getBucketName;
-(void) setBucketName:(NSString *)name;
-(void) setBucketID:(NSString *)strid;
-(void) setBucketOwnerID:(NSString *)ownerid;
-(NSString *) getBucketName:(BOOL)newline;
-(NSMutableArray *) getBucketPhotoIDs;
-(NSInteger) getBucketID;
-(NSString *) getBucketIDToString;
-(NSString *) getBucketOwnerName;
-(NSString *) getFriendsBucketName;
-(NSInteger) getUserID;
-(NSString *) getUserIDToString;
-(NSInteger) getNewPhotoCount;
-(NSArray *) getBucketUserIDs;
-(NSArray *) getBucketGroupIDs;
-(BOOL) isMyBucket;

@end
