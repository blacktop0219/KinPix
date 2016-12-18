//
//  MyFriendsViewController.m
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "MyFriendsViewController.h"
#import "FriendsHeadCell.h"
#import "FriendsViewCell.h"
#import "SDImageCache.h"
#import "AlbumEditViewController.h"

@interface MyFriendsViewController ()
{
    NSInteger iCurrentIndex;
}
@end

@implementation MyFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.curCharIndex = 27;
    self.temArray = [[NSMutableArray alloc] init];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getFriendRequest];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) refreshData
{
    [self sortArray];
    [self refreshUserLabel];
}

- (void) getFriendRequest
{
    [self.request clearDelegatesAndCancel];
    
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getFriendsFunctionURL:FUNC_FRIEND_GET_LIST] tag:2000 delegate:self];
    [self.request startAsynchronous];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sortArray
{
    [self.temArray removeAllObjects];
    AppDelegate *delegate = [AppDelegate sharedInstance];

    if([self.searchTf.text length] == 0)
    {
        self.temArray = [[NSMutableArray alloc] initWithArray:delegate.arrFriends];
        [self.collectionView reloadData];
    }
    else
    {
        for(FriendInfoStruct *info in delegate.arrFriends)
        {
            NSString *name = [[info getUserName] uppercaseString];
            
            NSRange range = [name rangeOfString:[self.searchTf.text uppercaseString]];
            
            if(range.location != NSNotFound && range.location == 0)
                [self.temArray addObject:info];
        }
        
        [self.collectionView reloadData];
    }
}


- (IBAction)onSearch:(id)sender {
    
    [self sortArray];

    [self.searchTf resignFirstResponder];
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
    if(request.tag == 2000)
    {
        if(status == 200)
        {
            [[AppDelegate sharedInstance] refreshFriendsInfos:[json objectForKey:@"friends"]];
            [self sortArray];
        }
    }
    else if(request.tag == 2001)
    {
        
    }
    
    [self refreshUserLabel];
}

-(void) refreshUserLabel
{
    if([self.temArray count] > 1)
        self.followLbl.text = [NSString stringWithFormat:@"There are %d people in your list", (int)[self.temArray count]];
    else if (self.temArray.count < 1 && [AppDelegate sharedInstance].arrFriends.count < 1)
        self.followLbl.text = [NSString stringWithFormat:@"You have no one in your people list. Add someone today!"];
    else
        self.followLbl.text = [NSString stringWithFormat:@"There are %d person in your list", (int)[self.temArray count]];
}

#pragma mark -
#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return [self.temArray count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
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
        
        cell.btnMain.tag = indexPath.row;
        cell.actBtn.tag = indexPath.row;
        
        FriendInfoStruct *info = [self.temArray objectAtIndex:(indexPath.row - 1)];
        cell.nameLbl.text = [info getUserName];
        [cell.photoView sd_setImageWithURL:[info getPhotoURL] placeholderImage:[Utils getDefaultProfileImage]];
        
        [self setLayerImage:cell.photoView];
    }
    
    return cell;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (buttonIndex != 0)
        return;
    
    [self.request clearDelegatesAndCancel];
    
    FriendInfoStruct *info = [self.temArray objectAtIndex:iCurrentIndex];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getFriendsFunctionURL:FUNC_FRIEND_PROC_REQ] tag:2001 delegate:self];
    
    [self.request setPostValue:[info getUserIDToString] forKey:@"touserid"];
    
    [self.request setPostValue:@"3" forKey:@"status"];
    [self.request startAsynchronous];
    
    [[AppDelegate sharedInstance].arrFriends removeObject:info];
    [self.temArray removeObject:info];
    [self.collectionView reloadData];
}


- (IBAction)onShowFollow:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag - 1;
    FriendInfoStruct *info = [[AppDelegate sharedInstance].arrFriends objectAtIndex:iCurrentIndex];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" from your people list?", [info getUserName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x600;
    [alertview show];
}

- (IBAction)onMyGroup:(id)sender
{
    UIViewController *vc = [[AppDelegate sharedInstance] getUIViewController:@"myGroupView"];
    [self.navigationController pushViewController:vc animated:NO];
}

- (IBAction)onFriendSelect:(id)sender
{
    NSInteger idx = ((UIView *)sender).tag;
    if (idx < 1)
        return;
    
    FriendInfoStruct *info = [self.temArray objectAtIndex:idx - 1];
    
    AlbumEditViewController *controller = (AlbumEditViewController *)[[AppDelegate sharedInstance] getUIViewController:@"groupEditVC"];
    controller.iInitUserID = [info getUserID];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sortArray];
    
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * newStr = [textField.text stringByReplacingCharactersInRange:range withString:string] ;
    
    textField.text = newStr;
    
    [self refreshData];
    
    return NO;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text = @"";
    
    [self refreshData];
    return YES;
}


#pragma mark -
#pragma mark - UITouchEvent Delegate

- (IBAction)onTouch:(id)sender
{
    [self.searchTf resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouch:nil];
}
@end
