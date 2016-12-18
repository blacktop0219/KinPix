//
//  ShareSelectBucketViewController.m
//  Zinger
//
//  Created by Tianming on 07/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "ShareSelectBucketViewController.h"
#import "BucketEditViewController.h"
#import "BucketViewCell.h"
#import "BucketInfoStruct.h"
#import "GroupHeadCell.h"
#import "SBJson.h"

@interface ShareSelectBucketViewController ()<S3PhotoUploaderDelegate>
{
    UIImage *placeImage;
    BOOL bMySectionShowed, bFriendSctionShowd;
}
@end

@implementation ShareSelectBucketViewController

@synthesize arrSelectedBucket;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //bMySectionShowed = YES;
    //bFriendSctionShowd = NO;
    [self hideButtons];
    placeImage = [Utils getDefaultProfileImage];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.covBucket reloadData];
}

- (BOOL) isSelectedItem:(BucketInfoStruct *)groupinfo
{
    for (BucketInfoStruct *info in arrSelectedBucket)
    {
        if ([info getBucketID] == [groupinfo getBucketID])
            return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource Methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        GroupHeadCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"groupHeadCell" forIndexPath:indexPath];
        reusableview = headerView;
        if (indexPath.section == 0)
        {
            headerView.lblTitle.text = [NSString stringWithFormat:@"My Group Albums(%d)", (int)[[AppDelegate sharedInstance].arrMyBucket count]];
            headerView.btnHeader.selected = bMySectionShowed;
        }
        else if (indexPath.section == 1)
        {
            headerView.lblTitle.text = [NSString stringWithFormat:@"Group Albums(%d) people have shared with you",
                                                        (int)[[AppDelegate sharedInstance].arrFriendBucket count]];
            headerView.btnHeader.selected = bFriendSctionShowd;
        }
        headerView.btnHeader.tag = indexPath.section;
    }
    
    return reusableview;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0)
        return bMySectionShowed ? [[AppDelegate sharedInstance].arrMyBucket count] + 1 : 0;
    
    return bFriendSctionShowd ? [[AppDelegate sharedInstance].arrFriendBucket count] : 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BucketInfoStruct *info;
    if (indexPath.section == 0)
    {
        if (indexPath.row > 0)
            info = [[AppDelegate sharedInstance].arrMyBucket objectAtIndex:(indexPath.row - 1)];
    }
    else
        info = [[AppDelegate sharedInstance].arrFriendBucket objectAtIndex:(indexPath.row)];
    
    BucketViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bucketViewCell" forIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        cell.viewAdd.hidden = NO;
        cell.viewMain.hidden = YES;
        return cell;
    }
    
    cell.viewAdd.hidden = YES;
    cell.viewMain.hidden = NO;
    if (indexPath.section == 0)
    {
        cell.btnBucket.tag = indexPath.row - 1;
        [cell.ivProfile sd_setImageWithURL:[[AppDelegate sharedInstance].objUserInfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
    }
    else
    {
        cell.btnBucket.tag = indexPath.row + 1000;
        FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:[info getUserID]];
        [cell.ivProfile sd_setImageWithURL:[finfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
    }
    
    cell.lblBucketName.font = [UIFont fontWithName:@"Helvetica" size:11];
    cell.lblBucketName.text = [info getBucketName:YES];
    [cell.btnBucket setSelected:[self isSelectedItem:info]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) processBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)processSelectItem:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    BucketInfoStruct *info;
    if (btn.tag >= 1000)
        info = [[AppDelegate sharedInstance].arrFriendBucket objectAtIndex:(btn.tag - 1000)];
    else
        info = [[AppDelegate sharedInstance].arrMyBucket objectAtIndex:(btn.tag)];
    
    if([self isSelectedItem:info] == YES)
        [arrSelectedBucket removeObject:info];
    else
    {
        [arrSelectedBucket removeAllObjects];
        [arrSelectedBucket addObject:info];
    }
    
    [self.covBucket reloadData];
}

- (IBAction)processNewBucket:(id)sender
{
    [self performSegueWithIdentifier:@"gotoCreateBucket" sender:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"gotoCreateBucket"])
    {
        BucketEditViewController *viewController = (BucketEditViewController *)[segue destinationViewController];
        viewController.bShareMode = YES;
        viewController.arrSelectedBucket = arrSelectedBucket;
    }
}

- (IBAction)processCancel:(id)sender
{
    UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel sharing a photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 3000;
    [alert show];
}

- (void) cancelShare
{
    [[AppDelegate sharedInstance] refreshShareEnvironment];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)processShare:(id)sender
{
    if ([AppDelegate sharedInstance].arrShareAlbums.count < 1)
    {
        [AppDelegate showMessage:@"Please select a Group Album." withTitle:@"Warning"];
        return;
    }
    
    [self sharePhoto];
}

- (IBAction)processHeaderAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.tag == 0) // My
    {
        bMySectionShowed = btn.selected;
    }
    else
    {
        bFriendSctionShowd = btn.selected;
    }
    
    [self.covBucket reloadData];
}

- (void) sharePhoto
{
    if (![AppDelegate isConnectedToInternet])
    {
        [MessageBox showErrorMsage:MSG_ERR_INTERNET_CONNECT_FAILED];
        return;
    }
    
    [self showM13HUD:@"Sending..."];
    S3PhotoUploader *photouploder = [[AppDelegate sharedInstance] getS3PhotoUploader:self];
    [photouploder uploadFeedPhotos:[AppDelegate sharedInstance].arrSharePhotos];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if(alertView.tag == 3000)
    {
        if(buttonIndex == 0)
            [self cancelShare];
    }
    else
    {
        [self cancelShare];
    }
}

-(void) uploadFinished
{
    [self hideM13HUD];
    [[[UIAlertView alloc] initWithTitle:nil message:@"Your photo(s) are successfully shared." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

-(void) uploadFailed:(NSInteger)errorcode
{
    [self hideM13HUD];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Image upload failed. Please check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
