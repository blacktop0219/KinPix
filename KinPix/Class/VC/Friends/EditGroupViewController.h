//
//  EditGroupViewController.h
//  Zinger
//
//  Created by QingHou on 11/13/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupInfoStruct.h"

@interface EditGroupViewController : TabParentViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTf;
@property (weak, nonatomic) IBOutlet UILabel *memberLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property int type; //0 : Create  1 : Edit Group
@property BOOL bChanged;

@property GroupInfoStruct *objGroupInfo;
@property (weak, nonatomic) NSMutableArray *arrSelectedGroups;

- (IBAction)onSave:(id)sender;
- (IBAction)onAdd:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onEdit:(id)sender;

- (BOOL) isChanged;

@end
