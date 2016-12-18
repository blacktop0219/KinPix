//
//  LegalViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LegalViewController : TabParentViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *termsBtn;
@property (weak, nonatomic) IBOutlet UIButton *privacyBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;

@property int type;
@property BOOL b_shouldAccept;
@property BOOL b_tabBased;
@property BOOL bShowPrivacy;
@property (strong,nonatomic) NSString *termsContent;
@property (strong,nonatomic) NSString *privacyContent;

- (IBAction)onBack:(id)sender;
- (IBAction)onTerms:(id)sender;
- (IBAction)onPrivacy:(id)sender;
- (IBAction)onAccept:(id)sender;

@end
