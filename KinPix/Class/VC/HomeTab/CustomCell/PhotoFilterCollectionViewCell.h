//
//  PhotoFilterCollectionViewCell.h
//  Zinger
//
//  Created by Tianming on 27/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoActionDelegate.h"

@interface PhotoFilterCollectionViewCell : UICollectionViewCell<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *ivPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTag;
@property (weak, nonatomic) IBOutlet UILabel *lblNew;
@property (weak, nonatomic) IBOutlet UILabel *lblTagTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnPermission;

@property (weak, nonatomic) IBOutlet UIButton *btnFavorite;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UIButton *btnFlag;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeUser;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeCount;

@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UIView *viewTag;
@property (weak, nonatomic) IBOutlet UIView *viewButton;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIView *viewTime;

@property (weak, nonatomic) id<PhotoActionDelegate>delegate;

-(void) initWithPhotoInfo:(PhotoInfoStruct *)pinfo index:(NSInteger)index;

+(NSInteger) getItemHeight:(PhotoInfoStruct *)pinfo;

- (IBAction)processFavoriteAction:(id)sender;
- (IBAction)processCommentAction:(id)sender;
- (IBAction)processLikeAction:(id)sender;
- (IBAction)processMoreAction:(id)sender;
- (IBAction)processFlagAction:(id)sender;
- (IBAction)processLikeViewAction:(id)sender;
- (IBAction)processPermissionViewAction:(id)sender;

@end
