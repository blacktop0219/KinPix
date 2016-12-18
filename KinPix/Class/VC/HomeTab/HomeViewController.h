//
//  HomeViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullToRefreshView.h"
#import "IntroView.h"
#import "IBActionSheet.h"

#define  i_LatestPhotoView  10000
#define  i_MyPhotoView      100000

@interface HomeViewController : TabParentViewController<PullToRefreshViewDelegate, IBActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblFeed;
@property (strong, nonatomic) IBOutlet IntroView *viewIntro;


- (IBAction)processUserSelect:(id)sender;
- (IBAction)processSort:(id)sender;
- (void)processGroupFilter:(NSMutableArray *)groups;
- (IBAction)processNewFriendsReq:(id)sender;
- (IBAction)processCloseHint:(id)sender;
- (IBAction)processSeeMore:(id)sender;

@end
