//
//  ParentViewController.h
//  Zinger
//
//  Created by QingHou on 10/26/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "NGTabBarController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequestDelegate.h"
#import "M13ProgressHUD.h"
#import "M13ProgressViewRing.h"

#define TYPE_GO_TABBAR      0x010000
#define TYPE_GO_FAVOUR      0x020000
#define TYPE_GO_MENU        0x040000

@interface ParentViewController : UIViewController<NGTabBarControllerDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    MBProgressHUD *HUD;
    M13ProgressHUD *m13_HUD;
}

- (void) showHUD :(NSString*)text;
- (void) showCustomeHUD :(NSString*)text view:(UIView *)view;
- (void) hideHUD;

- (void) showM13HUD:(NSString*)text;
- (void) completeM13HUD;
- (void) hideM13HUD;

- (void) goTabBarController;
- (void) goLegalView:(BOOL)b_shouldAccept :(BOOL)b_tabBased :(BOOL)privacyflag;
- (void) goToFriendsRequestPage;
- (void) goToFavoritePage;

-(BOOL) isRequireAlertDialog:(NSInteger)actiontype;
-(BOOL) isParentAlertView:(NSInteger)tag;

-(void) onSettings;
-(void) onFavorite;
-(void) gotoMenuPage;
-(void) showActionSheet;
-(BOOL) completedAction:(BOOL) bShowActionSheet;
-(void) refreshActionType;

- (void) setLayerImage:(UIImageView*)imgView;

@property (strong, nonatomic) ASIFormDataRequest * request;

@end
