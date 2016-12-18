//
//  ParentViewController.m
//  Zinger
//
//  Created by QingHou on 10/26/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "ParentViewController.h"
#import "NGTabBarController.h"
#import "LegalViewController.h"
#import "MyFriendsViewController.h"
#import "AlbumEditViewController.h"
#import "PhotoDetailViewController.h"
#import "ShareViewController.h"
#import "EditGroupViewController.h"

static NSInteger iLastActionType;

@implementation ParentViewController
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    [self initM13HUD];
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark - MBPRogressHUD Delegate

- (void) showHUD :(NSString*)text
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    
    HUD.delegate = nil;
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = text;
    [HUD show:YES];
}

- (void) showCustomeHUD :(NSString*)text view:(UIView *)view
{
    HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    
    HUD.delegate = nil;
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = text;
    [HUD show:YES];
}

- (void) hideHUD
{
    [HUD hide:YES];
}

- (void) initM13HUD
{
    m13_HUD = [[M13ProgressHUD alloc] initWithProgressView:[[M13ProgressViewRing alloc] init]];
    m13_HUD.progressViewSize = CGSizeMake(45.0, 45.0);
    m13_HUD.animationPoint = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, [UIScreen mainScreen].bounds.size.height / 2);
    [m13_HUD setMaskType:M13ProgressHUDMaskTypeNone];
    
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    [window addSubview:m13_HUD];
}

- (void) showM13HUD:(NSString*)text
{
    [m13_HUD setIndeterminate:YES];
    m13_HUD.status = text;
    [m13_HUD show:YES];
}

- (void) completeM13HUD
{
    [m13_HUD performAction:M13ProgressViewActionSuccess animated:YES];
}

- (void) hideM13HUD
{
    [m13_HUD hide:YES];
    [m13_HUD setIndeterminate:NO];

    [m13_HUD performAction:M13ProgressViewActionNone animated:NO];
}

-(void) goTabBarController
{
    UINavigationController *nav1 = (UINavigationController *)[[AppDelegate sharedInstance] getUIViewController:@"homeNav"];
    UINavigationController *nav2 = (UINavigationController *)[[AppDelegate sharedInstance] getUIViewController:@"friendsNav"];
    UINavigationController *nav3 = (UINavigationController *)[[AppDelegate sharedInstance] getUIViewController:@"shareNav"];
    UINavigationController *nav4 = (UINavigationController *)[[AppDelegate sharedInstance] getUIViewController:@"albumNav"];
    UINavigationController *nav5 = (UINavigationController *)[[AppDelegate sharedInstance] getUIViewController:@"notificationNav"];
    
    nav1.navigationBarHidden = YES;
    nav2.navigationBarHidden = YES;
    nav3.navigationBarHidden = YES;
    nav4.navigationBarHidden = YES;
    nav5.navigationBarHidden = YES;
    
    nav1.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"" image:[UIImage imageNamed:@"tab1"] selectedImage:[UIImage imageNamed:@"tab1_selected"]];
    nav2.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"" image:[UIImage imageNamed:@"tab2"] selectedImage:[UIImage imageNamed:@"tab2_selected"]];
    nav3.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"" image:[UIImage imageNamed:@"tab3"] selectedImage:[UIImage imageNamed:@"tab3_selected"]];
    nav4.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"" image:[UIImage imageNamed:@"tab4"] selectedImage:[UIImage imageNamed:@"tab4_selected"]];
    nav5.ng_tabBarItem = [NGTabBarItem itemWithTitle:@"" image:[UIImage imageNamed:@"tab5"] selectedImage:[UIImage imageNamed:@"tab5_selected"]];
    
    NSArray *viewController = [NSArray arrayWithObjects:nav1,nav2,nav3,nav4,nav5, nil];
    
    NGTabBarController *tabBarController = [[NGTabBarController alloc] initWithDelegate:self];
    [AppDelegate sharedInstance].tabBarController = tabBarController;
    [AppDelegate sharedInstance].tabNotificationItem = nav5.ng_tabBarItem;
    [AppDelegate sharedInstance].tabBarController = tabBarController;
    
    tabBarController.tabBarPosition = NGTabBarPositionBottom;
    tabBarController.viewControllers = viewController;
    
//    if ([[AppDelegate sharedInstance].objUserInfo isLogined] && [[AppDelegate sharedInstance].arrMyPhotos count] == 0 && [AppDelegate sharedInstance].arrFriendsPhotos.count == 0)
//        [tabBarController setSelectedViewController:nav3];
    
    [self.navigationController pushViewController:tabBarController animated:YES];
    [[AppDelegate sharedInstance] playAudio:s_Login];
}

- (void) goLegalView:(BOOL)b_shouldAccept :(BOOL)b_tabBased :(BOOL)privacyflag
{
    LegalViewController *vc = (LegalViewController *)[[AppDelegate sharedInstance] getUIViewController:@"legalView"];
    vc.b_shouldAccept = b_shouldAccept;
    vc.b_tabBased = b_tabBased;
    vc.bShowPrivacy = privacyflag;
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) goToFriendsRequestPage
{
    NGTabBarController *tabController = (NGTabBarController *)[AppDelegate sharedInstance].tabBarController;
    tabController.selectedIndex = 1;
    UINavigationController *navFriends = [tabController.viewControllers objectAtIndex:1];
    [navFriends popToRootViewControllerAnimated:NO];
    
    UIViewController *viewController = [[AppDelegate sharedInstance] getUIViewController:@"addFriendsViewController"];
    [navFriends pushViewController:viewController animated:NO];
}

-(void) goToFavoritePage
{
    NGTabBarController *tabController = (NGTabBarController *)[AppDelegate sharedInstance].tabBarController;
    tabController.selectedIndex = 3;
    UINavigationController *navPhotoGroup = [tabController.viewControllers objectAtIndex:3];
    [navPhotoGroup popToRootViewControllerAnimated:NO];
    
    AlbumEditViewController *viewController = (AlbumEditViewController *)[[AppDelegate sharedInstance] getUIViewController:@"groupEditVC"];
    viewController.objAlbum = [[AppDelegate sharedInstance] findAlbumInfo:k_favoriteAlbum];
    [navPhotoGroup pushViewController:viewController animated:NO];
}

////////////////////////////////////////////////////////////////////////
#pragma mark - NGTabBarControllerDelegate
////////////////////////////////////////////////////////////////////////

- (CGSize)tabBarController:(NGTabBarController *)tabBarController
sizeOfItemForViewController:(UIViewController *)viewController
                   atIndex:(NSUInteger)index
                  position:(NGTabBarPosition)position
{
    if (NGTabBarIsVertical(position))
        return CGSizeMake(150.f, 60.f);

    return CGSizeMake(64.f, 42.f);
}

- (BOOL)tabBarController:(NGTabBarController *)tabBarController
            shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index
{
    if ([AppDelegate sharedInstance].arrSharePhotos.count > 0)
    {
         UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel sharing a photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = 0x1025 | TYPE_GO_TABBAR;
        [alertview show];
        return NO;
    }
    
    if ([self isRequireAlertDialog:TYPE_GO_TABBAR])
        return NO;
    
    UINavigationController *nav = [[AppDelegate sharedInstance].tabBarController.viewControllers objectAtIndex:index];
    if (tabBarController.selectedIndex == index)
        [nav popToRootViewControllerAnimated:YES];
    else
        [nav popToRootViewControllerAnimated:NO];
    
    return YES;
}

-(BOOL) isRequireAlertDialog:(NSInteger)actiontype;
{
    UIViewController *controller = [self getCurrentActivedController:[AppDelegate sharedInstance].tabBarController.selectedIndex];
    if ([controller isKindOfClass:[PhotoDetailViewController class]])
    {
        PhotoDetailViewController *pdcontroller = (PhotoDetailViewController *)controller;
        if ([pdcontroller isChanged])
        {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to save your permission changes?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            alertview.tag = 0x1026 | actiontype;
            [alertview show];
            return YES;
        }
    }
    else if ([controller isKindOfClass:[BucketEditViewController class]])
    {
        BucketEditViewController *becontroller = (BucketEditViewController *)controller;
        if ([becontroller isChanged])
        {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you want to save your group album changes?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            alertview.tag = 0x1027 | actiontype;
            [alertview show];
            return YES;
        }
    }
    else if ([controller isKindOfClass:[EditGroupViewController class]])
    {
        EditGroupViewController *egcontroller = (EditGroupViewController *)controller;
        if ([egcontroller isChanged])
        {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Do you want to save your circle changes?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
            alertview.tag = 0x1028 | actiontype;
            [alertview show];
            return YES;
        }
    }
    
    return NO;
}

- (UIViewController *) getCurrentActivedController:(NSInteger) index
{
    NSArray *arrControllers = [AppDelegate sharedInstance].tabBarController.viewControllers;
    UINavigationController *nav = [arrControllers objectAtIndex:index];
    NSArray *arrSubControllers = nav.viewControllers;
    if ([arrSubControllers count] > 0)
        return [arrSubControllers objectAtIndex:arrSubControllers.count - 1];
    
    return nil;
}

-(BOOL) isParentAlertView:(NSInteger)tag
{
    NSInteger value = (tag & 0xffff);
    if (value > 0x1024 && value < 0x1029)
        return YES;
    
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (![self isParentAlertView:alertView.tag])
        return;
    
    NGTabBarController *tabController = [AppDelegate sharedInstance].tabBarController;
    NSInteger type = alertView.tag & 0xff0000;
    NSInteger value = alertView.tag & 0xffff;
    if(buttonIndex == 0)
    {
        iLastActionType = type;
        if (value == 0x1025)
        {
            [[AppDelegate sharedInstance] refreshShareEnvironment];
            if (tabController.selectedIndex != tabController.curIndex)
            {
                tabController.selectedIndex = tabController.curIndex;
            }
            else
            {
                UINavigationController *navController = [tabController.viewControllers objectAtIndex:tabController.selectedIndex];
                if (tabController.selectedIndex == 2)
                    [navController popToRootViewControllerAnimated:NO];
                else
                {
                    for (int j = 0; j < navController.viewControllers.count; j++)
                    {
                        UIViewController *controller = [navController.viewControllers objectAtIndex:j];
                        if ([controller isKindOfClass:[ShareViewController class]] && j > 0)
                        {
                            [navController popToViewController:[navController.viewControllers objectAtIndex:j - 1] animated:NO];
                            break;
                        }
                    }
                }
            }
        }
        else if (value == 0x1026)
        {
            UIViewController *controller = [self getCurrentActivedController:tabController.selectedIndex];
            if ([controller isKindOfClass:[PhotoDetailViewController class]])
            {
                PhotoDetailViewController *pdcontroller = (PhotoDetailViewController *)controller;
                [pdcontroller processSaveAction];
            }
        }
        else if (value == 0x1027)
        {
            UIViewController *controller = [self getCurrentActivedController:tabController.selectedIndex];
            if ([controller isKindOfClass:[BucketEditViewController class]])
            {
                BucketEditViewController *becontroller = (BucketEditViewController *)controller;
                [becontroller processCreatBucket:nil];
            }
        }
        else if (value == 0x1028)
        {
            UIViewController *controller = [self getCurrentActivedController:tabController.selectedIndex];
            if ([controller isKindOfClass:[EditGroupViewController class]])
            {
                EditGroupViewController *egcontroller = (EditGroupViewController *)controller;
                [egcontroller onSave:nil];
            }
        }
    }
    else
    {
        iLastActionType = -1;
        if (value == 0x1025)
            return;
        
        if (type == TYPE_GO_TABBAR)
            tabController.selectedIndex = tabController.curIndex;
        else if (type == TYPE_GO_MENU)
            [self gotoMenuPage];
        else if (type == TYPE_GO_FAVOUR)
            [self showActionSheet];
    }
}

-(void) refreshActionType
{
    iLastActionType = -1;
}

-(BOOL) completedAction:(BOOL) bShowActionSheet
{
    if (iLastActionType == TYPE_GO_TABBAR)
    {
        [AppDelegate sharedInstance].tabBarController.selectedIndex = [AppDelegate sharedInstance].tabBarController.curIndex;
        return YES;
    }
    else if (iLastActionType == TYPE_GO_MENU)
    {
        [self gotoMenuPage];
        return YES;
    }
    else if (bShowActionSheet && iLastActionType == TYPE_GO_FAVOUR)
    {
        [self showActionSheet];
        return YES;
    }
    
    return NO;
}

-(void) showActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Search", @"My Trending Photos", @"My Favourite Photos", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 0x10000;
    [actionSheet showInView:self.view];
}

-(void) gotoMenuPage
{
    UINavigationController *VC = (UINavigationController *)[[AppDelegate sharedInstance] getUIViewController:@"leftVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void) onFavorite
{
    if ([self isRequireAlertDialog:TYPE_GO_FAVOUR])
        return;
    
    [self showActionSheet];
}

-(void) onSettings
{
    if ([self isRequireAlertDialog:TYPE_GO_MENU])
        return;
    
    //[[AppDelegate sharedInstance] playAudio:s_TabButton];
    [self gotoMenuPage];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 2)
    {
        [self goToFavoritePage];
    }
    else if (buttonIndex == 1)
    {
        UINavigationController *VC = (UINavigationController *)[[AppDelegate sharedInstance] getUIViewController:@"trendingView"];
        [self.navigationController pushViewController:VC animated:YES];
    }
    else if (buttonIndex == 0)
    {
        UINavigationController *VC = (UINavigationController *)[[AppDelegate sharedInstance] getUIViewController:@"searchPhotoVC"];
        [self.navigationController pushViewController:VC animated:YES];
    }
}



- (void) setLayerImage:(UIImageView*)imgView
{
    imgView.layer.cornerRadius = imgView.frame.size.height / 2;
    imgView.layer.masksToBounds = YES;
    imgView.layer.borderWidth = 0;
    [imgView.layer setBorderColor:[photoBorderColor CGColor]];
    float fBorderWidth = imgView.frame.size.height / 14;
    if (fBorderWidth > 4)
        fBorderWidth = 4;
    [imgView.layer setBorderWidth:fBorderWidth];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    [self hideHUD];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
