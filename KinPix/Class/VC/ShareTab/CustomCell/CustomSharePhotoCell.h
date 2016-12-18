//
//  CustomSharePhotoCell.h
//  Zinger
//
//  Created by QingHou on 11/14/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFTokenField.h"
#import "SharePhotoViewController.h"

@interface CustomSharePhotoCell : UITableViewCell<ZFTokenFieldDataSource, ZFTokenFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UIButton *btnPopover;
@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtTitle;
@property (weak, nonatomic) IBOutlet UIView *viewTag;
@property (weak, nonatomic) IBOutlet ZFTokenField *txtTag;
@property (weak, nonatomic) IBOutlet UIScrollView *svTag;
@property (weak, nonatomic) IBOutlet UIButton *btnEditPhoto;

@property (nonatomic, strong) NSMutableArray *tokens;

@property (nonatomic, retain) SharePhotoViewController *controller;

-(void) setTagArray:(NSMutableArray *)array;
-(BOOL) hasFocus;
-(void) setFocused:(BOOL)flag;
-(void) completeToken;

@end
