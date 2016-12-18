//
//  FriendInfoStruct.h
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendInfoStruct : NSObject
{
    NSInteger iUserID;
    NSString *strFirstName;
    NSString *strLastName;
    NSString *strPhotoUrl;
    
    NSInteger iNewPhotoCount;
    NSMutableArray *arrPhotoIds;
    NSMutableArray *arrAlbumIds;
    NSMutableArray *arrGroupIds;
}


-(void) initWithJSonData:(NSDictionary *)dict;

-(void) setUserID:(NSInteger)userid;
-(void) setFirstName:(NSString *)firstname;
-(void) setLastName:(NSString *)lastname;
-(void) setPhotoURL:(NSString *)photo;
-(void) setNewPhotoCount:(NSInteger)photocount;

-(NSInteger) getUserID;
-(NSString *) getUserIDToString;
-(NSString *) getFirstName;
-(NSString *) getLastName;
-(NSString *) getPhotoStringURL;
-(NSURL *) getPhotoURL;
-(NSInteger) getNewPhotoCount;
-(NSArray *) getPhotoIDs;
-(NSArray *) getAlbumIds;
-(NSString *) getUserName;

@end
