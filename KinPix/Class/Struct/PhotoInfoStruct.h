//
//  PhotoInfoStruct.h
//  Zinger
//
//  Created by Tianming on 19/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BucketInfoStruct.h"

@interface PhotoInfoStruct : NSObject
{
    NSInteger iPhotoID;
    NSInteger iUserID;
    NSString *strPhotoUrl;
    NSString *strThumbUrl;
    NSString *strUploadKey;
    NSString *strTitle;
    NSString *strTag;
    NSMutableArray *arrTagArray;
    NSInteger iAlbumID;
    NSInteger iGroupID;
    NSInteger iWidth, iHeight, iSize;
    NSInteger iLikeCount;
    NSInteger iPostTimeSec;
    NSInteger iCommentCount, iViewCount;
    
    UIImage *imgPhoto;
    
    BOOL bFavoriteFlag;
    BOOL bLikedFlag;
    BOOL bSpamFlag;
    BOOL bViewedFlag;
    BOOL bNewCommentFlag;
    
    NSString *strOwnerName;
    NSMutableArray *arrGroupInfos;
    NSMutableArray *arrAlbumInfos;
    BucketInfoStruct *bucketinfo;
    NSMutableArray *arrUserInfos;
    NSMutableArray *arrComments;
}

-(void) initWithJsonData:(NSDictionary *)dict;

-(void) setPhotoID:(NSInteger)photoid;
-(void) setPostUserID:(NSInteger)userid;
-(void) setPhotoUrl:(NSString *)url;
-(void) setThumbUrl:(NSString *)url;
-(void) setTitle:(NSString *)comment;
-(void) setTag:(NSString *)tag;
-(void) setTagArray:(NSArray *)array;
-(void) setAlbumId:(NSInteger) albumid;
-(void) setPhoto:(UIImage *)photo;
-(void) setWidth:(NSInteger)width;
-(void) setHeight:(NSInteger)height;
-(void) setSize:(NSInteger)size;
-(void) setNewCommentFlag:(BOOL)flag;
-(void) setPhotoUploadKey:(NSString *)strKey;

-(BOOL) isFavorite;
-(BOOL) isLiked;
-(BOOL) isFlaged;
-(BOOL) isViewed;
-(BOOL) isNewComment;
-(BOOL) isSharedPhoto;
-(BOOL) isMySharedPhoto;
-(BOOL) isMyPhoto;
-(BOOL) isMyBucket;
-(BOOL) isBucketPhoto;

-(NSInteger) getPhotoID;
-(NSInteger) getUserID;
-(NSString *) getLikeCountToString;
-(NSString *) getPhotoIDToString;
-(NSInteger) getPostUserID;
-(NSString *) getUserName;
-(NSString *) getPhotoStringURL;
-(NSString *) getThumbStringURL;
-(NSString *) getTitle;
-(NSMutableArray *)getTagArray;
-(NSString *) getTag;
-(NSString *)getBucketName;
-(NSInteger) getBucketID;
-(NSString *)getAlbumNames;
-(NSInteger) getWidth;
-(NSInteger) getHeight;
-(NSInteger) getSize;
-(NSString *) getWidthToString;
-(NSString *) getHeightToString;
-(NSString *) getSizeToString;
-(NSInteger) getLikeCount;
-(NSInteger) getViewCount;
-(NSInteger) getCommentCount;
-(UIImage *) getPhoto;
-(NSString *) getPostTime;
-(NSInteger) getBucketOwnerUserID;
-(NSString *) getBucketOwnerName;
-(NSMutableArray *) getCommentArray;
-(NSInteger) getLatestCommentID;
-(NSString *) getPhotoUploadKey;

-(NSURL *)getPhotoURL;
-(NSURL *)getPhotoThumbURL;

-(void) refreshBucketInfo;
-(void) setCommentArray:(NSMutableArray *)arrComments;
-(void) setFavoriteFlag:(BOOL)flag;
-(void) setLikedFlag:(BOOL)flag;
-(void) setViewed:(BOOL)flag;
-(void) setSpamFlag:(BOOL)flag;

-(NSArray *) getShareGroupInfo;
-(NSArray *) getShareUserInfo;
@end
