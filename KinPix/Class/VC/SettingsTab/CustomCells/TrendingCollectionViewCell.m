//
//  TrendingCollectionViewCell.m
//  Zinger
//
//  Created by Piao Dev on 17/01/15.
//  Copyright (c) 2015 Piao Dev. All rights reserved.
//

#import "TrendingCollectionViewCell.h"

@implementation TrendingCollectionViewCell

- (void)awakeFromNib
{
    [self processImage:self.ivPhoto];
}

-(void) processImage:(UIImageView *)feedimage
{
    feedimage.contentMode = UIViewContentModeScaleAspectFill;
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:feedimage.bounds byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(4.0, 4.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    feedimage.layer.mask = maskLayer;
    
    feedimage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    feedimage.layer.borderWidth = 0.4f;
}

@end
