//
//  ShareSelectAlbumViewController.h
//  Zinger
//
//  Created by Tianming on 07/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareSelectBucketViewController : TabParentViewController

@property (weak, nonatomic) IBOutlet UICollectionView *covBucket;

@property (weak, nonatomic) NSMutableArray *arrSelectedBucket;

- (IBAction)processBackAction:(id)sender;
- (IBAction)processSelectItem:(id)sender;
- (IBAction)processNewBucket:(id)sender;

- (IBAction)processCancel:(id)sender;
- (IBAction)processShare:(id)sender;
- (IBAction)processHeaderAction:(id)sender;

@end
