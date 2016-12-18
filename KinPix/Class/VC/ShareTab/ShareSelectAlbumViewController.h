//
//  ShareSelectAlbumViewController.h
//  Zinger
//
//  Created by Tianming on 07/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareSelectAlbumViewController : TabParentViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) NSMutableArray *arrSelectedAlbums;

- (IBAction)onBack:(id)sender;
- (IBAction)onAlbum:(id)sender;

- (IBAction)processDoneAction:(id)sender;
- (IBAction)processAddAlbum:(id)sender;

@end
