//
//  PhotoPreviewController.m
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "AlbumEditViewController.h"
#import "PhotoDetailViewController.h"
#import "ActionSheetStringPicker.h"
#import "PhotoFilterCollectionViewCell.h"
#import "PhotoSearchViewController.h"
#import "PhotoPropertiesViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "BucketPermissionViewController.h"
#import "LikerViewController.h"
#import "CommentViewController.h"
#import "ShareViewController.h"
#import <AviarySDK/AviarySDK.h>
#import "SDImageCache.h"

#define CELL_IDENTIFIER @"photoFilterCell"

enum VIEW_TYPE
{
    TYPE_FILTER = 200,
    TYPE_FILTER_ALBUM,
    TYPE_FILTER_FRIENDS,
    TYPE_FILTER_BUCKET,
};

@interface AlbumEditViewController ()<AFPhotoEditorControllerDelegate, S3PhotoUploaderDelegate>
{
    PullToRefreshView   *viewPull;
    
    NSMutableArray *arrPopover;
    NSMutableArray *arrCurrentPhotos;
    NSMutableArray *arrCurrentBuckets;
    NSMutableArray *arrCurrentAlbums;
    NSMutableArray *arrPhotoHeight;
    NSMutableArray *arrFriendsInfo;
    
    NSInteger iCurrentIdx, iUploadCount, iPhotoCount;
    PhotoInfoStruct *curPhotoInfo;
    
    // View Type
    NSInteger iViewType;
    
    // selected data
    NSInteger iAlbumId; // 0 : ALL, -1 : No Filter,  0 < Selected BucketID
    NSInteger iBucketId; // 0 : ALL, -1 : No Filter,  0 < Selected AlbumID
    BOOL bLoading;
    BOOL bEndFlag;
    BOOL isMyflag;
    
    CGFloat fLastOffset;
    NSInteger iScreenHeight;
}
@end

@implementation AlbumEditViewController
{
    
}

@synthesize lblAlbum, lblBucket, lblUserName, lblAddPhoto;
@synthesize iInitUserID, covPhoto, ivUserImage;
@synthesize lblResult, bBucketMode, viewHeader;
@synthesize lblProperties, btnProperties, btnAdd;
@synthesize objAlbum, objBucket, lblAlbumTitle, lblBucketTitle;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [covPhoto registerNib:[UINib nibWithNibName:@"PhotoFilterCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CELL_IDENTIFIER];
    
    lblResult.hidden = YES;
    arrCurrentPhotos = [[NSMutableArray alloc] init];
    arrPhotoHeight = [[NSMutableArray alloc] init];
    
    if (objBucket)
        bBucketMode = YES;
    else
        bBucketMode = NO;
    if (iInitUserID < 1)
    {
        if (objAlbum)
            iInitUserID = [objAlbum getUserID];
        else if (objBucket)
            iInitUserID = [objBucket getUserID];
    }
    [self initPhotoInfo:YES];
    
    arrFriendsInfo = [[NSMutableArray alloc] init];
    [Utils copyArray:[AppDelegate sharedInstance].arrFriends desarray:arrFriendsInfo];
    
    self.navigationController.navigationBarHidden = YES;
    arrPopover = [[NSMutableArray alloc] init];
    [AppDelegate processUserImage:ivUserImage];
    iScreenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    self.covPhoto.alwaysBounceVertical = YES;
    
    viewPull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)covPhoto];
    viewPull.delegate = self;
    
    [covPhoto addSubview:viewPull];
    viewPull.backgroundColor = [UIColor clearColor];
}
    
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [arrPhotoHeight removeAllObjects];
    [covPhoto reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.request clearDelegatesAndCancel];
}

#pragma mark - pull delegate
-(void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    if (iAlbumId == -1 && iBucketId == -1)
    {
        [AppDelegate showMessage:@"Please select filter type" withTitle:@"Warning"];
        [viewPull finishedLoading];
        return;
    }
    
    [self reloadPhotoInfo:0 loadmoreflag:NO];
    [viewPull setState:PullToRefreshViewStateLoading];
}

-(void) initPhotoInfo:(BOOL)binit
{
    //Album = All, Date Shared = All, Album = All  Expiry Date = No Expiry
    lblAlbum.text = @"All";
    lblBucket.text = @"All";
    iBucketId = 0;
    iAlbumId = 0;
    arrCurrentAlbums = nil;
    arrCurrentBuckets = nil;
    
    if (!binit)
    {
        objBucket = nil;
        objAlbum = nil;
        bBucketMode = NO;
    }
    
    AppDelegate *delegate = [AppDelegate sharedInstance];
    if (iInitUserID < 1)
    {
        if (objBucket)
            iInitUserID = [objBucket getUserID];
        else if (objAlbum)
            iInitUserID = [objAlbum getUserID];
    }
    
    isMyflag = NO;
    if (iInitUserID == [[AppDelegate sharedInstance].objUserInfo.strUserId integerValue])
    {
        lblUserName.text = @"Me";
        arrCurrentAlbums = delegate.arrMyAlbums;
        arrCurrentBuckets = delegate.arrMyBucket;
        UIImage *placeImage = [Utils getDefaultProfileImage];
        [ivUserImage sd_setImageWithURL:[delegate.objUserInfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
        
        lblAlbumTitle.text = @"My\nAlbums";
        lblBucketTitle.text = @"My\nGroup Albums";
        isMyflag = YES;
    }
    else
    {
        if (iInitUserID < 1)
        {
            lblBucketTitle.text = @"Group Albums";
            lblAlbumTitle.text = @"Albums";
            lblUserName.text = @"Everyone";
            objAlbum = nil;
            objBucket = nil;
            ivUserImage.image = [UIImage imageNamed:@"img_everyone.png"];
            [self refreshAlbumAndBucket:nil buckettype:0 albumeinfo:nil albumtype:0];
            return;
        }
        
        FriendInfoStruct *finfo = [delegate findFriendInfo:iInitUserID];
        lblUserName.text = [finfo getUserName];
        arrCurrentAlbums = [[AppDelegate sharedInstance] findFriendAlbums:iInitUserID];
        arrCurrentBuckets = [[AppDelegate sharedInstance] findFriendBuckets:iInitUserID];
        UIImage *placeImage = [Utils getDefaultProfileImage];
        [ivUserImage sd_setImageWithURL:[finfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
        lblAlbumTitle.text = [NSString stringWithFormat:@"%@'s\nAlbums", [finfo getFirstName]];
        lblBucketTitle.text = [NSString stringWithFormat:@"%@'s\nGroup Albums", [finfo getFirstName]];
    }
    
    [self refreshAlbumAndBucket:objBucket buckettype:0 albumeinfo:objAlbum albumtype:0];
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
        [self refreshButtonState:YES showaddphoto:YES];
    }
    else if (objAlbum)
    {
        lblBucket.text = @"No Filter";
        iBucketId = -1;
        lblAlbum.text = [objAlbum getAlbumName];
        iAlbumId = [objAlbum getAlbumID];
        [self refreshButtonState:[objAlbum canDelete] showaddphoto:![objAlbum isFavoriteAlbum]];
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
        
        [self refreshButtonState:NO showaddphoto:NO];
    }
    
    [self reloadPhotoInfo:0 loadmoreflag:NO];
}

-(void) refreshButtonState:(BOOL)showproperties showaddphoto:(BOOL)showaddphoto
{
    lblProperties.hidden = !showproperties;
    btnProperties.hidden = !showproperties;
    btnAdd.hidden = !showaddphoto;
    lblAddPhoto.hidden = !showaddphoto;
}

-(void) reloadPhotoInfo:(NSInteger)photoid loadmoreflag:(BOOL)loadmoreflag
{
    if (photoid < 1 || [arrCurrentPhotos count] < 1)
    {
        [arrCurrentPhotos removeAllObjects];
        [arrPhotoHeight removeAllObjects];
        bEndFlag = NO;
    }
    
    if (loadmoreflag && (bEndFlag || bLoading))
        return;
    
    if (iAlbumId == -1 && iBucketId == -1)
    {
        //[AppDelegate showMessage:@"Please select filter type" withTitle:@"Warning"];
        [arrCurrentPhotos removeAllObjects];
        [arrPhotoHeight removeAllObjects];
        [self refreshFilterResult:NO];
        [viewPull finishedLoading];
        return;
    }
    
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_FILTER] tag:TYPE_FILTER_PHOTO delegate:self];
    [self.request setPostValue:[Utils getStringFromInteger:iInitUserID] forKey:@"photouserid"];
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
    
    [self.request startAsynchronous];
    bLoading = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (IBAction)processPropertiesAction:(id)sender
{
    [self refreshAsOriginal:NO];
    if (iBucketId > 0)
    {
        if (objBucket)
        {
            if ([objBucket isMyBucket])
                [self performSegueWithIdentifier:@"editBucket" sender:nil];
            else
                [self performSegueWithIdentifier:@"gotoBucketPermission" sender:nil];
        }
    }
    else
    {
        if (iAlbumId < 1)
            return;
        
        if (objAlbum && [objAlbum canDelete])
            [self performSegueWithIdentifier:@"editAlbum" sender:nil];
    }
}

- (IBAction)processAddAction:(id)sender
{
    [self refreshAsOriginal:YES];
    ShareViewController *VC = (ShareViewController*)[[AppDelegate sharedInstance] getUIViewController:@"sharePhotoView"];
    VC.bShowBack = YES;
    if (objBucket)
    {
        [[AppDelegate sharedInstance].arrShareAlbums addObject:objBucket];
        [AppDelegate sharedInstance].bAlbumMode = NO;
        [AppDelegate sharedInstance].bBucketMode = YES;
    }
    else if (objAlbum)
    {
        [[AppDelegate sharedInstance].arrShareAlbums addObject:objAlbum];
        [AppDelegate sharedInstance].bAlbumMode = YES;
        [AppDelegate sharedInstance].bBucketMode = NO;
    }
        
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"editAlbum"])
    {
        CreateAlbumViewController *controllerAlbumEdit = (CreateAlbumViewController *)[segue destinationViewController];
        controllerAlbumEdit.albumdelegate = self;
        controllerAlbumEdit.info = objAlbum;
    }
    else if([segue.identifier isEqualToString:@"editBucket"])
    {
        BucketEditViewController *vcBucket = (BucketEditViewController *)[segue destinationViewController];
        vcBucket.delegate = self;
        vcBucket.objInfo = objBucket;
    }
    else if ([segue.identifier isEqualToString:@"gotoBucketPermission"])
    {
        BucketPermissionViewController *controller = (BucketPermissionViewController *)[segue destinationViewController];
        controller.objInfo = objBucket;
    }
}

- (IBAction)processFilterAlbum:(id)sender
{
    [self refreshAsOriginal:YES];
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"All"];
    [arrPopover addObject:@"No Filter"];
    for (AlbumInfoStruct *info in arrCurrentAlbums)
        [arrPopover addObject:[info getAlbumName]];
    
    iViewType = TYPE_FILTER_ALBUM;
    [self showFilterSheet];
}

-(IBAction)processSearchAction:(id)sender
{
    [self refreshAsOriginal:YES];
    PhotoSearchViewController *viewController = (PhotoSearchViewController *)[[AppDelegate sharedInstance] getUIViewController:@"searchPhotoVC"];
    viewController.iCurrentUserID = iInitUserID;
    viewController.bShowSettingButton = YES;
    if (iBucketId > 0 )
        viewController.objStartBucket = objBucket;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)processSelectUser:(id)sender
{
    [self refreshAsOriginal:YES];
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"Everyone"];
    [arrPopover addObject:@"Me"];
    for (FriendInfoStruct *info in arrFriendsInfo)
        [arrPopover addObject:[info getUserName]];
    
    iViewType = TYPE_FILTER_FRIENDS;
    [self showFilterSheet];
}

- (IBAction)processFilterBucket:(id)sender;
{
    [self refreshAsOriginal:YES];
    [arrPopover removeAllObjects];
    [arrPopover addObject:@"All"];
    [arrPopover addObject:@"No Filter"];
    for (BucketInfoStruct *info in arrCurrentBuckets)
        [arrPopover addObject:[info getBucketName]];
    
    iViewType = TYPE_FILTER_BUCKET;
    [self showFilterSheet];
}

- (IBAction)proecssRefreshHeader:(id)sender
{
    [self refreshAsOriginal:YES];
}

-(void) showFilterSheet
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        switch (iViewType)
        {
            case TYPE_FILTER_FRIENDS:
                if ([self.lblUserName respondsToSelector:@selector(setText:)])
                    [self.lblUserName performSelector:@selector(setText:) withObject:selectedValue];
                
                if (selectedIndex < [arrFriendsInfo count] + 2)
                {
                    if (selectedIndex == 0)
                        iInitUserID = 0;
                    else if (selectedIndex == 1)
                        iInitUserID = [[AppDelegate sharedInstance].objUserInfo getUserID];
                    else
                    {
                        FriendInfoStruct *info = [arrFriendsInfo objectAtIndex:(selectedIndex - 2)];
                        iInitUserID = [info getUserID];
                    }
                    [self initPhotoInfo:NO];
                }
                break;
                
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
        }
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
    };
    
    switch (iViewType)
    {
        case TYPE_FILTER_FRIENDS:
            [ActionSheetStringPicker showPickerWithTitle:@"Select People" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblUserName];
            break;
            
            
        case TYPE_FILTER_ALBUM:
            [ActionSheetStringPicker showPickerWithTitle:@"Select Album" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblAlbum];
            break;
            
        case TYPE_FILTER_BUCKET:
            [ActionSheetStringPicker showPickerWithTitle:@"Select Group Album" rows:arrPopover initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblBucket];
            break;
            
    }
}

-(void) refreshFilterResult:(BOOL)bError
{
    if (bError)
    {
        [arrCurrentPhotos removeAllObjects];
        [arrPhotoHeight removeAllObjects];
        [covPhoto reloadData];
        lblResult.hidden = NO;
        return;
    }
    
    if ([arrCurrentPhotos count] < 1)
        lblResult.hidden = NO;
    else
        lblResult.hidden = YES;
    
    [covPhoto reloadData];
}


#pragma mark - action delegate
- (void)processComment:(PhotoInfoStruct *)info
{
    CommentViewController *viewController = (CommentViewController *)[[AppDelegate sharedInstance] getUIViewController:@"commentViewVC"];
    viewController.photoinfo = info;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)processMore:(PhotoInfoStruct *)info index:(NSInteger)index
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Permissions", @"Download Photo", @"Edit Photo", @"Change Caption or Tag", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = index;
    iCurrentIdx = index;
    curPhotoInfo = info;
    [actionSheet showInView:self.view];
}

-(void) processPermission:(PhotoInfoStruct *)info index:(NSInteger)index
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
    controller.arrViewPhotos = arrCurrentPhotos;
    controller.iCurrentIdx = index;
    controller.bShowPermission = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0x10000)
    {
        if (buttonIndex == 2)
        {
            iInitUserID = [[AppDelegate sharedInstance].objUserInfo.strUserId integerValue];
            objAlbum = [[AppDelegate sharedInstance] findAlbumInfo:k_favoriteAlbum];
            bBucketMode = NO;
            objBucket = nil;
            [self initPhotoInfo:YES];
            return;
        }
        
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if(buttonIndex == 0) // Delete
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = TYPE_DELETE_PHOTO;
        [alertview show];
    }
    else if(buttonIndex == 1) // Permissions
    {
        if (actionSheet.tag >= arrCurrentPhotos.count)
            return;
        
        PhotoInfoStruct *pinfo = [arrCurrentPhotos objectAtIndex:actionSheet.tag];
        [self processPermission:pinfo index:actionSheet.tag];
    }
    else if(buttonIndex == 2) // Download
    {
        PhotoFilterCollectionViewCell *cell = (PhotoFilterCollectionViewCell *)[covPhoto cellForItemAtIndexPath:[NSIndexPath indexPathForRow:actionSheet.tag inSection:0]];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library saveImage:cell.ivPhoto.image toAlbum:k_DownloadPhotoPath withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
            else
            {
                [AppDelegate showMessage:@"Your photo has been downloaded to your local camera roll." withTitle:nil];
            }
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
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
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


- (void)processLikeView:(PhotoInfoStruct *)info
{
    LikerViewController *controller = (LikerViewController *)[[AppDelegate sharedInstance] getUIViewController:@"showLikersVC"];
    controller.iLikeCount = [info getLikeCount];
    controller.iPhotoID = [info getPhotoID];
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - scroll delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height < 600)
        return;
    
    if (fLastOffset >= 0 && ((fLastOffset + covPhoto.frame.size.height) < scrollView.contentSize.height))
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
                
                rect = covPhoto.frame;
                rect.origin.y = viewHeader.frame.origin.y + viewHeader.frame.size.height + 3;
                rect.size.height = iScreenHeight - 48 - rect.origin.y;
                covPhoto.frame = rect;
            }
        }
        else if (fLastOffset < scrollView.contentOffset.y) //ScrollDirectionUp
        {
            // org 72
            CGRect rect = covPhoto.frame;
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
                covPhoto.frame = rect;
                
                rect = viewHeader.frame;
                rect.origin.y = covPhoto.frame.origin.y - rect.size.height - 3;
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
    
    CGRect rect = covPhoto.frame;
    rect.origin.y = rectHeader.size.height + 75;
    rect.size.height = iScreenHeight - 48 - rect.origin.y;
        
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    viewHeader.frame = rectHeader;
    covPhoto.frame = rect;
    [UIView commitAnimations];
}


#pragma mark - Button Action

- (IBAction)processPhotoSelect:(id)sender
{
    PhotoDetailViewController *controller = (PhotoDetailViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoDetailVC"];
    UIButton *btn = (UIButton *)sender;
    controller.arrViewPhotos = arrCurrentPhotos;
    controller.iCurrentIdx = btn.tag;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)processBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)processLeaveComment:(id)sender
{
    
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
        if (iCurrentIdx < [arrCurrentPhotos count])
        {
            PhotoInfoStruct *currentInfo = [arrCurrentPhotos objectAtIndex:iCurrentIdx];
            [self showM13HUD:@"Deleting..."];
            ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_DELETE_PHOTO] tag:TYPE_DELETE_PHOTO delegate:self];
            [request setPostValue:[currentInfo getPhotoIDToString] forKey:@"photoid"];
            [request startAsynchronous];
        }
    }
    else if (alertView.tag == TYPE_FLAG_PHOTO)
    {
        if (iCurrentIdx < [arrCurrentPhotos count])
        {
            PhotoInfoStruct *currentInfo = [arrCurrentPhotos objectAtIndex:iCurrentIdx];
            [currentInfo setSpamFlag:YES];
            ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_FLAG_PHOTO] tag:TYPE_FLAG_PHOTO delegate:self];
            [request setPostValue:[currentInfo getPhotoIDToString] forKey:@"photoid"];
            [request startAsynchronous];
        }
    }
}

-(void) deletePhoto:(NSInteger) photoid
{
    for (int idx = 0; idx < [arrCurrentPhotos count]; idx++)
    {
        PhotoInfoStruct *info = [arrCurrentPhotos objectAtIndex:idx];
        if ([info getPhotoID] == photoid)
        {
            [arrCurrentPhotos removeObject:info];
            if (idx < [arrPhotoHeight count])
                [arrPhotoHeight removeObjectAtIndex:idx];
            break;
        }
    }
    
    [covPhoto reloadData];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    NSString    *value = [request responseString];
    NSLog(@"Value = %@", value);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if(status == 200)
    {
        if (request.tag == TYPE_DELETE_PHOTO)
        {
            [self hideM13HUD];
            NSInteger photoid = [[json objectForKey:@"photoid"] integerValue];
            [self deletePhoto:photoid];
        }
        else if (request.tag == TYPE_FLAG_PHOTO)
        {
            [covPhoto reloadData];
        }
        else if (request.tag == TYPE_FILTER_PHOTO)
        {
            NSDictionary *dict = [json objectForKey:@"photos"];
            NSMutableArray *arrTemp = [NSMutableArray array];
            NSInteger iPhotoid = [[json objectForKey:@"photoid"] integerValue];
            if (iPhotoid == 0)
            {
                [arrCurrentPhotos removeAllObjects];
                [arrPhotoHeight removeAllObjects];
            }
            NSMutableArray *arrComments = [[AppDelegate sharedInstance] getComments:[dict objectForKey:@"comments"]];
            [[AppDelegate sharedInstance] refreshPhotoInfo:[dict objectForKey:@"photoinfos"] comments:arrComments arrdes:arrTemp];
            if (arrTemp.count < 1)
                bEndFlag = YES;
            [arrCurrentPhotos addObjectsFromArray:arrTemp];
            [self refreshFilterResult:NO];
        }
    }
    else
    {
        if (request.tag == TYPE_DELETE_PHOTO)
        {
            [AppDelegate showMessage:@"Can't delete this photo." withTitle:@"Error"];
            [self hideM13HUD];
        }
    }
    
    if (request.tag == TYPE_FILTER_PHOTO)
    {
        bLoading = NO;
        [viewPull finishedLoading];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.tag == TYPE_DELETE_PHOTO)
        [self hideM13HUD];
    
    [super requestFailed:request];
    if (request.tag == TYPE_FILTER_PHOTO)
    {
        [viewPull finishedLoading];
        bLoading = NO;
    }
}


#pragma mark -
#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == TYPE_FILTER)
        return arrPopover.count;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == TYPE_FILTER)
        return 45;
    
    return 50;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self refreshAsOriginal:YES];
    PhotoDetailViewController *controller = (PhotoDetailViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoDetailVC"];
    controller.arrViewPhotos = arrCurrentPhotos;
    controller.iCurrentIdx = indexPath.row;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrCurrentPhotos count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoFilterCollectionViewCell *cell = (PhotoFilterCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    PhotoInfoStruct *info;
    if ([arrCurrentPhotos count] > indexPath.row)
        info = [arrCurrentPhotos objectAtIndex:indexPath.row];
    [cell initWithPhotoInfo:info index:indexPath.row];
    cell.delegate = self;
    
    [cell layoutIfNeeded];
    [cell needsUpdateConstraints];
    
    if (indexPath.row == (arrCurrentPhotos.count - 1) && arrCurrentPhotos.count > 10)
    {
        [self reloadPhotoInfo:[[arrCurrentPhotos objectAtIndex:indexPath.row] getPhotoID] loadmoreflag:YES];
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
        PhotoInfoStruct *info = [arrCurrentPhotos objectAtIndex:indexPath.row];
        float ypos = [PhotoFilterCollectionViewCell getItemHeight:info];
        [arrPhotoHeight setObject:[NSString stringWithFormat:@"%d", (int)ypos] atIndexedSubscript:indexPath.row];
    }
    
    return CGSizeMake(PHOTO_WIDTH, [[arrPhotoHeight objectAtIndex:indexPath.row] integerValue]);
}

-(void) updateAlbum:(AlbumInfoStruct *)info
{
    if (iAlbumId == [info getAlbumID])
    {
        lblAlbum.text = [info getAlbumName];
        objAlbum = info;
    }
}

-(void) updateBucket:(BucketInfoStruct *)info
{
    if (iBucketId == [info getBucketID])
    {
        lblBucket.text = [info getBucketName];
        objBucket = info;
    }
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
        if (!image)
        {
            [AppDelegate showMessage:@"Photo edit failed." withTitle:@"Error"];
        }
        else
        {
            [self showHUD:@"Saving..."];
            [curPhotoInfo setPhoto:image];
            S3PhotoUploader *photouploader = [[AppDelegate sharedInstance] getS3PhotoUploader:self];
            [photouploader uploadFeedPhoto:curPhotoInfo];
        }
    }];
}



// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:YES completion:nil];
}

-(void) uploadFinished
{
    [self hideHUD];
    [arrPhotoHeight removeAllObjects];
    [covPhoto reloadData];
}

-(void) uploadFailed:(NSInteger)errorcode
{
    [self hideHUD];
    [AppDelegate showMessage:@"Image upload failed. Please check your internet connection." withTitle:@"Error"];
}

@end
