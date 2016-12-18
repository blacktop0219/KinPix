//
//  FriendsViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddFriendsViewController : TabParentViewController<ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *contactsLbl;
@property (weak, nonatomic) IBOutlet UITextField *pinTf;
@property (weak, nonatomic) IBOutlet UITextField *emailTf;

@property(weak, nonatomic) UIView *activeTextView;

@property (strong, nonatomic) NSString *contactStr;

- (IBAction)onMyFriend:(id)sender;
- (IBAction)onMyGroups:(id)sender;
- (IBAction)onLocalContacts:(id)sender;
- (IBAction)onSendRequest:(id)sender;
- (IBAction)onBack:(id)sender;
- (IBAction)onTouch:(id)sender;




@end
