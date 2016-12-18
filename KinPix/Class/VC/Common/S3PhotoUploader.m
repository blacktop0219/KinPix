//
//  S3PhotoUploader.m
//  KinPix
//
//  Created by Piao Dev on 19/03/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "S3PhotoUploader.h"
#import "AWSS3Client.h"
#import "SBJson.h"

@implementation S3PhotoUploader
{
    NSInteger iAllCount;
    NSInteger iUploadedCount;
    NSInteger iWidth, iHeight;
    NSInteger iErrorCode;
    BOOL bUploadFail;
    BOOL bDelegateCalled;
    BOOL bProfileUpload;
    BOOL bFirst;
    PhotoInfoStruct *ophotoinfo;
    NSArray *oarrPhotos;
    ASIFormDataRequest *request;
    
    NSString *strUserPhotoName;
    UIImage *imgUserPhoto;
}

@synthesize delegate;

-(void) initEnvironmentForPhotoUpload
{
    [AppDelegate sharedInstance].strAwsAccessKey = @"AKIAIORU3OASK5IGGU3A";
    [AppDelegate sharedInstance].strAwsSecretKey = @"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";
    iUploadedCount = 0;
    bUploadFail = NO;
    bDelegateCalled = NO;
    ophotoinfo = nil;
    oarrPhotos = nil;
    strUserPhotoName = nil;
    imgUserPhoto = nil;
}

-(BOOL) isValidUploadKey
{
    if ([AppDelegate sharedInstance].strAwsAccessKey.length > 10 && [AppDelegate sharedInstance].strAwsSecretKey.length > 10)
        return YES;
    
    return NO;
}

-(void) uploadFeedPhotos:(NSArray *)arrphotos
{
    bFirst = YES;
    iAllCount = arrphotos.count * 2;
    [self initEnvironmentForPhotoUpload];
    oarrPhotos = arrphotos;
    
    if ([self isValidUploadKey])
        [self uploadToServer];
    else
        [self getUploadKey];
}

-(void) getUploadKey
{
    bDelegateCalled = YES;
    [request clearDelegatesAndCancel];
    request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_UPLOAD_KEY] tag:TYPE_GET_UPLOADKEY delegate:self];
    [request startAsynchronous];
}

-(void) uploadFeedPhoto:(PhotoInfoStruct *)photoinfo
{
    bFirst = YES;
    iAllCount = 2;
    [self initEnvironmentForPhotoUpload];
    ophotoinfo = photoinfo;
    if ([self isValidUploadKey])
        [self uploadToServer];
    else
        [self getUploadKey];
}

-(void) uploadToServer
{
    iUploadedCount = 0;
    bUploadFail = NO;
    bDelegateCalled = NO;
    if (oarrPhotos)
    {
        [self saveFeedsToS3Bucket:oarrPhotos];
        [self saveFeedsThumbnailToS3Bucket:oarrPhotos];
    }
    else if (ophotoinfo)
    {
        [self saveFeedToS3Bucket:ophotoinfo];
        [self saveFeedThumbnailToS3Bucket:ophotoinfo];
    }
    else
    {
        [self savePhotoToS3Bucket];
    }
}

-(void) saveFeedsToS3Bucket:(NSArray *)arrphotos
{
    AWSS3Client *s3Client = [[AWSS3Client alloc] initWithAccessKeyID:[AppDelegate sharedInstance].strAwsAccessKey secret:[AppDelegate sharedInstance].strAwsSecretKey];
    s3Client.bucket = KEY_S3BUCKET_FEED;
    NSInteger interval = [[NSDate date] timeIntervalSince1970];
    NSInteger random = arc4random() % 1000;
    
    int idx = 0;
    for(PhotoInfoStruct *pinfo in arrphotos)
    {
        UIImage *img = [pinfo getPhoto];
        NSData *imgData = UIImageJPEGRepresentation(img, [AppDelegate sharedInstance].fImageQuality);
        NSString *strKey = [self generateNewImageName:[AppDelegate sharedInstance].objUserInfo.strUserId idx:++idx timesec:interval randnum:random];
        [pinfo setPhotoUploadKey:strKey];
        [pinfo setSize:imgData.length];
        if (bUploadFail)
            break;
        
        [s3Client putObjectWithData:imgData key:strKey mimeType:@"image/jpg" permission:AWSS3ObjectPermissionPublicReadWrite progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
             
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             iUploadedCount ++;
             [self processCheck];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (!bUploadFail)
                 iErrorCode = [error code];
             bUploadFail = YES;
             [self processCheck];
         }];
    }
}

-(void) saveKeyFile
{
    //[AppDelegate sharedInstance].strAwsAccessKey = @"AKIAJ7TKBMF5JIPPQ4AA";
    //[AppDelegate sharedInstance].strAwsSecretKey = @"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";
    
    AWSS3Client *s3Client = [[AWSS3Client alloc] initWithAccessKeyID:[AppDelegate sharedInstance].strAwsAccessKey secret:[AppDelegate sharedInstance].strAwsSecretKey];
    s3Client.bucket = KEY_S3BUCKET_KEYS;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"sharekey" ofType:@""];
    NSData *keyData = [NSData dataWithContentsOfFile:filePath];
    [s3Client putObjectWithData:keyData key:@"sharekey" mimeType:@"text" permission:AWSS3ObjectPermissionPublicReadWrite progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         bUploadFail = YES;
     }];
}

-(void) saveFeedsThumbnailToS3Bucket:(NSArray *)arrphotos
{
    AWSS3Client *s3Client = [[AWSS3Client alloc] initWithAccessKeyID:[AppDelegate sharedInstance].strAwsAccessKey secret:[AppDelegate sharedInstance].strAwsSecretKey];
    s3Client.bucket = KEY_S3BUCKET_THUMB;
    
    for(PhotoInfoStruct *pinfo in arrphotos)
    {
        NSData *imgData = [Utils getThumbImageData:[pinfo getPhoto]];
        NSString *strKey = [pinfo getPhotoUploadKey];
        if (bUploadFail)
            break;
        
        [s3Client putObjectWithData:imgData key:strKey mimeType:@"image/jpg" permission:AWSS3ObjectPermissionPublicReadWrite progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
         {
         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
             iUploadedCount ++;
             [self processCheck];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (!bUploadFail)
                 iErrorCode = [error code];
             bUploadFail = YES;
             [self processCheck];
         }];
    }
}


-(NSString *) generateNewImageName:(NSString *) userid idx:(int)idx timesec:(NSInteger)timesec randnum:(NSInteger)randnum
{
    return [NSString stringWithFormat:@"%@/%d-%03d_%d.jpg", userid, (int)timesec, (int)randnum, idx];
}

-(void) saveFeedToS3Bucket:(PhotoInfoStruct *)photoinfo
{
    AWSS3Client *s3Client = [[AWSS3Client alloc] initWithAccessKeyID:[AppDelegate sharedInstance].strAwsAccessKey secret:[AppDelegate sharedInstance].strAwsSecretKey];
    s3Client.bucket = KEY_S3BUCKET_FEED;
    
    NSInteger interval = [[NSDate date] timeIntervalSince1970];
    NSInteger random = arc4random() % 1000;
    
    UIImage *img = [photoinfo getPhoto];
    iWidth = img.size.width;
    iHeight = img.size.height;
    NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
    NSString *strKey = [self generateNewImageName:[AppDelegate sharedInstance].objUserInfo.strUserId idx:0  timesec:interval randnum:random];
    [photoinfo setPhotoUploadKey:strKey];
    [photoinfo setSize:imgData.length];
    [s3Client putObjectWithData:imgData key:strKey mimeType:@"image/jpg" permission:AWSS3ObjectPermissionPublicReadWrite progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
         
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         iUploadedCount ++;
         [self processCheck];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (!bUploadFail)
             iErrorCode = [error code];
         bUploadFail = YES;
         [self processCheck];
     }];
}

-(void) saveFeedThumbnailToS3Bucket:(PhotoInfoStruct *)photoinfo
{
    AWSS3Client *s3Client = [[AWSS3Client alloc] initWithAccessKeyID:[AppDelegate sharedInstance].strAwsAccessKey secret:[AppDelegate sharedInstance].strAwsSecretKey];
    s3Client.bucket = KEY_S3BUCKET_THUMB;
    
    NSData *imgData = [Utils getThumbImageData:[photoinfo getPhoto]];
    NSString *strKey = [photoinfo getPhotoUploadKey];
    if (bUploadFail)
        return;
    
    [s3Client putObjectWithData:imgData key:strKey mimeType:@"image/jpg" permission:AWSS3ObjectPermissionPublicReadWrite progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         iUploadedCount ++;
         [self processCheck];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (!bUploadFail)
             iErrorCode = [error code];
         bUploadFail = YES;
         [self processCheck];
     }];
}

-(void) processCheck
{
    if (bDelegateCalled)
        return;
    
    if (bUploadFail)
    {
        if (bFirst && iErrorCode == ERR_S3_UPLOAD_KEY_INVAILD)
            [self getUploadKey];
        else
            [self sendUploadFailed:iErrorCode];
    }
    else if (iUploadedCount == iAllCount)
    {
        if (ophotoinfo)
            [self updatePhotoInfo];
        else
            [self registerPhotoInfos];
    }
}

-(void) updatePhotoInfo
{
    [request clearDelegatesAndCancel];
    request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_UPDATE_PHOTO] tag:TYPE_UPDATE_PHOTO delegate:self];
    [request setPostValue:[ophotoinfo getPhotoIDToString] forKey:@"photoid"];
    [request setPostValue:[ophotoinfo getSizeToString] forKey:@"size"];
    [request setPostValue:[Utils getStringFromInteger:iWidth] forKey:@"width"];
    [request setPostValue:[Utils getStringFromInteger:iHeight] forKey:@"height"];
    [request setPostValue:[ophotoinfo getPhotoUploadKey] forKey:@"name"];
    [request startAsynchronous];
}

-(void) registerPhotoInfos
{
    [request clearDelegatesAndCancel];
    request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_SHARE] tag:2001 delegate:self];
    NSMutableArray *photosArray = [[NSMutableArray alloc] init];
    for(PhotoInfoStruct *pinfo in oarrPhotos)
    {
        NSMutableDictionary *detailPhotoDict = [[NSMutableDictionary alloc] init];
        
        if([[pinfo getTag] length] > 0)
            [detailPhotoDict setObject:[pinfo getTag] forKey:@"tag"];
        
        if([[pinfo getTitle] length] > 0)
            [detailPhotoDict setObject:[pinfo getTitle] forKey:@"title"];
        
        [detailPhotoDict setObject:[pinfo getPhotoUploadKey] forKey:@"photourl"];
        [detailPhotoDict setObject:[pinfo getWidthToString] forKey:@"width"];
        [detailPhotoDict setObject:[pinfo getHeightToString] forKey:@"height"];
        [detailPhotoDict setObject:[pinfo getSizeToString] forKey:@"size"];
        [photosArray addObject:detailPhotoDict];
    }
    
    [request setPostValue:[photosArray JSONRepresentation] forKey:@"photos"];
    
    if ([AppDelegate sharedInstance].bAlbumMode)
    {
        // ablum setting
        NSString *strAlbum = @"";
        for(AlbumInfoStruct *ainfo in [AppDelegate sharedInstance].arrShareAlbums)
        {
            if([strAlbum length] == 0)
                strAlbum = [ainfo getAlbumIDToString];
            else
                strAlbum = [strAlbum stringByAppendingFormat:@",%d", (int)[ainfo getAlbumID]];
        }
        [request setPostValue:strAlbum forKey:@"albumids"];
        
        // share userids
        NSString *peopleStr = @"";
        for(FriendInfoStruct *info in [AppDelegate sharedInstance].arrShareFriends)
        {
            if([peopleStr length] == 0)
                peopleStr = [NSString stringWithString:[info getUserIDToString]];
            else
                peopleStr = [peopleStr stringByAppendingFormat:@",%d", (int)[info getUserID]];
        }
        
        if([peopleStr length] > 0)
            [request setPostValue:peopleStr forKey:@"puserids"];
        
        // share group
        NSString *groupStr = @"";
        for(GroupInfoStruct *ginfo in [AppDelegate sharedInstance].arrShareGroups)
        {
            if([groupStr length] == 0)
                groupStr = [ginfo getGrouIDToString];
            else
                groupStr = [groupStr stringByAppendingFormat:@",%d", (int)[ginfo getGroupID]];
        }
        
        if([groupStr length] > 0)
            [request setPostValue:groupStr forKey:@"pgroupids"];
    }
    else
    {
        // bucket setting
        NSString *strBucket = @"";
        if ([AppDelegate sharedInstance].arrShareAlbums.count > 0)
        {
            BucketInfoStruct *binfo = [[AppDelegate sharedInstance].arrShareAlbums objectAtIndex:0];
            strBucket = [binfo getBucketIDToString];
        }
        [request setPostValue:strBucket forKey:@"bucketid"];
    }
    
    [request startAsynchronous];
}


-(void) refreshUploadKey:(NSDictionary *)dict
{
    NSString *strKeyURL = [dict objectForKey:@"signedkeyurl"];
    if (strKeyURL.length > 30)
    {
        [request clearDelegatesAndCancel];
        request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strKeyURL]];
        request.tag = TYPE_DOWNLOAD_KEYFILE;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *file = [NSString stringWithFormat:@"%@/temp", documentsDirectory];
        [request setDownloadDestinationPath:file];
        [request setDelegate:self];
        [request startAsynchronous];
    }
}

-(void) sendUploadFailed:(NSInteger)errcode
{
    bDelegateCalled = YES;
    if (errcode == ERR_S3_UPLOAD_KEY_INVAILD)
        [MessageBox showErrorMsage:MSG_ERR_S3_INVALID_KEY];
    else if (errcode == ERR_S3_CONNECTION_FAILED)
        [MessageBox showErrorMsage:MSG_ERR_INTERNET_CONNECT_FAILED];
    else
    {
        if (ophotoinfo)
            [MessageBox showErrorMsage:MSG_ERR_PHOTO_UPDATE_FAILED];
        else
            [MessageBox showErrorMsage:MSG_ERR_PHOTO_UPLOAD_FAILED];
    }
    [self.delegate uploadFailed:errcode];
}

-(void)requestFinished:(ASIHTTPRequest *)rrequest
{
    NSLog(@"Share Result = %@", [rrequest responseString]);
    if (rrequest.tag == TYPE_DOWNLOAD_KEYFILE)
    {
        bFirst = NO;
        if ([[AppDelegate sharedInstance] updateUpdateKeyFinish])
            [self uploadToServer];
        else
            [self sendUploadFailed:ERR_S3_UPLOAD_KEY_INVAILD];
        return;
    }

    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:rrequest.responseData
                                                         options:kNilOptions
                                                           error:&error];
    if(rrequest.tag == TYPE_GET_UPLOADKEY)
    {
        [self refreshUploadKey:json];
        return;
    }
    
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
    {
        [self sendUploadFailed:ERR_PHOTO_UPDATE_FAILED];
        return;
    }
    
    if (rrequest.tag == TYPE_UPDATE_PHOTO)
    {
        if ([ophotoinfo getPhotoID] == [[json objectForKey:@"photoid"] integerValue])
            [ophotoinfo initWithJsonData:[json objectForKey:@"photoinfo"]];
    }
    
    if(status == 200)
        [delegate uploadFinished];
    else
        [self sendUploadFailed:ERR_PHOTO_UPDATE_FAILED];
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    [self sendUploadFailed:ERR_PHOTO_UPDATE_FAILED];
}

-(void) savePhotoToS3Bucket
{
    AWSS3Client *s3Client = [[AWSS3Client alloc] initWithAccessKeyID:[AppDelegate sharedInstance].strAwsAccessKey secret:[AppDelegate sharedInstance].strAwsSecretKey];
    s3Client.bucket = KEY_S3BUCKET_USER;
    NSData *imgData = [Utils getThumbImageData:imgUserPhoto];
    [s3Client putObjectWithData:imgData key:strUserPhotoName mimeType:@"image/jpg" permission:AWSS3ObjectPermissionPublicReadWrite progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
     {
     } success:^(AFHTTPRequestOperation *operation, id responseObject) {
         [delegate uploadFinished];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         iErrorCode = [error code];
         if (bFirst && iErrorCode == ERR_S3_UPLOAD_KEY_INVAILD)
             [self getUploadKey];
         else
             [self sendUploadFailed:ERR_PHOTO_UPDATE_FAILED];
     }];
}

-(void) uploadProfilePhoto:(UIImage *)imgPhoto photourl:(NSString *)photourl
{
    [self initEnvironmentForPhotoUpload];
    
    bFirst = YES;
    imgUserPhoto = imgPhoto;
    strUserPhotoName = photourl;
    if ([self isValidUploadKey])
        [self uploadToServer];
    else
        [self getUploadKey];

    
    
}


@end
