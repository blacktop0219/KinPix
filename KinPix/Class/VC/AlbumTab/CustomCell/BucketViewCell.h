//
//  ShareAlbumViewCell.h
//  Zinger
//
//  Created by Tianming on 07/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BucketViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIButton *btnBucket;
@property (weak, nonatomic) IBOutlet UIButton *btnOption;
@property (weak, nonatomic) IBOutlet UILabel *lblBucketName;
@property (weak, nonatomic) IBOutlet UIImageView *ivProfile;

@property (weak, nonatomic) IBOutlet UIView *viewAdd;

@end
