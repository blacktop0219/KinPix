//
//  PremiumViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface PremiumViewController : TabParentViewController<SKProductsRequestDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewCheck1;
@property (weak, nonatomic) IBOutlet UIView *viewCheck2;
@property (weak, nonatomic) IBOutlet UIView *viewHelp;
@property (weak, nonatomic) IBOutlet UIView *viewLimitLocation;
@property (weak, nonatomic) IBOutlet UIView *viewLimitBar;
@property (weak, nonatomic) IBOutlet UITableView *tblPurchase;

@property (weak, nonatomic) IBOutlet UILabel *lblCurrentPackage;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiryDate;
@property (weak, nonatomic) IBOutlet UILabel *lblRemainCount;
@property (weak, nonatomic) IBOutlet UILabel *lblMaxCount;
@property (weak, nonatomic) IBOutlet UILabel *lblCurPhotoCount;
@property (weak, nonatomic) IBOutlet UIButton *btnDelete;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;

- (IBAction)processPurchase:(id)sender;

- (IBAction)processSearchAction:(id)sender;
- (IBAction)processDeleteAction:(id)sender;
- (IBAction)onBack:(id)sender;

@end
