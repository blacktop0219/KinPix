//
//  FriendsViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "AddFriendsViewController.h"

@interface AddFriendsViewController ()

@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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



- (IBAction)onMyFriend:(id)sender {

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onMyGroups:(id)sender {
}

- (IBAction)onLocalContacts:(id)sender {
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    
    [self presentViewController:picker animated:YES completion:nil];

}

- (IBAction)onSendRequest:(id)sender {
    
    if([self.pinTf.text length] == 0 && [self.emailTf.text length] == 0 && [self.contactsLbl.text isEqualToString:@"Local Contacts"])
    {
        [AppDelegate showMessage:@"Please Input Email or Pin code to invite people" withTitle:@"Error"];
        return;
    }
    
    if ([self.pinTf.text isEqualToString:[AppDelegate sharedInstance].objUserInfo.strPinCode])
    {
        [AppDelegate showMessage:@"It's your pincode" withTitle:@"Error"];
        return;
    }
    
    if ([self.emailTf.text isEqualToString:[AppDelegate sharedInstance].objUserInfo.strEmail])
    {
        [AppDelegate showMessage:@"It's your email" withTitle:@"Error"];
        return;
    }
    
    [self showHUD:@"Checking..."];
    
    [self.request clearDelegatesAndCancel];
    
    self.request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getFriendsFunctionURL:FUNC_FRIEND_SEND_REQ] delegate:self];
    if(![self.contactsLbl.text isEqualToString:@"Local Contacts"])
        [self.request setPostValue:self.contactsLbl.text forKey:@"email"];
    else if([self.emailTf.text length] > 0)
        [self.request setPostValue:self.emailTf.text forKey:@"email"];
    else if([self.pinTf.text length] > 0)
        [self.request setPostValue:self.pinTf.text forKey:@"pincode"];
    
    [self.request startAsynchronous];
}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
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
        NSString *strAddr = @"";
        if(![self.contactsLbl.text isEqualToString:@"Local Contacts"])
            strAddr = self.contactsLbl.text;
        else if([self.emailTf.text length] > 0)
            strAddr = self.emailTf.text;
        else if([self.pinTf.text length] > 0)
            strAddr = self.pinTf.text;

        NSString *firstName = [json objectForKey:@"firstname"];
        NSString *lastName = [json objectForKey:@"lastname"];
        
        if([firstName length] > 0)
        {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You have sent an invite to %@ %@", firstName, lastName] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
        else
            [[[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"You have sent an invite to %@", strAddr] delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];

    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    self.scrollView.contentSize = CGSizeMake(320,350);
    self.activeTextView = textField;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if(textField == self.pinTf){
        self.emailTf.text = @"";
        self.contactsLbl.text  = @"Local Contacts";

        NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        if( [[string uppercaseString] isEqualToString:[filtered uppercaseString]])
        {
            
            NSString *lastStr;
            
            if([textField.text length] > 0)
                lastStr = [textField.text substringFromIndex:[textField.text length] - 1];
            
            NSString * newStr = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@"-" withString:@""] ;

            if([string isEqualToString:@""] && [lastStr isEqualToString:@"-"])
            {
                newStr = [newStr substringToIndex:[newStr length] - 1];
            }
            
            if([newStr length] == 0)
                return YES;
            
            if([newStr length] >= 8)
                return NO;
            
            NSString *firstStr = @"";
            NSString *secStr = @"";
            NSString *thirdStr = @"";
            
            firstStr = [newStr substringToIndex:1];
            newStr = [newStr substringFromIndex:1];
            
            if([newStr length] >=3)
            {
                secStr = [newStr substringToIndex:3];
                newStr = [newStr substringFromIndex:3];
            }
            else
            {
                secStr = newStr;
                thirdStr = @"";
                newStr = @"";
            }
            
            if([newStr length] >0)
                thirdStr = newStr;
            
            newStr = firstStr;
            if([firstStr length] > 0)
                newStr = [newStr stringByAppendingFormat:@"-%@",secStr];
            if([secStr length] == 3)
                newStr = [newStr stringByAppendingFormat:@"-%@",thirdStr];
            
            textField.text = newStr;
            return NO;
        }
        
        return NO;
    }
    else if(textField == self.emailTf)
    {
        self.pinTf.text = @"";
        self.contactsLbl.text  = @"Local Contacts";
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.scrollView.contentSize = CGSizeMake(320,200);

    self.activeTextView = nil;
    
    [textField resignFirstResponder];
    
    return YES;
}

#pragma makr -
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    self.pinTf.text = @"";
    self.emailTf.text = @"";
    self.contactsLbl.text = @"Local Contacts";
}

#pragma mark -
#pragma mark - ABPeoplePickerNavigationController Delegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
//    NSString* name = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
//    
//    NSLog(@"name = %@", name);
    
    return YES;
}

//For iOS8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if(property == kABPersonPhoneProperty || property == kABPersonEmailProperty)
    {
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        
        self.contactStr = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(multi, identifier));
        
        
        [self dismissViewControllerAnimated:YES completion:nil];

    }

    self.contactsLbl.text = self.contactStr;
    
    self.pinTf.text = @"";
    self.emailTf.text = @"";
}

//For iOS7
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    if(property == kABPersonPhoneProperty || property == kABPersonEmailProperty)
    {
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        
        self.contactStr = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(multi, identifier));
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    
    self.contactsLbl.text = self.contactStr;
    
    self.pinTf.text = @"";
    self.emailTf.text = @"";

    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark -
#pragma mark - UITouchEvent Delegate

- (IBAction)onTouch:(id)sender
{
    [self.pinTf resignFirstResponder];
    [self.emailTf resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouch:nil];
}

@end
