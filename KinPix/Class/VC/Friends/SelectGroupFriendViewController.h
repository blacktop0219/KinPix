//
//  EditGroupViewController.h
//  Zinger
//
//  Created by QingHou on 11/13/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectGroupFriendViewController : TabParentViewController

@property (weak, nonatomic) IBOutlet UITextField *searchTf;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

// Changed Option
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property BOOL bPermissionMode; // No Group user
@property (weak, nonatomic) NSMutableArray *arrSelectedFriends;

- (IBAction)onSearch:(id)sender;
- (IBAction)onTouch:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onMainBtn:(UIButton *)sender;
- (IBAction)processDoneAction:(id)sender;

@end
