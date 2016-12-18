//
//  PhotoInfoStruct.m
//  Zinger
//
//  Created by Tianming on 19/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "PhotoInfoStruct.h"
#import "CommentInfoStruct.h"

@implementation PhotoInfoStruct

-(id) init
{
    iPhotoID = iGroupID = iUserID = 0;
    strPhotoUrl = @"";
    strThumbUrl = @"";
    strTitle = @"";
    strTag = @"";
    strUploadKey = @"";
    iAlbumID = iWidth = iHeight = iSize = 0;
    iLikeCount = iCommentCount = iViewCount = 0;
    bFavoriteFlag = bLikedFlag = NO;
    bViewedFlag = bNewCommentFlag = NO;
    imgPhoto = nil;
    arrTagArray = [[NSMutableArray alloc] init];
    arrComments = [[NSMutableArray alloc] init];
    
    arrAlbumInfos = [[NSMutableArray alloc] init];
    arrGroupInfos = [[NSMutableArray alloc] init];
    arrUserInfos = [[NSMutableArray alloc] init];
    
    return self;
}

-(void) initWithJsonData:(NSDictionary *)dict
{
    iPhotoID = [[dict objectForKey:@"photoid"] integerValue];
    iAlbumID = [[dict objectForKey:@"albumid"] integerValue];
    if (iAlbumID < 1)
        iAlbumID = [[dict objectForKey:@"bucketid"] integerValue];
    iUserID = [[dict objectForKey:@"userid"] integerValue];
    strTag = [dict objectForKey:@"tag"];
    strTitle = [dict objectForKey:@"title"];
    strPhotoUrl = [dict objectForKey:@"photourl"];
    strThumbUrl = [dict objectForKey:@"thumb"];
    iWidth = [[dict objectForKey:@"width"] integerValue];
    iHeight = [[dict objectForKey:@"height"] integerValue];
    iSize = [[dict objectForKey:@"size"] integerValue];
    iLikeCount = [[dict objectForKey:@"likecount"] integerValue];
    iCommentCount = [[dict objectForKey:@"commentcount"] integerValue];
    iViewCount = [[dict objectForKey:@"viewcount"] integerValue];
    iPostTimeSec = [[dict objectForKey:@"posttime"] integerValue];
    iGroupID = [[dict objectForKey:@"groupid"] integerValue];
    bLikedFlag = [[dict objectForKey:@"liked"] integerValue] > 0;
    bViewedFlag = [[dict objectForKey:@"viewd"] integerValue] > 0;
    bFavoriteFlag = [[dict objectForKey:@"favorited"] integerValue] > 0;
    bNewCommentFlag = [[dict objectForKey:@"newcomment"] integerValue] > 0;
    bSpamFlag = [[dict objectForKey:@"flaged"] integerValue] > 0;
    
    NSArray *array = [strTag componentsSeparatedByString:@" "];
    [arrTagArray removeAllObjects];
    for (NSString *str in array)
    {
        if (str.length < 1)
            continue;
        [arrTagArray addObject:str];
    }
   
    [self initAlbumInfos:[dict objectForKey:@"albuminfos"]];
    [self initGroupInfos:[dict objectForKey:@"groupinfos"]];
    [self initBucketInfos:[dict objectForKey:@"bucketinfos"]];
    [self initUserInfos:[dict objectForKey:@"userinfos"]];
    
    strOwnerName = [dict objectForKey:@"photousername"];
    arrComments = [[NSMutableArray alloc] init];
    strUploadKey = @"";
    [self setCommentArray:[dict objectForKey:@"comments"] addflag:NO];
    
}

-(NSURL *)getPhotoURL
{
    return [NSURL URLWithString:strPhotoUrl];
}

-(NSURL *)getPhotoThumbURL
{
    return [NSURL URLWithString:strThumbUrl];
}

-(void) initUserInfos:(NSObject *)obj
{
    [arrUserInfos removeAllObjects];
    if (obj == [NSNull null])
        return;
    
    NSArray *arrtmp = [((NSString *) obj) componentsSeparatedByString:@","];
    for (NSString *str in arrtmp)
    {
        NSArray *arritem = [str componentsSeparatedByString:@"#"];
        FriendInfoStruct *finfo = [[FriendInfoStruct alloc] init];
        [finfo setUserID:[[arritem objectAtIndex:0] integerValue]];
        [finfo setFirstName:[arritem objectAtIndex:1]];
        [finfo setLastName:[arritem objectAtIndex:2]];
        //[finfo setPhotoName:[arritem objectAtIndex:3]];
        [arrUserInfos addObject:finfo];
    }
}


-(void) initBucketInfos:(NSObject *)obj
{
    bucketinfo = nil;
    if (obj == [NSNull null])
        return;
    
    NSArray *arritem = [((NSString *)obj) componentsSeparatedByString:@"#"];
    bucketinfo = [[BucketInfoStruct alloc] init];
    [bucketinfo setBucketID:[arritem objectAtIndex:0]];
    [bucketinfo setBucketName:[arritem objectAtIndex:1]];
    [bucketinfo setBucketOwnerID:[arritem objectAtIndex:2]];
}

-(void) initGroupInfos:(NSObject *)obj
{
    [arrGroupInfos removeAllObjects];
    if (obj == [NSNull null])
        return;
    
    NSArray *arrtmp = [((NSString *) obj) componentsSeparatedByString:@","];
    for (NSString *str in arrtmp)
    {
        NSArray *arritem = [str componentsSeparatedByString:@"#"];
        GroupInfoStruct *ginfo = [[GroupInfoStruct alloc] init];
        [ginfo setGroupID:[[arritem objectAtIndex:0] integerValue]];
        [ginfo setGroupName:[arritem objectAtIndex:1]];
        [arrGroupInfos addObject:ginfo];
    }
}

-(void) initAlbumInfos:(NSObject *)obj
{
    [arrAlbumInfos removeAllObjects];
    if (obj == [NSNull null])
        return;
    
    NSArray *arrtmp = [((NSString *) obj) componentsSeparatedByString:@","];
    for (NSString *str in arrtmp)
    {
        NSArray *arritem = [str componentsSeparatedByString:@"#"];
        AlbumInfoStruct *ainfo = [[AlbumInfoStruct alloc] init];
        [ainfo setAlbumID:[arritem objectAtIndex:0]];
        [ainfo setAlbumName:[arritem objectAtIndex:1]];
        [arrAlbumInfos addObject:ainfo];
    }
}

-(void) setCommentArray:(NSArray *)array addflag:(BOOL)addflag
{
    if (!addflag)
        [arrComments removeAllObjects];
    
    for (NSDictionary *dict in array)
    {
        CommentInfoStruct *info = [[CommentInfoStruct alloc] init];
        [info initWithJsonData:dict];
        //[arrComments addObject:info];
        [self addComment:info];
    }
}

-(void) addComment:(CommentInfoStruct *)cinfo
{
    int i = 0;
    for (i = 0; i < arrComments.count; i++)
    {
        CommentInfoStruct *tmp = [arrComments objectAtIndex:i];
        if ([tmp getCommentID] > [cinfo getCommentID])
            break;
    }
    
    [arrComments insertObject:cinfo atIndex:i];
}

-(NSMutableArray *) getCommentArray
{
    return arrComments;
}

-(BOOL) isFavorite
{
    return bFavoriteFlag;
}

-(BOOL) isFlaged
{
    return bSpamFlag;
}

-(BOOL) isLiked
{
    return bLikedFlag;
}

-(BOOL) isMySharedPhoto
{
    if (iUserID == [AppDelegate sharedInstance].objUserInfo.iUserID)
    {
        if ([arrGroupInfos count] > 0)
            return YES;
        
        if (arrUserInfos.count < 1)
            return NO;
        
        return YES;
    }
    
    return NO;
}

-(BOOL) isSharedPhoto
{
    if ([self isMyBucket])
    {
        BucketInfoStruct *binfo = [[AppDelegate sharedInstance] findBucketInfoByID:[self getBucketID]];
        if ([binfo getBucketGroupIDs].count > 0)
            return YES;
        
        if ([binfo getBucketUserIDs].count > 1)
            return YES;
        
        if ([binfo getBucketUserIDs].count == 1 && ![[[binfo getBucketUserIDs] objectAtIndex:0] isEqualToString:[AppDelegate sharedInstance].objUserInfo.strUserId])
            return YES;
        
        return NO;
    }
    
    if ([arrGroupInfos count] < 1)
    {
        if (arrUserInfos.count < 1)
            return NO;
        
        if (arrUserInfos.count > 1)
            return YES;
        
        FriendInfoStruct *finfo = [arrUserInfos objectAtIndex:0];
        if ([finfo getUserID] == [[AppDelegate sharedInstance].objUserInfo getUserID])
            return NO;
    }
    
    return YES;
}

-(BOOL) isMyPhoto
{
    return (iUserID == [AppDelegate sharedInstance].objUserInfo.iUserID);
}

-(BOOL) isMyBucket
{
    if (bucketinfo)
        return [bucketinfo isMyBucket];
    
    return NO;
}

-(BOOL) isBucketPhoto
{
    if (bucketinfo)
        return YES;
    
    return NO;
}

-(BOOL) isViewed
{
    if (iUserID == [[AppDelegate sharedInstance].objUserInfo.strUserId integerValue])
        return YES;
    
    return bViewedFlag;
}

-(BOOL) isNewComment
{
    return bNewCommentFlag;
}

-(void) setPhotoID:(NSInteger)photoid
{
    iPhotoID = photoid;
}

-(void) setPostUserID:(NSInteger)userid
{
    iUserID = userid;
}

-(void) setPhotoUrl:(NSString *)url
{
    strPhotoUrl = url;
}

-(void) setThumbUrl:(NSString *)url
{
    strThumbUrl = url;
}

-(void) setTitle:(NSString *)comment
{
    strTitle = comment;
}

-(void) setTag:(NSString *)tag
{
    strTag = tag;
}

-(void) setTagArray:(NSArray *)array
{
    [arrTagArray removeAllObjects];
    strTag = @"";
    for (NSString *str in array)
    {
        [arrTagArray addObject:str];
        if (strTag.length < 1)
            strTag = str;
        else
            strTag = [strTag stringByAppendingFormat:@" %@", str];
    }
}


-(void) setAlbumId:(NSInteger) albumid
{
    iAlbumID = albumid;
}


-(void) setPhoto:(UIImage *)photo
{
    imgPhoto = photo;
}

-(void) setWidth:(NSInteger)width
{
    iWidth = width;
}

-(void) setHeight:(NSInteger)height
{
    iHeight = height;
}

-(void) setSize:(NSInteger)size
{
    iSize = size;
}

-(void) setNewCommentFlag:(BOOL)flag
{
    bNewCommentFlag = flag;
}

-(void) setPhotoUploadKey:(NSString *)strKey
{
    strUploadKey = strKey;
}

-(NSString *) getPhotoUploadKey
{
    return strUploadKey;
}

-(NSInteger) getPhotoID
{
    return iPhotoID;
}

-(NSInteger) getUserID
{
    return iUserID;
}

-(NSString *) getLikeCountToString
{
    return [NSString stringWithFormat:@"%d", (int)iLikeCount];
}

-(NSInteger) setPhotoID
{
    return iPhotoID;
}

-(void) setSpamFlag:(BOOL)flag
{
    bSpamFlag = flag;
}


-(NSString *) getPhotoIDToString
{
    return [NSString stringWithFormat:@"%d", (int)iPhotoID];
}

-(NSInteger) getPostUserID
{
    return iUserID;
}

-(NSString *) getPhotoStringURL
{
    return strPhotoUrl;
}

-(NSString *) getThumbStringURL
{
    return strThumbUrl;
}

-(NSMutableArray *)getTagArray
{
    return arrTagArray;
}

-(NSString *) getTitle
{
    return strTitle;
}

-(NSString *) getTag
{
    return strTag;
}

-(NSString *)getBucketName
{
    if (!bucketinfo)
        return @"";
    
    return [bucketinfo getBucketName];
}

-(NSInteger) getBucketID
{
    return [bucketinfo getBucketID];
}


-(NSString *)getAlbumNames
{
    NSString *strval = @"";
    for (AlbumInfoStruct *info in arrAlbumInfos)
    {
        if (strval.length > 0)
            strval = [NSString stringWithFormat:@"%@, %@", strval, [info getAlbumName]];
        else
            strval = [info getAlbumName];
    }
    
    return strval;
}

-(NSInteger) getAlbumID
{
    return iAlbumID;
}

-(NSInteger) getWidth
{
    return iWidth;
}

-(NSInteger) getHeight
{
    return iHeight;
}

-(NSInteger) getSize
{
    return iSize;
}

-(NSString *) getWidthToString
{
    return [NSString stringWithFormat:@"%d", (int)iWidth];
}

-(NSString *) getHeightToString
{
    return [NSString stringWithFormat:@"%d", (int)iHeight];
}

-(NSString *) getSizeToString
{
    return [NSString stringWithFormat:@"%d", (int)iSize];
}

-(NSInteger) getLikeCount
{
    return iLikeCount;
}

-(NSInteger) getViewCount
{
    return iViewCount;
}

-(NSInteger) getCommentCount
{
    return iCommentCount;
}

-(UIImage *) getPhoto
{
    return imgPhoto;
}

-(void) refreshBucketInfo
{
    bucketinfo = [[AppDelegate sharedInstance] findBucketInfoByID:[bucketinfo getBucketID]];
    [[AppDelegate sharedInstance] getBucketGroupInfo:[bucketinfo getBucketID] arrdes:arrGroupInfos];
    [[AppDelegate sharedInstance] getBucketUserInfo:[bucketinfo getBucketID] arrdes:arrUserInfos];
}

-(NSArray *) getShareGroupInfo
{
    return arrGroupInfos;
}

-(NSArray *) getShareUserInfo
{
    return arrUserInfos;
}

-(void) setCommentArray:(NSMutableArray *)comments
{
    if (!arrComments)
        arrComments = [NSMutableArray array];
    else
        [arrComments removeAllObjects];
    for (CommentInfoStruct *cinfo in comments)
    {
        if ([cinfo getPhotoID] != iPhotoID)
            continue;
        
        [self addComment:cinfo];
    }
}

-(NSInteger) getLatestCommentID
{
    NSInteger commentid = 0;
    for (CommentInfoStruct *cinfo in arrComments)
    {
        if ([cinfo getCommentID] > commentid)
            commentid = [cinfo getCommentID];
    }
    
    return commentid;
}

-(void) setFavoriteFlag:(BOOL)flag
{
    bFavoriteFlag = flag;
}

-(NSString *)getUserName
{
    if ([self isMyPhoto])
        return @"Me";
    
    FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:iUserID];
    if (finfo)
        return [finfo getUserName];
    
    for (finfo in arrUserInfos)
    {
        if ([finfo getUserID] == iUserID)
            return [finfo getUserName];
    }
    
    return @"Unknown";
}

-(NSString *) getPostTime
{
    return [Utils getTimeString:iPostTimeSec];
}

-(NSInteger) getBucketOwnerUserID
{
    if (!bucketinfo)
        return 0;
    
    return [bucketinfo getUserID];
}

-(NSString *) getBucketOwnerName
{
    if (!bucketinfo)
        return @"Me";
    
    if ([bucketinfo getUserID] == [AppDelegate sharedInstance].objUserInfo.iUserID)
        return @"Me";
    
    FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:[bucketinfo getUserID]];
    if (finfo)
        return [finfo getUserName];
    
    return @"Me";
}

-(void) setLikedFlag:(BOOL)flag
{
    if (bLikedFlag != flag)
    {
        if (flag)
            iLikeCount ++;
        else if(iLikeCount > 0)
            iLikeCount --;
    }
    bLikedFlag = flag;
}

-(void) setViewed:(BOOL)flag
{
    bViewedFlag = flag;
}

@end
