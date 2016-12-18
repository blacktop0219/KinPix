//
//  PhotoDetailViewController.m
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "CommentViewCell.h"
#import "LikerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "SelectGroupFriendViewController.h"
#import "PhotoPropertiesViewController.h"
#import "BucketEditViewController.h"
#import "ShareSelectGroupViewController.h"
#import "CommentViewController.h"
#import <AviarySDK/AviarySDK.h>
#import "SDImageCache.h"

@interface PhotoDetailViewController ()<AFPhotoEditorControllerDelegate, S3PhotoUploaderDelegate>
{
    PhotoInfoStruct *currentInfo;
    EBPhotoPagesController *objPhotoPagesController;
    BOOL bShowKeyboard;
    UIImage *imgDefault;
    CGRect rect;
    DetailView *viewDetail1;
    DetailView *viewDetail2;
    DetailView *viewDetail3;
    NSInteger iLastIndex;
    NSInteger iScreenHeight;
    NSInteger iCurrentImgIndex;
    UIImage *imgCurrentView;
    NSInteger iCurrentDeleteIndex;
    NSInteger iUploadCount;
    BOOL bReloadRequire;
    BOOL bFullScreenEditMode;
    BOOL bBackMode;
    NSInteger iFullLastIndex;
}
@end

@implementation PhotoDetailViewController

@synthesize iCurrentIdx, arrViewPhotos;
@synthesize scMain;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    iLastIndex = -1;
    rect = scMain.frame;
    rect.size.width = rect.size.width * arrViewPhotos.count;
    scMain.contentSize = rect.size;
    
    imgDefault = [UIImage imageNamed:@"img_emptyphoto.png"];
    rect.size.width = scMain.frame.size.width;
    rect.origin.y = 0;
    bShowKeyboard = NO;
    viewDetail1 = [self createNewDetailView];
    viewDetail2 = [self createNewDetailView];
    viewDetail3 = [self createNewDetailView];

    iScreenHeight = [UIScreen mainScreen].bounds.size.height - 72;
    [self initScrollView];
    if (self.bShowPermission)
        [[self getCurrentActivatedView] showPermission];
    scMain.delegate = self;
}


-(DetailView *) createNewDetailView
{
    [[NSBundle mainBundle] loadNibNamed:@"DetailView" owner:self options:nil];
    DetailView *viewtmp = self.viewDetail;
    viewtmp.delegate = self;
    [viewtmp.doneBtn addTarget:self action:@selector(processLeaveCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    viewtmp.txtComment.delegate = self;
    return viewtmp;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    DetailView *detailview = [self getCurrentActivatedView];
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = detailview.viewTextComment.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    detailview.viewTextComment.frame = r;
    
    r = detailview.tblComment.frame;
    r.size.height = detailview.viewTextComment.frame.origin.y - r.origin.y;
    detailview.tblComment.frame = r;
    
    CGPoint point = detailview.tblComment.contentOffset;
    point.y = point.y - diff;
    detailview.tblComment.contentOffset = point;
}

- (IBAction)processLeaveCommentAction:(id)sender
{
    DetailView *detailview = [self getCurrentActivatedView];
    [detailview.txtComment resignFirstResponder];
    if ([detailview.txtComment.text length] > 0)
    {
        NSString *strComment = detailview.txtComment.text;
        [self.request clearDelegatesAndCancel];
        self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_LEAVE_COMMENT] tag:TYPE_LEAVE_COMMENT delegate:self];
        [self.request setPostValue:[detailview.pinfo getPhotoIDToString] forKey:@"photoid"];
        [self.request setPostValue:strComment forKey:@"comment"];
        [self.request setPostValue:@"refresh" forKey:@"type"];
        [self.request startAsynchronous];
        [self showHUD:@"Processing..."];
        detailview.txtComment.text = @"";
    }
}

-(void) initScrollView
{
    [viewDetail1 removeFromSuperview];
    [viewDetail2 removeFromSuperview];
    [viewDetail3 removeFromSuperview];
    
    CGRect rectDefault = scMain.frame;
    rectDefault.origin.x = - rectDefault.size.width * 3;
    viewDetail1.frame = rectDefault;
    viewDetail2.frame = rectDefault;
    viewDetail3.frame = rectDefault;
    
    [scMain addSubview:viewDetail1];
    [scMain addSubview:viewDetail2];
    [scMain addSubview:viewDetail3];
    
    CGPoint point = scMain.contentOffset;
    point.x = iCurrentIdx * scMain.frame.size.width;
    scMain.contentOffset = point;
    [self scrollViewDidScroll:nil];
}

-(DetailView *) findViewInIndex:(NSInteger)idx
{
    NSInteger iPosx = idx * scMain.frame.size.width;
    if (iPosx == viewDetail1.frame.origin.x)
        return viewDetail1;
    
    if (iPosx == viewDetail2.frame.origin.x)
        return viewDetail2;
    
    if (iPosx == viewDetail3.frame.origin.x)
        return viewDetail3;
    
    return nil;
}

-(void) initDetailViewItem:(NSInteger)idx detailview:(DetailView *)detailview
{
    rect.origin.x = idx * 320;
    detailview.frame = rect;
    [detailview initWithViewData:[arrViewPhotos objectAtIndex:idx] index:idx];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[self getCurrentActivatedView].txtComment resignFirstResponder];
    NSInteger idx = scMain.contentOffset.x / scMain.frame.size.width;
    if ([[self getCurrentActivatedView] isChanged])
    {
        CGPoint point = scrollView.contentOffset;
        NSInteger count = point.x / 320;
        if (point.x > (320 * count + 160))
            count ++;
        point.x = 320 * count;
        scrollView.contentOffset = point;
        return;
    }
    
    DetailView *curView = [self findViewInIndex:idx];
    DetailView *privView = [self findViewInIndex:idx - 1];
    DetailView *nextView = [self findViewInIndex:idx + 1];
    
    if (!curView)
    {
        curView = [self findViewNotInView:privView view2:nextView];
        [self initDetailViewItem:idx detailview:curView];
    }
    
    if (curView)
    {
        [curView setViewActivated];
    }
    
    if (idx > 0 && !privView)
    {
        privView = [self findViewNotInView:curView view2:nextView];
        [self initDetailViewItem:idx - 1 detailview:privView];
    }
    
    if (idx + 1 < [arrViewPhotos count] && !nextView)
    {
        nextView = [self findViewNotInView:privView view2:curView];
        [self initDetailViewItem:idx + 1 detailview:nextView];
    }
    
    iLastIndex = idx;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    DetailView *objCurrentView = [self getCurrentActivatedView];
    if ([objCurrentView isChanged])
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you want to save your photo permission changes?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = TYPE_CHANGE_PERMISSION;
        bBackMode = NO;
        [alertview show];
    }
}


-(DetailView *) findViewNotInView:(DetailView *)view1 view2:(DetailView *)view2
{
    if (viewDetail1 != view1 && viewDetail1 != view2)
        return viewDetail1;
    
    if (viewDetail2 != view1 && viewDetail2 != view2)
        return viewDetail2;
    
    if (viewDetail3 != view1 && viewDetail3 != view2)
        return viewDetail3;
    
    DetailView *viewTmpDetail = [self createNewDetailView];
    [scMain addSubview:viewTmpDetail];
    return viewTmpDetail;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated
{
    if ([arrViewPhotos count] < 1)
    {
        [self processBack:nil];
        return;
    }
    
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    if ([arrViewPhotos count] < 1)
    {
        [self processBack:nil];
        return;
    }
    
    if (iCurrentIdx >= [arrViewPhotos count])
        iCurrentIdx = [arrViewPhotos count] - 1;
    
    DetailView *temp = [self getCurrentActivatedView];
    if (bReloadRequire)
        [temp updatedPermission];
    else
        [temp refreshCollectionView];
    bReloadRequire = NO;
}

-(DetailView *) getCurrentActivatedView
{
    NSInteger idx = scMain.contentOffset.x / scMain.frame.size.width;
    return [self findViewInIndex:idx];
}

- (BOOL) isChanged
{
    return [[self getCurrentActivatedView] isChanged];
}

- (IBAction)processBack:(id)sender
{
    if ([arrViewPhotos count] > 0 && [self isChanged])
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you want to save your photo permission changes?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = TYPE_CHANGE_PERMISSION;
        bBackMode = YES;
        [alertview show];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) processShowComment:(PhotoInfoStruct *)info comments:(NSMutableArray *)arrComments
{
    if (bShowKeyboard)
    {
        [[self getCurrentActivatedView].txtComment resignFirstResponder];
        return;
    }
    
    CommentViewController *viewController = (CommentViewController *)[[AppDelegate sharedInstance] getUIViewController:@"commentViewVC"];
    viewController.photoinfo = info;
    [self presentViewController:viewController animated:YES completion:nil];
}

-(void) processShowPermission:(PhotoInfoStruct *)pinfo
{
    if ([pinfo isMyBucket])
    {
        BucketEditViewController *vcBucket = (BucketEditViewController *)[[AppDelegate sharedInstance] getUIViewController:@"bucketEditController"];
        vcBucket.objInfo = [[AppDelegate sharedInstance] findBucketInfoByID:[pinfo getBucketID]];
        [self.navigationController pushViewController:vcBucket animated:YES];
    }
}

#pragma mark -
#pragma mark - EBPhotoPagesDataSource and Delegate
- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
    shouldExpectPhotoAtIndex:(NSInteger)index
{
    if (arrViewPhotos.count > index)
        return YES;
    
    return NO;
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController
shouldAllowDeleteForPhotoAtIndex:(NSInteger)index
{
    if (arrViewPhotos.count > index)
    {
        PhotoInfoStruct *pinfo = [arrViewPhotos objectAtIndex:index];
        return [pinfo isMyPhoto];
    }
    
    return NO;
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didDeletePhotoAtIndex:(NSInteger)index
{
    if (arrViewPhotos.count <= index)
        return;

    iCurrentDeleteIndex = index;
    bFullScreenEditMode = YES;
    currentInfo = [arrViewPhotos objectAtIndex:index];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = TYPE_DELETE_PHOTO;
    [alertview show];
}

- (BOOL)photoPagesController:(EBPhotoPagesController *)photoPagesController isFlagedPhotoForPhotoAtIndex:(NSInteger)index
{
    if (arrViewPhotos.count > index)
    {
        PhotoInfoStruct *pinfo = [arrViewPhotos objectAtIndex:index];
        if ([pinfo isMyPhoto])
            return NO;
        
        return [pinfo isFlaged];
    }
    
    return NO;
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
       didReportPhotoAtIndex:(NSInteger)index
{
    if (arrViewPhotos.count <= index)
        return;
    
    PhotoInfoStruct *pinfo = [arrViewPhotos objectAtIndex:index];
    if ([pinfo isFlaged])
    {
        [AppDelegate showMessage:@"You already flagged this photo." withTitle:@"Information"];
        return;
    }
    
    currentInfo = pinfo;
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to flag this photo as inappropriate?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = TYPE_FLAG_PHOTO;
    [alertview show];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
     didDownloadPhotoAtIndex:(NSInteger)index
{
    if (arrViewPhotos.count <= index)
        return;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PhotoInfoStruct *pinfo = [arrViewPhotos objectAtIndex:index];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[pinfo getPhotoURL]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
         }
         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (!image)
                 return;
             
             ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
             [library saveImage:image toAlbum:k_DownloadPhotoPath withCompletionBlock:^(NSError *error) {
                 if (error!=nil) {
                     NSLog(@"Big error: %@", [error description]);
                 }
                 else
                     [AppDelegate showMessage:@"Your photo has been downloaded to your local camera roll." withTitle:nil];
             }];
         }];
    });
    
    
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
            didEditPhotoAtIndex:(NSInteger)index
{
    if (arrViewPhotos.count <= index)
        return;
    
    bFullScreenEditMode = YES;
    iFullLastIndex = index;
    bReloadRequire = YES;
    objPhotoPagesController = photoPagesController;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PhotoInfoStruct *pinfo = [arrViewPhotos objectAtIndex:index];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[pinfo getPhotoURL]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
         }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (!image)
                 return;
             
             [self launchPhotoEditorWithImage:image];
         }];
    });
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
            didChangeCaptionPhotoAtIndex:(NSInteger)index
{
    bReloadRequire = YES;
    PhotoInfoStruct *pinfo = [arrViewPhotos objectAtIndex:index];
    PhotoPropertiesViewController *viewcontroller = (PhotoPropertiesViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoEditVC"];
    viewcontroller.photoinfo = pinfo;
    viewcontroller.bModalView = YES;
    
    //viewcontroller.veiwDetail = [self getCurrentActivatedView];
    [photoPagesController presentViewController:viewcontroller animated:YES completion:nil];
}

- (void)photoPagesController:(EBPhotoPagesController *)photoPagesController
         didReadPhotoAtIndex:(NSInteger)index
{
    PhotoInfoStruct *pinfo = [arrViewPhotos objectAtIndex:index];
    if ([pinfo isMyPhoto] || [pinfo isViewed])
        return;
    
    [pinfo setViewed:YES];
    [[AppDelegate sharedInstance] viewPhoto:[pinfo getPhotoIDToString]];
}

- (void)photoPagesController:(EBPhotoPagesController *)controller
                imageAtIndex:(NSInteger)index
           completionHandler:(void (^)(UIImage *))handler
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PhotoInfoStruct *pinfo = [arrViewPhotos objectAtIndex:index];
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[pinfo getPhotoURL]
                         options:0
                        progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
         }
        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
        {
            if (image)
                handler(image);
            else
                handler(imgDefault);
        }];
    });  
}

#pragma mark -
#pragma mark - action
- (void)processFullScreen:(PhotoInfoStruct *)info index:(NSInteger)index
{
    if (bShowKeyboard)
    {
        [[self getCurrentActivatedView].txtComment resignFirstResponder];
        return;
    }
    
    index = 0;
    for (PhotoInfoStruct *finfo in arrViewPhotos)
    {
        if ([finfo getPhotoID] == [info getPhotoID])
            break;
        index ++;
    }
    
    // Create browser
    objPhotoPagesController = [[EBPhotoPagesController alloc]
                                                    initWithDataSource:self delegate:self photoAtIndex:index];
    [self presentViewController:objPhotoPagesController animated:YES completion:nil];
}

- (void)processAddFamilys:(NSMutableArray *)arrFamilys
{
    SelectGroupFriendViewController *controller = (SelectGroupFriendViewController *)[[AppDelegate sharedInstance] getUIViewController:@"addUserVC"];
    controller.arrSelectedFriends = arrFamilys;
    controller.bPermissionMode = YES;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)processAddGroups:(NSMutableArray *)arrGroups
{
    ShareSelectGroupViewController *controller = (ShareSelectGroupViewController *)[[AppDelegate sharedInstance] getUIViewController:@"shareSelectGroupVC"];
    controller.arrSelectedGroups = arrGroups;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) processSaveAction
{
    DetailView *activatedView = [self getCurrentActivatedView];
    [self processSavePermission:[activatedView getGroups] arrFriends:[activatedView getFamilies] photoinfo:activatedView.pinfo parentflag:YES];
}

- (void)processSavePermission:(NSMutableArray *)arrGroups arrFriends:(NSMutableArray *)arrFriends photoinfo:(PhotoInfoStruct *)photoinfo parentflag:(BOOL)parentflag
{
    if (!parentflag)
        [self refreshActionType];
    
    [self showHUD:@"Saving..."];
    NSString *strGroupids = @"";
    for (GroupInfoStruct *info in arrGroups)
    {
        if (strGroupids.length > 0)
            strGroupids = [NSString stringWithFormat:@"%@,%d", strGroupids, (int)[info getGroupID]];
        else
            strGroupids = [NSString stringWithFormat:@"%d", (int)[info getGroupID]];
    }
    
    NSString *strFriendids = @"";
    for (FriendInfoStruct *info in arrFriends)
    {
        if (strFriendids.length > 0)
            strFriendids = [NSString stringWithFormat:@"%@,%d", strFriendids, (int)[info getUserID]];
        else
            strFriendids = [info getUserIDToString];
    }
    
    if (!currentInfo)
        currentInfo = [self getCurrentActivatedView].pinfo;

    if ([currentInfo isBucketPhoto])
    {
        ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getGroupFunctionURL:FUNC_BUCKET_UPDATE] tag:TYPE_UPDATE_BUCKET delegate:self];
        [request setPostValue:[Utils getStringFromInteger:[currentInfo getBucketID]] forKey:@"bucketid"];
        NSString *strFriendIds = [AppDelegate sharedInstance].objUserInfo.strUserId;
        for(FriendInfoStruct *info in arrFriends)
        {
            if([strFriendIds length] == 0)
                strFriendIds = [NSString stringWithString:[info getUserIDToString]];
            else
                strFriendIds = [strFriendIds stringByAppendingFormat:@",%d", (int)[info getUserID]];
        }
        [request setPostValue:strFriendIds forKey:@"friendids"];
        
        NSString *strGroups = @"";
        for(GroupInfoStruct *info in arrGroups)
        {
            if([strGroups length] == 0)
                strGroups = [NSString stringWithString:[info getGrouIDToString]];
            else
                strGroups = [strGroups stringByAppendingFormat:@",%d", (int)[info getGroupID]];
        }
        [request setPostValue:strGroups forKey:@"groupids"];
        [request startAsynchronous];
    }
    else
    {
        ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_SAVE_PROPERTIES] tag:TYPE_SAVE_PROPERTIES delegate:self];
        [request setPostValue:strGroupids forKey:@"groupids"];
        [request setPostValue:strFriendids forKey:@"userids"];
        [request setPostValue:[photoinfo getPhotoIDToString] forKey:@"photoid"];
        [request startAsynchronous];
        currentInfo = photoinfo;
    }
}


#pragma mark - Web delegate

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
    if(status == 200)
    {
        if (request.tag == TYPE_DELETE_PHOTO)
        {
            NSInteger photoid = [[json objectForKey:@"photoid"] integerValue];
            for (PhotoInfoStruct *info in arrViewPhotos)
            {
                if ([info getPhotoID] == photoid)
                {
                    [arrViewPhotos removeObject:info];
                    break;
                }
            }
            
            [objPhotoPagesController deletePhotoAtIndex:iCurrentDeleteIndex];
            if ([arrViewPhotos count] < 1)
                [self processBack:nil];
            else
                [self refreshCurrentPhoto:photoid];
            
        }
        else if (request.tag == TYPE_SAVE_PROPERTIES)
        {
            currentInfo = [self getCurrentActivatedView].pinfo;
            if ([currentInfo getPhotoID] == [[json objectForKey:@"photoid"] integerValue])
            {
                [currentInfo initWithJsonData:[json objectForKey:@"photoinfo"]];
                [AppDelegate showMessage:@"Photo permissions has been saved." withTitle:nil];
                [[self getCurrentActivatedView] updatedPermission];
            }
        }
        else if (request.tag == TYPE_UPDATE_BUCKET)
        {
            [[AppDelegate sharedInstance] refreshBucketInfos:[json objectForKey:@"buckets"]];
            NSArray *arrDelPhotos = [json objectForKey:@"deletedphotos"];
            for (NSString *strPhotoID in arrDelPhotos)
            {
                for (PhotoInfoStruct *photoinfo in arrViewPhotos) {
                    if ([photoinfo getPhotoID] == [strPhotoID integerValue])
                    {
                        [arrViewPhotos removeObject:photoinfo];
                        break;
                    }
                }
            }
            
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:@"Photo permissions has been saved." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alertview.tag = 0x10000;
            [alertview show];

        }
        else if (request.tag == TYPE_LEAVE_COMMENT)
        {
            currentInfo = [self getCurrentActivatedView].pinfo;
            if ([currentInfo getPhotoID] == [[json objectForKey:@"photoid"] integerValue])
            {
                [currentInfo initWithJsonData:[json objectForKey:@"photoinfo"]];
                [[self getCurrentActivatedView] updatedPermission];
            }
        }
    }
    else
    {
        if (request.tag == TYPE_DELETE_PHOTO)
            [AppDelegate showMessage:@"Can't delete this photo." withTitle:@"Error"];
    }
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    [self hideHUD];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[self getCurrentActivatedView].txtComment resignFirstResponder];
    
    if (actionSheet.tag == 0x10000)
    {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if(buttonIndex == 0) // Delete
    {
        bFullScreenEditMode = NO;
        currentInfo = [self getCurrentActivatedView].pinfo;
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = TYPE_DELETE_PHOTO;
        [alertview show];
    }
    else if (buttonIndex == 1) // Permissions
    {
        if ([[self getCurrentActivatedView].pinfo isMyBucket])
            [self processShowPermission:[self getCurrentActivatedView].pinfo];
        else
            [[self getCurrentActivatedView] showPermission];
    }
    else if(buttonIndex == 2) // Download
    {
        DetailView *currentView = [self getCurrentActivatedView];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library saveImage:currentView.ivImage.image toAlbum:k_DownloadPhotoPath withCompletionBlock:^(NSError *error) {
            if (error!=nil)
                NSLog(@"Big error: %@", [error description]);
            else
                [AppDelegate showMessage:@"Your photo has been downloaded to your local camera roll." withTitle:nil];
        }];
    }
    else if (buttonIndex == 3) // Edit Photo
    {
        DetailView *tmpCurrentView = [self getCurrentActivatedView];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            PhotoInfoStruct *pinfo = tmpCurrentView.pinfo;
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[pinfo getPhotoURL]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize)
             {}
             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
             {
                 if (image)
                 {
                     bFullScreenEditMode = NO;
                     [self launchPhotoEditorWithImage:image];
                 }
                 else
                     [AppDelegate showMessage:@"Can't load photo" withTitle:@"Error"];
             }];
        });
    }
    else if (buttonIndex == 4) // Change Tag or Caption
    {
        PhotoPropertiesViewController *viewcontroller = (PhotoPropertiesViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoEditVC"];
        viewcontroller.photoinfo = currentInfo;
        viewcontroller.veiwDetail = [self getCurrentActivatedView];
        [self.navigationController pushViewController:viewcontroller animated:YES];
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
    if (bFullScreenEditMode)
        [objPhotoPagesController presentViewController:photoEditor animated:YES completion:nil];
    else
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
    [editor dismissViewControllerAnimated:YES completion:^
    {
        S3PhotoUploader *photouploader = [[AppDelegate sharedInstance] getS3PhotoUploader:self];
        if (bFullScreenEditMode)
        {
            iUploadCount = 0;
            PhotoInfoStruct *objCurrentInfo = [arrViewPhotos objectAtIndex:iFullLastIndex];
            [objCurrentInfo setPhoto:image];
            
            [self showCustomeHUD:@"Saving..." view:objPhotoPagesController.view];
            [photouploader uploadFeedPhoto:objCurrentInfo];
        }
        else
        {
            PhotoInfoStruct *objCurrentInfo = [self getCurrentActivatedView].pinfo;
            [objCurrentInfo setPhoto:image];
            
            [self showHUD:@"Saving..."];
            [photouploader uploadFeedPhoto:objCurrentInfo];
        }
        
    }];
}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:YES completion:nil];
}


-(NSInteger) getCurrentPageIndex
{
    return scMain.contentOffset.x / scMain.frame.size.width;
}

-(void) refreshCurrentPhoto:(NSInteger)photoid
{
    for (PhotoInfoStruct *info in arrViewPhotos)
    {
        if ([info getPhotoID] == photoid)
        {
            [arrViewPhotos removeObject:info];
            break;
        }
    }
    
    NSInteger idx = [self getCurrentPageIndex];
    DetailView *detailView = [self getCurrentActivatedView];
    CGRect rectdetail = detailView.frame;
    rectdetail.origin.x = -640;
    detailView.frame = rectdetail;
    
    CGSize size = scMain.contentSize;
    size.width = [arrViewPhotos count] * 320;
    scMain.contentSize = size;
    
    NSInteger pos = idx;
    if (idx >= [arrViewPhotos count])
        pos = [arrViewPhotos count] - 1;
    if (pos < 0)
        pos = 0;
    rect.origin.x = rect.size.width * pos;
    
    iLastIndex = -1; // for refresh
    detailView = [self findViewInIndex:idx + 1];
    if (detailView)
    {
        detailView.frame = rect;
    }
    else
    {
        detailView = [self findViewInIndex:idx - 1];
        if (detailView)
            detailView.frame = rect;
    }
    
    [self scrollViewDidScroll:nil];
}

#pragma mark -
#pragma mark -  UIKeyboard Notification

-(void) keyboardWillShow:(NSNotification *)note
{
    bShowKeyboard = YES;
    DetailView *currentView = [self getCurrentActivatedView];
    // get keyboard size and loctaion
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    // get a rect for the textView frame
    CGRect containerFrame = currentView.viewTextComment.frame;
    NSInteger iScrollHeight = containerFrame.origin.y + 160 + keyboardBounds.size.height;
    containerFrame.origin.y -= (iScreenHeight - keyboardBounds.size.height - containerFrame.size.height);
    currentView.scView.contentSize = CGSizeMake(320, iScrollHeight);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    currentView.scView.contentOffset = containerFrame.origin;
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    bShowKeyboard = NO;
    DetailView *currentView = [self getCurrentActivatedView];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = currentView.viewTextComment.frame;
    containerFrame.size.height += containerFrame.origin.y;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // set views with new info
    // commit animations
    currentView.scView.contentSize = containerFrame.size;
    [UIView commitAnimations];
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
    
    if (alertView.tag == 0x10000)
    {
        if (arrViewPhotos.count < 1)
            [self processBack:nil];
        else
        {
            iCurrentIdx = 0;
            PhotoInfoStruct *curinfo = [self getCurrentActivatedView].pinfo;
            for (int i = 0; i < arrViewPhotos.count; i++)
            {
                PhotoInfoStruct *tmp = [arrViewPhotos objectAtIndex:i];
                if ([tmp getPhotoID] == [curinfo getPhotoID])
                {
                    iCurrentIdx = i;
                    break;
                }
            }
            
            [self initScrollView];
        }
        return;
    }
    
    if (buttonIndex == 1)
    {
        if (alertView.tag == TYPE_CHANGE_PERMISSION && bBackMode)
            [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (alertView.tag == TYPE_DELETE_PHOTO)
    {
        if (!currentInfo)
            return;
        
        if (bFullScreenEditMode)
            [self showCustomeHUD:@"Deleting..." view:objPhotoPagesController.view];
        else
            [self showHUD:@"Deleting..."];
        
        ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_DELETE_PHOTO] tag:TYPE_DELETE_PHOTO delegate:self];
        [request setPostValue:[currentInfo getPhotoIDToString] forKey:@"photoid"];
        [request startAsynchronous];
    }
    else if (alertView.tag == TYPE_FLAG_PHOTO)
    {
        [currentInfo setSpamFlag:YES];
        [objPhotoPagesController refreshFlagedPhoto];
        [[AppDelegate sharedInstance] flagPhoto:[currentInfo getPhotoIDToString] type:1 content:@"Spam"];
    }
    else if (alertView.tag == TYPE_CHANGE_PERMISSION)
    {
        [[self getCurrentActivatedView] processSaveAction:nil];
    }
}

- (void)processMore:(PhotoInfoStruct *)info index:(NSInteger)index
{
    [[self getCurrentActivatedView].txtComment resignFirstResponder];
    currentInfo = info;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Permissions", @"Download Photo", @"Edit Photo", @"Change Caption or Tag", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (void)processLikeView:(PhotoInfoStruct *)info
{
    [[self getCurrentActivatedView].txtComment resignFirstResponder];
    LikerViewController *controller = (LikerViewController *)[[AppDelegate sharedInstance] getUIViewController:@"showLikersVC"];
    controller.iLikeCount = [info getLikeCount];
    controller.iPhotoID = [info getPhotoID];
    [self.navigationController pushViewController:controller animated:YES];
}

-(void) uploadFinished
{
    [self hideHUD];
    [[AppDelegate sharedInstance] updateImageSize:[self getCurrentActivatedView].pinfo];
    if (bFullScreenEditMode)
        [objPhotoPagesController refreshFullScreenPhoto];
    else
        [[self getCurrentActivatedView] updatedPermission];
}

-(void) uploadFailed:(NSInteger)errorcode
{
    [self hideHUD];
}


@end
