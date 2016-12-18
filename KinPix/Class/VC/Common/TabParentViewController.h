//
//  TabParentViewController.h
//  Zinger
//
//  Created by QingHou on 11/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIBadgeButton.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import <AVFoundation/AVFoundation.h>

@interface TabParentViewController : ParentViewController

@property (strong, nonatomic) UIButton *btnFavorite;
@property (strong, nonatomic) UIButton *btnSettings;


- (void) hideButtons;
- (void) removeSettingTarget;

- (void) setImage:(UIImageView*)imgView obj:(NSObject *)obj;
- (void) setImage:(UIImageView*)imgView obj:(NSObject *)obj cashOption:(SDWebImageOptions)cashOption;
@end
