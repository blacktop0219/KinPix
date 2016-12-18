//
//  CommentInfoStruct.m
//  Zinger
//
//  Created by Tianming on 19/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "CommentInfoStruct.h"
#import "AppDelegate.h"

@implementation CommentInfoStruct

-(id) init
{
    iCommentID = 0;
    iUserID = 0;
    iPhotoID = 0;
    iTimeSec = 0;
    strComment = @"";
    
    return self;
}

-(id) initWithUserComment:(NSString *)comment
{
    iCommentID = 0;
    UserInfoStruct *info = [AppDelegate sharedInstance].objUserInfo;
    iUserID = [info getUserID];
    iPhotoID = 0;
    iTimeSec = 0;
    strComment = comment;
    strPhotoUrl = info.strPhotoUrl;
    strUserName = @"Me";
    
    return self;
}

//commentid, userid, photoid, time, comment
-(void) initWithJsonData:(NSDictionary *)dict
{
    iCommentID = [[dict objectForKey:@"commentid"] integerValue];
    iUserID = [[dict objectForKey:@"userid"] integerValue];
    iPhotoID = [[dict objectForKey:@"photoid"] integerValue];
    iTimeSec = [[dict objectForKey:@"time"] integerValue];
    strComment = [dict objectForKey:@"comment"];
    if (iUserID == [[AppDelegate sharedInstance].objUserInfo.strUserId integerValue])
    {
        strUserName = @"Me";
        strPhotoUrl = [AppDelegate sharedInstance].objUserInfo.strPhotoUrl;
    }
    else
    {
        strUserName = [NSString stringWithFormat:@"%@ %@", [dict objectForKey:@"firstname"], [dict objectForKey:@"lastname"]];
        strPhotoUrl = [dict objectForKey:@"photo"];
    }

}

-(void) refreshUserInfo
{
    FriendInfoStruct *info = [[AppDelegate sharedInstance] findFriendInfo:iUserID];
    if (info)
    {
        strUserName = [info getUserName];
        strPhotoUrl = [info getPhotoStringURL];
    }
    else if (iUserID == [[AppDelegate sharedInstance].objUserInfo.strUserId integerValue])
    {
        strUserName = @"Me";
        strPhotoUrl = [AppDelegate sharedInstance].objUserInfo.strPhotoUrl;
    }
}

-(void) setCommentID:(NSInteger)commentID
{
    iCommentID = commentID;
}

-(void) setUserID:(NSInteger) userID
{
    iUserID = userID;
}

-(void) setCommentText:(NSString *) comment
{
    strComment = comment;
}

-(BOOL) isMyComment
{
    if (iUserID == [[AppDelegate sharedInstance].objUserInfo getUserID])
        return YES;
    
    return NO;
}

-(NSInteger) getCommentID
{
    return iCommentID;
}

-(NSString *) getPhotoIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iPhotoID];
    
}

-(NSString *) getCommentIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iCommentID];
    
}

-(NSInteger) getPhotoID
{
    return iPhotoID;
}

-(NSInteger) getTimeSec
{
    return iTimeSec;
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSString *) getUserName
{
    if (strUserName.length < 1)
        [self refreshUserInfo];
    
    return strUserName;
}

-(NSString *) getUserPhotoStringURL
{
    if (strPhotoUrl.length < 1)
        [self refreshUserInfo];
    
    return strPhotoUrl;
}

-(NSURL *) getUserPhotoURL
{
    return [NSURL URLWithString:strPhotoUrl];
}

-(NSString *) getCommentText
{
    return strComment;
}

@end
