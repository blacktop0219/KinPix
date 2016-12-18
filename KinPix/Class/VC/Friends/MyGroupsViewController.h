//
//  MyGroupsViewController.h
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyGroupsViewController : TabParentViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property int curIndex;

- (IBAction)onMyFriends:(id)sender;
- (IBAction)onAddGroup:(id)sender;
- (IBAction)onAction:(id)sender;
- (IBAction)onCollectionCell:(id)sender;

@end
