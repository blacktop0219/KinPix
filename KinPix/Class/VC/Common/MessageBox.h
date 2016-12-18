//
//  MessageBox.h
//  KinPix
//
//  Created by Piao Dev on 24/03/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageBox : NSObject

enum {
    MSG_ERR_INTERNET_CONNECT_FAILED = 1000,
    MSG_ERR_PHOTO_UPLOAD_FAILED,
    MSG_ERR_S3_INVALID_KEY,
    MSG_ERR_PHOTO_UPDATE_FAILED,
};

+(void) showErrorMsage:(NSInteger)errType;
+(void) showErrorMsage:(NSInteger)errType delegate:(id<UIAlertViewDelegate>)delegate;
+(void) showErrorMsage:(NSInteger)errType delegate:(id<UIAlertViewDelegate>)delegate tag:(NSInteger)tag;

@end
