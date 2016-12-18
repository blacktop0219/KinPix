//
//  NotificationViewController.m
//  Zinger
//
//  Created by QingHou on 11/8/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "NotificationViewController.h"
#import "FriendRequestCell.h"
#import "NewPhotoCell.h"
#import "PhotoDetailViewController.h"
#import "AlbumEditViewController.h"

@interface NotificationViewController ()
{
    NSMutableArray *arrFriendsRequest;
    NSMutableArray *arrFriendsHistory;
    NSMutableArray *arrPhotoHistory;
    NSMutableArray *arrUserInofs;
    NSInteger iCurrentIdx;
}
@end

@implementation NotificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.switchView removeFromSuperview];
    
    //[self.tableView setTableHeaderView:self.switchView];
    [self.headSwitch.layer setCornerRadius:15.0];
    self.typeSwitch.selectedSegmentIndex = 1;
    [self onTypeSwitch:nil];

    arrFriendsHistory = [[NSMutableArray alloc] init];
    arrFriendsRequest = [[NSMutableArray alloc] init];
    arrPhotoHistory = [[NSMutableArray alloc] init];
    arrUserInofs = [[NSMutableArray alloc] init];
    [self getFriendRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNotifications) name:@"UpdateNotificationList" object:nil];
}


-(void) refreshNotifications
{
    [self getFriendRequest];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshBadgeNumber];
    [self getFriendRequest];
}

-(void) refreshBadgeNumber
{
    AppDelegate *delegate = [AppDelegate sharedInstance];
    if (delegate.objUserInfo.bShowFriendNotif && delegate.iFriendNotifCount > 0)
        [self.friendReqBadgeBtn setBadgeString:[NSString stringWithFormat:@"%d", (int)delegate.iFriendNotifCount]];
    else
        [self.friendReqBadgeBtn setBadgeString:@""];
    
    if (delegate.objUserInfo.bShowPhotoNotif && delegate.iPhotoNotifCount > 0)
        [self.photoBadgeBtn setBadgeString:[NSString stringWithFormat:@"%d", (int)delegate.iPhotoNotifCount]];
    else
        [self.photoBadgeBtn setBadgeString:@""];
}

-(NSInteger) getFriendNotificationCount
{
    NSInteger count = [arrFriendsRequest count];
    for (EventNotificationStruct *info in arrFriendsHistory)
    {
        if (![info isReaded])
            count++;
    }
    
    return count;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) changeSwitch
{
    if(self.typeSwitch.selectedSegmentIndex == 0)
    {
        self.headLbl.text = @"People Notifications :";
        self.headSwitch.on = [AppDelegate sharedInstance].objUserInfo.bShowFriendNotif;
    }
    else
    {
        self.headLbl.text = @"Photo Notifications :";
        self.headSwitch.on = [AppDelegate sharedInstance].objUserInfo.bShowPhotoNotif;
    }
    
    [self.tableView reloadData];
}


-(NSInteger) getPhotoNotificationCount
{
    NSInteger count = 0;
    for (EventNotificationStruct *info in arrPhotoHistory)
    {
        if (![info isReaded])
            count ++;
    }
    
    return count;
}


- (void) getFriendRequest
{
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getFriendsFunctionURL:FUNC_FRIEND_GET_LIST] tag:TYPE_GET_FRIENDS delegate:self];
    [self.request startAsynchronous];
}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) processFriendRequest:(int)tag IgnoreRequest:(BOOL)bIgnore
{
    [self showHUD:@"Processing..."];
    [self.request clearDelegatesAndCancel];
    FriendsRequestStruct *info = [arrFriendsRequest objectAtIndex:tag];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getFriendsFunctionURL:FUNC_FRIEND_PROC_REQ] tag:TYPE_PROCESS_FRIEND_REQ delegate:self];
    [self.request setPostValue:[info getUserIDToString] forKey:@"touserid"];
    
    if(bIgnore == YES)
        [self.request setPostValue:@"2" forKey:@"status"];
    else
        [self.request setPostValue:@"1" forKey:@"status"];
    
    [self.request startAsynchronous];
}

- (IBAction)onAccept:(UIButton *)sender
{
    self.isAccepted = YES;
    self.curIndex = (int)sender.tag;
    [self processFriendRequest:(int)sender.tag IgnoreRequest:NO];
    
}

- (IBAction)onIgnore:(UIButton *)sender {

    self.isAccepted = NO;
    self.curIndex = (int)sender.tag;
    [self processFriendRequest:(int)sender.tag IgnoreRequest:YES];
}

- (IBAction)onClear:(id)sender {
    
    if(self.switchType == 0)
    {
        [self.request clearDelegatesAndCancel];
        
        self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_CLEAR_HISTORY] tag:TYPE_CLEAR_NOTIFICATION delegate:self];
        [self.request setPostValue:@"friend" forKey:@"type"];
        if([arrFriendsHistory count] > 0)
        {
            EventNotificationStruct *info = [arrFriendsHistory firstObject];
            [self.request setPostValue:[info getQueueID] forKey:@"queueid"];
        }
        
        [self.request startAsynchronous];
        [arrFriendsHistory removeAllObjects];
        [self.tableView reloadData];
    }
    else
    {
        [self.request clearDelegatesAndCancel];
        
        self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_CLEAR_HISTORY] tag:TYPE_CLEAR_NOTIFICATION delegate:self];
        [self.request setPostValue:@"photo" forKey:@"type"];
        if([arrPhotoHistory count] > 0)
        {
            EventNotificationStruct *info = [arrPhotoHistory firstObject];
            [self.request setPostValue:[info getQueueID] forKey:@"queueid"];
        }
        
        [self.request startAsynchronous];
        [arrPhotoHistory removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void) setNotificationState:(NSString *)type
{
    [self.request clearDelegatesAndCancel];
    
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_SET_NOTIFICATION] tag:TYPE_SET_NOTIFICATION_STATE delegate:self];
    if(self.headSwitch.isOn == YES)
        [self.request setPostValue:@"1" forKey:@"state"];
    else
        [self.request setPostValue:@"0" forKey:@"state"];
    [self.request setPostValue:type forKey:@"type"];
    [self.request startAsynchronous];
    
    [[AppDelegate sharedInstance] refreshNotificationState];
}

- (IBAction)onTypeSwitch:(id)sender
{
    self.switchType = (int)self.typeSwitch.selectedSegmentIndex;
    [self changeSwitch];
    [self.request clearDelegatesAndCancel];
    
    if (self.switchType == 0 && [arrFriendsHistory count] > 0)
    {
        EventNotificationStruct *info = [arrFriendsHistory objectAtIndex:0];
        self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_CHECKED_HISTORY] tag:TYPE_CHECKED_NOTIFICATOIN delegate:self];
        [self.request setPostValue:@"friend" forKey:@"type"];
        [self.request setPostValue:[info getQueueID] forKey:@"queueid"];
        [self.request startAsynchronous];
        
        for (EventNotificationStruct *info in arrFriendsHistory)
            [info setReaded:YES];
        [self refreshBadgeNumber];
        [self.tableView reloadData];
    }
}

- (IBAction)onNotificationSwitch:(id)sender {
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if(self.switchType == 0)
    {
        [AppDelegate sharedInstance].objUserInfo.bShowFriendNotif = self.headSwitch.isOn;
        [self setNotificationState:@"friend"];
    }
    else
    {
        [AppDelegate sharedInstance].objUserInfo.bShowPhotoNotif = self.headSwitch.isOn;
        [self setNotificationState:@"photo"];
    }
    
    [userDefaults synchronize];
}


#pragma mark -
#pragma mark - ASIHTTPRequest Delegate

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
    if (request.tag == TYPE_GET_PHOTOINFOS)
    {
        //EventNotificationStruct *einfo = [arrPhotoHistory objectAtIndex:iCurrentIdx];
        NSMutableArray *arrPhotoInfos = [[NSMutableArray alloc] init];
        NSDictionary *dict = [json objectForKey:@"phtoinfos"];
        NSMutableArray *arrComments = [[AppDelegate sharedInstance] getComments:[dict objectForKey:@"comments"]];
        [[AppDelegate sharedInstance] refreshPhotoInfo:[dict objectForKey:@"photoinfo"] comments:arrComments arrdes:arrPhotoInfos];
        if ([arrPhotoInfos count] < 1)
        {
            [AppDelegate showMessage:@"Can't load photo information." withTitle:@"Error"];
            return;
        }
        
        PhotoDetailViewController *controller = (PhotoDetailViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoDetailVC"];
        controller.arrViewPhotos = arrPhotoInfos;
        controller.iCurrentIdx = 0;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if(status == 200)
    {
        
        NSDictionary *dict = [json objectForKey:@"result"];
        [AppDelegate sharedInstance].iPhotoNotifCount = [[dict objectForKey:@"photonotification"] integerValue];
        [AppDelegate sharedInstance].iFriendNotifCount = [[dict objectForKey:@"friendnotification"] integerValue];
        [[AppDelegate sharedInstance] refreshNotificationState];
        [self refreshBadgeNumber];
        
        if(request.tag == TYPE_GET_FRIENDS || request.tag == TYPE_PROCESS_FRIEND_REQ)
        {
            [[AppDelegate sharedInstance] refreshOnlyFriendBucket:[json objectForKey:@"friendbucket"]];
            [self refreshFriendsRequest:[json objectForKey:@"request_friends"]];
            [self refreshUserInfos:[json objectForKey:@"userinfos"]];
            [[AppDelegate sharedInstance] refreshFriendsInfos:[json objectForKey:@"friends"]];
            [self refreshEventHistory:[json objectForKey:@"friendhistory"] photohistroy:[json objectForKey:@"photohistory"]];
            [self refreshBadgeNumber];
            [self.tableView reloadData];
        }
        else if(request.tag == TYPE_SET_NOTIFICATION_STATE)
        {
            
        }
        else if(request.tag == TYPE_CLEAR_NOTIFICATION)
        {
            
        }
        else if (request.tag == TYPE_CHECKED_NOTIFICATOIN)
        {
            
        }

    }
}

- (void) refreshUserInfos:(NSArray *) array
{
    if (arrUserInofs)
        [arrUserInofs removeAllObjects];
    else
        arrUserInofs = [NSMutableArray array];
    
    for (NSDictionary *dict in array)
    {
        FriendInfoStruct *info = [[FriendInfoStruct alloc] init];
        [info initWithJSonData:dict];
        [arrUserInofs addObject:info];
    }
}

- (void) refreshFriendsRequest:(NSArray *) array
{
    if (arrFriendsRequest)
        [arrFriendsRequest removeAllObjects];
    else
        arrFriendsRequest = [NSMutableArray array];
    
    for (NSDictionary *dict in array)
    {
        FriendsRequestStruct *info = [[FriendsRequestStruct alloc] init];
        [info initWithJSonData:dict];
        [arrFriendsRequest addObject:info];
    }
}

- (void) refreshEventHistory:(NSArray *) array photohistroy:(NSArray *)arrphistory
{
    if (arrFriendsHistory)
        [arrFriendsHistory removeAllObjects];
    else
        arrFriendsHistory = [NSMutableArray array];
    
    if (arrPhotoHistory)
        [arrPhotoHistory removeAllObjects];
    else
        arrPhotoHistory = [NSMutableArray array];
    
    for (NSDictionary *dict in array)
    {
        EventNotificationStruct *info = [[EventNotificationStruct alloc] init];
        [info initWithJSonData:dict];
        [arrFriendsHistory addObject:info];
    }
    
    for (NSDictionary *dict in arrphistory)
    {
        EventNotificationStruct *info = [[EventNotificationStruct alloc] init];
        [info initWithJSonData:dict];
        [arrPhotoHistory addObject:info];
    }
    
    [self refreshBadgeNumber];
}

-(FriendInfoStruct *) getUserInfo:(NSInteger) userid
{
    for (FriendInfoStruct *info in arrUserInofs)
    {
        if ([info getUserID] == userid)
            return info;
    }
    
    return nil;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.switchType == 0)
        return [arrFriendsRequest count] + [arrFriendsHistory count];
    
    return [arrPhotoHistory count];
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.switchType == 1)
        return 50;
    
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.switchType == 0)
    {
        static NSString *identifier = @"FriendRequestCell";
        FriendRequestCell   *cell = (FriendRequestCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if((indexPath.row + 1) <= [arrFriendsRequest count])
        {
            cell.historyLbl.hidden = YES;
            cell.dateLbl.hidden = YES;
            cell.requestView.hidden = NO;
            
            FriendsRequestStruct *info = [arrFriendsRequest objectAtIndex:indexPath.row];
            
            cell.nameLbl.text = [info getUserName];
            UIImage *placeImage = [Utils getDefaultProfileImage];
            [cell.photoView sd_setImageWithURL:[info getPhotoURL] placeholderImage:placeImage options:SDWebImageProgressiveDownload];
            cell.acceptBtn.tag = indexPath.row;
            cell.ignoreBtn.tag = indexPath.row;
        }
        else
        {
            cell.historyLbl.hidden = NO;
            cell.dateLbl.hidden = NO;
            cell.requestView.hidden = YES;
            
            EventNotificationStruct *info = [arrFriendsHistory objectAtIndex:(indexPath.row - [arrFriendsRequest count])];
            FriendInfoStruct *userinfo = [self getUserInfo:[info getUserID]];
            cell.historyLbl.text = [info getMessage:userinfo];
            cell.dateLbl.text = [Utils getHistoryDateStr:(int)[info getTimeSec]];
        }
        return cell;
    }
    else
    {
        static NSString *identifier = @"NewPhotoCell";
        
        NewPhotoCell   *cell = (NewPhotoCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        EventNotificationStruct *info = [arrPhotoHistory objectAtIndex:indexPath.row];
        FriendInfoStruct *userinfo = [self getUserInfo:[info getUserID]];
        
        UIImage *placeImage = [Utils getDefaultProfileImage];
        [cell.ivPhoto sd_setImageWithURL:[userinfo getPhotoURL] placeholderImage:placeImage options:SDWebImageProgressiveDownload];
        if ([info isReaded])
        {
            cell.lblMessage.textColor = [UIColor darkGrayColor];
            cell.lblTime.textColor = [UIColor darkGrayColor];
        }
        else
        {
            cell.lblMessage.textColor = mainFontColor;
            cell.lblTime.textColor = mainFontColor;
        }
        
        cell.lblMessage.text = [info getMessage:userinfo];
        cell.lblTime.text = [info getTimeToString];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(self.switchType == 1)
    {
        iCurrentIdx = indexPath.row;
        EventNotificationStruct *info = [arrPhotoHistory objectAtIndex:iCurrentIdx];
        if ([info isBucketViewNotification])
        {
            AlbumEditViewController *controllerAlbumEdit = (AlbumEditViewController *)[[AppDelegate sharedInstance] getUIViewController:@"groupEditVC"];
            controllerAlbumEdit.bBucketMode = YES;
            controllerAlbumEdit.objBucket = [[AppDelegate sharedInstance] findBucketInfoByID:[info getBucketID]];
            [self.navigationController pushViewController:controllerAlbumEdit animated:YES];
            [[AppDelegate sharedInstance] checkedNotification:[info getQueueID] type:@"photo"];
        }
        else
        {
            [self showHUD:@"Loading..."];
            ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_GET_PHOTOINFO] tag:TYPE_GET_PHOTOINFOS delegate:self];
            [request setPostValue:[info getPhotoIDsToString] forKey:@"photoids"];
            if (![info isReaded])
                [request setPostValue:[info getQueueID] forKey:@"queueid"];
            [request startAsynchronous];
        }
        
        if (![info isReaded])
        {
            [info setReaded:YES];
            NewPhotoCell   *cell = (NewPhotoCell*)[tableView cellForRowAtIndexPath:indexPath];
            cell.lblMessage.textColor = [UIColor darkGrayColor];
            cell.lblTime.textColor = [UIColor darkGrayColor];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
