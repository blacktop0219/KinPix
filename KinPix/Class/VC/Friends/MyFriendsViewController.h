//
//  MyFriendsViewController.h
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyFriendsViewController : TabParentViewController<UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UITextField *searchTf;
@property (strong, nonatomic)  IBOutlet UILabel *followLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray *temArray;

@property int curCharIndex;

- (IBAction)onSearch:(id)sender;
- (IBAction)onTouch:(id)sender;
- (IBAction)onShowFollow:(id)sender;
- (IBAction)onMyGroup:(id)sender;
- (IBAction)onFriendSelect:(id)sender;

@end
