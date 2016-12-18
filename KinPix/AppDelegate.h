//
//  AppDelegate.h
//  Zinger
//
//  Created by HyonMu on 10/26/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "NGTabBarController.h"
#import "NGTabBarItem.h"
#import "FriendInfoStruct.h"
#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "FriendInfoStruct.h"
#import "PhotoInfoStruct.h"
#import "AlbumInfoStruct.h"
#import "GroupInfoStruct.h"
#import "BucketInfoStruct.h"
#import "CommentInfoStruct.h"
#import "UserInfoStruct.h"
#import "NGTabBarController.h"
#import "FriendsRequestStruct.h"
#import "EventNotificationStruct.h"
#import "S3PhotoUploader.h"

@class TabParentViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, ASIHTTPRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *token;

@property (strong, nonatomic) CLLocationManager *m_locationManager;
@property (strong, nonatomic) CLLocation *m_curLocation;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

//User Location
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *state;
@property (strong, nonatomic) NSString *country;

// Key Information
@property (strong, nonatomic) NSString *strAwsAccessKey;
@property (strong, nonatomic) NSString *strAwsSecretKey;

@property (strong, nonatomic) UserInfoStruct *objUserInfo;
@property (nonatomic) NSInteger iFriendNotifCount, iPhotoNotifCount;
@property (nonatomic) float fImageQuality;

@property BOOL bAlbumMode;
@property BOOL bBucketMode;

//for Share
@property (strong, nonatomic) NSMutableArray *arrShareGroups;
@property (strong, nonatomic) NSMutableArray *arrShareAlbums;
@property (strong, nonatomic) NSMutableArray *arrSharePhotos;
@property (strong, nonatomic) NSMutableArray *arrShareFriends;

// for cache data
@property (strong, nonatomic) NSMutableArray *arrLastPhotos;
@property (strong, nonatomic) NSMutableArray *arrOrderPhotos;
@property (strong, nonatomic) NSMutableArray *arrMyPhotos;
@property (strong, nonatomic) NSMutableArray *arrFriends;
@property (strong, nonatomic) NSMutableArray *arrMyAlbums;
@property (strong, nonatomic) NSMutableArray *arrMyGroups;
@property (strong, nonatomic) NSMutableArray *arrFriendsAlbums;
// for bucket
@property (strong, nonatomic) NSMutableArray *arrMyBucket;
@property (strong, nonatomic) NSMutableArray *arrFriendBucket;
@property (strong, nonatomic) NSMutableArray *arrFriendBucketUsers;

@property int maxPhotoCount;
//Terms & Contents

@property (strong, nonatomic) TabParentViewController *visibleVC;
@property (strong, nonatomic) NGTabBarItem *tabNotificationItem;
@property (strong, nonatomic) NGTabBarController *tabBarController;
//Settings


/// Web api functions
- (ASIFormDataRequest *) getDefaultRequest:(NSURL *)url tag:(NSInteger)tag delegate:(id <ASIHTTPRequestDelegate>)delegate;
- (ASIFormDataRequest *) getGeneralHttpRequest:(NSURL *)url delegate:(id <ASIHTTPRequestDelegate>)delegate;
- (S3PhotoUploader *) getS3PhotoUploader:(id<S3PhotoUploaderDelegate>)delegate;
-(void) processAutoLogin;
-(void) flagPhoto:(NSString *)photoid type:(NSInteger)type content:(NSString *)content;
-(void) favoritePhoto:(NSString *)photoid type:(NSString *)type;
-(void) likePhoto:(NSString *)photoid type:(NSString *)type;
-(void) leaveComment:(NSString *)photoid comment:(NSString *)comment;
-(void) checkedNotification:(NSString *)notificationid type:(NSString *)type;
-(void) viewPhoto:(NSString *)photoid;
-(void) updateImageSize:(PhotoInfoStruct *)pinfo;
-(void) logout;
-(void) getImageQuality;
-(void) viewComment:(NSString *)photoid commentid:(NSString *)commentid viewedphoto:(BOOL)viewedphoto;
-(void) updatePolicyViewState;
-(void) updateNotificationState;
-(void) getUploadKey;
-(BOOL) updateUpdateKeyFinish;

- (void) getFriendRequest;
-(UIViewController *) getUIViewController:(NSString *)strViewControllerName;


+(AppDelegate*) sharedInstance;
+(UIFont *)getAppSystemFont:(NSInteger)fontSize;
+(void) processUserImage:(UIImageView *)imageview;
+(void) processFeedView:(UIView *) view feedimage:(UIImageView *)feedimage;
+(void) processPhotoView:(UIImageView *)photoimage;
+(void) processNewLabel:(UIView *) lblNew;

-(void) playAudio:(NSString*)fileName;

// Environment Init
-(void) refreshShareEnvironment;
-(void) refreshUserEnvironment;

// result refresh
-(NSMutableArray *) getComments:(NSArray *)array;
-(void) refreshPhotoInfo:(NSArray *)array comments:(NSMutableArray *)arrcomments arrdes:(NSMutableArray *)arrdes;

//// Init Global User infos
-(void) refreshGlobalInfo:(NSDictionary *)dict;
-(void) refreshNotificationState;
- (void) refreshBucketInfos:(NSDictionary *) dict;
-(void) refreshOnlyFriendBucket:(NSDictionary *)dict;

-(void) refreshHomeData:(NSDictionary *)json;
- (void) refreshFriendsInfos:(NSArray *) array;
- (void) refreshMyGroupInfos:(NSArray *) array;
- (void) refreshFriendAlbumInfos:(NSArray *) array;
- (void) refreshMyAlbumInfos:(NSArray *) array;

- (void) getBucketGroupInfo:(NSInteger) bucketid arrdes:(NSMutableArray *)arrdes;
- (void) getBucketUserInfo:(NSInteger) bucketid arrdes:(NSMutableArray *)arrdes;

+ (BOOL)isConnectedToInternet;
-(BOOL) isCheckedError:(NSInteger)errorCode message:(NSString *)msg;
-(BOOL) loadUserInfo;
-(void) saveUserInfo:(NSString *)strEmail password:(NSString *)strPassword;
+ (void)showMessage:(NSString *)text withTitle:(NSString *)title;

-(FriendInfoStruct *) findFriendInfo:(NSInteger)userid;
-(GroupInfoStruct *) findGroupInfo:(NSInteger)groupid;
-(GroupInfoStruct *) findGroupInfoByName:(NSString *)groupname;
-(BucketInfoStruct *) findBucketInfo:(NSString *)bucketname;
-(BucketInfoStruct *) findBucketInfoByID:(NSInteger)bucketid;
-(AlbumInfoStruct *) findAlbumInfo:(NSString *)albumName;
-(NSMutableArray *) findFriendAlbums:(NSInteger)userid;
-(NSMutableArray *) findFriendBuckets:(NSInteger)userid;
-(FriendInfoStruct *) findBucketUserInfo:(NSInteger)userid;

@end
