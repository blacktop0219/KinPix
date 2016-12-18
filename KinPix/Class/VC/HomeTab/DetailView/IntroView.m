//
//  IntroView.m
//  KinPix
//
//  Created by Piao Dev on 25/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "IntroView.h"

@implementation IntroView

- (void) awakeFromNib
{
    CGRect rect = self.scMain.frame;
    self.scMain.contentSize = CGSizeMake(rect.size.width * 3, rect.size.height);
    self.pageMain.pageIndicatorTintColor = [UIColor colorWithRed:143.0 / 255.0 green:223.0 / 255.0 blue:255.0 / 255.0 alpha:1.0];
    self.pageMain.currentPageIndicatorTintColor = mainColor;
    
    [self.viewInside.layer setCornerRadius:7.0];
    self.viewInside.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.viewInside.layer.borderWidth = 0.4f;
    
    rect = self.viewInside.frame;
    rect.origin.y = ([[UIScreen mainScreen] bounds].size.height - rect.size.height) / 2;
    self.viewInside.frame = rect;
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.btnNext.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(7.0, 7.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    self.btnNext.layer.mask = maskLayer;
    
    self.btnNext.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.btnNext.layer.borderWidth = 0.4f;
}

- (IBAction)processNext:(id)sender
{
    if (self.scMain.contentOffset.x > 500)
        [self closeScreen];
    else
        [self gotoNextPage];
}

- (IBAction)processClose:(id)sender
{
    [self closeScreen];
}

- (IBAction)processPageChanged:(id)sender
{
    NSInteger iCurrent = self.pageMain.currentPage;
    iCurrent ++;
    iCurrent = iCurrent % 3;
    
    CGRect rect = self.scMain.frame;
    rect.origin.x = iCurrent * rect.size.width;
    [self.scMain scrollRectToVisible:rect animated:YES];
}

- (IBAction)processTabAction:(id)sender
{
    CGPoint tapPoint = [sender locationInView:self];
    CGRect rect = self.viewInside.frame;
    if (tapPoint.x > rect.origin.x && tapPoint.x < (rect.origin.x + rect.size.width)
        && tapPoint.y > rect.origin.y && tapPoint.y < (rect.origin.y + rect.size.height))
        return;
    
    [self closeScreen];
}

-(void) gotoNextPage
{
    CGPoint point = self.scMain.contentOffset;
    point.x += self.scMain.frame.size.width;
    CGRect rect = self.scMain.frame;
    rect.origin.x = point.x;
    [self.scMain scrollRectToVisible:rect animated:YES];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger idx = self.scMain.contentOffset.x / self.scMain.frame.size.width;
    if (idx == 2)
        [self.btnNext setTitle:@"Get Started" forState:UIControlStateNormal];
    else
        [self.btnNext setTitle:@"Next" forState:UIControlStateNormal];
    self.pageMain.currentPage = idx;
}

-(void) closeScreen
{
    [UIView transitionWithView:self
                      duration:0.5
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        self.alpha = 0;
                    }
                    completion:^(BOOL finished) {
                        [self removeFromSuperview];
                    }];
}

@end
