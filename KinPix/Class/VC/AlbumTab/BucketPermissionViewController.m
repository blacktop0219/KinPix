//
//  CreateBucketViewController.m
//  Zinger
//
//  Created by Tianming on 09/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "BucketPermissionViewController.h"
#import "FriendsViewCell.h"

@interface BucketPermissionViewController ()
{
    NSMutableArray *arrFriends;
    NSInteger iCurrentIndex;
}
@end

@implementation BucketPermissionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrFriends = [[NSMutableArray alloc] init];
    
    if (self.objInfo)
    {
        FriendInfoStruct *ownerinfo = [[AppDelegate sharedInstance] findBucketUserInfo:[self.objInfo getUserID]];
        if (ownerinfo)
            [arrFriends addObject:ownerinfo];
        for (NSString *strid in [self.objInfo getBucketUserIDs])
        {
            NSInteger userid = [strid integerValue];
            if ([ownerinfo getUserID] == userid)
                continue;
            
            FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findBucketUserInfo:userid];
            if (finfo)
                [arrFriends addObject:finfo];
        }
    }
}

//-(void) createBucket
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrFriends count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"friendsCollectionCell" forIndexPath:indexPath];
    cell.actBtn.hidden = YES;
    FriendInfoStruct *info = [arrFriends objectAtIndex:indexPath.row];
    cell.nameLbl.text = [info getUserName];
    [cell.photoView sd_setImageWithURL:[info getPhotoURL] placeholderImage:[Utils getDefaultProfileImage]];
    [self setLayerImage:cell.photoView];
    
    return cell;
}

- (IBAction)processBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
