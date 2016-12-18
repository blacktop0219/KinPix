//
//  CommentInfoStruct.h
//  Zinger
//
//  Created by Tianming on 19/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommentInfoStruct : NSObject
{
    NSInteger iCommentID;
    NSInteger iUserID;
    NSInteger iPhotoID;
    NSString *strComment;
    NSInteger iTimeSec;
    
    NSString *strUserName;
    NSString *strPhotoUrl;
}

-(id) initWithUserComment:(NSString *)strComment;
-(void) initWithJsonData:(NSDictionary *)dict;
-(void) setCommentID:(NSInteger)commentID;
-(void) setUserID:(NSInteger) userID;
-(void) setCommentText:(NSString *) comment;

-(BOOL) isMyComment;

-(NSInteger) getCommentID;
-(NSString *) getPhotoIDToString;
-(NSString *) getCommentIDToString;
-(NSInteger) getUserID;
-(NSInteger) getPhotoID;
-(NSInteger) getTimeSec;
-(NSString *) getUserName;
-(NSString *) getUserPhotoStringURL;
-(NSURL *) getUserPhotoURL;
-(NSString *) getCommentText;

@end
