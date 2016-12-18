//
//  LeftViewController.h
//  Pineapple
//
//  Created by QingHou on 7/2/14.
//  Copyright (c) 2014 QingHou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsViewController : TabParentViewController

@property (weak, nonatomic) IBOutlet UITableView *m_tableView;

- (IBAction)processBack:(id)sender;

@end
