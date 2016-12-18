//
//  LogOutViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogOutViewController : TabParentViewController
@property (weak, nonatomic) IBOutlet UIView *coverView;

- (IBAction)onLogOut:(id)sender;

- (IBAction)onBack:(id)sender;

@end
