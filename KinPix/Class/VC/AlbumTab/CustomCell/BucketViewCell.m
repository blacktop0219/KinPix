//
//  ShareAlbumViewCell.m
//  Zinger
//
//  Created by Tianming on 07/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "BucketViewCell.h"

@implementation BucketViewCell

- (void)awakeFromNib
{
    if (self.viewAdd)
    {
        [self.viewAdd removeFromSuperview];
        [self addSubview:self.viewAdd];
    }
    
    [AppDelegate processUserImage:self.ivProfile];
    [self.viewMain removeFromSuperview];
    [self addSubview:self.viewMain];
}


@end
