//
//  S3PhotoUploader.h
//  KinPix
//
//  Created by Piao Dev on 19/03/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequestDelegate.h"

enum S3Error
{
    ERR_S3_CONNECTION_FAILED = -1000,
    ERR_S3_UPLOAD_KEY_INVAILD = -1011,
    ERR_PHOTO_UPDATE_FAILED,
};

@protocol S3PhotoUploaderDelegate <NSObject>

-(void) uploadFinished;
-(void) uploadFailed:(NSInteger)errorcode;

@end

@interface S3PhotoUploader : NSObject<ASIHTTPRequestDelegate>

@property (weak, nonatomic) id<S3PhotoUploaderDelegate>delegate;

-(void) saveKeyFile;
-(void) uploadFeedPhotos:(NSArray *)arrphotos;
-(void) uploadFeedPhoto:(PhotoInfoStruct *)photoinfo;
-(void) uploadProfilePhoto:(UIImage *)imgPhoto photourl:(NSString *)photourl;

@end
