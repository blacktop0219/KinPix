//
//  PhotoPreviewController.m
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "PhotoSearchViewController.h"
#import "CommentViewCell.h"
#import "CommentInfoStruct.h"
#import "PhotoInfoStruct.h"
#import "FriendInfoStruct.h"
#import "AlbumInfoStruct.h"
#import "PhotoDetailViewController.h"
#import "ActionSheetStringPicker.h"
#import "ActionSheetMonthPicker.h"
#import "PhotoFilterCollectionViewCell.h"
#import "LikerViewController.h"
#import "BucketEditViewController.h"
#import "PhotoPropertiesViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "CommentViewController.h"
#import <AviarySDK/AviarySDK.h>
#import "SDImageCache.h"

#define CELL_IDENTIFIER @"photoFilterCell"

enum VIEW_TYPE
{
    TYPE_COMMENT = 100,
    
    TYPE_FILTER = 200,
    TYPE_FILTER_SHARED_WITH,
    TYPE_FILTER_FRIENDS,
    TYPE_FILTER_ALBUM,
    TYPE_FILTER_BUCKET,
    TYPE_FILTER_EXPIRY,
    TYPE_FILTER_GROUP,
    TYPE_FILTER_DATE
};

@interface PhotoSearchViewController ()<AFPhotoEditorControllerDelegate, UpdateBucketDelegate, S3PhotoUploaderDelegate>
{
    NSMutableArray *arrPopover;
    NSMutableArray *arrPhotos;
    
    NSMutableArray *arrGroups;
    NSMutableArray *arrCurrentAlbums;
    NSMutableArray *arrCurrentBuckets;
    NSMutableArray *arrFriends;
    FriendInfoStruct *objCurrentFriend;
    NSMutableArray *arrPhotoHeight;

    NSMutableArray *arrAllAlbums;
    NSMutableArray *arrAllBuckets;
    NSString *strKeyword;
    CGFloat fLastOffset;
    NSInteger iScreenHeight, iUploadCount;
}
@end

@implementation PhotoSearchViewController
{
    // View Type
    NSInteger iViewType;
    
    NSInteger iCurrentIdx;
    // selected data
    NSInteger iExpiryDate;
    
    FriendInfoStruct *objUser;
    GroupInfoStruct *objGroup;
    AlbumInfoStruct *objAlbum;
    BucketInfoStruct *objBucket;
    FriendInfoStruct *objSharedUser;
    
    NSInteger iAlbumId; // 0 : ALL, -1 : No Filter,  0 < Selected BucketID
    NSInteger iBucketId; // 0 : ALL, -1 : No Filter,  0 < Selected AlbumID
    
    BOOL bLoading;
    BOOL bEndFlag;
    BOOL bBucketMode;
    
    PhotoInfoStruct *curPhotoInfo;
}

@synthesize lblAlbum, lblDateShared, lblExpiryDate, lblUserName, lblGroup, lblSharedWith;
@synthesize ivProfile, viewExpiryDate, viewGroup, lblResult, viewSharedWidth;
@synthesize iCurrentUserID, lblBucket, lblBucketTitle, viewHeader;
@synthesize lblAlbumTitle, objStartBucket, txtSearch, covPhotos;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //if (!self.bShowSettingButton)
    //    [self hideButtons];
    
    [covPhotos registerNib:[UINib nibWithNibName:@"PhotoFilterCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    
    arrPhotoHeight = [[NSMutableArray alloc] init];
    arrPhotos = [[NSMutableArray alloc] init];
    
    arrGroups = [[NSMutableArray alloc] init];
    arrFriends = [[NSMutableArray alloc] init];
    arrAllAlbums = [[NSMutableArray alloc] init];
    arrPopover = [[NSMutableArray alloc] init];
    
//    if (objStartBucket)
//    {
//        iCurrentUserID = [objStartBucket getUserID];
//        bBucketMode = YES;
//    }
    
    iScreenHeight = [[UIScreen mainScreen] bounds].size.height;
    [Utils copyArray:[AppDelegate sharedInstance].arrFriends desarray:arrFriends];
    [self refreshAllFriendsInfo];
    [AppDelegate processUserImage:ivProfile];
    [self refreshChangeUser:YES];
    lblResult.hidden = YES;
    self.navigationController.navigationBarHidden = YES;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [arrPhotoHeight removeAllObjects];
    [covPhotos reloadData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.request clearDelegatesAndCancel];
}

-(void) refreshAllFriendsInfo
{
    
}

-(void) updateBucket:(BucketInfoStruct *)info
{
    if (iBucketId == [info getBucketID])
    {
        lblBucket.text = [info getBucketName];
        objBucket = info;
    }
}

-(void) refreshChangeUser:(BOOL)bStart
{
    lblAlbum.text = @"All";
    lblDateShared.text = @"All";
    lblExpiryDate.text = @"All";
    lblGroup.text = @"All";
    lblSharedWith.text = @"All";
    lblBucket.text = @"All";
    iBucketId = 0;
    iAlbumId = 0;
    
    objAlbum = nil;
    objBucket = nil;
    objSharedUser = nil;
    iExpiryDate = 0;
    
    if (iCurrentUserID == [[AppDelegate sharedInstance].objUserInfo getUserID])
    {
        lblBucketTitle.text = @"My\nbuckets";
        lblAlbumTitle.text = @"My\nalbums";
        viewGroup.hidden = NO;
        viewSharedWidth.hidden = NO;
        
        // User Name
        lblUserName.text = @"Me";
        UIImage *placeImage = [Utils getDefaultProfileImage];
        [ivProfile sd_setImageWithURL:[[AppDelegate sharedInstance].objUserInfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
        
        arrGroups = [AppDelegate sharedInstance].arrMyGroups;
        arrCurrentAlbums = [AppDelegate sharedInstance].arrMyAlbums;
        arrCurrentBuckets = [AppDelegate sharedInstance].arrMyBucket;
    }
    else
    {
        viewSharedWidth.hidden = YES;
        viewGroup.hidden = YES;
        if (iCurrentUserID  && iCurrentUserID != [objUser getUserID])
        {
            for (FriendInfoStruct *finfo in arrFriends)
            {
                if (iCurrentUserID == [finfo getUserID])
                {
                    objUser = finfo;
                    break;
                }
            }
        }
        
        if (objUser == nil)
        {
            lblBucketTitle.text = @"Group Albums";
            lblAlbumTitle.text = @"Albums";
            lblUserName.text = @"Everyone";
            objAlbum = nil;
            objBucket = nil;
            ivProfile.image = [UIImage imageNamed:@"img_everyone.png"];
            [self refreshAlbumAndBucket:nil buckettype:0 albumeinfo:nil albumtype:0];
            return;
        }
        
        lblBucketTitle.text = [NSString stringWithFormat:@"%@'s\nbuckets", [objUser getFirstName]];
        lblAlbumTitle.text = [NSString stringWithFormat:@"%@'s\nalbums", [objUser getFirstName]];
        viewGroup.hidden = YES;
        
        // User Name
        lblUserName.text = [objUser getUserName];
        objCurrentFriend = [[AppDelegate sharedInstance] findFriendInfo:[objUser getUserID]];
        UIImage *placeImage = [Utils getDefaultProfileImage];
        [ivProfile sd_setImageWithURL:[objCurrentFriend getPhotoURL] placeholderImage:placeImage options:SDWebImageProgressiveDownload];
        objGroup = nil;
        
        arrCurrentAlbums = [[AppDelegate sharedInstance] findFriendAlbums:[objUser getUserID]];
        arrCurrentBuckets = [[AppDelegate sharedInstance] findFriendBuckets:[objUser getUserID]];
    }
    
    [self refreshAlbumAndBucket:nil buckettype:0 albumeinfo:nil albumtype:0];
}

-(void) refreshAlbumAndBucket:(BucketInfoStruct *)bucketinfo buckettype:(NSInteger)buckettype albumeinfo:(AlbumInfoStruct *)albuminfo
                    albumtype:(NSInteger)albumtype
{
    objBucket = bucketinfo;
    objAlbum = albuminfo;
    if (objBucket)
    {
        lblAlbum.text = @"No Filter";
        iAlbumId = -1;
        lblBucket.text = [objBucket getBucketName];
        iBucketId = [objBucket getBucketID];
    }
    else if (objAlbum)
    {
        lblBucket.text = @"No Filter";
        iBucketId = -1;
        lblAlbum.text = [objAlbum getAlbumName];
        iAlbumId = [objAlbum getAlbumID];
    }
    else
    {
        if (buckettype == 0)
        {
            lblBucket.text = @"All";
            iBucketId = 0;
        }
        else
        {
            lblBucket.text = @"No Filter";
            iBucketId = -1;
        }
        
        if (albumtype == 0)
        {
            lblAlbum.text = @"All";
            iAlbumId = 0;
        }
        else
        {
            lblAlbum.text = @"No Filter";
            iAlbumId = -1;
        }
    }
    
    if (iCurrentUserID == 0 || iBucketId >= 0)
        viewExpiryDate.hidden = YES;
    else if (iAlbumId >= 0)
        viewExpiryDate.hidden = NO;
    
    if (iBucketId > 0)
        viewSharedWidth.hidden = YES;
    
    [self reloadPhotoInfo:0 loadmoreflag:NO];
}


-(void) reloadPhotoInfo:(NSInteger)photoid loadmoreflag:(BOOL)loadmoreflag
{
    if (photoid < 1 || [arrPhotos count] < 1)
    {
        [arrPhotos removeAllObjects];
        [arrPhotoHeight removeAllObjects];
        bEndFlag = NO;
    }
    
    if (loadmoreflag && (bEndFlag || bLoading))
        return;
    
    if (iAlbumId == -1 && iBucketId == -1)
    {
        //[AppDelegate showMessage:@"Please select filter type" withTitle:@"Warning"];
        [arrPhotos removeAllObjects];
        [arrPhotoHeight removeAllObjects];
        [self refreshFilterResult:NO];
        return;
    }
    
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_FILTER] tag:TYPE_FILTER_PHOTO delegate:self];
    [self.request setPostValue:[Utils getStringFromInteger:iCurrentUserID] forKey:@"photouserid"];
    [self.request setPostValue:[Utils getStringFromInteger:photoid] forKey:@"photoid"];
    
    if (iAlbumId == 0 && iBucketId == 0)
        [self.request setPostValue:@"all" forKey:@"mode"];
    else if (iBucketId >= 0)
    {
        [self.request setPostValue:@"bucket" forKey:@"mode"];
        if (iBucketId)
            [self.request setPostValue:[Utils getStringFromInteger:iBucketId] forKey:@"bucketid"];
    }
    else if (iAlbumId >= 0)
    {
        [self.request setPostValue:@"album" forKey:@"mode"];
        if (iAlbumId)
            [self.request setPostValue:[Utils getStringFromInteger:iAlbumId] forKey:@"albumid"];
    }

    if (objSharedUser)
        [self.request setPostValue:[objSharedUser getUserIDToString] forKey:@"sharedwuserid"];
    
    if (iAlbumId >= 0)
    {
//        if (iCurrentUserID == [[AppDelegate sharedInstance].objUserInfo getUserID])
//        {
//            if (objGroup)
//                [self.request setPostValue:[objGroup getGrouIDToString] forKey:@"groupid"];
//        }
        
        if (iExpiryDate)
        {
            NSInteger expdate = 0;
            if (iExpiryDate == 1)
                expdate = 0;
            else if (iExpiryDate == 2)
                expdate = 3;
            else if (iExpiryDate == 3)
                expdate = 7;
            else if (iExpiryDate == 4)
                expdate = 30;
            else if (iExpiryDate == 5)
                expdate = 180;
            else if (iExpiryDate == 6)
                expdate = 365;
            
            [self.request setPostValue:[NSString stringWithFormat:@"%d", (int)expdate] forKey:@"wexpiredate"];
        }
    }
    
    if (![lblDateShared.text isEqualToString:@"All"])
    {
        NSDate *tmpdate = [Utils getMonthFromString:lblDateShared.text];
        [self.request setPostValue:[Utils getYearStrigFromDat:tmpdate] forKey:@"sharedyear"];
        [self.request setPostValue:[Utils getMonthStrigFromDateForDB:tmpdate] forKey:@"sharedmonth"];
    }
    
    if (strKeyword.length > 0)
        [self.request setPostValue:strKeyword forKey:@"keyword"];
    
    bLoading = YES;
    [self.request startAsynchronous];
}

- (void)processComment:(PhotoInfoStruct *)info
{
    CommentViewController *viewController = (CommentViewController *)[[AppDelegate sharedInstance] getUIViewController:@"commentViewVC"];
    viewController.photoinfo = info;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)processPermission:(PhotoInfoStruct *)info index:(NSInteger)index
{
    if ([info isMyBucket])
    {
        BucketEditViewController *vcBucket = (BucketEditViewController *)[[AppDelegate sharedInstance] getUIViewController:@"bucketEditController"];
        vcBucket.objInfo = [[AppDelegate sharedInstance] findBucketInfoByID:[info getBucketID]];
        vcBucket.delegate = self;
        [self.navigationController pushViewController:vcBucket animated:YES];
        return;
    }
    
    PhotoDetailViewController *controller = (PhotoDetailViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoDetailVC"];
    controller.arrViewPhotos = arrPhotos;
    controller.bShowPermission = YES;
    controller.iCurrentIdx = index;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)processMore:(PhotoInfoStruct *)info index:(NSInteger)index
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Permissions", @"Download Photo", @"Edit Photo", @"Change Caption or Tag", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = index + 100;
    curPhotoInfo = info;
    iCurrentIdx = index;
    [actionSheet showInView:self.view];
}


- (void)processLikeView:(PhotoInfoStruct *)info
{
    LikerViewController *controller = (LikerViewController *)[[AppDelegate sharedInstance] getUIViewController:@"showLikersVC"];
    controller.iLikeCount = [info getLikeCount];
    controller.iPhotoID = [info getPhotoID];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideHUD];
    NSString    *value = [request responseString];
    NSLog(@"Value = %@", value);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    
    if(status == 200)
    {
        if (request.tag == TYPE_DELETE_PHOTO)
        {
            NSInteger photoid = [[json objectForKey:@"photoid"] integerValue];
            [self deletePhoto:photoid];
        }
        else if (request.tag == TYPE_FLAG_PHOTO)
        {
            [covPhotos reloadData];
        }
        else if (request.tag == TYPE_FILTER_PHOTO)
        {
            NSDictionary *dict = [json objectForKey:@"photos"];
            NSMutableArray *arrTemp = [NSMutableArray array];
            NSInteger iPhotoid = [[json objectForKey:@"photoid"] integerValue];
            if (iPhotoid == 0)
            {
                [arrPhotos removeAllObjects];
                [arrPhotoHeight removeAllObjects];
            }
            NSMutableArray *arrComments = [[AppDelegate sharedInstance] getComments:[dict objectForKey:@"comments"]];
            [[AppDelegate sharedInstance] refreshPhotoInfo:[dict objectForKey:@"photoinfos"] comments:arrComments arrdes:arrTemp];
            if (arrTemp.count < 1)
                bEndFlag = YES;
            [arrPhotos addObjectsFromArray:arrTemp];
            [self refreshFilterResult:NO];
        }
    }
    else
    {
        if (request.tag == TYPE_DELETE_PHOTO)
        {
            [AppDelegate showMessage:@"Can't delete this photo." withTitle:@"Error"];
        }
    }
    
    if (request.tag == TYPE_FILTER_PHOTO) bLoading = NO;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    if (request.tag == TYPE_FILTER_PHOTO) bLoading = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) refreshFilterResult:(BOOL)bError
{
    if (bError)
    {
        [arrPhotos removeAllObjects];
        [arrPhotoHeight removeAllObjects];
        [covPhotos reloadData];
        lblResult.hidden = NO;
        return;
    }
    
    if ([arrPhotos count] < 1)
        lblResult.hidden = NO;
    else
        lblResult.hidden = YES;
    
    [covPhotos reloadData];
}

-(void) deletePhoto:(NSInteger) photoid
{
    for (int idx = 0; idx < [arrPhotos count]; idx++)
    {
        PhotoInfoStruct *info = [arrPhotos objectAtIndex:idx];
        if ([info getPhotoID] == photoid)
        {
            [arrPhotos removeObject:info];
            if (idx < [arrPhotoHeight count])
                [arrPhotoHeight removeObjectAtIndex:idx];
            break;
        }
    }
    
    [covPhotos reloadData];
}



#pragma mark - Navigation



- (IBAction)processSearchAction:(id)sender
{
    [txtSearch resignFirstResponder];
    [self showHUD:@"Searching..."];
    strKeyword = txtSearch.text;
    [self reloadPhotoInfo:0 loadmoreflag:NO];
}

- (IBAction)processChangeUser:(id)sender
{
    [txtSearch resignFirstResponder];
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"Everyone"];
    [arrPopover addObject:@"Me"];
    for (FriendInfoStruct *info in arrFriends)
        [arrPopover addObject:[info getUserName]];
    
    iViewType = TYPE_FILTER_FRIENDS;
    [self showFilterSheet];
}

- (IBAction)processFilterDateShared:(id)sender
{
    [txtSearch resignFirstResponder];
    iViewType = TYPE_FILTER_DATE;
    
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Show All", @"Show Year", @"Show Month", nil];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"All", @"Month/Year", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0x10000)
    {
        if (buttonIndex == 0)
            return;
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (actionSheet.tag >= 100)
    {
        actionSheet.tag -= 100;
        if(buttonIndex == 0) // Delete
        {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            alertview.tag = TYPE_DELETE_PHOTO;
            [alertview show];
        }
        else if (buttonIndex == 1) // Permissions.
        {
            if (actionSheet.tag >= arrPhotos.count)
                return;
            
            PhotoInfoStruct *pinfo = [arrPhotos objectAtIndex:actionSheet.tag];
            [self processPermission:pinfo index:actionSheet.tag];
        }
        else if(buttonIndex == 2) // Download
        {
            PhotoFilterCollectionViewCell *cell = (PhotoFilterCollectionViewCell *)[covPhotos cellForItemAtIndexPath:[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library saveImage:cell.ivPhoto.image toAlbum:k_DownloadPhotoPath withCompletionBlock:^(NSError *error) {
                if (error!=nil) {
                    NSLog(@"Big error: %@", [error description]);
                }
                else
                    [AppDelegate showMessage:@"Your photo has been downloaded to your local camera roll." withTitle:nil];
            }];
        }
        else if (buttonIndex == 3) // Edit Photo
        {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                PhotoInfoStruct *pinfo = curPhotoInfo;
                SDWebImageManager *manager = [SDWebImageManager sharedManager];
                [manager downloadImageWithURL:[pinfo getPhotoURL]
                                      options:0
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize)
                 {
                 }
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
                 {
                     if (image)
                         [self launchPhotoEditorWithImage:image];
                     else
                         [AppDelegate showMessage:@"Can't load photo" withTitle:@"Error"];
                 }];
            });
        }
        else if(buttonIndex == 4) // Change title and tag
        {
            PhotoPropertiesViewController *viewcontroller = (PhotoPropertiesViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoEditVC"];
            viewcontroller.photoinfo = curPhotoInfo;
            [self.navigationController pushViewController:viewcontroller animated:YES];
        }
    }
    else
    {
        if(buttonIndex == 0) // ALL
        {
            lblDateShared.text = @"All";
            [self reloadPhotoInfo:0 loadmoreflag:NO];
        }
        else if (buttonIndex == 1) // Month
        {
            ActionSheetMonthPicker *monthPicker =[[ActionSheetMonthPicker alloc] initWithTitle:@"Shared Month" datePickerMode:UIDatePickerModeDate selectedDate:[Utils getMonthFromString:lblDateShared.text] target:self action:@selector(timeWasSelected:element:) origin:lblDateShared];
            [monthPicker showActionSheetPicker];
        }
    }
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element
{
    [element setText:[Utils getMonthStrigFromDate:selectedTime]];
    [self reloadPhotoInfo:0 loadmoreflag:NO];
}

- (IBAction)processFilterAlbum:(id)sender
{
    [txtSearch resignFirstResponder];
    if (!iCurrentUserID)
        return;
    
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"All"];
    [arrPopover addObject:@"No Filter"];
    for (AlbumInfoStruct *info in arrCurrentAlbums)
        [arrPopover addObject:[info getAlbumName]];
    
    iViewType = TYPE_FILTER_ALBUM;
    [self showFilterSheet];
}

- (IBAction)processFilterBucket:(id)sender
{
    [txtSearch resignFirstResponder];
    if (!iCurrentUserID)
        return;
    
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"All"];
    [arrPopover addObject:@"No Filter"];
    for (BucketInfoStruct *info in arrCurrentBuckets)
        [arrPopover addObject:[info getBucketName]];
    
    iViewType = TYPE_FILTER_BUCKET;
    [self showFilterSheet];
}


- (IBAction)processFilterExpireDate:(id)sender
{
    [txtSearch resignFirstResponder];
    if (!iCurrentUserID)
        return;
    
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"All"];
    [arrPopover addObject:@"No Expiry"];
    [arrPopover addObject:@"Within 3 days"];
    [arrPopover addObject:@"Within 7 days"];
    [arrPopover addObject:@"Within 1 month"];
    [arrPopover addObject:@"Within 6 months"];
    [arrPopover addObject:@"Within 1 year"];
    
    iViewType = TYPE_FILTER_EXPIRY;
    [self showFilterSheet];
}

- (IBAction)processFilterSharedWith:(id)sender
{
    [txtSearch resignFirstResponder];
    if (!iCurrentUserID)
        return;
    
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"All"];
    for (FriendInfoStruct *info in [AppDelegate sharedInstance].arrFriends)
        [arrPopover addObject:[info getUserName]];
    
    iViewType = TYPE_FILTER_SHARED_WITH;
    [self showFilterSheet];
}

- (IBAction)processFilterGroup:(id)sender
{
    [txtSearch resignFirstResponder];
    if (!iCurrentUserID)
        return;
    
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"All"];
    for (GroupInfoStruct *info in arrGroups)
        [arrPopover addObject:[info getGroupName]];
    
    iViewType = TYPE_FILTER_GROUP;
    [self showFilterSheet];
}

- (IBAction)processTabAction:(id)sender
{
    [self.txtSearch resignFirstResponder];
    [self refreshAsOriginal:YES];
}

-(void) showFilterSheet
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        switch (iViewType)
        {
            case TYPE_FILTER_ALBUM:
                if ([self.lblAlbum respondsToSelector:@selector(setText:)])
                    [self.lblAlbum performSelector:@selector(setText:) withObject:selectedValue];
                
                objAlbum = nil;
                iAlbumId = -1;
                if (selectedIndex < [arrCurrentAlbums count] + 2)
                {
                    if (selectedIndex == 0)
                    {
                        iAlbumId = 0;
                        objBucket = nil;
                    }
                    else if (selectedIndex > 1)
                    {
                        objBucket = nil;
                        objAlbum = [arrCurrentAlbums objectAtIndex:selectedIndex - 2];
                        iAlbumId = [objAlbum getAlbumID];
                    }
                    
                    [self refreshAlbumAndBucket:objBucket buckettype:iBucketId albumeinfo:objAlbum albumtype:iAlbumId];
                }
                else
                    [self refreshFilterResult:YES];
                break;
            
            case TYPE_FILTER_BUCKET:
                if ([self.lblBucket respondsToSelector:@selector(setText:)])
                    [self.lblBucket performSelector:@selector(setText:) withObject:selectedValue];
                
                if ([self.lblBucket respondsToSelector:@selector(setText:)])
                    [self.lblBucket performSelector:@selector(setText:) withObject:selectedValue];
                
                objBucket = nil;
                iBucketId = -1;
                if (selectedIndex < [arrCurrentBuckets count] + 2)
                {
                    if (selectedIndex == 0)
                    {
                        iBucketId = 0;
                        objAlbum = nil;
                    }
                    else if (selectedIndex > 1)
                    {
                        objAlbum = nil;
                        objBucket = [arrCurrentBuckets objectAtIndex:selectedIndex - 2];
                        iBucketId = [objBucket getBucketID];
                    }
                    
                    [self refreshAlbumAndBucket:objBucket buckettype:iBucketId albumeinfo:objAlbum albumtype:iAlbumId];
                }
                else
                    [self refreshFilterResult:YES];
                break;
                
            case TYPE_FILTER_DATE:
                if ([self.lblDateShared respondsToSelector:@selector(setText:)])
                    [self.lblDateShared performSelector:@selector(setText:) withObject:selectedValue];
                [self reloadPhotoInfo:0 loadmoreflag:NO];
                break;
                
            case TYPE_FILTER_EXPIRY:
                if ([self.lblExpiryDate respondsToSelector:@selector(setText:)])
                    [self.lblExpiryDate performSelector:@selector(setText:) withObject:selectedValue];
                iExpiryDate = selectedIndex;
                [self reloadPhotoInfo:0 loadmoreflag:NO];
                break;
                
            case TYPE_FILTER_FRIENDS:
                if ([self.lblUserName respondsToSelector:@selector(setText:)])
                    [self.lblUserName performSelector:@selector(setText:) withObject:selectedValue];
                if (selectedIndex == 0)
                {
                    objUser = nil;
                    iCurrentUserID = 0;
                }
                else if (selectedIndex == 1)
                    iCurrentUserID = [[AppDelegate sharedInstance].objUserInfo getUserID];
                else
                {
                    FriendInfoStruct *info;
                    if (arrFriends.count > selectedIndex - 2)
                        info = [arrFriends objectAtIndex:selectedIndex - 2];
                    iCurrentUserID = [info getUserID];
                }
                [self refreshChangeUser:NO];
                break;
                
//            case TYPE_FILTER_GROUP:
//                if ([self.lblGroup respondsToSelector:@selector(setText:)])
//                    [self.lblGroup performSelector:@selector(setText:) withObject:selectedValue];
//                if (selectedIndex == 0)
//                    objGroup = nil;
//                else
//                    objGroup = [arrGroups objectAtIndex:selectedIndex - 1];
//                break;
                
            case TYPE_FILTER_SHARED_WITH:
                if ([self.lblSharedWith respondsToSelector:@selector(setText:)])
                    [self.lblSharedWith performSelector:@selector(setText:) withObject:selectedValue];
                
                if (selectedIndex == 0)
                    objSharedUser = nil;
                else
                    objSharedUser = [arrFriends objectAtIndex:selectedIndex - 1];
                [self reloadPhotoInfo:0 loadmoreflag:NO];
                break;
        }
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
    };
    
    switch (iViewType)
    {
        case TYPE_FILTER_ALBUM:
            [ActionSheetStringPicker showPickerWithTitle:@"Select Album name" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblAlbum];
            break;
        
        case TYPE_FILTER_BUCKET:
            [ActionSheetStringPicker showPickerWithTitle:@"Select Group Album" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblBucket];
            break;
            
            
        case TYPE_FILTER_DATE:
            [ActionSheetStringPicker showPickerWithTitle:@"Select Filter date" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblDateShared];
            break;
            
        case TYPE_FILTER_EXPIRY:
            [ActionSheetStringPicker showPickerWithTitle:@"Select Expiry Date" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblExpiryDate];
            break;
            
        case TYPE_FILTER_FRIENDS:
            [ActionSheetStringPicker showPickerWithTitle:@"Select People" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblUserName];
            break;
            
        case TYPE_FILTER_GROUP:
            [ActionSheetStringPicker showPickerWithTitle:@"Select Circle" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblGroup];
            break;
            
        case TYPE_FILTER_SHARED_WITH:
            [ActionSheetStringPicker showPickerWithTitle:@"Select Shared with" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblSharedWith];
            break;
    }
}

-(BOOL) isMeSelected
{
    if (iCurrentUserID == [[AppDelegate sharedInstance].objUserInfo getUserID])
        return YES;
    
    return NO;
}

//-(void) refreshAlbum:(AlbumInfoStruct *)ainfo
//{
//    bBucketMode = NO;
//    objAlbum = ainfo;
//    if (!ainfo)
//    {
//        objBucket = nil;
//        if (![lblBucket.text isEqualToString:@"All"])
//            lblBucket.text = @"No Filter";
//    }
//    else
//        lblBucket.text = @"No Filter";
//    
//    if ([self isMeSelected])
//        viewGroup.hidden = NO;
//    else
//        viewGroup.hidden = YES;
//    
//    viewExpiryDate.hidden = NO;
//}
//
//-(void) refreshBucket:(BucketInfoStruct *)binfo
//{
//    bBucketMode = YES;
//    objBucket = binfo;
//    if (!binfo)
//    {
//        objAlbum = nil;
//        if (![lblAlbum.text isEqualToString:@"All"])
//            lblExpiryDate.text = @"No Filter";
//        iExpiryDate = 0;
//    }
//    else
//    {
//        lblAlbum.text = @"No Filter";
//        viewGroup.hidden = YES;
//    }
//    
//    
//    viewGroup.hidden = (binfo != nil);
//    viewExpiryDate.hidden = (binfo != nil);
//    objBucket = binfo;
//}

- (IBAction)processBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark - Alertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (buttonIndex == 1)
        return;
    
    if (alertView.tag == TYPE_DELETE_PHOTO)
    {
        if (iCurrentIdx < [arrPhotos count])
        {
            PhotoInfoStruct *currentInfo = [arrPhotos objectAtIndex:iCurrentIdx];
            [self showHUD:@"Deleting..."];
            ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_DELETE_PHOTO] tag:TYPE_DELETE_PHOTO delegate:self];
            [request setPostValue:[currentInfo getPhotoIDToString] forKey:@"photoid"];
            [request startAsynchronous];
        }
    }
    else if (alertView.tag == TYPE_FLAG_PHOTO)
    {
        if (iCurrentIdx < [arrPhotos count])
        {
            PhotoInfoStruct *currentInfo = [arrPhotos objectAtIndex:iCurrentIdx];
            [currentInfo setSpamFlag:YES];
            ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_FLAG_PHOTO] tag:TYPE_FLAG_PHOTO delegate:self];
            [request setPostValue:[currentInfo getPhotoIDToString] forKey:@"photoid"];
            [request startAsynchronous];
        }
    }
}

#pragma mark - scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height < 650)
        return;
    
    if (fLastOffset >= 0 && ((fLastOffset + covPhotos.frame.size.height) < scrollView.contentSize.height))
    {
        if (fLastOffset > scrollView.contentOffset.y) //ScrollDirectionDown
        {
            // org 72
            CGRect rect = viewHeader.frame;
            if (rect.origin.y > 72)
            {
                [self refreshAsOriginal:NO];
            }
            else if (rect.origin.y < 72)
            {
                CGFloat fdiff = fLastOffset - scrollView.contentOffset.y;
                rect.origin.y += fdiff;
                if (rect.origin.y > 72)
                    rect.origin.y = 72;
                viewHeader.frame = rect;
                
                rect = covPhotos.frame;
                rect.origin.y = viewHeader.frame.origin.y + viewHeader.frame.size.height + 3;
                rect.size.height = iScreenHeight - 48 - rect.origin.y;
                covPhotos.frame = rect;
            }
        }
        else if (fLastOffset < scrollView.contentOffset.y) //ScrollDirectionUp
        {
            // org 72
            CGRect rect = covPhotos.frame;
            if (rect.origin.y < 75)
            {
                [self refreshAsOriginal:NO];
            }
            else if (rect.origin.y > 75)
            {
                CGFloat fdiff = (scrollView.contentOffset.y - fLastOffset);
                rect.origin.y -= fdiff;
                if (rect.origin.y < 75)
                    rect.origin.y = 75;
                rect.size.height = iScreenHeight - 48 - rect.origin.y;
                covPhotos.frame = rect;
                
                rect = viewHeader.frame;
                rect.origin.y = covPhotos.frame.origin.y - rect.size.height - 3;
                viewHeader.frame = rect;
            }
        }
    }
    
    fLastOffset = scrollView.contentOffset.y;
}

-(void) refreshAsOriginal:(BOOL)animation
{
    CGRect rectHeader = viewHeader.frame;
    rectHeader.origin.y = 72;
    
    CGRect rect = covPhotos.frame;
    rect.origin.y = rectHeader.size.height + 75;
    rect.size.height = iScreenHeight - 48 - rect.origin.y;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    viewHeader.frame = rectHeader;
    covPhotos.frame = rect;
    [UIView commitAnimations];
}


-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self refreshAsOriginal:YES];
    PhotoDetailViewController *controller = (PhotoDetailViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoDetailVC"];
    controller.arrViewPhotos = arrPhotos;
    controller.iCurrentIdx = indexPath.row;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrPhotos count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoFilterCollectionViewCell *cell = (PhotoFilterCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    PhotoInfoStruct *info = nil;
    if ([arrPhotos count] > indexPath.row)
        info = [arrPhotos objectAtIndex:indexPath.row];
    [cell initWithPhotoInfo:info index:indexPath.row];
    cell.delegate = self;
    [cell layoutIfNeeded];
    [cell needsUpdateConstraints];
    
    if (indexPath.row == (arrPhotos.count - 1) && arrPhotos.count > 10)
    {
        [self reloadPhotoInfo:[[arrPhotos objectAtIndex:indexPath.row] getPhotoID] loadmoreflag:YES];
    }
    
    return cell;
}

#define ITEM_WIDTH 157
#define PHOTO_WIDTH 147

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([arrPhotoHeight count] <= indexPath.row)
    {
        while (indexPath.row >= arrPhotoHeight.count)
        {
            [arrPhotoHeight addObject:[NSString stringWithFormat:@"0"]];
        }
    }
    
    if ([[arrPhotoHeight objectAtIndex:indexPath.row] isEqualToString:@"0"])
    {
        PhotoInfoStruct *info = [arrPhotos objectAtIndex:indexPath.row];
        float ypos = [PhotoFilterCollectionViewCell getItemHeight:info];
        [arrPhotoHeight setObject:[NSString stringWithFormat:@"%d", (int)ypos] atIndexedSubscript:indexPath.row];
    }
    
    return CGSizeMake(PHOTO_WIDTH, [[arrPhotoHeight objectAtIndex:indexPath.row] integerValue]);
}

#pragma mark - Photo Editor

- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage
{
    iUploadCount = 0;
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set API Key and Secret
    [AFPhotoEditorController setAPIKey:kAFAviaryAPIKey secret:kAFAviarySecret];
    
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [editor dismissViewControllerAnimated:YES completion:^{
        [curPhotoInfo setPhoto:image];
        [self showHUD:@"Saving..."];
        S3PhotoUploader *photouploader = [[AppDelegate sharedInstance] getS3PhotoUploader:self];
        [photouploader uploadFeedPhoto:curPhotoInfo];
    }];
}

-(void) uploadFailed:(NSInteger)errorcode
{
    [self hideHUD];
}

-(void) uploadFinished
{
    [self hideHUD];
    [arrPhotoHeight removeAllObjects];
    [covPhotos reloadData];
}


// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:YES completion:nil];
}

@end
