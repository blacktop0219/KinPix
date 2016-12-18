//
//  AlbumEditViewController.h
//  Zinger
//
//  Created by Tianming on 22/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlbumInfoStruct.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "CreateAlbumViewController.h"
#import "BucketEditViewController.h"
#import "PhotoFilterCollectionViewCell.h"
#import "PullToRefreshView.h"

@interface AlbumEditViewController : TabParentViewController<UIAlertViewDelegate, CHTCollectionViewDelegateWaterfallLayout,
            UITextFieldDelegate, UpdateAlbumDelegate, UpdateBucketDelegate, PhotoActionDelegate,
            UIScrollViewDelegate, PullToRefreshViewDelegate>

@property BOOL bBucketMode; // IF NO, then it's create mode
@property (nonatomic, strong) AlbumInfoStruct *objAlbum;
@property (nonatomic, strong) BucketInfoStruct *objBucket;

@property (weak, nonatomic) IBOutlet UILabel *lblProperties;
@property (weak, nonatomic) IBOutlet UIButton *btnProperties;
@property (weak, nonatomic) IBOutlet UILabel *lblAddPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;

@property (weak, nonatomic) IBOutlet UILabel *lblAlbumTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBucketTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;
@property (weak, nonatomic) IBOutlet UILabel *lblAlbum;
@property (weak, nonatomic) IBOutlet UILabel *lblBucket;



@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIImageView *ivUserImage;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *covPhoto;


@property (nonatomic) NSInteger iInitUserID;

- (IBAction)processPropertiesAction:(id)sender;
- (IBAction)processAddAction:(id)sender;

- (IBAction)processFilterAlbum:(id)sender;
- (IBAction)processFilterBucket:(id)sender;
- (IBAction)processSearchAction:(id)sender;
- (IBAction)processSelectUser:(id)sender;
- (IBAction)proecssRefreshHeader:(id)sender;


- (IBAction)processPhotoSelect:(id)sender;
- (IBAction)processBack:(id)sender;

@end
