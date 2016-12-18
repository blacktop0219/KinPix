//
//  PhotoDetailViewController.m
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "CommentViewCell.h"
#import "MWPhoto.h"
#import "LikerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "SelectGroupFriendViewController.h"
#import "PhotoPropertiesViewController.h"
#import "ShareSelectGroupViewController.h"
#import "CommentViewController.h"

@interface PhotoDetailViewController ()
{
    PhotoInfoStruct *currentInfo;
    BOOL bShowKeyboard;
    UIImage *imgDefault;
    NSMutableArray *photos;
    CGRect rect;
    DetailView *viewDetail1;
    DetailView *viewDetail2;
    DetailView *viewDetail3;
    NSInteger iLastIndex;
    NSInteger iScreenHeight;
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
    
    rect.size.width = scMain.frame.size.width;
    rect.origin.y = 0;
    bShowKeyboard = NO;
    viewDetail1 = [self createNewDetailView];
    viewDetail2 = [self createNewDetailView];
    viewDetail3 = [self createNewDetailView];

    iScreenHeight = [UIScreen mainScreen].bounds.size.height - 72;
    [self initScrollView];
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

-(BOOL) shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
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
    if (iLastIndex == idx)
        return;
    
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
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
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
    [temp refershCollectionView];
}

-(DetailView *) getCurrentActivatedView
{
    NSInteger idx = scMain.contentOffset.x / scMain.frame.size.width;
    return [self findViewInIndex:idx];
}


- (IBAction)processBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) processShowComment:(PhotoInfoStruct *)info comments:(NSMutableArray *)arrComments
{
    [[self getCurrentActivatedView].txtComment resignFirstResponder];
    
    CommentViewController *viewController = (CommentViewController *)[[AppDelegate sharedInstance] getUIViewController:@"commentViewVC"];
    viewController.photoinfo = info;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)processFullScreen:(PhotoInfoStruct *)info index:(NSInteger)index
{
    if (bShowKeyboard)
    {
        [[self getCurrentActivatedView].txtComment resignFirstResponder];
        return;
    }
    
    if (!photos)
        photos = [[NSMutableArray alloc] init];
    else
        [photos removeAllObjects];
    
    for (PhotoInfoStruct *info in arrViewPhotos)
    {
        if (info)
            [photos addObject:[MWPhoto photoWithURL:[Utils getPhotoURL:[info getPhotoName]]]];
    }
    
    if ([photos count] < 1)
        return;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.arrPhotoInfos = arrViewPhotos;
    [browser setInitialPageIndex:[self getCurrentPageIndex]];
    
    [self presentViewController:browser animated:YES completion:nil];
}

- (void)processAddFamilys:(NSMutableArray *)arrFamilys
{
    SelectGroupFriendViewController *controller = (SelectGroupFriendViewController *)[[AppDelegate sharedInstance] getUIViewController:@"addUserVC"];
    controller.arrSelectedFriends = arrFamilys;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)processAddGroups:(NSMutableArray *)arrGroups
{
    ShareSelectGroupViewController *controller = (ShareSelectGroupViewController *)[[AppDelegate sharedInstance] getUIViewController:@"shareSelectGroupVC"];
    controller.arrSelectedGroups = arrGroups;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)processSavePermission:(NSMutableArray *)arrGroups arrFriends:(NSMutableArray *)arrFriends photoinfo:(PhotoInfoStruct *)photoinfo
{
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
    
    ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_SAVE_PROPERTIES] tag:TYPE_SAVE_PROPERTIES delegate:self];
    [request setPostValue:strGroupids forKey:@"groupids"];
    [request setPostValue:strFriendids forKey:@"userids"];
    [request setPostValue:[photoinfo getPhotoIDToString] forKey:@"photoid"];
    [request startAsynchronous];
    currentInfo = photoinfo;
}


#pragma mark - MWPhotoBrowserDelegate

- (void)deleteCurrentPhoto:(NSInteger)index
{
    if (index >= arrViewPhotos.count)
        return;
    
    NSInteger photoid;
    PhotoInfoStruct *info = [arrViewPhotos objectAtIndex:index];
    photoid = [info getPhotoID];
    
    [self refreshCurrentPhoto:photoid];
    [photos removeObjectAtIndex:index];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < photos.count)
        return [photos objectAtIndex:index];
    return nil;
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
            
            [self refreshCurrentPhoto:photoid];
            if ([arrViewPhotos count] < 1)
                [self processBack:nil];
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
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to delete this photo?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertview.tag = TYPE_DELETE_PHOTO;
        [alertview show];
    }
    else if(buttonIndex == 1) // Download
    {
        DetailView *currentView = [self getCurrentActivatedView];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library saveImage:currentView.ivImage.image toAlbum:k_DownloadPhotoPath withCompletionBlock:^(NSError *error) {
            if (error!=nil) {
                NSLog(@"Big error: %@", [error description]);
            }
            else
                [AppDelegate showMessage:@"Your photo has been downloaded to your local camera roll." withTitle:nil];
        }];
    }
    else
    {
        PhotoPropertiesViewController *viewcontroller = (PhotoPropertiesViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoEditVC"];
        viewcontroller.photoinfo = currentInfo;
        viewcontroller.veiwDetail = [self getCurrentActivatedView];
        [self.navigationController pushViewController:viewcontroller animated:YES];
    }
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
    if (buttonIndex == 0)
        return;
    
    if (alertView.tag == TYPE_DELETE_PHOTO)
    {
        if (currentInfo)
        {
            [self showHUD:@"Deleting..."];
            ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_DELETE_PHOTO] tag:TYPE_DELETE_PHOTO delegate:self];
            [request setPostValue:[currentInfo getPhotoIDToString] forKey:@"photoid"];
            [request startAsynchronous];
        }
    }
}

- (void)processMore:(PhotoInfoStruct *)info index:(NSInteger)index
{
    [[self getCurrentActivatedView].txtComment resignFirstResponder];
    currentInfo = info;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:@"Download Photo", @"Change Caption or Tag", nil];
    
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


@end
