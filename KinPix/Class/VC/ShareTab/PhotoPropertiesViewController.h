//
//  SharePhotoViewController.h
//  Zinger
//
//  Created by QingHou on 11/14/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailView.h"

@interface PhotoPropertiesViewController : TabParentViewController<UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) PhotoInfoStruct *photoinfo;
@property (weak, nonatomic) DetailView *veiwDetail;
@property BOOL bModalView;

- (IBAction)onTouch:(id)sender;
- (IBAction)processBackAction:(id)sender;
- (IBAction)processSaveAction:(id)sender;

@end
