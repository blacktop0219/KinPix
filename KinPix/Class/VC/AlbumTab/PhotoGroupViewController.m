

#import "PhotoGroupViewController.h"
#import "AlbumEditViewController.h"
#import "BucketEditViewController.h"
#import "AlbumViewCell.h"
#import "AlbumInfoStruct.h"
#import "BucketViewCell.h"
#import "BucketInfoStruct.h"
#import "GroupHeadCell.h"

@interface PhotoGroupViewController ()
{
    NSInteger iCurrentIdx;
    UIImage *placeImage;
    BOOL bMySectionShowed, bFriendSctionShowd;
}
@end

@implementation PhotoGroupViewController

@synthesize covAlbum, covBucket;
@synthesize segOption, scvView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //bMySectionShowed = YES;
    //bFriendSctionShowd = NO;
    CGSize screensize = [UIScreen mainScreen].bounds.size;
    
    CGRect rect = covAlbum.frame;
    rect.origin.x = 320;
    covBucket.frame = rect;
    
    rect = scvView.frame;
    rect.size.width = 640;
    rect.size.height = screensize.height - rect.origin.y - 48;
    scvView.contentSize = rect.size;
    scvView.delegate = self;
    
    CGRect recttmp = covAlbum.frame;
    recttmp.size.height = rect.size.height;
    covAlbum.frame = recttmp;
    
    recttmp = covBucket.frame;
    recttmp.size.height = rect.size.height;
    covBucket.frame = recttmp;
    
    placeImage = [Utils getDefaultProfileImage];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.covAlbum reloadData];
    [self.covBucket reloadData];
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getGroupFunctionURL:FUNC_BUCKET_GET_FRIENDS] tag:TYPE_GET_FRIENDS_BUCKET delegate:self];
    [self.request startAsynchronous];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
        if (request.tag == TYPE_GET_FRIENDS_BUCKET)
        {
            [[AppDelegate sharedInstance] refreshOnlyFriendBucket:[json objectForKey:@"friendbucket"]];
            [self.covBucket reloadData];
        }
        else if ([self isAlbumSelected])
        {
            [[AppDelegate sharedInstance] refreshMyAlbumInfos:[json objectForKey:@"albums"]];
            [self.covAlbum reloadData];
        }
        else
        {
            [[AppDelegate sharedInstance] refreshBucketInfos:[json objectForKey:@"buckets"]];
            [self.covBucket reloadData];
        }
    }
    else if(status == 402)
    {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - UICollectionViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scvView.contentOffset.x  < 200)
        segOption.selectedSegmentIndex = 0;
    else
        segOption.selectedSegmentIndex = 1;
}

#pragma mark - UICollectionViewDataSource Methods


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == covBucket)
        return 2;
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        GroupHeadCell *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"groupHeadCell" forIndexPath:indexPath];
        reusableview = headerView;
        if (indexPath.section == 0)
        {
            headerView.lblTitle.text = [NSString stringWithFormat:@"My Group Albums(%d)", (int)[[AppDelegate sharedInstance].arrMyBucket count]];
            headerView.btnHeader.selected = bMySectionShowed;
        }
        else if (indexPath.section == 1)
        {
            headerView.lblTitle.text = [NSString stringWithFormat:@"Group Albums(%d) people have shared with you",
                                        (int)[[AppDelegate sharedInstance].arrFriendBucket count]];
            headerView.btnHeader.selected = bFriendSctionShowd;
        }
        headerView.btnHeader.tag = indexPath.section;
        
    }
    
    return reusableview;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == covBucket)
    {
        if (section == 0)
            return bMySectionShowed ? [[AppDelegate sharedInstance].arrMyBucket count] + 1 : 0;
        
        return bFriendSctionShowd ? [[AppDelegate sharedInstance].arrFriendBucket count] : 0;
    }
    
    return [[AppDelegate sharedInstance].arrMyAlbums count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == covBucket)
    {
        BucketViewCell *cell;
        if (indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bucketViewCell" forIndexPath:indexPath];
                cell.viewAdd.hidden = NO;
                cell.viewMain.hidden = YES;
            }
            else
            {
                BucketInfoStruct *info = [[AppDelegate sharedInstance].arrMyBucket objectAtIndex:indexPath.row - 1];
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bucketViewCell" forIndexPath:indexPath];
                cell.viewAdd.hidden = YES;
                cell.viewMain.hidden = NO;
                cell.btnOption.hidden = NO;
                
                cell.btnOption.tag = indexPath.row - 1;
                cell.btnBucket.tag = indexPath.row - 1;
                cell.lblBucketName.font = [UIFont fontWithName:@"Helvetica" size:11];
                cell.lblBucketName.text = [info getBucketName:YES];
                [cell.ivProfile sd_setImageWithURL:[[AppDelegate sharedInstance].objUserInfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
            }
        }
        else
        {
            BucketInfoStruct *info = [[AppDelegate sharedInstance].arrFriendBucket objectAtIndex:indexPath.row];
            FriendInfoStruct *finfo = [[AppDelegate sharedInstance] findFriendInfo:[info getUserID]];
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"bucketViewCell" forIndexPath:indexPath];
            
            cell.viewAdd.hidden = YES;
            cell.viewMain.hidden = NO;
            cell.btnOption.hidden = YES;
            
            cell.btnBucket.tag = indexPath.row + 1000;
            cell.lblBucketName.font = [UIFont fontWithName:@"Helvetica" size:11];
            cell.lblBucketName.text = [info getBucketName:YES];
            [cell.ivProfile sd_setImageWithURL:[finfo getPhotoURL] placeholderImage:placeImage options:SDWebImageRefreshCached];
        }
        
        return cell;
    }
    else
    {
        AlbumViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumViewCell" forIndexPath:indexPath];
        
        if(indexPath.row == 0)
        {
            cell.viewAdd.hidden = NO;
            cell.viewAlbum.hidden = YES;
            cell.btnMain.tag = indexPath.row;
        }
        else
        {
            cell.viewAdd.hidden = YES;
            cell.viewAlbum.hidden = NO;
            cell.btnPopover.tag = indexPath.row - 1;
            cell.btnMain.tag = indexPath.row - 1;
            
            cell.lblName.font = [UIFont fontWithName:@"Helvetica" size:11];
            AlbumInfoStruct *albuminfo = [[AppDelegate sharedInstance].arrMyAlbums objectAtIndex:(indexPath.row - 1)];
            cell.lblName.text = [albuminfo getAlbumName];
            cell.btnPopover.hidden = ![albuminfo canDelete];
        }
        
        return cell;
    }
    
}

- (IBAction)processAddAction:(id)sender
{
    if ([self isAlbumSelected])
    {
        if([[AppDelegate sharedInstance].arrMyAlbums count] >= 50)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You have reached the maximum number of Album.  Please contact support@kinpix.co for assistance" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;
        }
        
        [self performSegueWithIdentifier:@"createAlbum" sender:nil];
    }
    else
    {
        if([[AppDelegate sharedInstance].arrMyBucket count] >= 50)
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You have reached the maximum number of Group Album.  Please contact support@kinpix.co for assistance" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
            return;
        }
        
        [self performSegueWithIdentifier:@"createBucket" sender:nil];
    }
    
}

- (BOOL) isAlbumSelected
{
    return segOption.selectedSegmentIndex == 0;
}

- (IBAction)processOptionAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIdx = btn.tag;
    if ([self isAlbumSelected])
    {
        AlbumInfoStruct *info = [[AppDelegate sharedInstance].arrMyAlbums objectAtIndex:iCurrentIdx];
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" from your album list?", [info getAlbumName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = 0x700;
        [alertview show];
    }
    else
    {
        BucketInfoStruct *info = [[AppDelegate sharedInstance].arrMyBucket objectAtIndex:iCurrentIdx];
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" from your group album list?", [info getBucketName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
        alertview.tag = 0x800;
        [alertview show];
    }
}

- (IBAction) processSelectAction:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIdx = (int)btn.tag;

    AlbumEditViewController *controllerAlbumEdit = (AlbumEditViewController *)[[AppDelegate sharedInstance] getUIViewController:@"groupEditVC"];
    if ([self isAlbumSelected])
    {
        controllerAlbumEdit.objAlbum = [[AppDelegate sharedInstance].arrMyAlbums objectAtIndex:iCurrentIdx];
    }
    else
    {
        controllerAlbumEdit.bBucketMode = YES;
        if (iCurrentIdx >= 1000)
            controllerAlbumEdit.objBucket = [[AppDelegate sharedInstance].arrFriendBucket objectAtIndex:iCurrentIdx - 1000];
        else
            controllerAlbumEdit.objBucket = [[AppDelegate sharedInstance].arrMyBucket objectAtIndex:iCurrentIdx];
    }
    [self.navigationController pushViewController:controllerAlbumEdit animated:YES];
}


#pragma mark -
#pragma mark - UITouchEvent Delegate

- (IBAction)switchViewOption:(id)sender
{
    if (segOption.selectedSegmentIndex == 1)
        [self showPage:NO];
    else
        [self showPage:YES];
}

- (IBAction)processHeaderAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    if (btn.tag == 0) // My
    {
        bMySectionShowed = btn.selected;
    }
    else
    {
        bFriendSctionShowd = btn.selected;
    }
    
    [covBucket reloadData];
}

-(void) showPage:(BOOL)bAlbum
{
    if (bAlbum)
        [scvView scrollRectToVisible:covAlbum.frame animated:YES];
    else
        [scvView scrollRectToVisible:covBucket.frame animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if(buttonIndex == 0)
    {
        if ([self isAlbumSelected])
        {
            AlbumInfoStruct *albuminfo = [[AppDelegate sharedInstance].arrMyAlbums objectAtIndex:iCurrentIdx];
            [self showHUD:@"Processing..."];
            
            [self.request clearDelegatesAndCancel];
            
            self.request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_ALBUM_DELETE] delegate:self];
            [self.request setPostValue:[albuminfo getAlbumIDToString] forKey:@"albumid"];
            [self.request startAsynchronous];
        }
        else
        {
            BucketInfoStruct *info = [[AppDelegate sharedInstance].arrMyBucket objectAtIndex:iCurrentIdx];
            [self showHUD:@"Processing..."];
            
            [self.request clearDelegatesAndCancel];
            
            self.request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getGroupFunctionURL:FUNC_BUCKET_DELETE] delegate:self];
            [self.request setPostValue:[info getBucketIDToString] forKey:@"bucketid"];
            [self.request startAsynchronous];
        }
    }
}

@end
