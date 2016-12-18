//
//  LikerInfoStruct.h
//  Zinger
//
//  Created by Piao Dev on 20/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LikerInfoStruct : NSObject
{
    NSInteger iUserID;
    NSInteger iLikeID;
    NSString *strFirstName;
    NSString *strLastName;
    NSString *strPhotoUrl;
    NSInteger iTimeSec;
}

-(void) initWithJSonData:(NSDictionary *)dict;

- (BOOL) isMyLike;

-(NSInteger) getLikeID;
-(NSString *) getLikeIDToString;
-(NSInteger) getUserID;
-(NSString *) getTimeString;
-(NSString *) getPhotoStringURL;
-(NSString *) getUserName;
-(NSURL *) getPhotoURL;

@end
