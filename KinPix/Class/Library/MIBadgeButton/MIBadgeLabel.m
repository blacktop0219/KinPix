//
//  MIBadgeLabel.m
//  Elmenus
//
//  Created by Mustafa Ibrahim on 2/3/14.
//  Copyright (c) 2014 Mustafa Ibrahim. All rights reserved.
//

#import "MIBadgeLabel.h"

@implementation MIBadgeLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:(UIRectCorner)UIRectCornerAllCorners cornerRadii:CGSizeMake(10.0f, 10.0f)];
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextSaveGState(ctx);
    {
        CGContextAddPath(ctx, borderPath.CGPath);
        
        CGContextSetLineWidth(ctx, 4.0f);
        CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
        
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    CGContextRestoreGState(ctx);
    
    CGContextSaveGState(ctx);
    {
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        
        CGRect textFrame = rect;
        CGSize textSize = [self.text sizeWithAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize:11.0f]}];
        
        textFrame.size.height = textSize.height;
        textFrame.origin.y = rect.origin.y + ceilf((rect.size.height - textFrame.size.height) / 2.0f);
        
#ifdef __IPHONE_7_0
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        [self.text drawInRect:textFrame withAttributes: @{NSFontAttributeName: [UIFont systemFontOfSize:11.0f],
                                                               NSParagraphStyleAttributeName: paragraphStyle }];
#else
        [self.text drawInRect:textFrame
                     withFont:[UIFont systemFontOfSize:11.0f]
                lineBreakMode:NSLineBreakByClipping
                    alignment:NSTextAlignmentCenter];
#endif
        
    }
    CGContextRestoreGState(ctx);

}


@end
