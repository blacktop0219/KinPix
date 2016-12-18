//
//  SignInViewController.m
//  Zinger
//
//  Created by QingHou on 10/27/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "SignInViewController.h"
#import "SBJson.h"

#define VIEW_TYPE_LOGIN 101
#define VIEW_TYPE_SIGNUP 102
#define VIEW_TYPE_VERIFY 103
#define VIEW_TYPE_FORGOT 104

#define IMAGE_COUNT     8
#define CYCLE           5

@interface SignInViewController ()<S3PhotoUploaderDelegate>
{
    UITextField *txtLastActivated;
    NSTimer *aTimer;
    NSString *strEmail;
    NSString *strPassword;
    NSInteger counter;
    NSInteger iLastPhotoIDX;
    NSMutableArray *arrBackground;
    BOOL bPhotoSetFlag;
    NSString *strPhotoURL;
}
@end

@implementation SignInViewController

@synthesize btnLoginBack, btnLoginLogin, ivBackgroud1, ivBackgroud2;
@synthesize viewLogin, viewLoginOption, ivLoginBack;
@synthesize viewFirstScreen, viewSecondScreen;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self adjustViewCorner:self.btnSignin corner:4];
    [self adjustViewCorner:self.btnSignup corner:4];
    
    // init Login pane
    [self adjustViewCorner:ivLoginBack corner:7];
    [self adjustViewCorner:viewLoginOption corner:3];
    [self adjustViewCorner:btnLoginBack corner:3];
    [self adjustViewCorner:btnLoginLogin corner:3];
    self.txtLoginEmail.returnKeyType = UIReturnKeyNext;
    self.txtLoginPass.returnKeyType = UIReturnKeyDone;
    
    // init Signup pane
    [self adjustViewCorner:self.ivSignupBack corner:7];
    [self adjustViewCorner:self.viewSignupOption corner:3];
    [self adjustViewCorner:self.btnSignupBack corner:3];
    [self adjustViewCorner:self.btnSignupSignup corner:3];
    [AppDelegate processUserImage:self.ivProfilePhoto];
    self.txtSignupEmail.returnKeyType = UIReturnKeyNext;
    self.txtSignupFirstName.returnKeyType = UIReturnKeyNext;
    self.txtSignupLastName.returnKeyType = UIReturnKeyNext;
    self.txtSignupPass.returnKeyType = UIReturnKeyNext;
    self.txtReEnterPassword.returnKeyType = UIReturnKeyDone;
    
    // init Verify pane
    [self adjustViewCorner:self.ivVerifyBack corner:7];
    [self adjustViewCorner:self.viewVerifyOption corner:3];
    [self adjustViewCorner:self.btnVerify corner:3];
    [self adjustViewCorner:self.btnResend corner:3];
    self.txtVerifyCode.returnKeyType = UIReturnKeyDone;
    
    UIFont *fontAppDefault = [AppDelegate getAppSystemFont:14];
    [self.txtLoginEmail setFont:fontAppDefault];
    [self.txtSignupFirstName setFont:fontAppDefault];
    [self.txtSignupEmail setFont:fontAppDefault];
    [self.txtSignupLastName setFont:fontAppDefault];
    [self.txtVerifyCode setFont:fontAppDefault];
    
    ivBackgroud2.alpha = 0;
    CGRect rect = viewFirstScreen.frame;
    rect.origin.x = 0;
    viewFirstScreen.frame = rect;
    rect.origin.x = 320;
    viewSecondScreen.frame = rect;
    
    iLastPhotoIDX = 0;
    
    NSInteger devtype = 4;
    if (IS_IPHONE_5)
        devtype = 5;
    NSString *strFileName = [NSString stringWithFormat:@"background%d-0.jpg", (int)devtype];
    //return [Utils getBackgroundPhoto:strFileName];
    ivBackgroud1.image = [UIImage imageNamed:strFileName];
    
    arrBackground = [[NSMutableArray alloc] initWithObjects:@"background0.jpg", @"background1.jpg", @"background2.jpg", @"background3.jpg", @"background4.jpg", @"background5.jpg", @"background6.jpg", nil];
//    [Utils getBackgroundLocalPhotos:arrBackground];
//    if ([arrBackground count] < 7)
//        [self loadBackgroudImage];

    if ([[AppDelegate sharedInstance] loadUserInfo])
    {
        if (![AppDelegate isConnectedToInternet])
        {
            [MessageBox showErrorMsage:MSG_ERR_INTERNET_CONNECT_FAILED];
            return;
        }
        
        [[AppDelegate sharedInstance] processAutoLogin];
        [self goTabBarController];
    }
}

- (BOOL) shouldAutorotate
{
    return NO;
}

-(void) loadBackgroudImage
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.mycompany.myqueue", 0);
    dispatch_async(backgroundQueue, ^{
        for (int i = 0; i < 7; i++)
        {
            BOOL bExist = NO;
            NSString *strFileName = [NSString stringWithFormat:@"background%d.jpg", i];
            for (NSString *strName in arrBackground)
            {
                if([strName isEqualToString:strFileName])
                {
                    bExist = YES;
                    break;
                }
            }
            
            if (bExist)
                continue;
            
            NSString *strDevType = @"iphone4";
            if (IS_IPHONE_5)
                strDevType = @"iphone5";
            
            NSString *strURL = [NSString stringWithFormat:@"https://s3.amazonaws.com/kinpix-app.user/background/%@/%@", strDevType, strFileName];
            NSData *imgdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            if ([Utils saveBackgroundPhoto:imgdata filename:strFileName])
                [arrBackground addObject:strFileName];
        }
    });
    
}

-(void) onBackRoot
{
    [self processBack:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    if (aTimer)
        [aTimer invalidate];
    aTimer = [NSTimer scheduledTimerWithTimeInterval:CYCLE target:self selector:@selector(processChangeBackground) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (aTimer)
        [aTimer invalidate];
    
    aTimer = nil;
}

-(void) processChangeBackground
{
    if (arrBackground.count < 2)
        return;
    
    BOOL bShowFirstView;
    if (ivBackgroud2.alpha == 0)
    {
        ivBackgroud2.image = [self getNextScreen];
        [self.view sendSubviewToBack:ivBackgroud2];
        ivBackgroud2.alpha = 1;
        bShowFirstView = NO;
    }
    else
    {
        ivBackgroud1.image = [self getNextScreen];
        [self.view sendSubviewToBack:ivBackgroud1];
        ivBackgroud1.alpha = 1;
        bShowFirstView = YES;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    if (bShowFirstView)
        ivBackgroud2.alpha = 0;
    else
        ivBackgroud1.alpha = 0;
    [UIView commitAnimations];
}

- (UIImage *)getNextScreen
{
    NSInteger iNewIDx;
    NSInteger iCount = arrBackground.count;
    do {
        iNewIDx = arc4random() % iCount;
    } while (iLastPhotoIDX == iNewIDx);
    
    NSInteger devtype = 4;
    if (IS_IPHONE_5)
        devtype = 5;
    iLastPhotoIDX = iNewIDx;
    
    NSString *strFileName = [NSString stringWithFormat:@"background%d-%d.jpg", (int)devtype, (int)iNewIDx];
    //return [Utils getBackgroundPhoto:strFileName];
    return [UIImage imageNamed:strFileName];
}

-(void) adjustViewCorner:(UIView *)adview corner:(NSInteger)corner
{
    adview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    adview.layer.borderWidth = 0.3;
    adview.layer.cornerRadius = corner;
    
    if ([adview isKindOfClass:[UIImageView class]])
        adview.layer.masksToBounds = YES;
}

- (IBAction)processTakePhoto:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo from Camera",@"Choose Existing Photo", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (IBAction)processForgetPassword:(id)sender
{
    [txtLastActivated resignFirstResponder];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Forgot Password?"
                                                          message:@"Please enter your email address to retrieve your password." delegate:self cancelButtonTitle:@"Send" otherButtonTitles:@"Cancel", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = VIEW_TYPE_FORGOT;
    [alertView show];
    
}

- (IBAction)processLoginAction:(id)sender
{
    if (![AppDelegate isConnectedToInternet])
    {
        [MessageBox showErrorMsage:MSG_ERR_INTERNET_CONNECT_FAILED];
        return;
    }
    
    if (self.txtLoginEmail.text.length < 1 || self.txtLoginPass.text.length < 1)
    {
        if (self.txtLoginEmail.text.length < 1) [self.txtLoginEmail becomeFirstResponder];
        else if (self.txtLoginPass.text.length < 1) [self.txtLoginPass becomeFirstResponder];
        [AppDelegate showMessage:@"Please enter your account info." withTitle:nil];
        return;
    }
    
    [self processTapAction:nil];
    [self showHUD:@"Login..."];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_SIGNIN] tag:TYPE_USER_LOGIN delegate:self];
    [self.request setPostValue:self.txtLoginEmail.text forKey:@"email"];
    [self.request setPostValue:self.txtLoginPass.text forKey:@"password"];
    [self.request setPostValue:[AppDelegate sharedInstance].city forKey:@"city"];
    [self.request setPostValue:[AppDelegate sharedInstance].country forKey:@"country"];
    [self.request setPostValue:[AppDelegate sharedInstance].state forKey:@"state"];
    [self.request setPostValue:[AppDelegate sharedInstance].token forKey:@"token"];
    NSString *strSecurityKey = [Utils generateSecurityKey:[AppDelegate sharedInstance].token email:self.txtLoginEmail.text sec:0];
    [self.request setPostValue:strSecurityKey forKey:@"key"];
    [self.request startAsynchronous];
    strEmail = self.txtLoginEmail.text;
    strPassword = self.txtLoginPass.text;
}

- (IBAction)processBack:(id)sender
{
    [self processTapAction:nil];
    if (!sender)
    {
        CGRect frame = viewFirstScreen.frame;
        frame.origin.x = 0;
        viewFirstScreen.frame = frame;
        
        frame = viewSecondScreen.frame;
        frame.origin.x = 320;
        viewSecondScreen.frame = frame;
        return;
    }
    
    [UIView transitionWithView:self.viewSecondScreen
                      duration:0.3
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        CGRect frame = viewFirstScreen.frame;
                        frame.origin.x = 0;
                        viewFirstScreen.frame = frame;
                        
                        frame = viewSecondScreen.frame;
                        frame.origin.x = 320;
                        viewSecondScreen.frame = frame;
                    }
                    completion:nil];
}

- (IBAction)processSignupSignup:(id)sender
{
    if (![AppDelegate isConnectedToInternet])
    {
        [MessageBox showErrorMsage:MSG_ERR_INTERNET_CONNECT_FAILED];
        return;
    }
    
    if (self.txtSignupFirstName.text.length < 1 || self.txtSignupLastName.text.length < 1 ||
        self.txtSignupEmail.text.length < 1 || self.txtSignupPass.text.length < 1 ||
        self.txtReEnterPassword.text.length < 1)
    {
        if (self.txtSignupFirstName.text.length < 1) [self.txtSignupFirstName becomeFirstResponder];
        else if (self.txtSignupLastName.text.length < 1) [self.txtSignupLastName becomeFirstResponder];
        else if (self.txtSignupEmail.text.length < 1) [self.txtSignupEmail becomeFirstResponder];
        else if (self.txtSignupPass.text.length < 1) [self.txtSignupPass becomeFirstResponder];
        else if (self.txtReEnterPassword.text.length < 1) [self.txtReEnterPassword becomeFirstResponder];
        
        [AppDelegate showMessage:@"Please enter your details to create an account" withTitle:nil];
        return;
    }
    
    if (![Utils isValidEmailAddress:self.txtSignupEmail.text])
    {
        [AppDelegate showMessage:@"Please enter a valid email address" withTitle:nil];
        [self.txtSignupEmail becomeFirstResponder];
        return;
    }
    
    if([self.txtSignupPass.text length] < 6 || [Utils isNumberIncluded:self.txtSignupPass.text] == NO)
    {
        [AppDelegate showMessage:@"Passwords should be at least 6 characters with at least one number." withTitle:nil];
        [self.txtSignupPass becomeFirstResponder];
        return;
    }
    
    if (![self.txtReEnterPassword.text isEqualToString:self.txtSignupPass.text])
    {
        [[[UIAlertView alloc] initWithTitle:@"PASSWORD ERROR" message:@"Please make sure you re-enter your password correctly." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [self processTapAction:nil];
    [self showHUD:@"Signup..."];
    if (bPhotoSetFlag)
    {
        S3PhotoUploader *photouploader = [[AppDelegate sharedInstance] getS3PhotoUploader:self];
        strPhotoURL = [Utils generateProfileName];
        [photouploader uploadProfilePhoto:self.ivProfilePhoto.image photourl:strPhotoURL];
    }
    else
    {
        strPhotoURL = @"";
        [self uploadFinished];
    }
}


#pragma mark - ASIHTTPRequest Delegate
-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideHUD];
    NSString    *value = [request responseString];
    NSLog(@"Value = %@", value);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if (status == ERR_USER_UNVERIFYED)
    {
        [self switchAsVerifyMode];
        return;
    }
    
    if (status == ERR_USER_IN_REVIEW || status == ERR_NO_ACCEPT_USER)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Due to high demand, KinPix is not accepting new accounts at this time,  please try again in 2-3 days." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alertView.tag = status;
        [alertView show];
        return;
    }
    
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    
    if(status == 200)
    {
        if (request.tag == TYPE_USER_FORGOT_PASS)
        {
            [AppDelegate showMessage:@"Please check your email" withTitle:@"Information"];
        }
        else if (request.tag == TYPE_USER_SIGNUP)
        {
            [self switchAsVerifyMode];
        }
        else if (request.tag == TYPE_CONFIRM_VERIFY || request.tag == TYPE_USER_LOGIN)
        {
            NSDictionary *dict = [json objectForKey:@"userinfo"];
            AppDelegate *delegate = [AppDelegate sharedInstance];
            [delegate.objUserInfo initWithJsonData:dict];
            [[AppDelegate sharedInstance] refreshHomeData:json];

            [self goTabBarController];
            [[AppDelegate sharedInstance] saveUserInfo:strEmail password:strPassword];
            [self onBackRoot];
        }
        else if (request.tag == TYPE_RESEND_VERIFY)
        {
            NSString *strReceivedEmail = [json objectForKey:@"email"];
            NSString *strMsg = [NSString stringWithFormat:@"Your verification code has been resent to %@", strReceivedEmail];
            [AppDelegate showMessage:strMsg withTitle:@"Information"];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideHUD];
    
    if (request.tag == TYPE_USER_FORGOT_PASS)
        [AppDelegate showMessage:@"Connection failed. Please check your internet connection." withTitle:@"Error"];
}

#pragma mark - init input value functions
-(void) initSignupView
{
    self.txtSignupFirstName.text = @"";
    self.txtSignupLastName.text = @"";
    self.txtSignupEmail.text = @"";
    self.txtSignupPass.text = @"";
    self.txtReEnterPassword.text = @"";
    bPhotoSetFlag = NO;
    strPhotoURL = @"";
    self.ivProfilePhoto.image = [UIImage imageNamed:@"male.png"];
}

-(void) initSigninView
{
    NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
    NSString *strSavedEmail = [userDefautls objectForKey:@"email"];
    self.txtLoginEmail.text = strSavedEmail;
    self.txtLoginPass.text = @"";
}

-(void) initVerifyView
{
    self.txtVerifyCode.text = @"";
}

-(void) switchAsVerifyMode
{
    [self initVerifyView];
    self.lblVerificationCode.text = [NSString stringWithFormat:@"Verification code was sent to %@.", strEmail];
    UIView *curView = [self getCurrentView];
    [self makeViewAsCenter:self.viewVerify animation:NO];
    CGRect frame = self.viewVerify.frame;
    frame.origin.x = 320;
    self.viewVerify.frame = frame;
    self.viewVerify.hidden = NO;
    [UIView transitionWithView:viewFirstScreen
                      duration:0.3
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        CGRect frame = curView.frame;
                        frame.origin.x = -320;
                        curView.frame = frame;
                        
                        frame = self.viewVerify.frame;
                        frame.origin.x = 0;
                        self.viewVerify.frame = frame;
                    }
                    completion:^(BOOL finished) {
                        curView.hidden = YES;
                        [self.txtVerifyCode becomeFirstResponder];
                    }];
}

#pragma mark -
#pragma mark - UIActionSheet Delegate

- (void) chooseExistingPhoto
{
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
    controller.allowsPickingMultipleItems = NO;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void) takePhoto
{
    [TGCamera setOption:kTGCameraOptionSaveImageToDevice value:[NSNumber numberWithBool:NO]];
    
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self takePhoto];
    }
    else if(buttonIndex == 1)
    {
        [self chooseExistingPhoto];
    }
}


- (IBAction)processTapAction:(id)sender
{
    [txtLastActivated resignFirstResponder];
}

- (IBAction)processFirstSignup:(id)sender
{
    [self prepareSecondView:VIEW_TYPE_SIGNUP];
    bPhotoSetFlag = NO;
    [self.ivProfilePhoto setImage:[UIImage imageNamed:@"male.png"]];
    [UIView transitionWithView:viewFirstScreen
                      duration:0.3
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        CGRect frame = viewFirstScreen.frame;
                        frame.origin.x = -320;
                        viewFirstScreen.frame = frame;
                        
                        frame = viewSecondScreen.frame;
                        frame.origin.x = 0;
                        viewSecondScreen.frame = frame;
                    }
                    completion:^(BOOL finished) {
                    }];
}

- (IBAction)processFirstLogin:(id)sender
{
    [self prepareSecondView:VIEW_TYPE_LOGIN];
    [UIView transitionWithView:viewFirstScreen
                      duration:0.3
                       options:UIViewAnimationOptionBeginFromCurrentState
                    animations:^{
                        CGRect frame = viewFirstScreen.frame;
                        frame.origin.x = -320;
                        viewFirstScreen.frame = frame;
                        
                        frame = viewSecondScreen.frame;
                        frame.origin.x = 0;
                        viewSecondScreen.frame = frame;
                    }
                    completion:^(BOOL finished) {
                        [self.txtLoginEmail becomeFirstResponder];
                    }];
}

-(void) prepareSecondView:(NSInteger)viewtype
{
    self.viewSignup.hidden = (viewtype != VIEW_TYPE_SIGNUP);
    self.viewLogin.hidden = (viewtype != VIEW_TYPE_LOGIN);
    self.viewVerify.hidden = (viewtype != VIEW_TYPE_VERIFY);
    if (viewtype == VIEW_TYPE_LOGIN)
    {
        [self initSigninView];
        [self makeViewAsCenter:self.viewLogin animation:NO];
    }
    else if (viewtype == VIEW_TYPE_SIGNUP)
    {
        [self initSignupView];
        [self makeViewAsCenter:self.viewSignup animation:NO];
    }
    else
    {
        [self initVerifyView];
        [self makeViewAsCenter:self.viewVerify animation:NO];
    }
    
    self.view.tag = viewtype;
}

-(UIView *) getCurrentView
{
    if (!self.viewSignup.hidden)
        return self.viewSignup;
    
    if (!self.viewVerify.hidden)
        return self.viewVerify;
    
    return self.viewLogin;
}

-(void) makeViewAsCenter:(UIView *)viewShow animation:(BOOL)animation
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect rect = viewShow.frame;
    rect.origin.y = (screenSize.height - rect.size.height) / 2 - 20;
    rect.origin.x = 0;
    if (animation)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        viewShow.frame = rect;
        [UIView commitAnimations];
    }
    else
        viewShow.frame = rect;
    
}

-(void) makeViewAsCenterInKeyboard:(UIView *)viewShow keyframe:(CGRect)keyframe
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect rect = viewShow.frame;
    rect.origin.y = (screenSize.height - rect.size.height - keyframe.size.height) / 2;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    viewShow.frame = rect;
    [UIView commitAnimations];
}

- (IBAction)processTermsAction:(id)sender
{
    [self goLegalView:NO :NO :NO];
}

- (IBAction)processPrivacyAction:(id)sender
{
    [self goLegalView:NO :NO :YES];
}

- (IBAction)processResendCode:(id)sender
{
    [self showHUD:@"Processing..."];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_RESEND_VERIFY] tag:TYPE_RESEND_VERIFY delegate:self];
    [self.request setPostValue:strEmail forKey:@"email"];
    [self.request startAsynchronous];
}

- (IBAction)processVerify:(id)sender
{
    if (![AppDelegate isConnectedToInternet])
    {
        [MessageBox showErrorMsage:MSG_ERR_INTERNET_CONNECT_FAILED];
        return;
    }
    
    if (self.txtVerifyCode.text.length < 1)
    {
        [AppDelegate showMessage:@"Please input verify code." withTitle:@"Error"];
        [self.txtVerifyCode becomeFirstResponder];
        return;
    }
    
    [self.txtVerifyCode resignFirstResponder];
    [self showHUD:@"Verifying..."];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_CONFIRM_VERIFY] tag:TYPE_CONFIRM_VERIFY delegate:self];
    [self.request setPostValue:strEmail forKey:@"email"];
    [self.request setPostValue:self.txtVerifyCode.text forKey:@"verifycode"];
    NSString *strSecurityKey = [Utils generateSecurityKey:[AppDelegate sharedInstance].token email:strEmail sec:0];
    [self.request setPostValue:[AppDelegate sharedInstance].token forKey:@"token"];
    [self.request setPostValue:strSecurityKey forKey:@"key"];
    [self.request startAsynchronous];
}

- (IBAction)processVerifyCloseAction:(id)sender
{
    [self processBack:sender];
}


#pragma mark -
#pragma makr - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (buttonIndex == 1)
        return;
    
    if (alertView.tag == VIEW_TYPE_FORGOT)
    {
        NSString *straEmail = [alertView textFieldAtIndex:0].text;
        if (straEmail.length < 1 || ![Utils isValidEmailAddress:straEmail])
        {
            [self processForgetPassword:nil];
            return;
        }
        
        [self showHUD:@"Processing..."];
        self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_FORGOT_PASS] tag:TYPE_USER_FORGOT_PASS delegate:self];
        [self.request setPostValue:straEmail forKey:@"email"];
        [self.request startAsynchronous];
    }
    else if (alertView.tag == ERR_USER_IN_REVIEW || alertView.tag == ERR_NO_ACCEPT_USER)
    {
        [self processBack:self];
    }
    
}

#pragma mark -
#pragma mark - UITouchEvent Delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark -  UIKeyboard Notification

// Called when the UIKeyboardDidShowNotification is received
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    // keyboard frame is in window coordinates
    NSDictionary *userInfo = [aNotification userInfo];
    CGRect keyboardInfoFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // get the height of the keyboard by taking into account the orientation of the device too
    CGRect windowFrame = [self.view.window convertRect:self.view.frame fromView:self.view];
    CGRect keyboardFrame = CGRectIntersection (windowFrame, keyboardInfoFrame);
    
    [self makeViewAsCenterInKeyboard:[self getCurrentView] keyframe:keyboardFrame];
}

// Called when the UIKeyboardWillHideNotification is received
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    [self makeViewAsCenter:[self getCurrentView] animation:YES];
}

#pragma mark -
#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    txtLastActivated = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.view.tag == VIEW_TYPE_LOGIN)
    {
        if (textField == self.txtLoginEmail)
            [self.txtLoginPass becomeFirstResponder];
        else
        {
            [self.txtLoginPass resignFirstResponder];
            [self processLoginAction:nil];
        }
    }
    
    if (self.view.tag == VIEW_TYPE_SIGNUP)
    {
        if (textField == self.txtSignupFirstName)
            [self.txtSignupLastName becomeFirstResponder];
        else if (textField == self.txtSignupLastName)
            [self.txtSignupEmail becomeFirstResponder];
        else if (textField == self.txtSignupEmail)
            [self.txtSignupPass becomeFirstResponder];
        else if (textField == self.txtSignupPass)
            [self.txtReEnterPassword becomeFirstResponder];
        else if (textField == self.txtReEnterPassword)
        {
            [self.txtReEnterPassword resignFirstResponder];
            [self processSignupSignup:nil];
        }
    }
    
    
    if (self.txtVerifyCode == textField)
        [self.txtVerifyCode resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark -
#pragma mark - TGCameraDelegate

- (void)cameraDidTakePhoto:(UIImage *)image
{
    [self dismissViewControllerAnimated:NO completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k_hideTab object:nil];
    
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle];
    imageCropVC.delegate = self;
    imageCropVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:imageCropVC animated:NO];
    
}

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - IQMediaPickerController Delegate

- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
    NSMutableDictionary *mediaDict = [NSMutableDictionary dictionaryWithDictionary:info];
    
    NSString *key = [[mediaDict allKeys] objectAtIndex:0];
    NSDictionary *dict = [[mediaDict objectForKey:key] objectAtIndex:0];
    UIImage *image = [dict objectForKey:IQMediaImage];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k_hideTab object:nil];
    
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle];
    imageCropVC.delegate = self;
    imageCropVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:imageCropVC animated:NO];
    
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
}

- (void)cameraWillTakePhoto
{
    
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    self.ivProfilePhoto.image = croppedImage;
    bPhotoSetFlag = YES;
    [self setLayerImage:self.ivProfilePhoto];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void) uploadFinished
{
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getUserFunctionURL:FUNC_USER_SIGNUP] tag:TYPE_USER_SIGNUP delegate:self];
    [self.request setPostValue:self.txtSignupFirstName.text forKey:@"firstname"];
    [self.request setPostValue:self.txtSignupLastName.text forKey:@"lastname"];
    [self.request setPostValue:self.txtSignupEmail.text forKey:@"email"];
    [self.request setPostValue:self.txtSignupPass.text forKey:@"password"];
    [self.request setPostValue:[AppDelegate sharedInstance].city forKey:@"city"];
    [self.request setPostValue:[AppDelegate sharedInstance].country forKey:@"country"];
    [self.request setPostValue:[AppDelegate sharedInstance].state forKey:@"state"];
    [self.request setPostValue:strPhotoURL forKey:@"photourl"];
    NSString *strSecurityKey = [Utils generateSecurityKey:@"" email:self.txtSignupEmail.text sec:0];
    [self.request setPostValue:strSecurityKey forKey:@"key"];
    
    strEmail = self.txtSignupEmail.text;
    strPassword = self.txtSignupPass.text;
    [self.request startAsynchronous];
}

-(void) uploadFailed:(NSInteger)errorcode
{
    [self hideHUD];
    [AppDelegate showMessage:@"Profile photo upload failed." withTitle:@"Error"];
}

@end
