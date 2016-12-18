//
//  Constants.h
//  KinPix
//
//  Created by Piao Dev on 28/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#ifndef KinPix_Constants_h
#define KinPix_Constants_h

#import "MessageBox.h"

#define KEY_IAP_PACKAGE2       @"iap.myechurch.purchase"
#define KEY_IAP_PACKAGE5       @"com.kinpix.package2"
#define KEY_IAP_PACKAGE10      @"com.kinpix.package3"

// Avirary API Keys
static NSString * const kAFAviaryAPIKey = @"61e9ba356f2feb7c";
static NSString * const kAFAviarySecret = @"7a6120c61c40bf4f";


#define DEFAULT_IMG_OPTION          (SDWebImageDownloaderProgressiveDownload | SDWebImageDownloaderIgnoreCachedResponse)

enum PROCESS_TYPES
{
    TYPE_GENERAL            = 0x1000,
    /// Photo APIs
    TYPE_LIKE_PHOTH         = 0x3000,
    TYPE_UNLIKE_PHOTH,
    TYPE_VIEWED_PHOTO,
    TYPE_UPDATE_PHOTO,
    TYPE_LEAVE_COMMENT,
    TYPE_COMMENT_LOADING,
    TYPE_SAVE_PROPERTIES,
    TYPE_FAVORITE_PHOTO,
    TYPE_UNFAVORITE_PHOTO,
    TYPE_FLAG_PHOTO,
    TYPE_DELETE_PHOTO,
    TYPE_FILTER_PHOTO,
    TYPE_GET_PHOTOINFOS,
    TYPE_GET_COMMENT,
    TYPE_GET_MORE_COMMENTS,
    TYPE_REFRESH_PHOTOINFO,
    TYPE_CHANGE_VIEW_MODE,
    TYPE_GET_UPLOADKEY,
    
    // Group APIs
    TYPE_GET_ALBUMS         = 0x4000,
    TYPE_GET_DEFAULT_ALBUMS,
    TYPE_SAVE_ALBUM,
    TYPE_UPDATE_BUCKET,
    TYPE_CHANGE_PERMISSION,
    TYPE_GET_FRIENDS_BUCKET,
    
    // Friends APIs
    TYPE_GET_FRIENDS        = 0x5000,
    TYPE_PROCESS_FRIEND_REQ,
    TYPE_SET_NOTIFICATION_STATE,
    TYPE_CLEAR_NOTIFICATION,
    TYPE_CHECKED_NOTIFICATOIN,
    
    // Users APIs
    TYPE_CONFIRM_VERIFY     = 0x6000,
    TYPE_RESEND_VERIFY,
    TYPE_USER_LOGIN,
    TYPE_USER_FORGOT_PASS,
    TYPE_USER_SIGNUP,
    TYPE_USER_LOGOUT,
    TYPE_EVENT_SITEINFO,
    TYPE_EVENT_NOTIFICATION_STATUS,
    TYPE_GET_APP_USAGE,
    TYPE_APP_PURCHASED,
    TYPE_IMAGE_SCALE,
    TYPE_DELETE_DUR_PHOTOS,
    TYPE_DOWNLOAD_KEYFILE,
    
};


// Error Codes
enum ERROR_CODES {
    ERR_INVALID_PACKET          = 1000,
    ERR_INVALID_SESSION_KEY     = 1001,
    ERR_PACKET_NO_FIELD         = 1002,

    // Photo Error
    ERR_PHOTO_DELETE            = 700,
    ERR_PHOTO_SHARE             = 701,
    ERR_PHOTO_LIKE              = 702,
    ERR_PHOTO_LEAVE_COMMENT     = 703,
    ERR_PHOTO_FAVORITE          = 704,
    ERR_PHOTO_UNLIKE            = 705,
    ERR_PHOTO_VIEW_COMMENT      = 706,
    ERR_PHOTO_VIEW              = 707,
    ERR_PHOTO_UNFAVORITE        = 708,
    ERR_PHOTO_FLAG              = 709,


    // User Error
    ERR_USER_DUPLICATE          = 600,
    ERR_USER_NO_REGISTER        = 601,
    ERR_USER_IVALID_PASS        = 602,
    ERR_USER_SUSPENDED          = 603,
    ERR_USER_IN_REVIEW          = 604,
    ERR_USER_UNVERIFYED         = 605,
    ERR_USER_REGISTER_FAIL      = 606,
    ERR_USER_UPDATE_FAIL        = 607,
    ERR_USER_CODE_INVALID       = 608,
    ERR_USER_INVALID_PHONE      = 609,
    ERR_NO_ACCEPT_USER          = 610,
    ERR_NO_EXIST_USER           = 611,
    
    ERR_USER_AUTO_LOGIN_FAILED  = 630,

    // Friend Error
    ERR_FRIEND_ALREADY_EXIST    = 500,
    ERR_FRIEND_NOT_FOUND_USER   = 501,
    ERR_FRIEND_NOT_EXIST_REQ    = 502,

    // Group Error
    ERR_GROUP_DUPLICATED        = 400,
    ERR_GROUP_CREATE            = 401,
    ERR_GROUP_DELETE            = 402,
    ERR_GROUP_UPDATE            = 403,
    ERR_ALBUM_DUPLICATED        = 410,
    ERR_ALBUM_CREATE            = 411,
    ERR_ALBUM_DELETE            = 412,
    ERR_ALBUM_UPDATE            = 413,
    ERR_ALBUM_LIMITED           = 414,
    ERR_BUCKET_DUPLICATED       = 420,
    ERR_BUCKET_CREATE           = 421,
    ERR_BUCKET_DELETE           = 422,
    ERR_BUCKET_UPDATE           = 423,
    ERR_BUCKET_LIMITED          = 424,
    
};

#endif
