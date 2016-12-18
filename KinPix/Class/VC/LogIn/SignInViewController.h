//
//  SignInViewController.h
//  Zinger
//
//  Created by QingHou on 10/27/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RSKImageCropper.h"
#import "TGCamera.h"
#import "TGCameraNavigationController.h"
#import "IQMediaPickerController.h"

@interface SignInViewController : ParentViewController<UIAlertViewDelegate, UITextFieldDelegate, UIActionSheetDelegate,
                        RSKImageCropViewControllerDelegate, TGCameraDelegate, IQMediaPickerControllerDelegate, UINavigationControllerDelegate>

// Main Screens
@property (weak, nonatomic) IBOutlet UIView *viewFirstScreen;
@property (weak, nonatomic) IBOutlet UIView *viewSecondScreen;
@property (weak, nonatomic) IBOutlet UIImageView *ivBackgroud1;
@property (weak, nonatomic) IBOutlet UIImageView *ivBackgroud2;
@property (weak, nonatomic) IBOutlet UIButton *btnSignup;
@property (weak, nonatomic) IBOutlet UIButton *btnSignin;
@property (weak, nonatomic) IBOutlet UITableView *tblMain;

// Login screen
@property (weak, nonatomic) IBOutlet UIView *viewLogin;
@property (weak, nonatomic) IBOutlet UITextField *txtLoginPass;
@property (weak, nonatomic) IBOutlet UITextField *txtLoginEmail;
@property (weak, nonatomic) IBOutlet UIView *viewLoginOption;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginBack;
@property (weak, nonatomic) IBOutlet UIButton *btnLoginLogin;
@property (weak, nonatomic) IBOutlet UIImageView *ivLoginBack;

// Signup screen
@property (weak, nonatomic) IBOutlet UIView *viewSignup;
@property (weak, nonatomic) IBOutlet UIView *viewSignupOption;
@property (weak, nonatomic) IBOutlet UITextField *txtSignupPass;
@property (weak, nonatomic) IBOutlet UITextField *txtSignupEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtSignupFirstName;
@property (weak, nonatomic) IBOutlet UITextField *txtSignupLastName;
@property (weak, nonatomic) IBOutlet UITextField *txtReEnterPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnSignupBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSignupSignup;
@property (weak, nonatomic) IBOutlet UIImageView *ivSignupBack;
@property (weak, nonatomic) IBOutlet UIImageView *ivProfilePhoto;

// Verify screen
@property (weak, nonatomic) IBOutlet UIView *viewVerify;
@property (weak, nonatomic) IBOutlet UIView *viewVerifyOption;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UITextField *txtVerifyCode;
@property (weak, nonatomic) IBOutlet UIButton *btnResend;
@property (weak, nonatomic) IBOutlet UIButton *btnVerify;
@property (weak, nonatomic) IBOutlet UIImageView *ivVerifyBack;
@property (weak, nonatomic) IBOutlet UILabel *lblVerificationCode;

// Login Screen
- (IBAction)processForgetPassword:(id)sender;
- (IBAction)processLoginAction:(id)sender;
- (IBAction)processBack:(id)sender;

// Signup Screen
- (IBAction)processTakePhoto:(id)sender;
- (IBAction)processSignupSignup:(id)sender;

// Verify Screen
- (IBAction)processResendCode:(id)sender;
- (IBAction)processVerify:(id)sender;
- (IBAction)processVerifyCloseAction:(id)sender;

// Common
- (IBAction)processTapAction:(id)sender;

// First Screen
- (IBAction)processFirstSignup:(id)sender;
- (IBAction)processFirstLogin:(id)sender;

- (IBAction)processTermsAction:(id)sender;
- (IBAction)processPrivacyAction:(id)sender;

@end
