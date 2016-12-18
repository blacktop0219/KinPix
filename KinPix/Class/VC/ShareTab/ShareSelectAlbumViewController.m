//
//  ShareSelectAlbumViewController.m
//  Zinger
//
//  Created by Tianming on 07/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "ShareSelectAlbumViewController.h"
#import "CreateAlbumViewController.h"
#import "AlbumViewCell.h"

@interface ShareSelectAlbumViewController ()
{
    NSMutableArray *arrSelAlbums;
    NSMutableArray *arrAlbums;
}
@end

@implementation ShareSelectAlbumViewController
@synthesize arrSelectedAlbums;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    arrSelAlbums = [[NSMutableArray alloc] init];
    arrAlbums = [[NSMutableArray alloc] init];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [self refreshViewData];
}

-(void) refreshViewData
{
    [arrAlbums removeAllObjects];
    [Utils copyArray:arrSelectedAlbums desarray:arrSelAlbums];
    for (int i = 0; i < [AppDelegate sharedInstance].arrMyAlbums.count; i++)
    {
        AlbumInfoStruct *album = [[AppDelegate sharedInstance].arrMyAlbums objectAtIndex:i];
        if (![album canDelete])
        {
            if ([[album getAlbumName] isEqualToString:k_favoriteAlbum])
                continue;
        }
        
        [arrAlbums addObject:album];
    }
    [self.collectionView reloadData];
}

- (BOOL) checkSelection:(AlbumInfoStruct *)groupinfo
{
    for (AlbumInfoStruct *info in arrSelAlbums)
    {
        if ([info getAlbumID] == [groupinfo getAlbumID])
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
    return arrAlbums.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AlbumViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"shareAlbumViewCell" forIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        cell.viewAdd.hidden = NO;
        cell.viewAlbum.hidden = YES;
    }
    else
    {
        cell.viewAdd.hidden = YES;
        cell.viewAlbum.hidden = NO;
        cell.btnMain.tag = indexPath.row - 1;
        cell.lblName.font = [UIFont fontWithName:@"Helvetica" size:11];
        
        AlbumInfoStruct *info = [arrAlbums objectAtIndex:(indexPath.row - 1)];
        [cell.btnMain setSelected:[self checkSelection:info]];
        cell.lblName.text = [info getAlbumName];
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

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onAlbum:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    AlbumInfoStruct *info = [arrAlbums objectAtIndex:(btn.tag)];
    
    if([self checkSelection:info] == YES)
    {
        for (AlbumInfoStruct *ainfo in arrSelAlbums)
        {
            if ([ainfo getAlbumID] == [info getAlbumID])
            {
                [arrSelAlbums removeObject:ainfo];
                break;
            }
        }
    }
    else
        [arrSelAlbums addObject:info];
    
    [self.collectionView reloadData];
}

- (IBAction)processDoneAction:(id)sender
{
    if ([arrSelAlbums count] < 1)
    {
        [AppDelegate showMessage:@"Please select a album." withTitle:@"Warning"];
        return;
    }
    
    [Utils copyArray:arrSelAlbums desarray:arrSelectedAlbums];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)processAddAlbum:(id)sender
{
    [self performSegueWithIdentifier:@"gotoCreateAlbum" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"gotoCreateAlbum"])
    {
        CreateAlbumViewController * viewController = (CreateAlbumViewController*)[segue destinationViewController];
        viewController.arrAlbumArray = arrSelectedAlbums;
        viewController.bShareMode = YES;
    }
}

@end
