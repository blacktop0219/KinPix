//
//  GroupViewCell.h
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *viewAdd;

@property (weak, nonatomic) IBOutlet UIView *viewAlbum;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *btnPopover;
@property (weak, nonatomic) IBOutlet UIButton *btnMain;

@end
