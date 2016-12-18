//
//  CreateBucketViewController.h
//  Zinger
//
//  Created by Tianming on 09/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BucketInfoStruct.h"

@protocol UpdateBucketDelegate <NSObject>

-(void) updateBucket:(BucketInfoStruct *)info;

@end

@interface BucketEditViewController : TabParentViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtBucketName;
@property (weak, nonatomic) IBOutlet UICollectionView *covFriends;
@property (weak, nonatomic) IBOutlet UICollectionView *covGroups;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) id<UpdateBucketDelegate> delegate;

@property BucketInfoStruct *objInfo;
@property (weak, nonatomic) NSMutableArray *arrSelectedBucket;
@property BOOL bShareMode;

- (IBAction)processCreatBucket:(id)sender;
- (IBAction)processBackAction:(id)sender;

- (IBAction)processFriendOption:(id)sender;
- (IBAction)processGroupOption:(id)sender;

- (IBAction)processAddGroup:(id)sender;
- (IBAction)processAddFriend:(id)sender;
- (IBAction)processTabAction:(id)sender;

- (BOOL) isChanged;

@end
