//
//  ShareSelectGroupViewController.m
//  Zinger
//
//  Created by QingHou on 11/20/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "ShareSelectGroupViewController.h"
#import "EditGroupViewController.h"
#import "GroupViewCell.h"

@interface ShareSelectGroupViewController ()
{
    NSMutableArray *arrTempArray;
}
@end

@implementation ShareSelectGroupViewController

@synthesize arrSelectedGroups;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    arrTempArray = [[NSMutableArray alloc] init];
    for (GroupInfoStruct *info in arrSelectedGroups)
        [arrTempArray addObject:info];
}

-(void) viewWillAppear:(BOOL)animated
{
    [self.collectionView reloadData];
}

- (BOOL) isSelectedGroup:(GroupInfoStruct *)groupinfo
{
    for (GroupInfoStruct *info in arrTempArray)
    {
        if ([info getGroupID] == [groupinfo getGroupID])
            return YES;
    }

    return NO;
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
    cell.titleLbl.font = [UIFont fontWithName:@"Helvetica" size:11];
    
    if (indexPath.row == 0)
    {
        cell.addView.hidden = NO;
        cell.mainView.hidden = YES;
    }
    else
    {
        cell.clickBtn.tag = indexPath.row - 1;
        cell.addView.hidden = YES;
        cell.mainView.hidden = NO;
        GroupInfoStruct *info = [[AppDelegate sharedInstance].arrMyGroups objectAtIndex:(indexPath.row - 1)];
        if([self isSelectedGroup:info] == YES)
        {
            [cell.clickBtn setSelected:YES];
            cell.titleLbl.tintColor = [UIColor whiteColor];
        }
        else
        {
            [cell.clickBtn setSelected:NO];
            cell.titleLbl.tintColor = [UIColor darkGrayColor];
        }
        
        cell.titleLbl.text = [info getGroupNameToShow];
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onGroup:(id)sender {
    
    UIButton *btn = (UIButton*)sender;
    GroupInfoStruct *info = [[AppDelegate sharedInstance].arrMyGroups objectAtIndex:(btn.tag)];
    
    if([self isSelectedGroup:info] == YES)
    {
        for (GroupInfoStruct *ginfo in arrTempArray)
        {
            if ([ginfo getGroupID] == [info getGroupID])
            {
                [arrTempArray removeObject:ginfo];
                break;
            }
        }
    }
    else
        [arrTempArray addObject:info];

    [self.collectionView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"gotoGroupEdit"])
    {
        EditGroupViewController *VC = (EditGroupViewController*)[segue destinationViewController];
        VC.type = 0;
        VC.arrSelectedGroups = arrTempArray;
    }
}

- (IBAction)processDoneAction:(id)sender
{
    [arrSelectedGroups removeAllObjects];
    for (GroupInfoStruct *info in arrTempArray)
        [arrSelectedGroups addObject:info];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)processAddAction:(id)sender
{
    [self performSegueWithIdentifier:@"gotoGroupEdit" sender:nil];
}

@end
