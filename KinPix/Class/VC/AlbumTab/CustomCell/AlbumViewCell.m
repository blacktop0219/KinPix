//
//  GroupViewCell.m
//  Zinger
//
//  Created by QingHou on 11/7/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "AlbumViewCell.h"

@implementation AlbumViewCell

- (void)awakeFromNib
{
    [self.viewAdd removeFromSuperview];
    [self addSubview:self.viewAdd];
    
    [self.viewAlbum removeFromSuperview];
    [self addSubview:self.viewAlbum];
}

@end
