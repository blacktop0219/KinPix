//
//  PhotoPreviewController.h
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTCollectionViewWaterfallLayout.h"
#import "PhotoActionDelegate.h"

@interface PhotoSearchViewController : TabParentViewController<UIAlertViewDelegate, CHTCollectionViewDelegateWaterfallLayout, PhotoActionDelegate>
{
}

@property (weak, nonatomic) IBOutlet UILabel *lblAlbum;
@property (weak, nonatomic) IBOutlet UILabel *lblBucket;
@property (weak, nonatomic) IBOutlet UILabel *lblDateShared;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiryDate;
@property (weak, nonatomic) IBOutlet UILabel *lblSharedWith;
@property (weak, nonatomic) IBOutlet UILabel *lblGroup;
@property (weak, nonatomic) IBOutlet UILabel *lblAlbumTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBucketTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblResult;

@property (weak, nonatomic) IBOutlet UITextField *txtSearch;
@property (weak, nonatomic) IBOutlet UIImageView *ivProfile;

@property (weak, nonatomic) IBOutlet UIView *viewGroup;
@property (weak, nonatomic) IBOutlet UIView *viewExpiryDate;
@property (weak, nonatomic) IBOutlet UICollectionView *covPhotos;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIView *viewSharedWidth;

@property NSInteger iCurrentUserID;
@property BOOL bShowSettingButton;
@property (weak, nonatomic) BucketInfoStruct *objStartBucket;

- (IBAction)processSearchAction:(id)sender;

- (IBAction)processChangeUser:(id)sender;
- (IBAction)processFilterDateShared:(id)sender;
- (IBAction)processFilterAlbum:(id)sender;
- (IBAction)processFilterBucket:(id)sender;
- (IBAction)processFilterExpireDate:(id)sender;
- (IBAction)processFilterSharedWith:(id)sender;
- (IBAction)processFilterGroup:(id)sender;
- (IBAction)processTabAction:(id)sender;

- (IBAction)processBack:(id)sender;

@end
