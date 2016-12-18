//
//  MyGroupsViewController.m
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "MyGroupsViewController.h"
#import "GroupHeadCell.h"
#import "GroupViewCell.h"
#import "EditGroupViewController.h"
#import "FriendsViewCell.h"
#import "GroupInfoStruct.h"

@interface MyGroupsViewController ()
{
    NSInteger iCurrentIndex;
}
@end

@implementation MyGroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return [[AppDelegate sharedInstance].arrMyGroups count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
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
        cell.mainBtn.tag = indexPath.row ;
        GroupInfoStruct *info = [[AppDelegate sharedInstance].arrMyGroups objectAtIndex:(indexPath.row - 1)];
        cell.titleLbl.text = [info getGroupNameToShow];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        GroupHeadCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GroupHeadCell" forIndexPath:indexPath];
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d", (int)indexPath.row);
}

- (IBAction)onMyFriends:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)onAddGroup:(id)sender {
    
    if([[AppDelegate sharedInstance].arrMyGroups count] == 50)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You have reached the maximum number of circles.  Please contact support@kinpix.co for assistance" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    [self performSegueWithIdentifier:@"addGroup" sender:nil];
}

- (IBAction)onAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag;
    GroupInfoStruct *info = [[AppDelegate sharedInstance].arrMyGroups objectAtIndex:iCurrentIndex];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" from your circle list?", [info getGroupName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x500;
    [alertview show];
}

#pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if([segue.identifier isEqualToString:@"addGroup"])
     {
         EditGroupViewController *VC = (EditGroupViewController*)[segue destinationViewController];
         VC.type = 0;
     }
     else if([segue.identifier isEqualToString:@"editGroup"])
     {
         EditGroupViewController *VC = (EditGroupViewController*)[segue destinationViewController];
         VC.type = 1;
         
         GroupInfoStruct *info = [[AppDelegate sharedInstance].arrMyGroups objectAtIndex:self.curIndex];
         VC.objGroupInfo = info;
     }
 }
 
#pragma mark -
#pragma mark - UITouchEvent Delegate

- (IBAction)onCollectionCell:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    
    if(btn.tag > 0)
    {
        self.curIndex = (int)btn.tag - 1;
        [self performSegueWithIdentifier:@"editGroup" sender:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if(buttonIndex == 0)
    {
        GroupInfoStruct *info = [[AppDelegate sharedInstance].arrMyGroups objectAtIndex:iCurrentIndex];
        NSString *groupID = [info getGrouIDToString];
        
        [self showHUD:@"Removing..."];
        
        [self.request clearDelegatesAndCancel];
        
        self.request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_GROUP_DELETE] delegate:self];
        [self.request setPostValue:groupID forKey:@"groupid"];
        [self.request startAsynchronous];
    }
}

-(void) requestFinished:(ASIHTTPRequest *)request
{
    [self hideHUD];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    NSLog(@"Result = %@", [request responseString]);
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    
    if (status == 200)
    {
        [[AppDelegate sharedInstance] refreshMyGroupInfos:[json objectForKey:@"grouplist"]];
        [self.collectionView reloadData];
    }
}

@end
