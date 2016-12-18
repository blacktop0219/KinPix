//
//  CreateAlbumViewController.m
//  Zinger
//
//  Created by QingHou on 11/20/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "CreateAlbumViewController.h"
#import "SharePhotoViewController.h"
#import "ActionSheetDatePicker.h"

@interface CreateAlbumViewController ()

@end

@implementation CreateAlbumViewController

@synthesize lblDate, btnCalender, txtAlbumName;
@synthesize swiExpiryDate, lblTitle;
@synthesize info, btnCreate;
@synthesize bShareMode;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.
    
    [swiExpiryDate.layer setCornerRadius:15.0];
    [swiExpiryDate setOn:NO];
    lblDate.text = [Utils getStrigFromDate:[NSDate date]];
    
    if (info)
    {
        txtAlbumName.text = [info getAlbumName];
        self.swiExpiryDate.on = [info hasExpire];
        if ([info hasExpire])
            lblDate.text = [info getExpiryDate];
        [btnCreate setImage:[UIImage imageNamed:@"saveBtn.png"] forState:UIControlStateNormal];
        lblTitle.text = @"Album Properties";
    }
    [self refreshUI];
}

-(void) refreshUI
{
    lblDate.enabled = [swiExpiryDate isOn];
    btnCalender.enabled = [swiExpiryDate isOn];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.txtAlbumName becomeFirstResponder];
}

- (void) createAlbum
{
    if([self.txtAlbumName.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Input Album name" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        
        return;
    }
    
    NSDate *date = [Utils getDateFromString:lblDate.text];
    if (swiExpiryDate.isOn && [date compare:[NSDate date]] == NSOrderedAscending)
    {
        [AppDelegate showMessage:@"Please select correct expiry date." withTitle:@"Error"];
        return;
    }
    

    ASIFormDataRequest *request;
    if (info)
    {
        [self showHUD:@"Updating.."];
        request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_ALBUM_UPDATE] delegate:self];
        [request setPostValue:[info getAlbumIDToString] forKey:@"albumid"];
    }
    else
    {
        [self showHUD:@"Creating.."];
        request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_ALBUM_CREATE] delegate:self];
    }
    
    [request setPostValue:self.txtAlbumName.text forKey:@"name"];
    if (swiExpiryDate.on)
        [request setPostValue:@"1" forKey:@"expflag"];
    [request setPostValue:lblDate.text forKey:@"expdate"];
    [request setPostValue:@"1" forKey:@"deleteflag"];
    [request startAsynchronous];
}

#pragma mark -
#pragma mark - ASIHTTPRequest Delegate

-(void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideHUD];
     NSLog(@"Share Result = %@", [request responseString]);
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    if(status == 200)
    {
        [[AppDelegate sharedInstance] refreshMyAlbumInfos:[json objectForKey:@"albums"]];
        if (bShareMode)
        {
            [_arrAlbumArray addObject:[[AppDelegate sharedInstance] findAlbumInfo:txtAlbumName.text]];
            [self onBack:nil];
        }
        else
        {
            NSString *strMsg;
            if (info)
            {
                info = [[AppDelegate sharedInstance] findAlbumInfo:txtAlbumName.text];
                if (_albumdelegate)
                    [_albumdelegate updateAlbum:info];
                strMsg = [NSString stringWithFormat:@"%@ album was saved", txtAlbumName.text];
            }
            else
                strMsg = [NSString stringWithFormat:@"%@ album was created", txtAlbumName.text];
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Information" message:strMsg delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            alertview.tag = 2000;
            [alertview show];
        }        
    }
}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onCreate:(id)sender
{
    [self.txtAlbumName resignFirstResponder];
    [self createAlbum];
}

- (IBAction)processCalendar:(id)sender
{
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Expiry Date" datePickerMode:UIDatePickerModeDate selectedDate:[Utils getDateFromString:lblDate.text] target:self action:@selector(timeWasSelected:element:) origin:lblDate];
    datePicker.minuteInterval = 4;
    [datePicker showActionSheetPicker];
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    [element setText:[Utils getStrigFromDate:selectedTime]];
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

- (IBAction)processExpiryAction:(id)sender
{
    [self refreshUI];
}

- (IBAction)processTabAction:(id)sender
{
    [txtAlbumName resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processTabAction:nil];
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
    
    if (alertView.tag == 2000)
    {
        [self onBack:nil];
    }
}

#pragma mark - textfield delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}


@end
