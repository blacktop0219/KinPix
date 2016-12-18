//
//  AppDelegate.m
//  Zinger
//
//  Created by HyonMu on 10/26/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//


#import <sys/socket.h>
#import <netinet/in.h>
#import <ifaddrs.h>

#import "Reachability.h"

#import "AppDelegate.h"
#import "OrderInfoStruct.h"
#import "PhotoDetailViewController.h"

#import <EBPhotoPages/EBPhotoPagesController.h>
#import <EBPhotoPages/EBPhotoViewController.h>

#import "AWSCore.h"

@implementation AppDelegate
{
    S3PhotoUploader *objPhotoUploader;
}

@synthesize arrMyAlbums, arrFriends, arrOrderPhotos, arrMyGroups, arrMyBucket;
@synthesize arrFriendsAlbums, arrLastPhotos, arrFriendBucketUsers;
@synthesize arrFriendBucket, fImageQuality, strAwsAccessKey, strAwsSecretKey;
@synthesize objUserInfo, iFriendNotifCount, iPhotoNotifCount;

static UIFont *fontSystem;

+(AppDelegate*) sharedInstance
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self loadUserInfo];
    [self registerToken:application];
    fImageQuality = 0.25;
    self.maxPhotoCount = max_sharePhotoCount;
    
    [self getUserLocation];
    [self loadPhotoSharedKey];
    
    self.objUserInfo = [[UserInfoStruct alloc] init];
    self.arrShareFriends = [[NSMutableArray alloc] init];
    self.arrSharePhotos = [[NSMutableArray alloc] init];
    self.arrShareGroups = [[NSMutableArray alloc] init];
    self.arrShareAlbums = [[NSMutableArray alloc] init];
    self.arrMyPhotos = [[NSMutableArray alloc] init];
    
    arrFriendBucket = [[NSMutableArray alloc] init];
    arrMyBucket = [[NSMutableArray alloc] init];
    arrOrderPhotos = [[NSMutableArray alloc] init];
    arrLastPhotos = [NSMutableArray array];
    arrFriendBucketUsers = [[NSMutableArray alloc] init];
    CGRect rect = [[UIScreen mainScreen] bounds];
    if (rect.size.width > rect.size.height)
    {
        NSInteger temp = rect.size.height;
        rect.size.height = rect.size.width;
        rect.size.width = temp;
    }
    self.window = [[UIWindow alloc] initWithFrame:rect];
    self.window.frame = rect;
    
    UINavigationController  *nav = (UINavigationController *)[self getUIViewController:@"homeNavVC"];
    nav.view.frame = rect;
    [self.window setRootViewController:nav];
    [self initAWSAnalytics];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    return YES;
}


+(UIFont *)getAppSystemFont:(NSInteger)fontSize
{
    if (!fontSystem)
        fontSystem = [UIFont fontWithName:@"Helvetica" size:11];
    
    return [fontSystem fontWithSize:fontSize];
}

-(void) initAWSAnalytics
{
    
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider
                                                          credentialsWithRegionType:AWSRegionUSEast1
                                                          identityPoolId:KEY_AMAZON_COGNITO_ID];
    
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    
    AWSMobileAnalyticsConfiguration *mobileAnalyticsConfiguration = [AWSMobileAnalyticsConfiguration new];
    mobileAnalyticsConfiguration.transmitOnWAN = YES;
    
    AWSMobileAnalytics *analytics = [AWSMobileAnalytics
                                     mobileAnalyticsForAppId: KEY_AMAZON_ANALYTICS //Mobile Analytics App ID
                                     configuration: mobileAnalyticsConfiguration
                                     completionBlock: nil];
    [analytics class];
}


-(UIViewController *) getUIViewController:(NSString *)strViewControllerName
{
    UIStoryboard *mainStoryboard;
    
    if(IS_IPHONE_5)
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    else
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone4" bundle:nil];
    
    UIViewController  *viewController = [mainStoryboard instantiateViewControllerWithIdentifier:strViewControllerName];
    
    return viewController;
}


- (void) registerToken:(UIApplication*)application
{
    //For Push Notification
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    else
    {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }

}

- (void) clearCashImage
{
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache clearMemory];
    [imageCache clearDisk];
}

#pragma  mark -
#pragma  mark -  CLLocationManager Delegate

- (void) getUserLocation
{
    self.m_locationManager = [CLLocationManager new];
    self.m_locationManager.delegate = self;
    self.m_locationManager.distanceFilter = kCLDistanceFilterNone;
    self.m_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if(IS_OS_8_OR_LATER) {
        [self.m_locationManager requestWhenInUseAuthorization];
        [self.m_locationManager requestAlwaysAuthorization];
    }
    
    [self.m_locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.m_curLocation = [locations objectAtIndex:0];
    
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:self.m_curLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {

            self.country = [placemark country]; // locality means "city"
            self.city = [placemark locality]; // locality means "city"
            self.state = [placemark administrativeArea]; // which is "state" in the U.S.A.
            
            [self.m_locationManager stopUpdatingLocation];
            [self.m_locationManager startUpdatingLocation];
            self.m_locationManager = nil;
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (objUserInfo && [objUserInfo.strUserId integerValue] > 0)
    {
        NSInteger count = [UIApplication sharedApplication].applicationIconBadgeNumber;
        [self refreshNotificationBadgeNumber:count];
        [self updateNotificationState];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


/// Device Token

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *devicePushToken=[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] ;
    devicePushToken = [devicePushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    self.token = devicePushToken;
    
    if (self.token)
        [self saveToken];
    
    NSLog(@"Token = %@", devicePushToken);    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //[self playAudio:s_NotficationBadgeAlert];
    NSDictionary *dict = [userInfo objectForKey:@"aps"];
    if (![dict objectForKey:@"photoids"])
    {
        UIAlertView *alert=  [[UIAlertView alloc] initWithTitle:@"Notification" message:[dict objectForKey:@"alert"] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    self.tabNotificationItem.badgeValue = [userInfo objectForKey:@"badge"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateNotificationList" object:nil];
    NSLog(@"Received RemoteNotification: %@", [dict objectForKey:@"alert"]);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Failed RemoteNotification");
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ERR_INVALID_SESSION_KEY || alertView.tag == ERR_INVALID_PACKET ||
        alertView.tag == ERR_USER_IN_REVIEW || alertView.tag == ERR_USER_SUSPENDED || alertView.tag == ERR_USER_AUTO_LOGIN_FAILED ||
        alertView.tag == ERR_USER_IVALID_PASS || alertView.tag == ERR_USER_NO_REGISTER)
    {
        [self playAudio:s_Logout];
        
        [self refreshUserEnvironment];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil];
    }
}

- (void) getFriendRequest
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getFriendsFunctionURL:FUNC_FRIEND_GET_LIST] tag:TYPE_GET_FRIENDS delegate:self];
    [request startAsynchronous];
}

- (void) getDefaultAlbumRequest
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getGroupFunctionURL:FUNC_ALBUM_DEFAULT_GET_LIST] tag:TYPE_GET_DEFAULT_ALBUMS delegate:self];
    [request startAsynchronous];
}

#pragma mark - Key Management
-(void) getUploadKey
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_UPLOAD_KEY] tag:TYPE_GET_UPLOADKEY delegate:self];
    [request startAsynchronous];
}

-(void) refreshUploadKey:(NSDictionary *)dict
{
    NSString *strKeyURL = [dict objectForKey:@"signedkeyurl"];
    if (strKeyURL.length > 30)
    {
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strKeyURL]];
        request.tag = TYPE_DOWNLOAD_KEYFILE;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *file = [NSString stringWithFormat:@"%@/temp", documentsDirectory];
        [request setDownloadDestinationPath:file];
        [request setDelegate:self];
        [request startAsynchronous];
    }
}

-(void) loadPhotoSharedKey
{
    NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
    strAwsSecretKey = [userDefautls objectForKey:@"AwsSecretKey"];
    strAwsAccessKey = [userDefautls objectForKey:@"AwsAccessKey"];
    if (strAwsSecretKey.length < 10 || strAwsAccessKey.length < 10)
        [self getUploadKey];
}


-(BOOL) updateUpdateKeyFinish
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [NSString stringWithFormat:@"%@/temp", documentsDirectory];
    NSError *error;
    NSString *strKeyInfos = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    NSString *strTmpAccessKey = nil, *strTmpSecurityKey = nil;
    if (!error && strKeyInfos.length > 30)
    {
        NSArray *arrkeys = [strKeyInfos componentsSeparatedByString:@"\n"];
        if (arrkeys.count == 2)
        {
            for (NSString *strPair in arrkeys)
            {
                NSArray *arrKeyValue = [strPair componentsSeparatedByString:@":"];
                if (arrKeyValue.count == 2)
                {
                    NSString *key = [arrKeyValue objectAtIndex:0];
                    NSString *value = [arrKeyValue objectAtIndex:1];
                    if ([key isEqualToString:@"accesskey"] && value.length > 10)
                        strTmpAccessKey = value;
                    else if (value.length > 20)
                        strTmpSecurityKey = value;
                }
            }
        }
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:file error:&error];
    if (strTmpAccessKey && strTmpSecurityKey)
    {
        strAwsAccessKey = strTmpAccessKey;
        strAwsSecretKey = strTmpSecurityKey;
        NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
        [userDefautls setObject:strAwsAccessKey forKey:@"AwsAccessKey"];
        [userDefautls setObject:strAwsSecretKey forKey:@"AwsSecretKey"];
        [userDefautls synchronize];
        return YES;
    }
    
    return NO;
}

/**
 * type : [0:unlike] [1:like]
 */
-(void) likePhoto:(NSString *)photoid type:(NSString *)type
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_LIKE_PHOTO] tag:TYPE_LIKE_PHOTH delegate:self];
    [request setPostValue:photoid forKey:@"photoid"];
    [request setPostValue:type forKey:@"type"];
    [request startAsynchronous];
}

/**
 * type : [0:unforvour] [1:favour]
 */
-(void) favoritePhoto:(NSString *)photoid type:(NSString *)type
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_FAVORITE_PHOTO] tag:TYPE_FAVORITE_PHOTO delegate:self];
    [request setPostValue:photoid forKey:@"photoid"];
    [request setPostValue:type forKey:@"type"];
    [request startAsynchronous];
}

-(void) viewPhoto:(NSString *)photoid
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_VIEWED_PHOTO] tag:TYPE_VIEWED_PHOTO delegate:self];
    [request setPostValue:photoid forKey:@"photoid"];
    [request startAsynchronous];
}

-(void) checkedNotification:(NSString *)notificationid type:(NSString *)type
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_CHECKED_HISTORY] tag:TYPE_CHECKED_NOTIFICATOIN delegate:self];
    [request setPostValue:type forKey:@"type"];
    [request setPostValue:notificationid forKey:@"queueid"];
    [request startAsynchronous];
}

-(void) updateImageSize:(PhotoInfoStruct *)pinfo
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_UPDATE_PHOTO] tag:TYPE_UPDATE_PHOTO delegate:self];
    [request setPostValue:[pinfo getPhotoIDToString] forKey:@"photoid"];
    [request setPostValue:[pinfo getSizeToString] forKey:@"size"];
    [request setPostValue:[pinfo getWidthToString] forKey:@"width"];
    [request setPostValue:[pinfo getHeightToString] forKey:@"height"];
    [request startAsynchronous];
}

-(void) logout
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_LOGOUT] tag:TYPE_USER_LOGOUT delegate:self];
    [request startAsynchronous];
}

-(void) getImageQuality
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_GET_IMAGEQUALITY] tag:TYPE_IMAGE_SCALE delegate:self];
    [request startAsynchronous];

}

-(void) viewComment:(NSString *)photoid commentid:(NSString *)commentid viewedphoto:(BOOL)viewedphoto
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_VIEWED_COMMONT] tag:TYPE_VIEWED_PHOTO delegate:self];
    [request setPostValue:photoid forKey:@"photoid"];
    [request setPostValue:commentid forKey:@"commentid"];
    if (!viewedphoto) [request setPostValue:@"photoview" forKey:@"photoview"];
    [request startAsynchronous];
}

-(void) updatePolicyViewState
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_UPDATE_POLICY] tag:TYPE_GENERAL delegate:self];
    [request startAsynchronous];
}

-(void) updateNotificationState
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_NOTIFICATION_STATE] tag:TYPE_EVENT_NOTIFICATION_STATUS delegate:self];
    [request startAsynchronous];
}

-(void) leaveComment:(NSString *)photoid comment:(NSString *)comment
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_LEAVE_COMMENT] tag:TYPE_LEAVE_COMMENT delegate:self];
    [request setPostValue:photoid forKey:@"photoid"];
    [request setPostValue:comment forKey:@"comment"];
    [request startAsynchronous];
}

-(void) processAutoLogin
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_SIGNIN] tag:TYPE_USER_LOGIN delegate:self];
    [request setPostValue:objUserInfo.strEmail forKey:@"email"];
    [request setPostValue:objUserInfo.strPassword forKey:@"password"];
    NSString *strSecurityKey = [Utils generateSecurityKey:[AppDelegate sharedInstance].token email:objUserInfo.strEmail sec:0];
    [request setPostValue:strSecurityKey forKey:@"key"];
    
    AppDelegate *delegate = [AppDelegate sharedInstance];
    
    if([delegate.token length] > 0)
        [request setPostValue:delegate.token forKey:@"token"];
    
    [request startAsynchronous];
}

-(void) flagPhoto:(NSString *)photoid type:(NSInteger)type content:(NSString *)content
{
    ASIFormDataRequest *request = [self getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_FLAG_PHOTO] tag:TYPE_FLAG_PHOTO delegate:self];
    [request setPostValue:photoid forKey:@"photoid"];
    [request setPostValue:[NSString stringWithFormat:@"%d", (int)type] forKey:@"type"];
    [request setPostValue:content forKey:@"content"];
    [request startAsynchronous];
}


- (ASIFormDataRequest *) getDefaultRequest:(NSURL *)url tag:(NSInteger)tag delegate:(id <ASIHTTPRequestDelegate>)delegate
{
    ASIFormDataRequest *request =[[ASIFormDataRequest alloc]initWithURL:url];
    request.delegate=delegate;
    request.tag = tag;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    
    if (objUserInfo && [objUserInfo.strUserId integerValue] > 0)
    {
        [request setPostValue:objUserInfo.strUserId forKey:@"userid"];
        [request setPostValue:objUserInfo.strSecurityKey forKey:@"key"];
    }
    else
    {
        NSInteger random = arc4random() % 999;
        NSString *strOtherPrx = [NSString stringWithFormat:@"%03d", (int)random];
        NSString *strSecurityKey = [Utils generateSecurityKey:strOtherPrx email:@"appuser@kinpix.com" sec:0];
        [request setPostValue:strSecurityKey forKey:@"okey"];
        [request setPostValue:strOtherPrx forKey:@"okeyref"];
    }
    
    return request;
}

- (ASIFormDataRequest *) getGeneralHttpRequest:(NSURL *)url delegate:(id <ASIHTTPRequestDelegate>)delegate
{
    ASIFormDataRequest *request =[[ASIFormDataRequest alloc]initWithURL:url];
    request.delegate = delegate;
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request setRequestMethod:@"POST"];
    [request setDefaultResponseEncoding:NSUTF8StringEncoding];
    [request setResponseEncoding:NSUTF8StringEncoding];
    
    if (objUserInfo && [objUserInfo.strUserId integerValue] > 0)
    {
        [request setPostValue:objUserInfo.strUserId forKey:@"userid"];
        [request setPostValue:objUserInfo.strSecurityKey forKey:@"key"];
    }
    
    return request;
}

- (S3PhotoUploader *) getS3PhotoUploader:(id<S3PhotoUploaderDelegate>)delegate
{
    if (!objPhotoUploader)
        objPhotoUploader = [[S3PhotoUploader alloc] init];
    objPhotoUploader.delegate = delegate;
    return objPhotoUploader;
}

#pragma mark -
#pragma mark - ASIHTTPRequest Delegate

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString    *value = [request responseString];
    NSLog(@"Value = %@", value);
    
    if (request.tag == TYPE_DOWNLOAD_KEYFILE)
    {
        [self updateUpdateKeyFinish];
        return;
    }
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([self isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    
    if (request.tag == TYPE_USER_LOGIN)
    {
        if (status == 200)
        {
            NSDictionary *dict = [json objectForKey:@"userinfo"];
            AppDelegate *delegate = [AppDelegate sharedInstance];
            [delegate.objUserInfo initWithJsonData:dict];
            [self refreshHomeData:json];
            NSDictionary* userInfo = @{@"viewmode": [json objectForKey:@"viewmode"], @"filtergroups":[json objectForKey:@"filtergroups"],
                                       @"filterbuckets":[json objectForKey:@"filterbuckets"]};
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_KEY_USER_LOGIN object:userInfo];
        }
        
        return;
    }
    
    if (status == 200)
    {
        switch (request.tag)
        {
            case TYPE_EVENT_NOTIFICATION_STATUS:
            case TYPE_VIEWED_PHOTO:
            case TYPE_CHECKED_NOTIFICATOIN:
            {
                NSDictionary *dict = [json objectForKey:@"notification"];
                if (!dict || [dict count] < 2)
                    return;
                
                iPhotoNotifCount = [[dict objectForKey:@"photonotification"] integerValue];
                iFriendNotifCount = [[dict objectForKey:@"friendnotification"] integerValue];
                [self refreshNotificationState];
                break;
            }
                
            case TYPE_GET_UPLOADKEY:
                [self refreshUploadKey:json];
                break;
                
            case TYPE_IMAGE_SCALE:
                [self refreshGlobalInfo:json];
                break;
                
            case TYPE_GET_DEFAULT_ALBUMS:
                [self refreshMyAlbumInfos:[json objectForKey:@"albums"]];
                break;
            default:
                break;
        }
    }
}

-(void) playAudio:(NSString*)fileName
{
//    NSError *error;
//    NSURL *soundUrl = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:fileName ofType:@"m4a"]];
//    
//    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
//    [self.audioPlayer play];
//    [self.audioPlayer setVolume:0.5];
}

#pragma mark - photo processing module

+(void) processUserImage:(UIImageView *)imageview;
{
    imageview.layer.cornerRadius = imageview.frame.size.height / 2;
    imageview.layer.masksToBounds = YES;
    imageview.layer.borderWidth = 0;
    [imageview.layer setBorderColor:[photoBorderColor CGColor]];
    float fBorderWidth = imageview.frame.size.height / 20;
    if (imageview.frame.size.height < 40)
        fBorderWidth = 1;
    
    [imageview.layer setBorderWidth:fBorderWidth];
}

+(void) processFeedView:(UIView *) view feedimage:(UIImageView *)feedimage
{
    [view.layer setCornerRadius:4.0];
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = 0.4f;
    
    if (!feedimage)
        return;
    
    feedimage.contentMode = UIViewContentModeScaleAspectFill;
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:feedimage.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    feedimage.layer.mask = maskLayer;
    
    feedimage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    feedimage.layer.borderWidth = 0.4f;
}

+(void) processNewLabel:(UIView *) lblNew
{
    NSInteger radius = lblNew.frame.size.height / 2 - 1;
    [lblNew.layer setCornerRadius:radius];
    lblNew.layer.masksToBounds = YES;
}

+(void) processPhotoView:(UIImageView *)photoimage
{
    photoimage.contentMode = UIViewContentModeScaleAspectFit;
    
    photoimage.clipsToBounds = YES;
    photoimage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    photoimage.layer.cornerRadius = 3.0f;
    photoimage.layer.borderWidth = 0.3f;
}

#pragma mark -
#pragma mark - Environment info

-(void) refreshGlobalInfo:(NSDictionary *)dict
{
    if ([dict objectForKey:@"imagescale"])
    {
        NSString *str = [dict objectForKey:@"imagescale"];
        if (str)
            fImageQuality = [str floatValue] / 100;
        
        if (fImageQuality < 0.1)
            fImageQuality = 0.1;
            
        if (fImageQuality > 1.0)
            fImageQuality = 1.0;
    }
    
    if ([dict objectForKey:@"notification"])
    {
        NSDictionary *tmpdict = [dict objectForKey:@"notification"];
        iPhotoNotifCount = [[tmpdict objectForKey:@"photonotification"] integerValue];
        iFriendNotifCount = [[tmpdict objectForKey:@"friendnotification"] integerValue];
        [self refreshNotificationState];
    }
}

-(void) refreshNotificationState
{
    NSInteger iNotifCount = 0;
    if (objUserInfo.bShowFriendNotif)
        iNotifCount += iFriendNotifCount;
    
    if (objUserInfo.bShowPhotoNotif)
        iNotifCount += iPhotoNotifCount;
    
    [self refreshNotificationBadgeNumber:iNotifCount];
}

-(void) refreshNotificationBadgeNumber:(NSInteger)count
{
    if (count == 0 || (!objUserInfo.bShowPhotoNotif && !objUserInfo.bShowFriendNotif))
    {
        self.tabNotificationItem.badgeValue = @"";
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    else
    {
        self.tabNotificationItem.badgeValue = [NSString stringWithFormat:@"%d", (int)count];
        [self.tabNotificationItem needsUpdateConstraints];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
    }
}

-(void) refreshShareEnvironment
{
    self.bAlbumMode = NO;
    self.bBucketMode = NO;
    [self.arrShareFriends removeAllObjects];
    [self.arrShareGroups removeAllObjects];
    [self.arrShareAlbums removeAllObjects];
    [self.arrSharePhotos removeAllObjects];
    self.maxPhotoCount = max_sharePhotoCount;
}

-(void) refreshUserEnvironment
{
    [self refreshShareEnvironment];
    [arrMyAlbums removeAllObjects];
    [arrMyBucket removeAllObjects];
    [arrMyGroups removeAllObjects];
    [self.arrMyPhotos removeAllObjects];
    [arrFriends removeAllObjects];
    [arrFriendBucket removeAllObjects];
    [arrFriendsAlbums removeAllObjects];
    [arrOrderPhotos removeAllObjects];
    [arrLastPhotos removeAllObjects];
    [objUserInfo initWithJsonData:nil];
}

#pragma mark -
#pragma mark - Init Global infos

- (void) refreshBucketInfos:(NSDictionary *) dict
{
    [self refreshMyBucket:[dict objectForKey:@"mybucket"] arrBuckets:arrMyBucket];
    [self refreshFriendBucket:[dict objectForKey:@"friendbucket"] arrBuckets:arrFriendBucket];
}

-(void) refreshOnlyFriendBucket:(NSDictionary *)dict
{
    [arrFriendBucket removeAllObjects];
    [arrFriendBucketUsers removeAllObjects];
    NSArray *arrUsers = [dict objectForKey:@"userinfos"];
    for (NSDictionary *dictUser in arrUsers)
    {
        FriendInfoStruct *finfo = [[FriendInfoStruct alloc] init];
        [finfo initWithJSonData:dictUser];
        [arrFriendBucketUsers addObject:finfo];
    }
    
    NSArray *array = [dict objectForKey:@"buckets"];
    for (NSDictionary *pdict in array)
    {
        BucketInfoStruct *info = [[BucketInfoStruct alloc] init];
        [info initWithJSonData:pdict];
        [arrFriendBucket addObject:info];
    }
}

-(void) refreshFriendBucket:(NSDictionary *)dict arrBuckets:(NSMutableArray *)arrBucket
{
    [arrBucket removeAllObjects];
    [arrFriendBucketUsers removeAllObjects];
    NSArray *arrUsers = [dict objectForKey:@"userinfos"];
    for (NSDictionary *dictUser in arrUsers)
    {
        FriendInfoStruct *finfo = [[FriendInfoStruct alloc] init];
        [finfo initWithJSonData:dictUser];
        [arrFriendBucketUsers addObject:finfo];
    }
    
    NSArray *array = [dict objectForKey:@"buckets"];
    for (NSDictionary *pdict in array)
    {
        BucketInfoStruct *info = [[BucketInfoStruct alloc] init];
        [info initWithJSonData:pdict];
        [arrBucket addObject:info];
    }
}

-(void) refreshMyBucket:(NSArray *)array arrBuckets:(NSMutableArray *)arrBucket
{
    [arrBucket removeAllObjects];
    for (NSDictionary *pdict in array)
    {
        BucketInfoStruct *info = [[BucketInfoStruct alloc] init];
        [info initWithJSonData:pdict];
        [arrBucket addObject:info];
    }
}

//-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
//{
//    UIViewController *controller = [window.rootViewController presentedViewController];
//    if ([controller isKindOfClass:[EBPhotoPagesController class]])
//        return UIInterfaceOrientationMaskAll;
//    
//    return UIInterfaceOrientationMaskPortrait;
//}


-(void) refreshHomeData:(NSDictionary *)json
{
    if ([json objectForKey:@"photolimitflag"])
        [AppDelegate showMessage:@"You have reached 90% of your KinPix photo limit" withTitle:@"Information"];
    [self refreshMyAlbumInfos:[json objectForKey:@"myabluminfo"]];
    [self refreshFriendAlbumInfos:[json objectForKey:@"friendabluminfo"]];
    [self refreshMyGroupInfos:[json objectForKey:@"groupinfo"]];
    [self refreshFriendsInfos:[json objectForKey:@"friendsinfo"]];
    [self refreshBucketInfos:[json objectForKey:@"bucketinfo"]];
    
    [self refreshGlobalInfo:json];
    
    [self refreshPhotoInfoOwner:[json objectForKey:@"photoinfo"] arrdes:arrOrderPhotos];
}

-(void) refreshPhotoInfoOwner:(NSDictionary *)arrjson arrdes:(NSMutableArray *)arrdes
{
    [self.arrMyPhotos removeAllObjects];
    
    NSMutableArray *arrTmpPhotos = [[NSMutableArray alloc] init];
    NSMutableArray *arrComments = [self getComments:[arrjson objectForKey:@"comments"]];
    [self refreshPhotoInfo:[arrjson objectForKey:@"main"] comments:arrComments arrdes:arrTmpPhotos];
    [self refreshPhotoInfo:[arrjson objectForKey:@"myphotos"] comments:arrComments arrdes:self.arrMyPhotos];
    [self refreshPhotoInfo:[arrjson objectForKey:@"lastphotos"] comments:arrComments arrdes:arrLastPhotos];
    
    [arrdes removeAllObjects];
     NSArray *array = [arrjson objectForKey:@"order"];
    for (NSDictionary *dict in array)
    {
        OrderInfoStruct *info = [[OrderInfoStruct alloc] initWithJsonData:dict];
        if (![info isBucketOrder] && [info getUserID] == [objUserInfo getUserID]) // "Me" row mean
            continue;
        
        FriendInfoStruct *finfo = [self findFriendInfo:[info getUserID]];
        if (!finfo)
            continue;
        
        [info addOwnPhotos:arrTmpPhotos];
        [arrdes addObject:info];
    }
}

-(NSMutableArray *) getComments:(NSArray *)array
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in array)
    {
        CommentInfoStruct *cinfo = [[CommentInfoStruct alloc] init];
        [cinfo initWithJsonData:dict];
        [result addObject:cinfo];
    }
    return result;
}

-(void) refreshPhotoInfo:(NSArray *)array comments:(NSMutableArray *)arrcomments arrdes:(NSMutableArray *)arrdes
{
    [arrdes removeAllObjects];
    for (NSDictionary *dicttmp in array)
    {
        PhotoInfoStruct *pinfo = [[PhotoInfoStruct alloc] init];
        [pinfo initWithJsonData:dicttmp];
        [pinfo setCommentArray:arrcomments];
        [arrdes addObject:pinfo];
    }
}

- (void) refreshFriendsInfos:(NSArray *) array
{
    if (arrFriends)
        [arrFriends removeAllObjects];
    else
        arrFriends = [NSMutableArray array];
    
    for (NSDictionary *dict in array)
    {
        FriendInfoStruct *info = [[FriendInfoStruct alloc] init];
        [info initWithJSonData:dict];
        [arrFriends addObject:info];
    }
}

- (void) getBucketGroupInfo:(NSInteger) bucketid arrdes:(NSMutableArray *)arrdes
{
    if (!arrdes)
        return;
    
    [arrdes removeAllObjects];
    BucketInfoStruct *bucketinfo = [self findBucketInfoByID:bucketid];
    for (NSString *strid in [bucketinfo getBucketGroupIDs])
    {
        GroupInfoStruct *ginfo = [self findGroupInfo:[strid integerValue]];
        if (ginfo)
            [arrdes addObject:ginfo];
    }
}

- (void) getBucketUserInfo:(NSInteger) bucketid arrdes:(NSMutableArray *)arrdes
{
    if (!arrdes)
        return;
    
    [arrdes removeAllObjects];
    BucketInfoStruct *bucketinfo = [self findBucketInfoByID:bucketid];
    for (NSString *strid in [bucketinfo getBucketUserIDs])
    {
        FriendInfoStruct *finfo = [self findBucketUserInfo:[strid integerValue]];
        if (finfo)
            [arrdes addObject:finfo];
    }
}

- (void) refreshMyAlbumInfos:(NSArray *) array
{
    if (arrMyAlbums)
        [arrMyAlbums removeAllObjects];
    else
        arrMyAlbums = [NSMutableArray array];
    
    for (NSDictionary *dict in array)
    {
        AlbumInfoStruct *info = [[AlbumInfoStruct alloc] init];
        [info initWithJSonData:dict];
        [arrMyAlbums addObject:info];
    }
}

- (void) refreshFriendAlbumInfos:(NSArray *) array
{
    if (arrFriendsAlbums)
        [arrFriendsAlbums removeAllObjects];
    else
        arrFriendsAlbums = [NSMutableArray array];

    for (NSDictionary *dict in array)
    {
        AlbumInfoStruct *info = [[AlbumInfoStruct alloc] init];
        [info initWithJSonData:dict];
        [arrFriendsAlbums addObject:info];
    }
}

- (void) refreshMyGroupInfos:(NSArray *) array
{
    if (arrMyGroups)
        [arrMyGroups removeAllObjects];
    else
        arrMyGroups = [NSMutableArray array];
    
    for (NSDictionary *dict in array)
    {
        GroupInfoStruct *info = [[GroupInfoStruct alloc] init];
        [info initWithJSonData:dict];
        [arrMyGroups addObject:info];
    }
}


-(BucketInfoStruct *) findBucketInfo:(NSString *)bucketname
{
    for (BucketInfoStruct *info in arrMyBucket)
    {
        if ([[info getBucketName] isEqualToString:bucketname])
            return info;
    }
    
    for (BucketInfoStruct *info in arrFriendBucket)
    {
        if ([[info getBucketName] isEqualToString:bucketname])
            return info;
    }

    return nil;
}

-(BucketInfoStruct *) findBucketInfoByID:(NSInteger)bucketid
{
    for (BucketInfoStruct *info in arrMyBucket)
    {
        if ([info getBucketID] == bucketid)
            return info;
    }
    
    for (BucketInfoStruct *info in arrFriendBucket)
    {
        if ([info getBucketID] == bucketid)
            return info;
    }
    
    return nil;
}

-(AlbumInfoStruct *) findAlbumInfo:(NSString *)albumName
{
    for (AlbumInfoStruct *info in arrMyAlbums)
    {
        if ([[info getAlbumName] isEqualToString:albumName])
            return info;
    }

    return nil;
}

-(NSMutableArray *) findFriendAlbums:(NSInteger)userid
{
    NSMutableArray *arrFriAlbum = [[NSMutableArray alloc] init];
    for (AlbumInfoStruct *item in arrFriendsAlbums) {
        if ([item getUserID] == userid)
            [arrFriAlbum addObject:item];
    }
    
    return arrFriAlbum;
}

-(NSMutableArray *) findFriendBuckets:(NSInteger)userid
{
    NSMutableArray *arrFriBucket = [[NSMutableArray alloc] init];
    for (BucketInfoStruct *item in arrFriendBucket) {
        if ([item getUserID] == userid)
            [arrFriBucket addObject:item];
    }
    
    return arrFriBucket;
}

-(FriendInfoStruct *) findBucketUserInfo:(NSInteger)userid
{
    for (FriendInfoStruct *finfo in arrFriendBucketUsers)
    {
        if ([finfo getUserID] == userid)
            return finfo;
    }
    
    return nil;
}


-(FriendInfoStruct *) findFriendInfo:(NSInteger)userid
{
    for (FriendInfoStruct *item in arrFriends) {
        if ([item getUserID] == userid)
            return item;
    }
    
    for (FriendInfoStruct *item in arrFriendBucketUsers)
    {
        if ([item getUserID] == userid)
            return item;
    }
    
    return nil;
}

-(GroupInfoStruct *) findGroupInfo:(NSInteger)groupid
{
    for (GroupInfoStruct *item in arrMyGroups) {
        if ([item getGroupID] == groupid)
            return item;
    }
    
    return nil;
}

-(GroupInfoStruct *) findGroupInfoByName:(NSString *)groupname
{
    for (GroupInfoStruct *ginfo in arrMyGroups)
    {
        if ([[ginfo getGroupName] isEqualToString:groupname])
            return ginfo;
    }
    
    return nil;
}

+ (BOOL)isConnectedToInternet {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)&zeroAddress);
    
    if (reachability) {
        SCNetworkReachabilityFlags flags;
        BOOL worked = SCNetworkReachabilityGetFlags(reachability, &flags);
        CFRelease(reachability);
        
        if (worked) {
            
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
                return YES;
            }
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
                return YES;
            }
        }
        
    }
    return NO;
}

-(void) saveUserInfo:(NSString *)strEmail password:(NSString *)strPassword
{
    if (strEmail.length < 1)
        return;
    
    NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
    [userDefautls setObject:strEmail forKey:@"email"];
    if (strPassword.length > 0)
    {
        [userDefautls setObject:strPassword forKey:@"password"];
        objUserInfo.strPassword = strPassword;
    }
    [userDefautls synchronize];
}

-(void) saveToken
{
    if (self.token.length < 1)
        return;
    
    NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
    [userDefautls setObject:self.token forKey:@"token"];
    [userDefautls synchronize];
}

-(BOOL) isCheckedError:(NSInteger)errorCode message:(NSString *)msg
{
    if (errorCode == 200)
        return NO;
    
    NSString *strMsg = msg;
    NSString *strTitle = @"Error";
    id<UIAlertViewDelegate> delegate = nil;
    switch (errorCode)
    {
        case ERR_FRIEND_NOT_FOUND_USER:
            strMsg = @"The Pin you have entered does not belong to a KinPix user.  Please try again.";
            break;
            
        case ERR_INVALID_PACKET:
        case ERR_INVALID_SESSION_KEY:
            strMsg = @"You have logged in to KinPix using a second device.  For your security, user’s can only use KinPix using one device at a time.";
            delegate = self;
            strTitle = @"Session Error";
            break;
            
        case ERR_ALBUM_CREATE:
            strMsg = @"Album creation failed.";
            break;
            
        case ERR_ALBUM_UPDATE:
            strMsg = @"Album creation failed.";
            break;
            
        case ERR_USER_IN_REVIEW:
        case ERR_NO_ACCEPT_USER:
            strTitle = @"Error";
            //strMsg = @"KinPix is not accepting new beta users at this time, please  signup again in a week or email support@kinpix.co.";
            strMsg = @"Due to high demand, KinPix is not accepting new accounts at this time,  please try again in 2-3 days.";
            delegate = self;
            break;
            
        case ERR_USER_SUSPENDED:
            strTitle = @"Error";
            //strMsg = @"KinPix is not accepting new beta users at this time, please  signup again in a week or email support@kinpix.co.";
            strMsg = @"Your account has been suspended.  Please contact KinPix support at support@kinpix.co";
            delegate = self;
            break;
            
        case ERR_ALBUM_LIMITED:
        case ERR_BUCKET_LIMITED:
            break;
            
        case ERR_USER_IVALID_PASS:
        case ERR_USER_NO_REGISTER:
            strTitle = @"Login Error";
            strMsg = @"The email address and/or password combination is incorrect or does not exist.  Please re-check your information or select \"Forgot Password\"";
            delegate = self;
            break;
            
        case ERR_NO_EXIST_USER:
            strTitle = @"Error";
            strMsg = @"Your account removed by administrator. Please  signup again";
            break;
            
        case ERR_USER_CODE_INVALID:
            strTitle = @"Error";
            strMsg = @"Verification code invalid. Please re-check your email.";
            break;
           
        case ERR_USER_DUPLICATE:
            strMsg = @"Email already exist.";
            break;
            
        case ERR_USER_AUTO_LOGIN_FAILED:
            strMsg = @"Please first login.";
            delegate = self;
            break;
    }

    if (strMsg.length < 12)
        return NO;
    
    if (msg.length > 15)
        strMsg = msg;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag = errorCode;
    [alertView show];
    return YES;
}

-(BOOL) loadUserInfo
{
    NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
    
    NSString *strEmail = [userDefautls objectForKey:@"email"];
    NSString *strPasswrod = [userDefautls objectForKey:@"password"];
    
    if (!self.token)
        self.token = [userDefautls objectForKey:@"token"];
    
    if (strEmail.length > 0 && strPasswrod.length > 0)
    {
        [[AppDelegate sharedInstance].objUserInfo initWithLoginInfo:strEmail password:strPasswrod];
        return YES;
    }
    return NO;
}

+ (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

@end
