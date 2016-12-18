//
//  LikerViewController.h
//  Zinger
//
//  Created by Piao Dev on 20/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshView.h"

@interface LikerViewController : TabParentViewController<UIAlertViewDelegate, PullToRefreshViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblLikers;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblNoResult;

@property NSInteger iLikeCount;
@property NSInteger iPhotoID;

-(IBAction)processBackAction:(id)sender;

@end
