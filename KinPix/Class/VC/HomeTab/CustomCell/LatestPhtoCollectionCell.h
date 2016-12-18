//
//  LatestPhtoCollectionCell.h
//  Zinger
//
//  Created by QingHou on 11/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LatestPhtoCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIView *viewBorder;
//@property (weak, nonatomic) IBOutlet UIImageView *ivDot;
@property (weak, nonatomic) IBOutlet UIButton *btnFavorite;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UILabel *lblNew;

@end
