//
//  SelectPinViewController.h
//  Zinger
//
//  Created by QingHou on 11/4/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectPinViewController : TabParentViewController<ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIButton *enterPinBtn;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@property int type;
@property (strong, nonatomic) NSString *contactStr;

- (IBAction)onLocalContacts:(id)sender;
- (IBAction)onBack:(id)sender;

@end
