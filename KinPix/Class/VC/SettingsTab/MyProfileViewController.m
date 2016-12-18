//
//  MyProfileViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "MyProfileViewController.h"
#import "RSKImageCropper.h"

@interface MyProfileViewController ()<S3PhotoUploaderDelegate>
{
    BOOL bPhotoSetFlag;
    NSString *strPhotoURL;
}
@end

@implementation MyProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.

    strPhotoURL = @"";
    if (IS_IPHONE_5)
        self.scrollView.contentSize = CGSizeMake(312, 450);
    else
        self.scrollView.contentSize = CGSizeMake(312, 360);
    [self updateView];
    
    self.passTf.returnKeyType = UIReturnKeyNext;
    self.emailTf.returnKeyType = UIReturnKeyNext;
    self.fistNameTf.returnKeyType = UIReturnKeyNext;
    self.lastNameTf.returnKeyType = UIReturnKeyNext;
    self.curPassTf.returnKeyType = UIReturnKeyNext;
    self.repassTf.returnKeyType = UIReturnKeyDone;
    
    self.b_isChanged = NO;
    [self.scrollView.layer setBorderWidth:0.6];
    [self.scrollView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void) updateView
{
    AppDelegate *delegate = [AppDelegate sharedInstance];
    
    self.fistNameTf.text = delegate.objUserInfo.strFirstName;
    self.lastNameTf.text = delegate.objUserInfo.strLastName;
    self.emailTf.text = delegate.objUserInfo.strEmail;
    
    [self.photoView sd_setImageWithURL:[[AppDelegate sharedInstance].objUserInfo getPhotoURL] placeholderImage:[Utils getDefaultProfileImage] options:SDWebImageRefreshCached];
    self.deletePhotoBtn.hidden = NO;
    [self.addPhotoBtn setImage:[UIImage imageNamed:@"changePhotoBtn"] forState:UIControlStateNormal];
    
    [self setLayerImage:self.photoView];
 }

- (IBAction)onDeletePhoto:(id)sender {
    self.photoView.image = [Utils getDefaultProfileImage];
    [self.addPhotoBtn setImage:[UIImage imageNamed:@"addPhotoBtn"] forState:UIControlStateNormal];
    self.deletePhotoBtn.hidden = YES;
    strPhotoURL = @"";
}

- (IBAction)onChangePhoto:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Profile Image" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo from Camera",@"Choose Existing Photo", nil];

    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (IBAction)onBack:(id)sender {
    
    if(self.b_isChanged == YES)
    {
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"" message:@"Would like like to save the changes you made to your profile?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes, Save",@"No, Don’t Save", nil];
        alert.tag = 2000;
        [alert show];
        
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self onTouchScroll:nil];
}

- (IBAction)onSave:(id)sender
{
    [self onTouchScroll:nil];
    AppDelegate *delegate = [AppDelegate sharedInstance];

    if([self.fistNameTf.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Input First Name." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    if([self.lastNameTf.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Input Last Name." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    if([self.emailTf.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Input Email." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    if([self.passTf.text length] > 0 || [self.repassTf.text  length] > 0 || [self.curPassTf.text length] > 0)
    {
        if([self.curPassTf.text length] == 0)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Input Current Password" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;
        }

        if([self.passTf.text length] == 0 || [self.repassTf.text  length] == 0)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Input Passwords." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;
        }
        
        if(![self.passTf.text isEqualToString:self.repassTf.text])
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords are not matched." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;
            
        }
        
        if([self.passTf.text length] < 6 || [Utils isNumberIncluded:self.passTf.text] == NO)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Passwords should be at least 6 characters with at least one number." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;
            
        }
        
        if(![delegate.objUserInfo.strPassword isEqualToString:self.curPassTf.text])
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Current Password is not correct." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;

        }

    }
    
    [self showHUD:@"Saving..."];
    if (strPhotoURL.length > 10)
    {
        S3PhotoUploader *photouploader = [[AppDelegate sharedInstance] getS3PhotoUploader:self];
        [photouploader uploadProfilePhoto:self.photoView.image photourl:strPhotoURL];
    }
    else
    {
        [self uploadFinished];
    }
}


#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.activeTextView = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.fistNameTf)
        [self.lastNameTf becomeFirstResponder];
    else if (textField == self.lastNameTf)
        [self.emailTf becomeFirstResponder];
    else if (textField == self.emailTf)
        [self.curPassTf becomeFirstResponder];
    else if (textField == self.curPassTf)
        [self.passTf becomeFirstResponder];
    else if (textField == self.passTf)
        [self.repassTf becomeFirstResponder];
    else
        [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.activeTextView = nil;
    
    return YES;
}

#pragma mark -
#pragma mark - UITouchEvent Delegate

- (IBAction)onTouchScroll:(id)sender
{
    [self.activeTextView resignFirstResponder];
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideHUD];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Profile update failed." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
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
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    
    if(status == 200)
    {
        self.b_isChanged = NO;
        NSDictionary *dict = [json objectForKey:@"userinfo"];
        NSString *strSecKey = [AppDelegate sharedInstance].objUserInfo.strSecurityKey;
        [[AppDelegate sharedInstance].objUserInfo initWithJsonData:dict];
        
        [AppDelegate sharedInstance].objUserInfo.strPassword = self.passTf.text;
        if (self.passTf.text.length > 0)
            [[AppDelegate sharedInstance] saveUserInfo:[AppDelegate sharedInstance].objUserInfo.strEmail password:self.passTf.text];
        else
            [[AppDelegate sharedInstance] saveUserInfo:[AppDelegate sharedInstance].objUserInfo.strEmail password:nil];
        [AppDelegate sharedInstance].objUserInfo.strSecurityKey = strSecKey;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Your profile changes have been saved." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag = 2001;
        [alert show];
        [self updateView];
    }
    else if(status ==  402)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"An Errir is occured while saving." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
}


#pragma mark -
#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if(alertView.tag == 2000)
    {
        if(buttonIndex == 0)
            [self onSave:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];
    }
    else if(alertView.tag == 2001)
    {
        self.curPassTf.text = @"";
        self.passTf.text = @"";
        self.repassTf.text = @"";
    }
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
    NSString *model = [[UIDevice currentDevice] model];
    if ([model rangeOfString:@"Simulator"].location != NSNotFound)
        return;
    
    [TGCamera setOption:kTGCameraOptionSaveImageToDevice value:[NSNumber numberWithBool:NO]];
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0x10000)
    {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if(buttonIndex == 0)
        [self takePhoto];
    else if(buttonIndex == 1)
        [self chooseExistingPhoto];
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{

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
    NSLog(@"Info: %@",info);
    
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
    
    self.photoView.image = croppedImage;
    strPhotoURL = [Utils generateProfileName];
    [self setLayerImage:self.photoView];
    
    self.deletePhotoBtn.hidden = NO;
    [self.addPhotoBtn setImage:[UIImage imageNamed:@"changePhotoBtn"] forState:UIControlStateNormal];
    self.b_isChanged = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:k_showTab object:nil];
    
    [self.navigationController popViewControllerAnimated:NO];
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
    CGRect coveredFrame = [self.view.window convertRect:keyboardFrame toView:self.view];
    
    // add the keyboard height to the content insets so that the scrollview can be scrolled
    UIEdgeInsets contentInsets = UIEdgeInsetsMake (0.0, 0.0, coveredFrame.size.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // make sure the scrollview content size width and height are greater than 0
    [self.scrollView setContentSize:CGSizeMake (self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
    
    // scroll to the text view
    
    [self.scrollView scrollRectToVisible:self.activeTextView.frame animated:YES];
    
}

// Called when the UIKeyboardWillHideNotification is received
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    // scroll back..
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) uploadFinished
{
    self.request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getUserFunctionURL:FUNC_USER_UPDATE_PROFILE] delegate:self];
    [self.request setPostValue:self.fistNameTf.text forKey:@"firstname"];
    [self.request setPostValue:self.lastNameTf.text forKey:@"lastname"];
    
    [self.request setPostValue:self.emailTf.text forKey:@"email"];
    [self.request setPostValue:self.passTf.text forKey:@"password"];
    [self.request setPostValue:strPhotoURL forKey:@"photourl"];
    [self.request setPostValue:[AppDelegate sharedInstance].objUserInfo.strUserId forKey:@"userid"];
    [self.request startAsynchronous];
}

-(void) uploadFailed:(NSInteger)errorcode
{
    [self hideHUD];
}

@end
