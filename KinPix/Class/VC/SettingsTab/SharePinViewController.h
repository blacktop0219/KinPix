//
//  SharePinViewController.h
//  Zinger
//
//  Created by QingHou on 10/31/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharePinViewController : TabParentViewController

@property (weak, nonatomic) IBOutlet UITextField *emailTf;
@property (weak, nonatomic) IBOutlet UILabel *titleLbl;
@property (weak, nonatomic) IBOutlet UIView *coverView;

@property int type;
@property (strong, nonatomic) NSString *contactStr;


- (IBAction)onBack:(id)sender;
- (IBAction)onSend:(id)sender;

@end
