//
//  HintTableViewCell.m
//  KinPix
//
//  Created by Piao Dev on 06/02/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "HintTableViewCell.h"

@implementation HintTableViewCell

- (void)awakeFromNib
{
    NSInteger radius = self.lblNewPhotoCount.frame.size.height / 2;
    [self.lblNewPhotoCount.layer setCornerRadius:radius];
    self.lblNewPhotoCount.layer.masksToBounds = YES;
    
    radius = 3;
    [self.lblNewPhotoIdentier.layer setCornerRadius:radius];
    self.lblNewPhotoIdentier.layer.masksToBounds = YES;
}

@end
