//
//  ShareKindSelectViewController.m
//  KinPix
//
//  Created by Piao Dev on 23/02/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "ShareKindSelectViewController.h"
#import "ShareSelectBucketViewController.h"

@implementation ShareKindSelectViewController
{
    UIColor *selectedColor;
}
@synthesize btnShareAlbum, btnShareBucket, btnAlbumInfo, btnBucketInfo;
@synthesize viewAlbumInfo, viewBucketInfo;
@synthesize lblAlbumInfo, lblAlbumTitle, lblBucketInfo, lblBucketTitle;

-(void) viewDidLoad
{
    [viewAlbumInfo.layer setCornerRadius:7.0];
    viewAlbumInfo.layer.borderColor = mainColor.CGColor;
    viewAlbumInfo.layer.borderWidth = 0.7f;
    
    [viewBucketInfo.layer setCornerRadius:7.0];
    viewBucketInfo.layer.borderColor = mainColor.CGColor;
    viewBucketInfo.layer.borderWidth = 0.7f;
    
    selectedColor = [UIColor colorWithRed:1.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0];
    btnShareAlbum.selected = [AppDelegate sharedInstance].bAlbumMode;
    btnShareBucket.selected = [AppDelegate sharedInstance].bBucketMode;
    [self refreshViewState:NO];
}

-(void) refreshViewState:(BOOL)animation
{
     if (animation)
     {
         [UIView animateWithDuration:1.0 animations:^{
             [self refreshView];
         }];
     }
    else
    {
        [self refreshView];
    }
}

-(void) refreshView
{
    btnAlbumInfo.selected = btnShareAlbum.selected;
    btnBucketInfo.selected = btnShareBucket.selected;
    if (btnShareAlbum.selected)
    {
        viewAlbumInfo.layer.borderColor = [[UIColor redColor] CGColor];
        lblAlbumTitle.textColor = [UIColor redColor];
        lblAlbumInfo.textColor = [UIColor redColor];
    }
    else
    {
        viewAlbumInfo.layer.borderColor = mainColor.CGColor;
        lblAlbumTitle.textColor = mainColor;
        lblAlbumInfo.textColor = mainColor;
    }
    
    if (btnShareBucket.selected)
    {
        viewBucketInfo.layer.borderColor = [[UIColor redColor] CGColor];
        lblBucketTitle.textColor = [UIColor redColor];
        lblBucketInfo.textColor = [UIColor redColor];
    }
    else
    {
        viewBucketInfo.layer.borderColor = mainColor.CGColor;
        lblBucketInfo.textColor = mainColor;
        lblBucketTitle.textColor = mainColor;
    }
}

- (IBAction)processOptionSelected:(id)sender
{
    if (sender == btnShareAlbum)
    {
        btnShareAlbum.selected = YES;
        btnShareBucket.selected = NO;
    }
    else
    {
        btnShareBucket.selected = YES;
        btnShareAlbum.selected = NO;
    }
    
    [self refreshViewState:YES];
    [self refreshInformationFrame:YES];
}

- (IBAction)processBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)processNextAction:(id)sender
{
    if ([btnShareAlbum isSelected])
    {
        if ([btnShareAlbum isSelected] != [AppDelegate sharedInstance].bAlbumMode)
        {
            [[AppDelegate sharedInstance].arrShareAlbums removeAllObjects];
            [[AppDelegate sharedInstance].arrShareGroups removeAllObjects];
            [[AppDelegate sharedInstance].arrShareFriends removeAllObjects];
        }
        
        if ([AppDelegate sharedInstance].arrShareAlbums.count < 1)
        {
            AlbumInfoStruct *defaultAlbum = [[AppDelegate sharedInstance] findAlbumInfo:@"Default"];
            if (defaultAlbum)
                [[AppDelegate sharedInstance].arrShareAlbums addObject:defaultAlbum];
        }
        
        [AppDelegate sharedInstance].bAlbumMode = YES;
        [AppDelegate sharedInstance].bBucketMode = NO;
        [self performSegueWithIdentifier:@"goSharePeople" sender:nil];
    }
    else if ([btnShareBucket isSelected])
    {
        if ([btnShareBucket isSelected] != [AppDelegate sharedInstance].bBucketMode)
        {
            [[AppDelegate sharedInstance].arrShareAlbums removeAllObjects];
        }
        
        [AppDelegate sharedInstance].bAlbumMode = NO;
        [AppDelegate sharedInstance].bBucketMode = YES;
        [self performSegueWithIdentifier:@"gotoSelectBucket" sender:nil];
    }
    else
    {
        [AppDelegate showMessage:@"Please select share type" withTitle:@"Warning"];
    }
}

- (void) cancelShare
{
    [[AppDelegate sharedInstance] refreshShareEnvironment];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
        
    if(alertView.tag == 3000)
    {
        if(buttonIndex == 0)
            [self cancelShare];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([[segue identifier] isEqualToString:@"gotoSelectBucket"])
    {
        ShareSelectBucketViewController *viewController = (ShareSelectBucketViewController *)[segue destinationViewController];
        viewController.arrSelectedBucket = [AppDelegate sharedInstance].arrShareAlbums;
    }
//    else if ([[segue identifier] isEqualToString:@"gotoSelectAlbums"])
//    {
//        ShareSelectAlbumViewController *viewController = (ShareSelectAlbumViewController*)[segue destinationViewController];
//        viewController.arrSelectedAlbums = [AppDelegate sharedInstance].arrShareAlbums;
//    }
}

- (IBAction)processCancelAction:(id)sender
{
    UIAlertView *alert =  [[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to cancel sharing a photo?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alert.tag = 3000;
    [alert show];
}

-(void) refreshInformationFrame:(BOOL)animation
{
    return;
    
    if (![btnShareAlbum isSelected])
        viewAlbumInfo.alpha = 0;
    
    if (![btnShareBucket isSelected])
        viewBucketInfo.alpha = 0;
    
    if (animation)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        if ([btnShareAlbum isSelected])
            viewAlbumInfo.alpha = 1;
        
        if ([btnShareBucket isSelected])
            viewBucketInfo.alpha = 1;
        [UIView commitAnimations];
    }
    else
    {
        if ([btnShareAlbum isSelected])
            viewAlbumInfo.alpha = 1;
        if ([btnShareBucket isSelected])
            viewBucketInfo.alpha = 1;
    }
}


@end
