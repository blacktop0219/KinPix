//
//  EditGroupViewController.m
//  Zinger
//
//  Created by QingHou on 11/13/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "SelectGroupFriendViewController.h"
#import "FriendsViewCell.h"

@interface SelectGroupFriendViewController ()
{
    NSMutableArray *arrCurrent;
    NSMutableArray *temArray;
    int curCharIndex;
}
@end

@implementation SelectGroupFriendViewController

@synthesize arrSelectedFriends;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    curCharIndex = 27;
    temArray = [[NSMutableArray alloc] init];
    arrCurrent = [[NSMutableArray alloc] init];
    
    if (self.bPermissionMode)
        self.lblTitle.text = @"Select People";
    else
        self.lblTitle.text = @"Add Users to Circle";
    
    [self hideButtons];
    [Utils copyArray:arrSelectedFriends desarray:arrCurrent];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sortArray];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void) refreshData
{
    [self sortArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sortArray
{
    [temArray removeAllObjects];
    AppDelegate *delegate = [AppDelegate sharedInstance];
    
    if([self.searchTf.text length] == 0)
    {
        temArray = [[NSMutableArray alloc] initWithArray:delegate.arrFriends];
    }
    else
    {
        for(FriendInfoStruct *info in delegate.arrFriends)
        {
            NSString *name = [[info getUserName] uppercaseString];
            NSRange range = [name rangeOfString:[self.searchTf.text uppercaseString]];
            if(range.location != NSNotFound && range.location == 0)
                [temArray addObject:info];
        }
    }
    
    [self.collectionView reloadData];
}

- (IBAction)onSearch:(id)sender {
    
    [self sortArray];
    
    [self.searchTf resignFirstResponder];
}

- (IBAction)onMainBtn:(UIButton *)sender
{
    FriendInfoStruct *info = [temArray objectAtIndex:sender.tag];
    if([self isSelectedUser:info])
    {
        for (FriendInfoStruct *tmp in arrCurrent)
        {
            if ([tmp getUserID] == [info getUserID])
            {
                [arrCurrent removeObject:tmp];
                break;
            }
        }
        [arrCurrent removeObject:info];
    }
    else
        [arrCurrent addObject:info];
    
    [self.collectionView reloadData];
}

- (IBAction)processDoneAction:(id)sender
{
    [Utils copyArray:arrCurrent desarray:arrSelectedFriends];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return [temArray count];
}

- (BOOL) isSelectedUser:(FriendInfoStruct *)info
{
    for (FriendInfoStruct *item in arrCurrent)
    {
        if ([item getUserID] == [info getUserID])
            return YES;
    }
        
    return NO;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"friendsCollectionCell" forIndexPath:indexPath];
    
    cell.mainBtn.tag = indexPath.row;
    
    FriendInfoStruct *info = [temArray objectAtIndex:(indexPath.row )];
    cell.nameLbl.text = [info getUserName];
    [cell.photoView sd_setImageWithURL:[info getPhotoURL] placeholderImage:[Utils getDefaultProfileImage]];
    cell.mainBtn.selected = [self isSelectedUser:info];
    return cell;
}


- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)onTouch:(id)sender{
    
    [self.searchTf resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouch:nil];
}

@end
