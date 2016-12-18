//
//  TrendingViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrendingViewController : TabParentViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblViewCount;
@property (weak, nonatomic) IBOutlet UILabel *lblViewType;
@property (weak, nonatomic) IBOutlet UICollectionView *covPhotos;

- (IBAction)processViewCount:(id)sender;
- (IBAction)processViewType:(id)sender;

- (IBAction)onBack:(id)sender;



@end
