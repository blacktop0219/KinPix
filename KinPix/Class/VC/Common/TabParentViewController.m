//
//  TabParentViewController.m
//  Zinger
//
//  Created by QingHou on 11/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "TabParentViewController.h"
#import "NotificationViewController.h"
#import "SDImageCache.h"
//#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+WebCache.h"
#import "FriendInfoStruct.h"
#import "UserInfoStruct.h"

@interface TabParentViewController ()

@end

@implementation TabParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBadgeButton];
    // Do any additional setup after loading the view.
}



- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.request clearDelegatesAndCancel];
}

- (void) initBadgeButton
{
    self.btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(238, 38, 40, 30)];
    [self.btnFavorite setImage:[UIImage imageNamed:@"btn_top_favorite.png"] forState:UIControlStateNormal];
    [self.btnFavorite addTarget:self action:@selector(onFavorite) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnFavorite];
    
    self.btnSettings = [[UIButton  alloc] initWithFrame:CGRectMake(280, 38, 40, 30)];
    [self.btnSettings setImage:[UIImage imageNamed:@"btn_settings.png"] forState:UIControlStateNormal];
    [self.btnSettings addTarget:self action:@selector(onSettings) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSettings];
}

- (void) hideButtons
{
    [self.btnFavorite removeFromSuperview];
    [self.btnSettings removeFromSuperview];
}

- (void) removeSettingTarget
{
    [self.btnSettings removeTarget:self action:@selector(onSettings) forControlEvents:UIControlEventTouchUpInside];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void) setImage:(UIImageView*)imgView obj:(NSObject *)obj
{
    [self setImage:imgView obj:obj cashOption:0];
}

- (void) setImage:(UIImageView*)imgView obj:(NSObject *)obj cashOption:(SDWebImageOptions)cashOption
{
    UIImage *sexImage;
    NSString *strURL;
    if ([obj isKindOfClass:[FriendInfoStruct class]])
    {
        FriendInfoStruct *info = (FriendInfoStruct *)obj;
        strURL = [info getPhotoStringURL];
        sexImage = [Utils getDefaultProfileImage];
    }
    else
    {
        UserInfoStruct *info = (UserInfoStruct *)obj;
        sexImage = [Utils getDefaultProfileImage];
        strURL = info.strPhotoUrl;
    }
    
    [imgView sd_setImageWithURL:[NSURL URLWithString:strURL] placeholderImage:sexImage options:SDWebImageRefreshCached];
}

@end
