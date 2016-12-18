//
//  HomeViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "HomeViewController.h"
#import "LatestPhotoTableViewCell.h"
#import "LatestPhtoCollectionCell.h"
#import "SharePhotoTableViewCell.h"
#import "SharePhotoCollectionViewCell.h"
#import "PhotoInfoStruct.h"
#import "FriendInfoStruct.h"
#import "AlbumEditViewController.h"
#import "PhotoDetailViewController.h"
#import "GroupSelectionViewController.h"
#import "NewFriendRequestCell.h"
#import "IntroView.h"
#import "OrderInfoStruct.h"
#import "HintTableViewCell.h"
#import "SeeMoreCollectionViewCell.h"

@interface HomeViewController ()
{
    PullToRefreshView   *viewPull;
    NSInteger iCurrentMode;
    BOOL bShowHint;
    UILabel *lbl;
    BOOL bGroupFilter;
    NSInteger iSelectedUserID;
    NSMutableArray *arrLastPhotos;
    NSMutableArray *arrMyPhoto;
    NSMutableArray *arrOrder;
    NSMutableArray *arrGroupFilter;
    //NSMutableArray *arrBucketFilter;
    NSString *strGroups;
    NSString *strBuckets;
    UIImage *imgPermissionNormal;
    UIImage *imgPermissionViewOnly;
}
@end

@implementation UINavigationController (Rotation_IOS6)

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end

@implementation HomeViewController

@synthesize tblFeed;


- (void)viewDidLoad
{
    [super viewDidLoad];
    lbl = [[UILabel alloc] init];
    arrLastPhotos = [AppDelegate sharedInstance].arrLastPhotos;
    
    bShowHint = [self getShowHintFlag];
    viewPull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)tblFeed];
    viewPull.delegate = self;
    
    imgPermissionNormal = [UIImage imageNamed:@"btn_small_permission_normal.png"];
    imgPermissionViewOnly = [UIImage imageNamed:@"btn_small_permission_disable.png"];
    
    [tblFeed addSubview:viewPull];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processRefresh:) name:NOTIF_KEY_USER_LOGIN object:nil];
    
    if ([[AppDelegate sharedInstance].objUserInfo isFirstLogin])
    {
        [[NSBundle mainBundle] loadNibNamed:@"IntroView" owner:self options:nil];
        IntroView *viewtmp = self.viewIntro;
        viewtmp.backgroundColor = [UIColor clearColor];
        [[AppDelegate sharedInstance].window addSubview:viewtmp];
        [[AppDelegate sharedInstance].objUserInfo refreshFlag];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tblFeed reloadData];
    if (!bGroupFilter)
    {
        if ([[AppDelegate sharedInstance].objUserInfo isLogined])
            [self getSharedPhoto:@"all"];
    }
}

-(void) processRefresh:(NSNotification *) notification
{
    if ([[AppDelegate sharedInstance].objUserInfo isLogined])
    {
        if (notification)
        {
            NSDictionary* userInfo = notification.userInfo;
            iCurrentMode = [userInfo[@"viewmode"] integerValue];
            strGroups = userInfo[@"filtergroups"];
            strBuckets = userInfo[@"filterbuckets"];
        }
        
        arrLastPhotos = [AppDelegate sharedInstance].arrLastPhotos;
        arrOrder = [AppDelegate sharedInstance].arrOrderPhotos;
        arrMyPhoto = [AppDelegate sharedInstance].arrMyPhotos;
        [tblFeed reloadData];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.request clearDelegatesAndCancel];
}

- (void) getSharedPhoto:(NSString*)type
{
    if (![[AppDelegate sharedInstance].objUserInfo isLogined])
    {
        [viewPull finishedLoading];
        [[AppDelegate sharedInstance] isCheckedError:ERR_USER_AUTO_LOGIN_FAILED message:nil];
        return;
    }
    
    [self.request clearDelegatesAndCancel];
    
    self.request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getUserFunctionURL:FUNC_USER_REFRESH_ALL] delegate:self];
    //[self.request setPostValue:type forKey:@"type"];
    [self.request startAsynchronous];
}

#pragma mark - pull delegate
-(void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    [viewPull setState:PullToRefreshViewStateLoading];
    [self getSharedPhoto:@"all"];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [viewPull finishedLoading];
    bGroupFilter = NO;
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
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    
    if(status == 200)
    {
        [[AppDelegate sharedInstance] refreshHomeData:json];
        [self refreshMode:json];
        [self processRefresh:nil];
    }
    
    [viewPull finishedLoading];
    bGroupFilter = NO;
}

-(void) refreshMode:(NSDictionary *)dict
{
    iCurrentMode = [[dict objectForKey:@"viewmode"] integerValue];
    strGroups = [dict objectForKey:@"filtergroups"];
    strBuckets = [dict objectForKey:@"filterbuckets"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2)
        return [arrOrder count];
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return 130;
    
    if (indexPath.section == 3)
        return 70;
    
    if (indexPath.section == 4)
    {
        if (bShowHint)
            return 200;
        else
            return 45;
    }
    
    
    return 87;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        LatestPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell1"];
        cell.collectionView.tag = i_LatestPhotoView;
        [cell.countView.layer setCornerRadius:10.0];
        cell.countLbl.text = [NSString stringWithFormat:@"%d", [self calculateLastNewPhotoCount]];
        cell.lblNoPhoto.hidden = (arrLastPhotos.count > 0);
        [cell.collectionView reloadData];
        return cell;
    }
    else if(indexPath.section == 1)
    {
        SharePhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell2"];
        cell.collectionView.tag = i_MyPhotoView;
        cell.btnUser.tag = i_MyPhotoView;
        cell.countView.hidden = YES;
        cell.nameLbl.text = @"Me";
        
        if (arrMyPhoto.count > 0)
            cell.lblNoPhoto.hidden = YES;
        else
            cell.lblNoPhoto.hidden = NO;
        
        UIImage *placeImage = [Utils getDefaultProfileImage];
        [cell.profileImgView sd_setImageWithURL:[[AppDelegate sharedInstance].objUserInfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
        [self setLayerImage:cell.profileImgView];
        [cell.collectionView reloadData];
        return cell;
    }
    else if (indexPath.section == 3)
    {
        NewFriendRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell5"];
        return cell;
    }
    else if (indexPath.section == 2)
    {
        OrderInfoStruct *oinfo = [arrOrder objectAtIndex:indexPath.row];
        SharePhotoTableViewCell *cell;
//        if ([oinfo isBucketOrder])
//        {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell4"];
//            if ([oinfo isMyOrder])
//            {
//                
//                BucketInfoStruct *binfo = [[AppDelegate sharedInstance] findBucketInfoByID:[oinfo getBucektID]];
//                cell.nameLbl.text = @"Me";
//                cell.lblBucketName.text = [binfo getBucketName];
//                if ([AppDelegate sharedInstance].profileImg)
//                    cell.ivBucketProfile.image = [AppDelegate sharedInstance].profileImg;
//                else
//                {
//                    UIImage *placeImage = [Utils getDefaultProfileImage];
//                    [cell.ivBucketProfile sd_setImageWithURL:[AppDelegate sharedInstance].objUserInfo.strPhotoUrl] placeholderImage:placeImage options:SDWebImageRefreshCached];
//                }
//            }
//            else
//            {
//                FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:[oinfo getUserID]];
//                BucketInfoStruct *binfo = [[AppDelegate sharedInstance] findBucketInfoByID:[oinfo getBucektID]];
//                cell.nameLbl.text = [finfo getFirstName];
//                cell.lblBucketName.text = [binfo getBucketName];
//                UIImage *placeImage = [Utils getDefaultProfileImage];
//                [cell.ivBucketProfile sd_setImageWithURL:[finfo getProfilePhoto]] placeholderImage:placeImage options:SDWebImageRefreshCached];
//            }
//        }
//        else
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"photoCell2"];
            FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:[oinfo getUserID]];
            cell.nameLbl.text = [finfo getFirstName];
            UIImage *placeImage = [Utils getDefaultProfileImage];
            [cell.profileImgView sd_setImageWithURL:[finfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
            [self setLayerImage:cell.profileImgView];
        }
        
        cell.countLbl.text = [oinfo getUnreadCountToString];
        cell.collectionView.tag = indexPath.row;
        cell.btnUser.tag = indexPath.row;
        cell.countView.hidden = NO;
        
        if ([oinfo getOrderPhotos].count > 0)
            cell.lblNoPhoto.hidden = YES;
        else
            cell.lblNoPhoto.hidden = NO;
        [cell.collectionView reloadData];
        return cell;

    }
    else
    {
        HintTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"hintTableViewCell"];
        if (bShowHint)
        {
            [cell.btnHide setTitle:@"Hide" forState:UIControlStateNormal];
            cell.viewMidSeperate.hidden = YES;
            cell.viewWhite.hidden = YES;
        }
        else
        {
            [cell.btnHide setTitle:@"Show" forState:UIControlStateNormal];
            cell.viewMidSeperate.hidden = NO;
            cell.viewWhite.hidden = NO;
        }

        return cell;
    }
    
    return nil;
}


-(BOOL) getShowHintFlag
{
    NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
    
    return [[userDefautls objectForKey:@"showhint"] boolValue];
}

- (int) calculateLastNewPhotoCount
{
    int count = 0;
    for (PhotoInfoStruct *info in arrLastPhotos)
    {
        if (![info isViewed])
            count ++;
    }
    
    return count;
}


#pragma mark -
#pragma mark -  Collection View Cell

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count;
    if((collectionView.tag == (int)i_LatestPhotoView))
        return [arrLastPhotos count];
    else if(collectionView.tag == (int)i_MyPhotoView)
        count = [arrMyPhoto count];
    else
    {
        OrderInfoStruct *info = [arrOrder objectAtIndex:collectionView.tag];
        count = [[info getOrderPhotos] count];
    }

    return count >= 3 ? ++count : count;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if((collectionView.tag == (int)i_LatestPhotoView))
    {
        LatestPhtoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCollCell1" forIndexPath:indexPath];
        if (indexPath.row < arrLastPhotos.count)
        {
            PhotoInfoStruct *info = [arrLastPhotos objectAtIndex:indexPath.row];
            cell.lblNew.hidden = [info isViewed];
            [cell.btnComment setSelected:[info isNewComment]];
            [cell.btnFavorite setSelected:[info isLiked]];
            [cell.imgView sd_setImageWithURL:[info getPhotoThumbURL] placeholderImage:nil options:0];
            return cell;
        }
        
        [cell.imgView sd_setImageWithURL:nil placeholderImage:nil options:0];
        return cell;
    }
    else if(collectionView.tag == (int)i_MyPhotoView)
    {
        SharePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCollCell2" forIndexPath:indexPath];
        cell.viewBorder.hidden = NO;
        cell.lblNew.hidden = YES;
        if (indexPath.row < arrMyPhoto.count)
        {
            PhotoInfoStruct *info = [arrMyPhoto objectAtIndex:indexPath.row];
            
            cell.btnShared.selected = NO;
            cell.btnShared.hidden = ![info isMyPhoto];
            [cell.btnShared setImage:imgPermissionNormal forState:UIControlStateNormal];
            if ([info isBucketPhoto])
            {
                if ([info isMyBucket])
                {
                    if ([info isSharedPhoto])
                        cell.btnShared.selected = [info isSharedPhoto];
                }
                else
                {
                    [cell.btnShared setImage:imgPermissionViewOnly forState:UIControlStateNormal];
                }
            }
            else
            {
                if ([info isMyPhoto])
                    cell.btnShared.selected = [info isMySharedPhoto];
            }
            
            [cell.btnComment setSelected:[info isNewComment]];
            [cell.btnFavorite setSelected:[info isLiked]];
            [cell.imgView sd_setImageWithURL:[info getPhotoThumbURL] placeholderImage:nil options:SDWebImageProgressiveDownload];
            return cell;
        }
        else if (indexPath.row == arrMyPhoto.count)
        {
            SeeMoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCollCell6" forIndexPath:indexPath];
            cell.btnSeeMore.tag = [[AppDelegate sharedInstance].objUserInfo getUserID];
            return cell;
        }
        
        cell.viewBorder.hidden = YES;
        [cell.imgView sd_setImageWithURL:nil placeholderImage:nil options:SDWebImageProgressiveDownload];
        return cell;

    }
    else
    {
        OrderInfoStruct *oinfo = [arrOrder objectAtIndex:collectionView.tag];
        SharePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCollCell2" forIndexPath:indexPath];
        
        cell.viewBorder.hidden = NO;
        cell.btnShared.hidden = YES;
        if ([oinfo getOrderPhotos].count > indexPath.row)
        {
            PhotoInfoStruct *pinfo = [[oinfo getOrderPhotos] objectAtIndex:indexPath.row];
            [cell.btnComment setSelected:[pinfo isNewComment]];
            [cell.btnFavorite setSelected:[pinfo isLiked]];
            cell.lblNew.hidden = [pinfo isViewed];
            [cell.imgView sd_setImageWithURL:[pinfo getPhotoURL] placeholderImage:nil options:SDWebImageProgressiveDownload];
            return cell;
        }
        else if (indexPath.row == [oinfo getOrderPhotos].count)
        {
            SeeMoreCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoCollCell6" forIndexPath:indexPath];
            cell.btnSeeMore.tag = [oinfo getUserID];
            return cell;
        }

        
        [cell.imgView sd_setImageWithURL:nil placeholderImage:nil options:SDWebImageProgressiveDownload];
        cell.lblNew.hidden = YES;
        cell.viewBorder.hidden = YES;
        return cell;
    }

    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    PhotoDetailViewController *controller = (PhotoDetailViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoDetailVC"];
    
    if((collectionView.tag == (int)i_LatestPhotoView))
    {
        controller.arrViewPhotos = arrLastPhotos;
        controller.iCurrentIdx = indexPath.row;
    }
    else if(collectionView.tag == (int)i_MyPhotoView)
    {
        controller.arrViewPhotos = arrMyPhoto;
        controller.iCurrentIdx = indexPath.row;
        
    }
    else
    {
        OrderInfoStruct *oinfo = [arrOrder objectAtIndex:collectionView.tag];
        controller.iCurrentIdx = indexPath.row;
        controller.arrViewPhotos = [oinfo getOrderPhotos];
    }
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)processUserSelect:(id)sender
{
    UIView *btn = (UIView *)sender;
    AlbumEditViewController *controller = (AlbumEditViewController *)[[AppDelegate sharedInstance] getUIViewController:@"groupEditVC"];
    if (btn.tag == i_MyPhotoView)
    {
        controller.iInitUserID = [[AppDelegate sharedInstance].objUserInfo.strUserId integerValue];
    }
    else
    {
        OrderInfoStruct *oinfo = [arrOrder objectAtIndex:btn.tag];
        if ([oinfo isBucketOrder])
            controller.objBucket = [[AppDelegate sharedInstance] findBucketInfoByID:[oinfo getBucektID]];
        else
            controller.iInitUserID = [oinfo getUserID];
    }
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)processSort:(id)sender
{
    
    IBActionSheet *standardIBAS = [[IBActionSheet alloc] initWithTitle:@"Select View Mode" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Sort by Date",
                                   @"Sort by Name",
                                   @"Only selected circles",
                                   @"Mark all Photos as viewed", nil];
    UIFont *font = [AppDelegate getAppSystemFont:16];
    [standardIBAS setFont:font];
    
    if (iCurrentMode > 0 && iCurrentMode < 4)
    {
        [standardIBAS setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17] forButtonAtIndex:iCurrentMode - 1];
    }
    
    [standardIBAS showInView:[AppDelegate sharedInstance].window];
}

-(void)actionSheet:(IBActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0x10000)
    {
        [super actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (buttonIndex == 3)
    {
        [viewPull setState:PullToRefreshViewStateLoading];
        [self.request clearDelegatesAndCancel];
        self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_VIEW_MODE] tag:TYPE_CHANGE_VIEW_MODE delegate:self];
        [self.request setPostValue:@"4" forKey:@"viewmode"];
        [self.request startAsynchronous];
    }
    else if(buttonIndex == 2) // select only group
    {
        GroupSelectionViewController *selectionView = (GroupSelectionViewController *)[[AppDelegate sharedInstance] getUIViewController:@"selectFilterGroupVC"];
        
        selectionView.controlView = self;
        if (iCurrentMode == 3)
        {
            selectionView.strGroupIds = strGroups;
            //selectionView.strBucketIds = strBuckets;
        }
        [self.navigationController presentViewController:selectionView animated:YES completion:nil];
    }
    else if(buttonIndex == 1) // alphabetically
    {
        [viewPull setState:PullToRefreshViewStateLoading];
        [self.request clearDelegatesAndCancel];
        self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_VIEW_MODE] tag:TYPE_CHANGE_VIEW_MODE delegate:self];
        [self.request setPostValue:@"2" forKey:@"viewmode"];
        [self.request startAsynchronous];
        
    }
    else if(buttonIndex == 0) // Default by Activity
    {
        [viewPull setState:PullToRefreshViewStateLoading];
        [self.request clearDelegatesAndCancel];
        self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_VIEW_MODE] tag:TYPE_CHANGE_VIEW_MODE delegate:self];
        [self.request setPostValue:@"1" forKey:@"viewmode"];
        [self.request startAsynchronous];
    }
}

- (void)processGroupFilter:(NSMutableArray *)groups
{
    bGroupFilter = YES;
    if (!arrGroupFilter)
        arrGroupFilter = [[NSMutableArray alloc] init];
    else
        [arrGroupFilter removeAllObjects];
    [Utils copyArray:groups desarray:arrGroupFilter];
    
//    if (!arrBucketFilter)
//        arrBucketFilter = [[NSMutableArray alloc] init];
//    else
//        [arrBucketFilter removeAllObjects];
//    [Utils copyArray:buckets desarray:arrBucketFilter];
    
    NSString *strGroupIDs = @"";
    for (GroupInfoStruct *info in groups)
    {
        if (strGroupIDs.length < 1)
            strGroupIDs = [Utils getStringFromInteger:[info getGroupID]];
        else
            strGroupIDs = [NSString stringWithFormat:@"%@,%d", strGroupIDs, (int)[info getGroupID]];
    }
    
//    NSString *strBucketIDs = @"";
//    for (BucketInfoStruct *info in buckets)
//    {
//        if (strBucketIDs.length < 1)
//            strBucketIDs = [info getBucketIDToString];
//        else
//            strBucketIDs = [NSString stringWithFormat:@"%@,%d", strBucketIDs, (int)[info getBucketID]];
//    }
    
    [viewPull setState:PullToRefreshViewStateLoading];
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_VIEW_MODE] tag:TYPE_CHANGE_VIEW_MODE delegate:self];
    [self.request setPostValue:@"3" forKey:@"viewmode"];
    [self.request setPostValue:strGroupIDs forKey:@"groupids"];
    //[self.request setPostValue:strBucketIDs forKey:@"bucketids"];
    [self.request startAsynchronous];
}

- (IBAction)processNewFriendsReq:(id)sender
{
    [self goToFriendsRequestPage];
}

- (IBAction)processCloseHint:(id)sender
{
    bShowHint = !bShowHint;
    NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
    [userDefautls setObject:[NSString stringWithFormat:@"%d", bShowHint] forKey:@"showhint"];
    [userDefautls synchronize];
    [tblFeed reloadData];
    if (bShowHint)
        [tblFeed scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)processSeeMore:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    AlbumEditViewController *controller = (AlbumEditViewController *)[[AppDelegate sharedInstance] getUIViewController:@"groupEditVC"];
    controller.iInitUserID = btn.tag;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - Navigation



@end
