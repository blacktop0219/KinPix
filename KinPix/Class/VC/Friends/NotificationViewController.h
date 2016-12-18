//
//  NotificationViewController.h
//  Zinger
//
//  Created by QingHou on 11/8/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationViewController : TabParentViewController

@property (weak, nonatomic) IBOutlet UIView *switchView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSwitch;

@property (weak, nonatomic) IBOutlet UILabel *headLbl;
@property (weak, nonatomic) IBOutlet UISwitch *headSwitch;
@property (weak, nonatomic) IBOutlet UIButton *headClearBtn;
@property (weak, nonatomic) IBOutlet MIBadgeButton *friendReqBadgeBtn;
@property (weak, nonatomic) IBOutlet MIBadgeButton *photoBadgeBtn;

@property int switchType;
@property int curIndex;
@property BOOL isAccepted;

- (IBAction)onBack:(id)sender;
- (IBAction)onAccept:(UIButton *)sender;
- (IBAction)onIgnore:(UIButton *)sender;
- (IBAction)onClear:(id)sender;

- (IBAction)onTypeSwitch:(id)sender;
- (IBAction)onNotificationSwitch:(id)sender;

@end
