//
//  NewPhotoCell.m
//  Zinger
//
//  Created by QingHou on 11/9/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "NewPhotoCell.h"

@implementation NewPhotoCell

@synthesize ivPhoto;

- (void)awakeFromNib
{
    [AppDelegate processUserImage:ivPhoto];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
