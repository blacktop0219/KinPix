//
//  MessageBox.m
//  KinPix
//
//  Created by Piao Dev on 24/03/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "MessageBox.h"

@implementation MessageBox

+(void) showErrorMsage:(NSInteger)errType
{
    [self showErrorMsage:errType delegate:nil tag:0];
}

+(void) showErrorMsage:(NSInteger)errType delegate:(id<UIAlertViewDelegate>)delegate
{
    [self showErrorMsage:errType delegate:delegate tag:0];
}

+(void) showErrorMsage:(NSInteger)errType delegate:(id<UIAlertViewDelegate>)delegate tag:(NSInteger)tag
{
    NSString *strMessage = @"Error occured";
    switch (errType)
    {
        case MSG_ERR_INTERNET_CONNECT_FAILED:
            strMessage = @"It seems you are not connected to the internet right now.  Please check your connection.";
            break;
            
        case MSG_ERR_PHOTO_UPLOAD_FAILED:
            strMessage = @"Photo upload failed.";
            break;
            
        case MSG_ERR_PHOTO_UPDATE_FAILED:
            strMessage = @"Photo update failed.";
            break;
            
        case MSG_ERR_S3_INVALID_KEY:
            strMessage = @"Photo upload failed. Please try again after 10 min.";
            break;
            
        default:
            break;
    }
    
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Error" message:strMessage
                               delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertview.tag = tag;
    [alertview show];
}

@end
