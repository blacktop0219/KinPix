//
//  TrendingViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "TrendingViewController.h"
#import "ActionSheetStringPicker.h"
#import "TrendingCollectionViewCell.h"
#import "PhotoDetailViewController.h"
#import "SettingsViewController.h"

@interface TrendingViewController ()
{
    NSInteger iViewType;
    NSInteger iViewCount;
    NSMutableArray *arrPhotos;
}
@end

@implementation TrendingViewController

@synthesize lblViewCount, lblViewType;
@synthesize covPhotos;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *arrControllers = self.navigationController.viewControllers;
    if (arrControllers.count > 1)
    {
        UIViewController *controller = [arrControllers objectAtIndex:arrControllers.count - 2];
        if ([controller isKindOfClass:[SettingsViewController class]])
            [self hideButtons];
    }
    
    iViewType = 0;
    iViewCount = 10;
    
    lblViewType.text = @"Most Viewed";
    lblViewCount.text = @"Top 10";
    arrPhotos = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

-(void) viewWillAppear:(BOOL)animated
{
    [covPhotos reloadData];
    [self reloadViewData];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.request clearDelegatesAndCancel];
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

- (IBAction)processViewCount:(id)sender
{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([lblViewCount respondsToSelector:@selector(setText:)])
            [lblViewCount performSelector:@selector(setText:) withObject:selectedValue];
        
        iViewCount = (selectedIndex + 1) * 10;
        [self reloadViewData];
    };
    
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
    };
    
    NSArray *arrItems = [NSArray arrayWithObjects:@"Top 10", @"Top 20", @"Top 30", @"Top 40", @"Top 50", nil];
    [ActionSheetStringPicker showPickerWithTitle:@"Select Photo Count" rows:arrItems initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.lblViewCount];
}

- (IBAction)processViewType:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Most Viewed", @"Most Liked", @"Most Commented", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0x10000)
    {
        if (buttonIndex == 1)
            return;
        
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (buttonIndex == 0) // Most viewed
    {
        lblViewType.text = @"Most Viewed";
    }
    else if(buttonIndex == 1) // Most Liked
    {
        lblViewType.text = @"Most Liked";
    }
    else if (buttonIndex == 2) // Most Commented
    {
        lblViewType.text = @"Most Commented";
    }
    
    iViewType = buttonIndex;
    [self reloadViewData];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoDetailViewController *controller = (PhotoDetailViewController *)[[AppDelegate sharedInstance] getUIViewController:@"photoDetailVC"];
    controller.arrViewPhotos = arrPhotos;
    controller.iCurrentIdx = indexPath.row;
    [self.navigationController pushViewController:controller animated:YES];
}


-(void) reloadViewData
{
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_TRENDINGINFO] tag:TYPE_FILTER_PHOTO delegate:self];
    
    [self.request setPostValue:[Utils getStringFromInteger:iViewType] forKey:@"type"];
    [self.request setPostValue:[Utils getStringFromInteger:iViewCount] forKey:@"count"];
    [self.request startAsynchronous];
}

#pragma mark - UICollectionViewDataSource Methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrPhotos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TrendingCollectionViewCell *cell;
    PhotoInfoStruct *info = [arrPhotos objectAtIndex:indexPath.row];
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"trendingCollectionViewCell" forIndexPath:indexPath];
    [cell.ivPhoto sd_setImageWithURL:[info getPhotoURL] placeholderImage:nil];
    
    if (iViewType == 0)
        cell.lblLabel.text = [NSString stringWithFormat:@"%d views", (int)[info getViewCount]];
    else if (iViewType == 1)
        cell.lblLabel.text = [NSString stringWithFormat:@"%d likes", (int)[info getLikeCount]];
    else if (iViewType == 2)
        cell.lblLabel.text = [NSString stringWithFormat:@"%d comments", (int)[info getCommentCount]];
    
    //cell.lblLabel.font = [UIFont fontWithName:@"Helvetica" size:11];
    return cell;
}

- (IBAction)onBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
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
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    if(status == 200)
    {
        NSDictionary *array = [json objectForKey:@"photos"];
        NSMutableArray *arrcomment = [[AppDelegate sharedInstance] getComments:[array objectForKey:@"comments"]];
        [[AppDelegate sharedInstance] refreshPhotoInfo:[array objectForKey:@"photoinfo"] comments:arrcomment arrdes:arrPhotos];
        [covPhotos reloadData];
    }
    else
    {
    }
}

@end
