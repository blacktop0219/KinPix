//
//  SharePeopleViewController.h
//  Zinger
//
//  Created by QingHou on 11/14/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface SharePeopleViewController : TabParentViewController<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *peopleCollectView;
@property (weak, nonatomic) IBOutlet UICollectionView *groupCollectView;
@property (weak, nonatomic) IBOutlet UICollectionView *covAlbums;
@property (weak, nonatomic) IBOutlet UIScrollView *scMain;

- (IBAction)onBack:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onShare:(id)sender;


//for Group
- (IBAction)onAddGroup:(id)sender;
- (IBAction)onGroupShowRemove:(id)sender;

//for People
- (IBAction)onPeoleShowRemove:(id)sender;

// for Album
- (IBAction)processAddAlbum:(id)sender;
- (IBAction)processAlbumOption:(id)sender;

@end
