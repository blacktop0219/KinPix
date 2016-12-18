//
//  SharePhotoViewController.h
//  Zinger
//
//  Created by QingHou on 11/14/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharePhotoViewController : TabParentViewController<UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property int curIndex;

- (IBAction)onAddPhoto:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onTouch:(id)sender;
- (IBAction)onGoSharePhoto:(id)sender;

//TableVeiwCell
- (IBAction)onShowRemove:(id)sender;
- (IBAction)processPhotoEdit:(id)sender;
- (IBAction)processCancelAction:(id)sender;


@end
