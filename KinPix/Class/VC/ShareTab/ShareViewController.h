//
//  ShareViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQMediaPickerController.h"
#import <AVFoundation/AVFoundation.h>
#import "TGCamera.h"
#import "TGCameraNavigationController.h"

@interface ShareViewController : TabParentViewController<IQMediaPickerControllerDelegate, UINavigationControllerDelegate, TGCameraDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;


@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *viewButton;

@property BOOL bShowBack;
@property BOOL b_isFromCamera;

- (IBAction)onCancel:(id)sender;
- (IBAction)onPhoto:(id)sender;
- (IBAction)onCamera:(id)sender;

- (IBAction)processBackAction:(id)sender;


@end
