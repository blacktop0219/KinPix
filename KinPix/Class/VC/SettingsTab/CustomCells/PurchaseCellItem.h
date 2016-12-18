//
//  PurchaseCellItem.h
//  KinPix
//
//  Created by Piao Dev on 28/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchaseCellItem : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;

@end
