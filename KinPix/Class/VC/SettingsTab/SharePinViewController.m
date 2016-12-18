//
//  SharePinViewController.m
//  Zinger
//
//  Created by QingHou on 10/31/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "SharePinViewController.h"

@interface SharePinViewController ()

@end

@implementation SharePinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.
    
    if(self.type == 0)
    {
        self.titleLbl.text = @"Please enter the Email Address of the person you would like to receive your Pin.";
        self.emailTf.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else
    {
        self.titleLbl.text = @"Please enter the phone number (10 digits including Country Code) to the person you would like to receive your Pin.";
        self.emailTf.keyboardType = UIKeyboardTypeNumberPad;
    }
    
    if([self.contactStr length] > 0)
        self.emailTf.text = self.contactStr;
    
    [self.coverView.layer setBorderWidth:0.6];
    [self.coverView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];

}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSend:(id)sender {
    
    if([self.emailTf.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Input Verification Code" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        
        return;
    }
    
    [self showHUD:@"Checking..."];
    
    ASIFormDataRequest *request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getUserFunctionURL:FUNC_USER_SEND_PINCODE] delegate:self];
    if(self.type == 0)
        [request setPostValue:self.emailTf.text forKey:@"email"];
    else
        [request setPostValue:[Utils getSafePhoneNumber:self.emailTf.text] forKey:@"phone"];
    [request startAsynchronous];

}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideHUD];
    
    NSString    *value = [request responseString];
    NSLog(@"Value = %@", value);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    
//    NSLog(@"value = %@", json);
    
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    
    if(status == 200)
    {
        [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Your Pincode was sent successfully." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        
    }
    else //if(status == 402)
    {
        
        if(self.type == 1)
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"PhoneNumber is invalid" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
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
    
    [self onBack:nil];
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(textField == self.emailTf && self.type == 1)
    {
        NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        if( [[string uppercaseString] isEqualToString:[filtered uppercaseString]])
        {
            NSString * searchStr = [[textField.text stringByReplacingCharactersInRange:range withString:string] stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            NSLog(@"%@", searchStr);
            
            textField.text = searchStr;
            
            return NO;
        }
        
        return NO;
        
    }
    return YES;
}

#pragma mark -
#pragma mark - UITouchEvent Delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.emailTf resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
