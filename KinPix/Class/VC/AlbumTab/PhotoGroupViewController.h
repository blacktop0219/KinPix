//
//  AlbumSummaryViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoGroupViewController : TabParentViewController<UIAlertViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *covAlbum;
@property (weak, nonatomic) IBOutlet UICollectionView *covBucket;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segOption;
@property (weak, nonatomic) IBOutlet UIScrollView *scvView;

- (IBAction)processAddAction:(id)sender;
- (IBAction)processOptionAction:(id)sender;
- (IBAction) processSelectAction:(id)sender;

- (IBAction)switchViewOption:(id)sender;
- (IBAction)processHeaderAction:(id)sender;

@end
