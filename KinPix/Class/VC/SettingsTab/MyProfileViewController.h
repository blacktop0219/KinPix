//
//  MyProfileViewController.h
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSKImageCropper.h"
#import "TGCamera.h"
#import "TGCameraNavigationController.h"
#import "IQMediaPickerController.h"

@interface MyProfileViewController : TabParentViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate, UIAlertViewDelegate, TGCameraDelegate, IQMediaPickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *fistNameTf;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTf;
@property (weak, nonatomic) IBOutlet UITextField *emailTf;
@property (weak, nonatomic) IBOutlet UITextField *curPassTf;

@property (weak, nonatomic) IBOutlet UITextField *passTf;
@property (weak, nonatomic) IBOutlet UITextField *repassTf;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *deletePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoBtn;


@property(weak, nonatomic) UIView *activeTextView;

@property BOOL b_isChanged;

- (IBAction)onDeletePhoto:(id)sender;
- (IBAction)onChangePhoto:(id)sender;
- (IBAction)onSave:(id)sender;
- (IBAction)onBack:(id)sender;

- (IBAction)onTouchScroll:(id)sender ;

@end
