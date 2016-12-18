//
//  GroupSelectionViewController.h
//  Zinger
//
//  Created by Tianming on 02/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HomeViewController.h"

@interface GroupSelectionViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tblGroup;
@property (strong, nonatomic) HomeViewController *controlView;

@property (weak, nonatomic) NSString *strGroupIds;
//@property (weak, nonatomic) NSString *strBucketIds;

- (IBAction)processCancelAction:(id)sender;
- (IBAction)processApplyAction:(id)sender;

@end
