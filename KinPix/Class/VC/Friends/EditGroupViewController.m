//
//  EditGroupViewController.m
//  Zinger
//
//  Created by QingHou on 11/13/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "EditGroupViewController.h"
#import "FriendsViewCell.h"
#import "SelectGroupFriendViewController.h"

@interface EditGroupViewController ()
{
    NSMutableArray *arrFriendList;
    NSInteger friendCount;
    NSInteger iCurrentIndex;
}
@end

@implementation EditGroupViewController

@synthesize objGroupInfo;
@synthesize arrSelectedGroups;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    friendCount = [[objGroupInfo getFriendIDs] count];
    
    if(self.type == 0)
        self.titleLbl.text = @"Create Circle";
    else
    {
        self.titleLbl.text = @"Edit Circle";
        self.groupNameTf.text = [self.objGroupInfo getGroupName];
    }
    
    arrFriendList = [[NSMutableArray alloc] init];
    for (NSString *strid in [objGroupInfo getFriendIDs])
        [Utils findAndAddFriendsInfo:arrFriendList friendid:[strid integerValue]];
    
    self.bChanged = NO;
}

- (BOOL) isChanged
{
    if (objGroupInfo)
    {
        if(![self.groupNameTf.text isEqualToString:[objGroupInfo getGroupName]])
            return YES;
        
        if (arrFriendList.count != [objGroupInfo getFriendIDs].count)
            return YES;
        
        for (NSString *strid in [objGroupInfo getFriendIDs])
        {
            BOOL bExist = NO;
            for (FriendInfoStruct *finfo in arrFriendList)
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
    }
    else
    {
        if ([self.groupNameTf.text length] > 0)
            return YES;
        
        if (arrFriendList.count > 0)
            return YES;
    }
    
    
    return NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) updateView
{
    int count = (int)[arrFriendList count];
    if(count < 2)
        self.memberLbl.text = [NSString stringWithFormat:@"%d Member", count];
    else
        self.memberLbl.text = [NSString stringWithFormat:@"%d Members", count];
    
    [self.collectionView reloadData];
    [self onTouch:nil];
}

- (IBAction)onShowFollow:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    FriendInfoStruct *info = [arrFriendList objectAtIndex:btn.tag - 1];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" from this circle?", [info getUserName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x600;
    iCurrentIndex = btn.tag - 1;
    [alertview show];
}

#pragma mark -
#pragma mark - UICollectionView Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrFriendList count] + 1;
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

        cell.actBtn.tag = indexPath.row;
        cell.btnMain.tag = indexPath.row;

        FriendInfoStruct *info = [arrFriendList objectAtIndex:indexPath.row - 1];
        cell.nameLbl.text = [info getUserName];
        [self setImage:cell.photoView obj:info cashOption:0];
        
        [self setLayerImage:cell.photoView];
    }
    
    return cell;
}

- (IBAction)onSave:(id)sender
{
    if (sender)
        [self refreshActionType];
    
    if([self.groupNameTf.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Input Circle Name" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    [self showHUD:@"Saving..."];
    [self.request clearDelegatesAndCancel];
    
    if(self.type == 0)
        self.request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_GROUP_CREATE] delegate:self];
    else
        self.request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_GROUP_UPDATE] delegate:self];
    
    [self.request setPostValue:self.groupNameTf.text forKey:@"groupname"];
    if(self.type == 1)
        [self.request setPostValue:[self.objGroupInfo getGrouIDToString] forKey:@"groupid"];
        
    NSString *guserids = nil;
    for(FriendInfoStruct *info in arrFriendList)
    {
        if(guserids == nil)
            guserids = [NSString stringWithFormat:@"%d", (int)[info getUserID]];
        else
            guserids = [guserids stringByAppendingFormat:@",%d", (int)[info getUserID]];
    }
    
    if(guserids != nil)
        [self.request setPostValue:guserids forKey:@"guserids"];
    [self.request startAsynchronous];
    self.bChanged = NO;
}

- (IBAction)onAdd:(id)sender
{
    [self performSegueWithIdentifier:@"gotoSelectFriends" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"gotoSelectFriends"])
    {
        SelectGroupFriendViewController *viewController = (SelectGroupFriendViewController*)[segue destinationViewController];
        viewController.arrSelectedFriends = arrFriendList;
    }
}

- (IBAction)onBack:(id)sender {

    if([self isChanged])
    {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you want to save your circle changes?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = 0x500;
        [alertview show];
        return;
    }
    
    [arrFriendList removeAllObjects];
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onEdit:(id)sender {
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideHUD];
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    
    NSLog(@"value = %@", json);
    
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    
    if(status == 200)
    {
        [[AppDelegate sharedInstance] refreshMyGroupInfos:[json objectForKey:@"grouplist"]];
        friendCount = (int)[arrFriendList count];

        if (arrSelectedGroups)
        {
            GroupInfoStruct *ginfo = [[AppDelegate sharedInstance] findGroupInfoByName:self.groupNameTf.text];
            if (ginfo)
                [arrSelectedGroups addObject:ginfo];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"The %@ circle has been saved", self.groupNameTf.text] delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            alertView.tag = 0x200;
            [alertView show];
        }
    }
}

#pragma makr -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (alertView.tag == 0x200)
    {
        if (![super completedAction:NO])
            [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (alertView.tag == 0x600)
    {
        if (buttonIndex == 1)
            return;
        
        self.bChanged = YES;
        [arrFriendList removeObjectAtIndex:iCurrentIndex];
        [self updateView];
        return;
    }
    
    if (alertView.tag == 0x500)
    {
        if (buttonIndex == 1)
        {
            [arrFriendList removeAllObjects];
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        [self onSave:self];
        return;
    }
}

#pragma mark -
#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 "] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
    if( [[string uppercaseString] isEqualToString:[filtered uppercaseString]])
    {
        self.bChanged = YES;
        
        NSString * newStr = [textField.text stringByReplacingCharactersInRange:range withString:string] ;

        if([newStr length] > 16)
            return NO;
        
        if([newStr length] >= 1)
        {
            NSString *firstStr = [[newStr substringToIndex:1] uppercaseString];
            
            NSString *otherStr = [newStr substringFromIndex:1];

            if([newStr length] == 1)
                newStr = firstStr;
            else
                newStr = [NSString stringWithFormat:@"%@%@", firstStr, otherStr];
            
            textField.text = newStr;

            
            return NO;
        }
        
        return YES;
    }

    return NO;
}


#pragma mark -
#pragma mark - UITouchEvent Delegate

- (IBAction)onTouch:(id)sender
{
    [self.groupNameTf resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouch:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
