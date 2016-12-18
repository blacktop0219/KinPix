//
//  SettingsViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface HtmlViewController : TabParentViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *versionLbl;

@property int type;

- (IBAction)onBack:(id)sender;

@end
