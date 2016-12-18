//
//  HintTableViewCell.h
//  KinPix
//
//  Created by Piao Dev on 06/02/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HintTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *viewBackground;
@property (weak, nonatomic) IBOutlet UILabel *lblNewPhotoCount;
@property (weak, nonatomic) IBOutlet UILabel *lblNewPhotoIdentier;
@property (weak, nonatomic) IBOutlet UIView *viewMidSeperate;
@property (weak, nonatomic) IBOutlet UIButton *btnHide;
@property (weak, nonatomic) IBOutlet UIView *viewWhite;


@end
