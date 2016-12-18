//
//  LikeUserViewCell.m
//  Zinger
//
//  Created by Piao Dev on 20/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "LikeUserViewCell.h"

@implementation LikeUserViewCell

- (void)awakeFromNib
{
    [AppDelegate processUserImage:self.ivUser];
    // Initialization code
}

-(void) initWithLikeData:(LikerInfoStruct *)info
{
    self.lblTime.text = [info getTimeString];
    self.lblUsername.text = [info getUserName];
    [self.ivUser sd_setImageWithURL:[info getPhotoURL] placeholderImage:[Utils getDefaultProfileImage]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
