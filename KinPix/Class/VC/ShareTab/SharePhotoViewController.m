//
//  SharePhotoViewController.m
//  Zinger
//
//  Created by QingHou on 11/14/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "SharePhotoViewController.h"
#import "ShareViewController.h"
#import "CustomSharePhotoCell.h"
#import "SharePeopleViewController.h"
#import "ShareSelectBucketViewController.h"
#import "ShareSelectAlbumViewController.h"
#import <AviarySDK/AviarySDK.h>
#import "SBJson.h"

#define  cellHeight 128

@interface SharePhotoViewController ()<AFPhotoEditorControllerDelegate, S3PhotoUploaderDelegate>
{
    AlbumInfoStruct *albuminfo;
    UITextField *txtLastSelected;
    NSInteger iCurrentIndex;
}
@end

@implementation SharePhotoViewController

@synthesize shareBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    
    if (![self isShareStep] && [AppDelegate sharedInstance].bBucketMode)
        [shareBtn setImage:[UIImage imageNamed:@"btn_rightshare.png"] forState:UIControlStateNormal];
    
    // Do any additional setup after loading the view.
    self.tableView.scrollEnabled = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[AppDelegate sharedInstance] getImageQuality];
    
    [self layoutView];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) layoutView
{
    int photoCount = (int)[[AppDelegate sharedInstance].arrSharePhotos count];
    
    NSInteger posy;
    CGRect rect = self.tableView.frame;
    rect.size.height = cellHeight * photoCount;
    self.tableView.frame = rect;
    posy = rect.origin.y + rect.size.height;
    
    self.scrollView.contentSize = CGSizeMake(320, rect.origin.y + rect.size.height + 20);
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[AppDelegate sharedInstance].arrSharePhotos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomSharePhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomSharePhotoCell" forIndexPath:indexPath];
    
    cell.btnPopover.tag = indexPath.row;
    cell.btnEditPhoto.tag = indexPath.row;
    cell.svTag.tag = indexPath.row;
   
    PhotoInfoStruct *info =[[AppDelegate sharedInstance].arrSharePhotos objectAtIndex:indexPath.row];
    cell.ivImage.image = [info getPhoto];
    cell.txtTitle.text = [info getTitle];
    cell.txtTitle.tag = 0x100;
    [cell setTagArray:[info getTagArray]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAddPhoto:(id)sender {
    
    if([[AppDelegate sharedInstance].arrSharePhotos count] >= max_sharePhotoCount)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"You can't add more than %d photos", max_sharePhotoCount] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
    else
    {
        NSMutableArray *array = [AppDelegate sharedInstance].arrSharePhotos;
        for (int i = 0; i < array.count; i++)
        {
            PhotoInfoStruct *info = [array objectAtIndex:i];
            CustomSharePhotoCell *cell = (CustomSharePhotoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [info setTitle:cell.txtTitle.text];
            [info setTagArray:cell.tokens];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) cancelShare
{
    [[AppDelegate sharedInstance] refreshShareEnvironment];    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)onCancel:(id)sender
{
    UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel sharing a photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 3000;
    [alert show];
}

- (BOOL) isShareStep
{
    ShareViewController *viewController = nil;
    NSArray *arrControllers = self.navigationController.viewControllers;
    
    for (NSInteger i = arrControllers.count - 1; i >= 0; i--)
    {
        UIViewController *controller = [arrControllers objectAtIndex:i];
        if ([controller isKindOfClass:[ShareViewController class]])
        {
            viewController = (ShareViewController *)controller;
            break;
        }
    }
    
    return !viewController.bShowBack;
}

- (IBAction)onGoSharePhoto:(id)sender
{
    [self onTouch:nil];
    if([[AppDelegate sharedInstance].arrSharePhotos count] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select Photo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil] show];
        return;
    }
    
    [self saveCurrentInputedData];
    if (![self isShareStep])
    {
        if ([AppDelegate sharedInstance].bAlbumMode)
            [self performSegueWithIdentifier:@"gotoSharePeople" sender:nil];
        else
            [self sharePhoto];
        return;
    }
    [self performSegueWithIdentifier:@"gotoSelectShareOption" sender:nil];
}

-(void) saveCurrentInputedData
{
    NSMutableArray *array = [AppDelegate sharedInstance].arrSharePhotos;
    for (int i = 0; i < array.count; i++)
    {
        PhotoInfoStruct *info = [array objectAtIndex:i];
        CustomSharePhotoCell *cell = (CustomSharePhotoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell completeToken];
        [info setTitle:cell.txtTitle.text];
        [info setTagArray:cell.tokens];
        
        CGSize size = cell.ivImage.image.size;
        [info setWidth:size.width];
        [info setHeight:size.height];
    }
}

- (IBAction)onShowRemove:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    iCurrentIndex = btn.tag;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to remove this photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertView.tag = 0x900;
    [alertView show];
}

- (IBAction)processPhotoEdit:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    iCurrentIndex = btn.tag;
    PhotoInfoStruct *pinfo = [[AppDelegate sharedInstance].arrSharePhotos objectAtIndex:iCurrentIndex];
    [self saveCurrentInputedData];
    [self launchPhotoEditorWithImage:[pinfo getPhoto]];
}

- (IBAction)processCancelAction:(id)sender
{
    UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel sharing a photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 3000;
    [alert show];
}

#pragma mark - Photo Editor

- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage
{
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    // Initialize the photo editor and set its delegate
    AFPhotoEditorController * photoEditor = [[AFPhotoEditorController alloc] initWithImage:editingResImage];
    [photoEditor setDelegate:self];
    
    // If a high res image is passed, create the high res context with the image and the photo editor.
    
    // Present the photo editor.
    [self presentViewController:photoEditor animated:YES completion:nil];
}

#pragma mark - Photo Editor Customization

- (void) setPhotoEditorCustomizationOptions
{
    // Set API Key and Secret
    [AFPhotoEditorController setAPIKey:kAFAviaryAPIKey secret:kAFAviarySecret];
    
    // Set Tool Order
    NSArray * toolOrder = @[kAFEffects, kAFFocus, kAFEnhance, kAFOrientation, kAFCrop, kAFAdjustments, kAFSplash, kAFDraw, kAFText, kAFRedeye, kAFBlemish, kAFMeme];
    [AFPhotoEditorCustomization setToolOrder:toolOrder];
    
    // Set Custom Crop Sizes
    [AFPhotoEditorCustomization setCropToolOriginalEnabled:NO];
    [AFPhotoEditorCustomization setCropToolCustomEnabled:YES];
    NSDictionary * fourBySix = @{kAFCropPresetHeight : @(4.0f), kAFCropPresetWidth : @(6.0f)};
    NSDictionary * fiveBySeven = @{kAFCropPresetHeight : @(5.0f), kAFCropPresetWidth : @(7.0f)};
    NSDictionary * square = @{kAFCropPresetName: @"Square", kAFCropPresetHeight : @(1.0f), kAFCropPresetWidth : @(1.0f)};
    [AFPhotoEditorCustomization setCropToolPresets:@[fourBySix, fiveBySeven, square]];
}

#pragma Photo Editor Delegate Methods

// This is called when the user taps "Done" in the photo editor.
- (void) photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image
{
    [editor dismissViewControllerAnimated:YES completion:nil];
    PhotoInfoStruct *info =[[AppDelegate sharedInstance].arrSharePhotos objectAtIndex:iCurrentIndex];
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    UIImage *finalImage = [UIImage imageWithData:imgData];
    [info setPhoto:finalImage];
    [self.tableView reloadData];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [editor dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (alertView.tag == 0x900)
    {
        if (buttonIndex == 0)
        {
            [self saveCurrentInputedData];
            [[AppDelegate sharedInstance].arrSharePhotos removeObjectAtIndex:iCurrentIndex];
            [self.tableView reloadData];
        }
    }
    else if(alertView.tag == 3000)
    {
        if(buttonIndex == 0)
            [self cancelShare];
    }
    else
        [self cancelShare];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"gotoShareBucket"])
    {
        ShareSelectBucketViewController *viewController = (ShareSelectBucketViewController *)[segue destinationViewController];
        viewController.arrSelectedBucket = [AppDelegate sharedInstance].arrShareAlbums;
    }
    else if ([[segue identifier] isEqualToString:@"gotoSelectAlbums"])
    {
        ShareSelectAlbumViewController *viewController = (ShareSelectAlbumViewController*)[segue destinationViewController];
        viewController.arrSelectedAlbums = [AppDelegate sharedInstance].arrShareAlbums;
    }
}

- (IBAction)onTouch:(id)sender {
    
    for(int i = 0; i < [[AppDelegate sharedInstance].arrSharePhotos count]; i++)
    {
        CustomSharePhotoCell *cell = (CustomSharePhotoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [cell.txtTag removeFocus];
        [cell.txtTitle resignFirstResponder];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouch:nil];
}

#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    txtLastSelected = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    txtLastSelected = nil;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag != 0x100)
        return YES;
    
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
        return NO;
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength >= 140) ? NO : YES;
}


#pragma mark -
#pragma mark -  UIKeyboard Notification

// Called when the UIKeyboardDidShowNotification is received
- (void)keyboardWasShown:(NSNotification *)aNotification
{
    if (![txtLastSelected isFirstResponder])
    {
        UITextField *txtCurrentTag;
        for(int i = 0; i < [[AppDelegate sharedInstance].arrSharePhotos count]; i++)
        {
            CustomSharePhotoCell *cell = (CustomSharePhotoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if ([cell hasFocus])
            {
                txtCurrentTag = cell.txtTag.textField;
                break;
            }
        }
        
        // keyboard frame is in window coordinates
        NSDictionary *userInfo = [aNotification userInfo];
        CGRect keyboardInfoFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        // get the height of the keyboard by taking into account the orientation of the device too
        CGRect windowFrame = [self.view.window convertRect:self.view.frame fromView:self.view];
        CGRect keyboardFrame = CGRectIntersection (windowFrame, keyboardInfoFrame);
        CGRect coveredFrame = [self.view.window convertRect:keyboardFrame toView:self.view];
        
        // add the keyboard height to the content insets so that the scrollview can be scrolled
        UIEdgeInsets contentInsets = UIEdgeInsetsMake (0.0, 0.0, coveredFrame.size.height + 60, 0.0);
        
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        // make sure the scrollview content size width and height are greater than 0
        [self.scrollView setContentSize:CGSizeMake (self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
        
        CGRect rect = txtCurrentTag.frame;
        rect.origin = [txtCurrentTag convertPoint:rect.origin  toView:self.tableView];
        [self.scrollView scrollRectToVisible:rect animated:YES];
    }
    else
    {
        // keyboard frame is in window coordinates
        NSDictionary *userInfo = [aNotification userInfo];
        CGRect keyboardInfoFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        // get the height of the keyboard by taking into account the orientation of the device too
        CGRect windowFrame = [self.view.window convertRect:self.view.frame fromView:self.view];
        CGRect keyboardFrame = CGRectIntersection (windowFrame, keyboardInfoFrame);
        CGRect coveredFrame = [self.view.window convertRect:keyboardFrame toView:self.view];
        
        // add the keyboard height to the content insets so that the scrollview can be scrolled
        UIEdgeInsets contentInsets = UIEdgeInsetsMake (0.0, 0.0, coveredFrame.size.height + 15, 0.0);
        
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        // make sure the scrollview content size width and height are greater than 0
        [self.scrollView setContentSize:CGSizeMake (self.scrollView.contentSize.width, self.scrollView.contentSize.height)];
        
        CGRect rect = txtLastSelected.frame;
        rect.origin = [txtLastSelected convertPoint:rect.origin  toView:self.tableView];
        [self.scrollView scrollRectToVisible:rect animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is received
- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    // scroll back..
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void) sharePhoto
{
    if (![AppDelegate isConnectedToInternet])
    {
        [MessageBox showErrorMsage:MSG_ERR_INTERNET_CONNECT_FAILED];
        return;
    }
    
    [self showM13HUD:@"Sharing..."];
    S3PhotoUploader *uploader = [[AppDelegate sharedInstance] getS3PhotoUploader:self];
    [uploader uploadFeedPhotos:[AppDelegate sharedInstance].arrSharePhotos];
}




-(NSString *) generateNewImageName:(NSString *) userid idx:(int)idx timesec:(NSInteger)timesec randnum:(NSInteger)randnum
{
    return [NSString stringWithFormat:@"%@/%d-%03d_%d.jpg", userid, (int)timesec, (int)randnum, idx];
}

-(void) uploadFinished
{
    [self hideM13HUD];
    [[[UIAlertView alloc] initWithTitle:nil message:@"Your photo(s) are successfully shared." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
}

-(void) uploadFailed:(NSInteger)errorcode
{
    [self hideM13HUD];
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Image upload failed. Please check your internet connection." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
