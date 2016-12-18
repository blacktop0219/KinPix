//
//  IntroView.h
//  KinPix
//
//  Created by Piao Dev on 25/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroView : UIView <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scMain;
@property (weak, nonatomic) IBOutlet UIPageControl *pageMain;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (weak, nonatomic) IBOutlet UIView *viewInside;

- (IBAction)processNext:(id)sender;
- (IBAction)processClose:(id)sender;
- (IBAction)processPageChanged:(id)sender;

- (IBAction)processTabAction:(id)sender;

@end
