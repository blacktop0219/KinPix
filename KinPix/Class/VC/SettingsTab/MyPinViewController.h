//
//  MyPinViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPinViewController : TabParentViewController
@property (weak, nonatomic) IBOutlet UILabel *pinLbl;
@property (weak, nonatomic) IBOutlet UIView *coverView;

- (IBAction)sendEmail:(id)sender;
- (IBAction)sendSMS:(id)sender;
- (IBAction)copyClipboard:(id)sender;

- (IBAction)onBack:(id)sender;

@end
