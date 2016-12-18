//
//  ShareViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "ShareViewController.h"
#import "SharePhotoViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AviarySDK/AviarySDK.h>

@interface ShareViewController ()<AFPhotoEditorControllerDelegate, UINavigationControllerDelegate>

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.
    
    self.b_isFromCamera = NO;
    [AppDelegate sharedInstance].maxPhotoCount = max_sharePhotoCount;
    self.btnBack.hidden = !self.bShowBack;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.b_isFromCamera = NO;
}

- (IBAction)onCancel:(id)sender
{
    [[AppDelegate sharedInstance] refreshShareEnvironment];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)onPhoto:(id)sender
{
    self.b_isFromCamera = NO;
    [AppDelegate sharedInstance].maxPhotoCount = (int)(max_sharePhotoCount -  [[AppDelegate sharedInstance].arrSharePhotos count]);
    IQMediaPickerController *controller = [[IQMediaPickerController alloc] init];
    controller.delegate = self;
    [controller setMediaType:IQMediaPickerControllerMediaTypePhotoLibrary];
    controller.allowsPickingMultipleItems = YES;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onCamera:(id)sender
{
    self.b_isFromCamera = YES;
    NSString *model = [[UIDevice currentDevice] model];
    if ([model rangeOfString:@"Simulator"].location != NSNotFound)
        return;
    
    [TGCamera setOption:kTGCameraOptionSaveImageToDevice value:[NSNumber numberWithBool:NO]];
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [self presentViewController:navigationController animated:YES completion:nil];
}


- (IBAction)processBackAction:(id)sender
{
    if ([AppDelegate sharedInstance].arrSharePhotos.count > 0)
    {
        UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel sharing a photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alert.tag = 3000;
        [alert show];
        return;
    }
    [[AppDelegate sharedInstance] refreshShareEnvironment];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if(alertView.tag == 3000)
    {
        if(buttonIndex == 0)
        {
            [[AppDelegate sharedInstance] refreshShareEnvironment];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark -
#pragma mark - IQMediaPickerController Delegate
- (void)mediaPickerController:(IQMediaPickerController*)controller didFinishMediaWithInfo:(NSDictionary *)info;
{
//    NSLog(@"Info: %@",info);

    NSMutableDictionary *mediaDict = [NSMutableDictionary dictionaryWithDictionary:info];
    
    NSString *key = [[mediaDict allKeys] objectAtIndex:0];

    for(NSDictionary *dict in [mediaDict objectForKey:key])
    {
        UIImage *imgData = (UIImage *)[dict objectForKey:IQMediaImage];
        if([AppDelegate sharedInstance].arrSharePhotos == nil)
            [AppDelegate sharedInstance].arrSharePhotos = [[NSMutableArray alloc] init];
        
        PhotoInfoStruct *info = [[PhotoInfoStruct alloc] init];
        [info setPhoto:imgData];
        //[info setSize:[[dict objectForKey:IQMediaSize] integerValue]];
        
        [[AppDelegate sharedInstance].arrSharePhotos addObject:info];
        [AppDelegate sharedInstance].maxPhotoCount = (int)(max_sharePhotoCount -  [[AppDelegate sharedInstance].arrSharePhotos count]);
    }

    [self performSegueWithIdentifier:@"goSharePhoto" sender:nil];
    
}

- (void)mediaPickerControllerDidCancel:(IQMediaPickerController *)controller;
{
}

#pragma mark -
#pragma mark - TGCameraDelegate

- (void)cameraDidTakePhoto:(UIImage *)image
{
    NSLog(@"Max Count = %d", [AppDelegate sharedInstance].maxPhotoCount);
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self launchPhotoEditorWithImage:image highResolutionImage:nil];
    }];
}

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - Photo Editor Creation and Presentation
- (void) launchPhotoEditorWithImage:(UIImage *)editingResImage highResolutionImage:(UIImage *)highResImage
{
    // Customize the editor's apperance. The customization options really only need to be set once in this case since they are never changing, so we used dispatch once here.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setPhotoEditorCustomizationOptions];
    });
    
    if (!editingResImage)
        return;
    
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
    if([AppDelegate sharedInstance].arrSharePhotos == nil)
        [AppDelegate sharedInstance].arrSharePhotos = [[NSMutableArray alloc] init];
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    UIImage *finalImage = [UIImage imageWithData:imgData];

    PhotoInfoStruct *info = [[PhotoInfoStruct alloc] init];
    [info setPhoto:finalImage];

    [[AppDelegate sharedInstance].arrSharePhotos addObject:info];
    [AppDelegate sharedInstance].maxPhotoCount = (int)(max_sharePhotoCount -  [[AppDelegate sharedInstance].arrSharePhotos count]);
    [self dismissViewControllerAnimated:NO completion:nil];
    [self performSegueWithIdentifier:@"goSharePhoto" sender:nil];

}

// This is called when the user taps "Cancel" in the photo editor.
- (void) photoEditorCanceled:(AFPhotoEditorController *)editor
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        ;
 }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
