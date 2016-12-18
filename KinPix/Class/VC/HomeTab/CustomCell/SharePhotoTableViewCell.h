//
//  SharePhotoTableViewCell.h
//  Zinger
//
//  Created by QingHou on 12/1/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharePhotoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *countView;
@property (weak, nonatomic) IBOutlet UILabel *countLbl;
@property (weak, nonatomic) IBOutlet UIButton *btnUser;
@property (weak, nonatomic) IBOutlet UILabel *lblNoPhoto;

// for bucket
@property (weak, nonatomic) IBOutlet UILabel *lblBucketName;
@property (weak, nonatomic) IBOutlet UIImageView *ivBucketProfile;

@end
