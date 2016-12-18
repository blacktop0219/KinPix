//
//  SharePhotoTableViewCell.m
//  Zinger
//
//  Created by QingHou on 12/1/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "SharePhotoTableViewCell.h"

@implementation SharePhotoTableViewCell

- (void)awakeFromNib
{
    [self.countView.layer setCornerRadius:10.0];
    [AppDelegate processUserImage:self.ivBucketProfile];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
