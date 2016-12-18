//
//  SharePeopleViewController.m
//  Zinger
//
//  Created by QingHou on 11/14/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "SharePeopleViewController.h"
#import "FriendsViewCell.h"
#import "GroupViewCell.h"
#import "SelectGroupFriendViewController.h"
#import "ShareSelectGroupViewController.h"
#import "ShareSelectAlbumViewController.h"
#import "CreateAlbumViewController.h"
#import "SBJson.h"
#import "AlbumViewCell.h"
#import "ShareViewController.h"


@interface SharePeopleViewController ()<S3PhotoUploaderDelegate>
{
    NSInteger iPhotoCount;
    NSInteger iCurrentIndex;
}

@end

@implementation SharePeopleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    
    if (self.scMain)
    {
        self.scMain.contentSize = CGSizeMake(320, 400);
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.peopleCollectView reloadData];
    [self.groupCollectView reloadData];
    [self.covAlbums reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == self.peopleCollectView)
        return [[AppDelegate sharedInstance].arrShareFriends count] + 1;
    
    if (collectionView == self.covAlbums)
        return [[AppDelegate sharedInstance].arrShareAlbums count] + 1;
    
    return [[AppDelegate sharedInstance].arrShareGroups count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.peopleCollectView)
    {
        FriendsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"friendsCollectionCell" forIndexPath:indexPath];
        if(indexPath.row == 0)
        {
            cell.addView.hidden = NO;
            cell.mainView.hidden = YES;
        }
        else
        {
            cell.addView.hidden = YES;
            cell.mainView.hidden = NO;
            cell.actBtn.hidden = NO;
            cell.actBtn.tag = indexPath.row;
            
            FriendInfoStruct *info = [[AppDelegate sharedInstance].arrShareFriends objectAtIndex:(indexPath.row - 1)];
            cell.nameLbl.text = [info getUserName];
            [cell.photoView sd_setImageWithURL:[info getPhotoURL] placeholderImage:[Utils getDefaultProfileImage]];
            [self setLayerImage:cell.photoView];
        }
        
        return cell;
    }
    else if (collectionView == self.covAlbums)
    {
        AlbumViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shareAlbumViewCell" forIndexPath:indexPath];
        if(indexPath.row == 0)
        {
            cell.viewAdd.hidden = NO;
            cell.viewAlbum.hidden = YES;
            cell.viewAlbum.tag = indexPath.row;
        }
        else
        {
            cell.viewAdd.hidden = YES;
            cell.viewAlbum.hidden = NO;
            
            cell.btnMain.tag = indexPath.row - 1;
            cell.btnPopover.tag = indexPath.row - 1;
            cell.viewAlbum.tag = indexPath.row;
            cell.lblName.font = [UIFont fontWithName:@"Helvetica" size:11];

            AlbumInfoStruct *info = [[AppDelegate sharedInstance].arrShareAlbums objectAtIndex:(indexPath.row - 1)];
            cell.lblName.text = [info getAlbumName];
        }
        
        return cell;
    }
    else
    {
        GroupViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"groupCollectionCell" forIndexPath:indexPath];
        if(indexPath.row == 0)
        {
            cell.addView.hidden = NO;
            cell.mainView.hidden = YES;
            cell.mainBtn.tag = indexPath.row;
        }
        else
        {
            cell.addView.hidden = YES;
            cell.mainView.hidden = NO;
            
            cell.actBtn.tag = indexPath.row - 1;
            cell.mainBtn.tag = indexPath.row;
            GroupInfoStruct *info = [[AppDelegate sharedInstance].arrShareGroups objectAtIndex:(indexPath.row - 1)];
            cell.titleLbl.text = [info getGroupNameToShow];
        }
        
        return cell;
    }
    
    return nil;
}


- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) cancelShare
{
    [[AppDelegate sharedInstance] refreshShareEnvironment];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onCancel:(id)sender {
    
    UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel sharing a photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 3000;
    [alert show];
}

- (BOOL) isShareStep
{
    ShareViewController *viewController = nil;
    NSArray *arrControllers = self.navigationController.viewControllers;
    
    for (NSInteger i = arrControllers.count - 1; i >= 0; i--)
    {
        UIViewController *controller = [arrControllers objectAtIndex:i];
        if ([controller isKindOfClass:[ShareViewController class]])
        {
            viewController = (ShareViewController *)controller;
            break;
        }
    }
    
    return !viewController.bShowBack;
}


- (IBAction)onShare:(id)sender
{
    if ([AppDelegate sharedInstance].arrShareAlbums.count < 1)
    {
        [AppDelegate showMessage:@"Please select album." withTitle:@"Warning"];
        return;
    }
    
    if ([AppDelegate sharedInstance].arrShareGroups.count < 1 && [AppDelegate sharedInstance].arrShareFriends.count < 1)
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Information" message:@"Are you sure you would like to share with only yourself right now?  (You can always add people later.)" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = 0x10000;
        [alertview show];
        return;
    }
    
    [self sharePhoto];
}


//For Group
- (IBAction)onAddGroup:(id)sender
{
    [self performSegueWithIdentifier:@"goShareSelectGroup" sender:nil];
}

- (IBAction)onGroupShowRemove:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag;
    
    GroupInfoStruct *info = [[AppDelegate sharedInstance].arrShareGroups objectAtIndex:iCurrentIndex];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" circle?", [info getGroupName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x500;
    [alertview show];
}


//For Peopl
- (IBAction)onPeoleShowRemove:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag - 1;
    FriendInfoStruct *info = [[AppDelegate sharedInstance].arrShareFriends objectAtIndex:iCurrentIndex];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" people?", [info getUserName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x600;
    [alertview show];
}

-(IBAction)processAddAlbum:(id)sender
{
    [self performSegueWithIdentifier:@"gotoSelectAlbum" sender:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)processAlbumOption:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag;
    AlbumInfoStruct *info = [[AppDelegate sharedInstance].arrShareAlbums objectAtIndex:iCurrentIndex];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove %@ \"album\"?", [info getAlbumName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x700;
    [alertview show];
}

- (void) sharePhoto
{
    if (![AppDelegate isConnectedToInternet])
    {
        [MessageBox showErrorMsage:MSG_ERR_INTERNET_CONNECT_FAILED];
        return;
    }
    
    iPhotoCount = [[AppDelegate sharedInstance].arrSharePhotos count];
    [self showM13HUD:@"Sending..."];
    S3PhotoUploader *uploader = [[AppDelegate sharedInstance] getS3PhotoUploader:self];
    [uploader uploadFeedPhotos:[AppDelegate sharedInstance].arrSharePhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (alertView.tag == 0x500 || alertView.tag == 0x600 || alertView.tag == 0x700)
    {
        if (buttonIndex == 1)
            return;
        
        if (alertView.tag == 0x500)
        {
            [[AppDelegate sharedInstance].arrShareGroups removeObjectAtIndex:iCurrentIndex];
            [self.groupCollectView reloadData];
        }
        else if (alertView.tag == 0x600)
        {
            [[AppDelegate sharedInstance].arrShareFriends removeObjectAtIndex:iCurrentIndex];
            [self.peopleCollectView reloadData];
        }
        else if (alertView.tag == 0x700)
        {
            [[AppDelegate sharedInstance].arrShareAlbums removeObjectAtIndex:iCurrentIndex];
            [self.covAlbums reloadData];
        }
        return;
    }

    if (alertView.tag == 0x10000)
    {
        if (buttonIndex == 1)
            return;
        
        [self sharePhoto];
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

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     
     if([[segue identifier] isEqualToString:@"goShareSelectPeople"])
     {
         SelectGroupFriendViewController *viewController = (SelectGroupFriendViewController*)[segue destinationViewController];
         viewController.arrSelectedFriends = [AppDelegate sharedInstance].arrShareFriends;
         viewController.bPermissionMode = YES;
     }
     else if([[segue identifier] isEqualToString:@"goShareSelectGroup"])
     {
         ShareSelectGroupViewController *viewController = (ShareSelectGroupViewController*)[segue destinationViewController];
         viewController.arrSelectedGroups = [AppDelegate sharedInstance].arrShareGroups;
     }
     else if ([[segue identifier] isEqualToString:@"gotoSelectAlbum"])
     {
         ShareSelectAlbumViewController *viewController = (ShareSelectAlbumViewController*)[segue destinationViewController];
         viewController.arrSelectedAlbums = [AppDelegate sharedInstance].arrShareAlbums;
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
}


@end
