//
//  LikerViewController.m
//  Zinger
//
//  Created by Piao Dev on 20/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "LikerViewController.h"
#import "ParseData.h"
#import "LikerInfoStruct.h"
#import "LikeUserViewCell.h"

@interface LikerViewController ()
{
    PullToRefreshView   *viewPull;
    NSMutableArray *arrLikers;
    BOOL bLoading;
    BOOL bEndFlag;
}
@end

@implementation LikerViewController

@synthesize iLikeCount, iPhotoID;
@synthesize tblLikers, lblTitle, lblNoResult;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //lblTitle.text = [NSString stringWithFormat:@"%d LIKERS", (int)iLikeCount];
    tblLikers.layer.borderColor = [UIColor grayColor].CGColor;
    tblLikers.layer.borderWidth = 0.3;
    
    arrLikers = [[NSMutableArray alloc] init];
    
    viewPull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *)tblLikers];
    viewPull.delegate = self;
    [self pullToRefreshViewShouldRefresh:nil];
    [tblLikers addSubview:viewPull];
    viewPull.backgroundColor = [UIColor clearColor];
    
    tblLikers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(IBAction)processBackAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - pull delegate
-(void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view
{
    lblNoResult.hidden = YES;
    [self reloadLikeInfo:0 loadmoreflag:NO];
    [viewPull setState:PullToRefreshViewStateLoading];
}

-(void) reloadLikeInfo:(NSInteger)likerid loadmoreflag:(BOOL)loadmoreflag
{
    if (likerid < 1 || [arrLikers count] < 1)
    {
        [arrLikers removeAllObjects];
        bEndFlag = NO;
    }
    
    if (loadmoreflag && (bEndFlag || bLoading))
        return;
    
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_GET_LIKERS] tag:TYPE_FILTER_PHOTO delegate:self];
    [self.request setPostValue:[Utils getStringFromInteger:iPhotoID] forKey:@"photoid"];
    [self.request setPostValue:[Utils getStringFromInteger:likerid] forKey:@"likeid"];
    [self.request startAsynchronous];
    bLoading = YES;
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
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
        NSArray *arr = [json objectForKey:@"likers"];
        if ([arr count] < 1)
            bEndFlag = YES;
        [ParseData parseLikeInfo:arr destination:arrLikers breqinit:NO];
        [self refreshFilterResult:NO];
    }
    else
    {
        if (request.tag == TYPE_DELETE_PHOTO)
            [AppDelegate showMessage:@"Can't delete this photo." withTitle:@"Error"];
    }
    
    if (request.tag == TYPE_FILTER_PHOTO)
    {
        bLoading = NO;
        [viewPull finishedLoading];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    if (request.tag == TYPE_FILTER_PHOTO)
    {
        [viewPull finishedLoading];
        bLoading = NO;
    }
}

-(void) refreshFilterResult:(BOOL)bError
{
    if (bError)
    {
        [arrLikers removeAllObjects];
        [tblLikers reloadData];
        lblNoResult.hidden = NO;
        return;
    }
    
    if ([arrLikers count] < 1)
        lblNoResult.hidden = NO;
    else
        lblNoResult.hidden = YES;
    
    [tblLikers reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - tableview delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrLikers count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LikerInfoStruct *info = [arrLikers objectAtIndex:indexPath.row];
    LikeUserViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"likeUserViewCell"];
    [cell initWithLikeData:info];
    
    if (indexPath.row == (arrLikers.count - 1) && [arrLikers count] > 20)
    {
        LikerInfoStruct *info = [arrLikers objectAtIndex:indexPath.row - 1];
        [self reloadLikeInfo:[info getLikeID] loadmoreflag:YES];
    }
    
    return cell;
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
