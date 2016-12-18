//
//  CreateBucketViewController.m
//  Zinger
//
//  Created by Tianming on 09/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "BucketEditViewController.h"
#import "FriendsViewCell.h"
#import "GroupViewCell.h"
#import "SelectGroupFriendViewController.h"
#import "ShareSelectGroupViewController.h"

@interface BucketEditViewController ()
{
    NSMutableArray *arrFriends;
    NSMutableArray *arrGroups;
    NSInteger iCurrentIndex;
}
@end

@implementation BucketEditViewController

@synthesize btnCreate;
@synthesize arrSelectedBucket;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrFriends = [[NSMutableArray alloc] init];
    arrGroups = [[NSMutableArray alloc] init];
    if (self.objInfo)
    {
        self.txtBucketName.text = [self.objInfo getBucketName];
        for (NSString *strid in [self.objInfo getBucketUserIDs])
        {
            if ([[AppDelegate sharedInstance].objUserInfo.strUserId isEqualToString:strid])
                continue;
            
            [Utils findAndAddFriendsInfo:arrFriends friendid:[strid integerValue]];
        }
        
        for (NSString *strid in [self.objInfo getBucketGroupIDs])
            [Utils findAndAddGroupInfo:arrGroups groupid:[strid integerValue]];
        
        if (!self.bShareMode)
            [btnCreate setImage:[UIImage imageNamed:@"saveBtn.png"] forState:UIControlStateNormal];

        self.lblTitle.text = @"Group Album Properties";
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.covFriends reloadData];
    [self.covGroups reloadData];
}

- (BOOL) isChanged
{
    if (self.objInfo)
    {
        if (![[self.objInfo getBucketName] isEqualToString:self.txtBucketName.text])
            return YES;
        
        NSInteger nFCount = 0;
        for (NSString *strid in [self.objInfo getBucketUserIDs])
        {
            if ([[AppDelegate sharedInstance].objUserInfo.strUserId isEqualToString:strid])
                continue;
            
            nFCount ++;
            BOOL bExist = NO;
            for (FriendInfoStruct *finfo in arrFriends)
            {
                if ([[finfo getUserIDToString] isEqualToString:strid])
                {
                    bExist = YES;
                    break;
                }
            }
            
            if (!bExist)
                return YES;
        }
        
        if (nFCount != [arrFriends count])
            return YES;
        
        for (NSString *strid in [self.objInfo getBucketGroupIDs])
        {
            BOOL bExist = NO;
            for (GroupInfoStruct *ginfo in arrGroups)
            {
                if ([[ginfo getGrouIDToString] isEqualToString:strid])
                {
                    bExist = YES;
                    break;
                }
            }
            
            if (!bExist)
                return YES;
        }
        
        if (arrGroups.count != [self.objInfo getBucketGroupIDs].count)
            return YES;
    }
    else
    {
        if (self.txtBucketName.text.length > 0 || arrFriends.count > 0 || arrGroups.count > 0)
            return YES;
    }
    
    return NO;
}
//-(void) createBucket
 
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(collectionView == self.covFriends)
        return [arrFriends count] + 1;
    
    return [arrGroups count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(collectionView == self.covFriends)
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
            
            FriendInfoStruct *info = [arrFriends objectAtIndex:(indexPath.row - 1)];
            cell.nameLbl.text = [info getUserName];
            [cell.photoView sd_setImageWithURL:[info getPhotoURL] placeholderImage:[Utils getDefaultProfileImage]];
            [self setLayerImage:cell.photoView];
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
            
            GroupInfoStruct *info = [arrGroups objectAtIndex:(indexPath.row - 1)];
            cell.titleLbl.text = [info getGroupNameToShow];
        }
        
        return cell;
    }
    
    return nil;
}

- (IBAction)processCreatBucket:(id)sender
{
    if (sender)
        [self refreshActionType];
    
    if ([self.txtBucketName.text length] < 1)
    {
        [AppDelegate showMessage:@"Please input group album name." withTitle:@"Error"];
        return;
    }
    
    [self showHUD:@"Saving.."];
    
    ASIFormDataRequest *request;
    if (self.objInfo)
    {
        request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_BUCKET_UPDATE] delegate:self];
        [request setPostValue:[self.objInfo getBucketIDToString] forKey:@"bucketid"];
        if (![self.txtBucketName.text isEqualToString:[self.objInfo getBucketName]])
            [request setPostValue:self.txtBucketName.text forKey:@"name"];
    }
    else
    {
        request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_BUCKET_CREATE] delegate:self];
        [request setPostValue:self.txtBucketName.text forKey:@"name"];
    }
    
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

- (IBAction)processBackAction:(id)sender
{
    if ([self isChanged])
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you want to save your group album changes?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = TYPE_CHANGE_PERMISSION;
        [alertview show];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)processFriendOption:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag - 1;
    
    FriendInfoStruct *info = [arrFriends objectAtIndex:iCurrentIndex];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" from this group album?", [info getUserName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x600;
    [alertview show];
}

- (IBAction)processGroupOption:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag;
    
    GroupInfoStruct *info = [arrGroups objectAtIndex:iCurrentIndex];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" from this group album?", [info getGroupName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x500;
    [alertview show];
}

- (IBAction)processAddGroup:(id)sender
{
    [self performSegueWithIdentifier:@"goShareSelectGroup" sender:nil];
}

- (IBAction)processAddFriend:(id)sender
{
    [self performSegueWithIdentifier:@"goShareSelectPeople" sender:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideHUD];
    NSLog(@"Share Result = %@", [request responseString]);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    if(status == 200)
    {
        [[AppDelegate sharedInstance] refreshBucketInfos:[json objectForKey:@"buckets"]];
        if (self.bShareMode)
        {
            BucketInfoStruct *info = [[AppDelegate sharedInstance] findBucketInfo:self.txtBucketName.text];
            if (info)
            {
                [arrSelectedBucket removeAllObjects];
                [arrSelectedBucket addObject:info];
            }
            [self processBackAction:nil];
        }
        else
        {
            NSString *strMsg;
            if (self.objInfo)
            {
                strMsg = [NSString stringWithFormat:@"%@ group album was saved", self.txtBucketName.text] ;
                [self.objInfo setBucketName:self.txtBucketName.text];
                if (_delegate)
                    [_delegate updateBucket:[[AppDelegate sharedInstance] findBucketInfo:self.txtBucketName.text]];
            }
            else
            {
                strMsg = [NSString stringWithFormat:@"%@ group album was created", self.txtBucketName.text];
            }
            
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Information" message:strMsg delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            alertview.tag = 200;
            [alertview show];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (alertView.tag == TYPE_CHANGE_PERMISSION)
    {
        if (buttonIndex == 1)
            [self.navigationController popViewControllerAnimated:YES];
        else
            [self processCreatBucket:self];
        return;
    }
    
    if(alertView.tag == 200)
    {
        if (![self completedAction:NO])
            [self.navigationController popViewControllerAnimated:YES];
    }
    else if (buttonIndex == 0)
    {
        if (alertView.tag == 0x600)
        {
            [arrFriends removeObjectAtIndex:iCurrentIndex];
            [self.covFriends reloadData];
        }
        else if (alertView.tag == 0x500)
        {
            [arrGroups removeObjectAtIndex:iCurrentIndex];
            [self.covGroups reloadData];
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"goShareSelectPeople"])
    {
        SelectGroupFriendViewController *viewController = (SelectGroupFriendViewController*)[segue destinationViewController];
        viewController.arrSelectedFriends = arrFriends;
        viewController.bPermissionMode = YES;
    }
    else if([[segue identifier] isEqualToString:@"goShareSelectGroup"])
    {
        ShareSelectGroupViewController *viewController = (ShareSelectGroupViewController *)[segue destinationViewController];
        viewController.arrSelectedGroups = arrGroups;
    }
}


- (IBAction)processTabAction:(id)sender
{
    [self.txtBucketName resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTabAction:nil];
}

@end
