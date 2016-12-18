//
//  ShareSelectGroupViewController.h
//  Zinger
//
//  Created by QingHou on 11/20/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareSelectGroupViewController : TabParentViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *arrSelectedGroups;

- (IBAction)onBack:(id)sender;
- (IBAction)onGroup:(id)sender;

- (IBAction)processDoneAction:(id)sender;
- (IBAction)processAddAction:(id)sender;

@end
