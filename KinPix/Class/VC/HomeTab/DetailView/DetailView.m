//
//  DetailView.m
//  Zinger
//
//  Created by Piao Dev on 14/01/15.
//  Copyright (c) 2015 Piao Dev. All rights reserved.
//

#import "DetailView.h"
#import "PhotoInfoStruct.h"
#import "CommentViewCell.h"
#import "FriendsViewCell.h"
#import "GroupViewCell.h"

#define DETAIL_TITLE_WIDTH      303
#define DETAIL_TAG_WIDTH        267

#define VIEW_PERMISSION_HEIGHT  347
#define VIEW_USER_PERMISSION    150

#define NAME_WIDTH      140
#define VALUE_WIDTH     210;

@implementation DetailView
{
    UIImage *imgDefault;
    NSMutableArray *arrComments;
    NSMutableArray *arrFamilys;
    NSMutableArray *arrGroups;
    NSMutableArray *arrHeights;
    BOOL bShowPermission;
    BOOL bShowOnlyPermission;
    NSInteger iScreenHeight;
    NSInteger iCurrentIndex;
    ASIFormDataRequest *rrequest;
    UIRefreshControl *refreshControl;
    UIImage *imgPermissionNormal;
    UIImage *imgPermissionViewOnly;
}

@synthesize lblTagTitle, lblTagValue, lblTime, lblTitle, lblUserName;
@synthesize btnFavorite, btnFlag, btnLike, btnMain, btnMore, btnSave;
@synthesize btnPermission, btnComment, lblGroupName, btnLikeCount;
@synthesize viewTitle, covFriends, covGroups, viewTextComment, txtComment;
@synthesize viewButton, viewComment, viewPermission, viewMoveButtons;
@synthesize tblComment, ivImage, pinfo, scView, lblShareKind, doneBtn;
@synthesize lblBucketOwner, lblBucketOwnerValue, lblSharedBy;
@synthesize viewGroup;

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self initView];
    iScreenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGRect rect = scView.frame;
    rect.size.height = iScreenHeight - rect.origin.y - 45 - 72;
    scView.frame = rect;
}

-(void) initView
{
    [self setTopBorder:viewButton];
    [self setTopBorder:viewComment];
    [self setTopBorder:viewTitle];
    [self setTopBorder:viewPermission];
    [self setTopBorder:tblComment];
    
    imgPermissionNormal = [UIImage imageNamed:@"btn_small_permission_normal.png"];
    imgPermissionViewOnly = [UIImage imageNamed:@"btn_small_permission_disable.png"];
    
    [covFriends registerNib:[UINib nibWithNibName:@"FriendsViewCell" bundle:nil] forCellWithReuseIdentifier:@"friendsCollectionCell"];
    [covGroups registerNib:[UINib nibWithNibName:@"GroupViewCell" bundle:nil] forCellWithReuseIdentifier:@"groupCollectionCell"];
    [tblComment registerNib:[UINib nibWithNibName:@"CommentViewCell" bundle:nil] forCellReuseIdentifier:@"detailCommentViewCell"];
    
    arrHeights = [[NSMutableArray alloc] init];
    arrFamilys = [[NSMutableArray alloc] init];
    arrGroups = [[NSMutableArray alloc] init];
    
    bShowPermission = NO;
    viewPermission.hidden = YES;
    self.layer.borderWidth = 0.3;
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.numberOfTapsRequired = 1;
    [tblComment addGestureRecognizer:tapGesture];
    
    tblComment.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = nil;
    [refreshControl addTarget:self action:@selector(refreshPhotoData:) forControlEvents:UIControlEventValueChanged];
    [scView addSubview:refreshControl];
    [self setUpTextFieldforIphone];
}

-(void) hideKeyboard
{
    [txtComment resignFirstResponder];
}

-(void)setUpTextFieldforIphone
{
    viewTextComment = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 45, 320, 45)];
    txtComment = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 7, 250, 23)];
    
    txtComment.minNumberOfLines = 1;
    txtComment.maxNumberOfLines = 5;
    txtComment.returnKeyType = UIReturnKeyDefault; //just as an example
    txtComment.placeholder = @"Add a comment...";
    txtComment.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 2, 0);
    [txtComment setContentInset:UIEdgeInsetsMake(6, 6, 6, 0)];
    [self addSubview:viewTextComment];
    txtComment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [viewTextComment addSubview:txtComment];
    
    doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(viewTextComment.frame.size.width - 62, 7, 55, 29);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [AppDelegate getAppSystemFont:13];
    [doneBtn setBackgroundColor:[UIColor colorWithRed:1.0 / 255.0 green:150.f / 255.0 blue:255.f / 255.0 alpha:1.0f]];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self adjustViewCorner:doneBtn corner:3];
    
    [viewTextComment addSubview:doneBtn];
    viewTextComment.backgroundColor = [UIColor colorWithRed:230.f / 255.0 green:230.f / 255.0 blue:230.f / 255.0 alpha:1.0f];
    viewTextComment.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    [scView addSubview:viewTextComment];
}

-(void) adjustViewCorner:(UIView *)adview corner:(NSInteger)corner
{
    adview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    adview.layer.borderWidth = 0.3;
    adview.layer.cornerRadius = corner;
    
    if ([adview isKindOfClass:[UIImageView class]])
        adview.layer.masksToBounds = YES;
}

- (void)refreshPhotoData:(UIRefreshControl *)refreshControl
{
    [rrequest clearDelegatesAndCancel];
    rrequest = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_DETAIL] tag:TYPE_REFRESH_PHOTOINFO delegate:self];
    [rrequest setPostValue:[pinfo getPhotoIDToString] forKey:@"photoid"];
    [rrequest startAsynchronous];
}

-(void) initWithViewData:(PhotoInfoStruct *) info index:(NSInteger)index
{
    [rrequest clearDelegatesAndCancel];
    [arrFamilys removeAllObjects];
    [arrGroups removeAllObjects];
    [arrHeights removeAllObjects];
    
    if ([pinfo isBucketPhoto])
        [pinfo refreshBucketInfo];
    
    if (!info)
    {
        pinfo = nil;
        [btnLike setSelected:NO];
        [btnFavorite setSelected:NO];
        ivImage.image = imgDefault;
    }
    else
    {
        if ([pinfo getPhotoID] != [info getPhotoID])
            [self refreshComponent];
        
        pinfo = info;
        [btnFavorite setSelected:[info isFavorite]];
        [btnLike setSelected:[info isLiked]];
        [btnFlag setSelected:[info isFlaged]];
        [btnComment setSelected:[info isNewComment]];
        [btnLikeCount setTitle:[NSString stringWithFormat:@"%d likes", (int)[info getLikeCount]] forState:UIControlStateNormal];
        btnFlag.hidden = [info isMyPhoto];
        btnMore.hidden = ![info isMyPhoto];
        arrComments = [info getCommentArray];

        [self setViewData:info];
        lblTitle.text = [info getTitle];
        lblTagValue.text = [info getTag];
        lblTime.text = [info getPostTime];
        
        if (!imgDefault)
            imgDefault = [UIImage imageNamed:@"img_emptyphoto.png"];
        [ivImage sd_setImageWithURL:[pinfo getPhotoURL] placeholderImage:imgDefault options:DEFAULT_IMG_OPTION];
        
        if ([pinfo isMyPhoto])
            lblUserName.text = @"Me";
        else
            lblUserName.text = [pinfo getUserName];
        
        bShowOnlyPermission = NO;
        btnPermission.selected = NO;
        viewGroup.hidden = NO;
        CGRect rectTmp = viewPermission.frame;
        rectTmp.size.height = VIEW_PERMISSION_HEIGHT;
        viewPermission.frame = rectTmp;
        [btnPermission setImage:imgPermissionNormal forState:UIControlStateNormal];
        if ([pinfo isBucketPhoto])
        {
            lblGroupName.text = [pinfo getBucketName];
            lblShareKind.text = @"Group Albums :";
            
            if ([pinfo isMyBucket])
            {
                btnPermission.selected = [pinfo isSharedPhoto];
            }
            else
            {
                viewGroup.hidden = YES;
                rectTmp.size.height = VIEW_USER_PERMISSION;
                viewPermission.frame = rectTmp;
                bShowOnlyPermission = YES;
                [btnPermission setImage:imgPermissionViewOnly forState:UIControlStateNormal];
            }
        }
        else
        {
            lblGroupName.text = [pinfo getAlbumNames];
            lblShareKind.text = @"Albums :";
            if ([info isMyPhoto])
                btnPermission.selected = [info isMySharedPhoto];
        }
        
        for (FriendInfoStruct *finfo in [info getShareUserInfo])
        {
            if ([pinfo isBucketPhoto] && [finfo getUserID] == [pinfo getBucketOwnerUserID])
                continue;
            
            [arrFamilys addObject:finfo];
        }
        
        for (GroupInfoStruct *ginfo in [info getShareGroupInfo])
            [arrGroups addObject:ginfo];
        
        if (![pinfo isBucketPhoto] && ![pinfo isMyPhoto])
        {
            CGRect rect = viewMoveButtons.frame;
            rect.origin.x = 8;
            viewMoveButtons.frame = rect;
        }
        else
        {
            CGRect rect = viewMoveButtons.frame;
            rect.origin.x = 39;
            viewMoveButtons.frame = rect;
        }
    }

    btnSave.hidden = bShowOnlyPermission;
    bShowPermission = NO;
    self.tag = index;
    [self refreshComponsetForTableView];
}

#pragma mark -
#pragma mark - tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (arrComments.count >= 7)
        return 2;
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return arrComments.count > 7 ? 7 : arrComments.count;
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSInteger height;
        if (arrHeights.count > indexPath.row)
        {
            height = [[arrHeights objectAtIndex:indexPath.row] integerValue];
            if (height)
                return height;
        }
        
        height = [CommentViewCell getItemHeight:[self getCommentFromIndex:indexPath.row]];
        [arrHeights addObject:[NSString stringWithFormat:@"%d", (int)height]];
        return height;
    }
   
    return 50;
}

-(CommentInfoStruct *) getCommentFromIndex:(NSInteger)index
{
    NSInteger idx = index;
    if ([arrComments count] >= 7)
        idx = ([arrComments count] - 7) + index;
        
    return [arrComments objectAtIndex:idx];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        CommentInfoStruct *info = [self getCommentFromIndex:indexPath.row];
        CommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCommentViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell initWithCommentData:info];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCommentViewCell"];
        if (!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moreCommentViewCell"];
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
            [btn addTarget:self action:@selector(processSeeAllComment:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:btn];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.text = @"See all comments";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
        cell.textLabel.textColor = [UIColor grayColor];
        return cell;
    }
}

-(IBAction) processSeeAllComment:(id)sender
{
    [self.delegate processShowComment:self.pinfo comments:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return;
    
    [self.delegate processShowComment:self.pinfo comments:nil];
}

-(void) setTopBorder:(UIView *)view
{
    CALayer *topBorder = [CALayer layer];
    topBorder.frame = CGRectMake(0.0f, 0.0f, 320, 0.5f);
    topBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                  alpha:1.0f].CGColor;
    [view.layer addSublayer:topBorder];
}


-(void) setViewData:(PhotoInfoStruct *)info
{
    if ([info getWidth] == 0 || [info getHeight] == 0)
        return;
    
    pinfo = info;
    CGRect intemp;
    CGRect rect = ivImage.frame;
    float iScale = [info getWidth] / rect.size.width;
    float fheight = [info getHeight] / iScale;
    float ypos = 0, inypos = 0;
    rect.size.height = fheight;
    ivImage.frame = rect;
    btnMain.frame = rect;
    ypos = rect.size.height + rect.origin.y;
    
    if ([info getTitle].length > 0 || [info getTag].length > 0)
    {
        inypos = 7;
        if ([info getTitle].length > 0)
        {
            intemp = lblTitle.frame;
            intemp.size.width = DETAIL_TITLE_WIDTH;
            lblTitle.frame = intemp;
            inypos = [self adjustTitle:[info getTitle] inypos:inypos label:lblTitle];
        }
        
        if ([info getTag].length > 0)
        {
            lblTagTitle.hidden = NO;
            lblTagValue.hidden = NO;
            intemp = lblTagTitle.frame;
            intemp.origin.y = inypos;
            lblTagTitle.frame = intemp;
            
            intemp = lblTagValue.frame;
            intemp.size.width = DETAIL_TAG_WIDTH;
            lblTagValue.frame = intemp;
            inypos = [self adjustTitle:[info getTag] inypos:inypos label:lblTagValue];
        }
        else
        {
            lblTagTitle.hidden = YES;
            lblTagValue.hidden = YES;
        }
        
        viewTitle.hidden = NO;
        rect = viewTitle.frame;
        rect.origin.y = ypos;
        rect.size.height = inypos;
        viewTitle.frame = rect;
        ypos += rect.size.height;
    }
    else
        viewTitle.hidden = YES;
    
    rect = lblBucketOwnerValue.frame;
    rect.size.width = NAME_WIDTH;
    if ([info isBucketPhoto])
    {
        rect.origin.y = lblBucketOwner.frame.origin.y;
        lblBucketOwnerValue.frame = rect;
        lblBucketOwnerValue.text = [info getBucketOwnerName];
        inypos = [self adjustTitle:[info getBucketOwnerName] inypos:lblBucketOwnerValue.frame.origin.y label:lblBucketOwnerValue];
        lblBucketOwnerValue.hidden = NO;
        lblBucketOwner.hidden = NO;
        
        rect = lblSharedBy.frame;
        rect.origin.y = 59;
        lblSharedBy.frame = rect;
        
        rect = lblUserName.frame;
        rect.origin.y = 59;
        rect.size.width = VALUE_WIDTH;
        lblUserName.frame = rect;
        
        rect = lblShareKind.frame;
        rect.origin.y = 77;
        lblShareKind.frame = rect;
        
        rect = lblGroupName.frame;
        rect.origin.y = 77;
        rect.size.width = VALUE_WIDTH;
        lblGroupName.frame = rect;
        
    }
    else
    {
        lblBucketOwner.hidden = YES;
        lblBucketOwnerValue.hidden = YES;
        rect = lblSharedBy.frame;
        rect.origin.y = lblBucketOwner.frame.origin.y;
        lblSharedBy.frame = rect;
        
        rect = lblUserName.frame;
        rect.origin.y = lblSharedBy.frame.origin.y;
        rect.size.width = NAME_WIDTH;
        lblUserName.frame = rect;
        
        rect = lblShareKind.frame;
        rect.origin.y = 57;
        lblShareKind.frame = rect;
        
        rect = lblGroupName.frame;
        rect.origin.y = 57;
        rect.size.width = VALUE_WIDTH;
        lblGroupName.frame = rect;
    }
    
    NSString *strValue;
    if ([info isBucketPhoto])
        strValue = [info getBucketName];
    else
        strValue = [info getAlbumNames];

    rect = lblGroupName.frame;
    inypos = [self adjustTitle:strValue inypos:lblGroupName.frame.origin.y label:lblGroupName];
    
    rect = viewButton.frame;
    rect.origin.y = ypos;
    NSInteger ishareheight = lblShareKind.frame.origin.y + lblShareKind.frame.size.height;
    rect.size.height = ishareheight > inypos ? ishareheight : inypos;
    viewButton.frame = rect;
    ypos += rect.size.height;
    
    rect = viewComment.frame;
    rect.origin.y = ypos;
    viewComment.frame = rect;
    ypos += rect.size.height;
    
    rect = tblComment.frame;
    rect.origin.y = ypos;
    tblComment.frame = rect;
    
    [self refreshComponsetForTableView];
}

-(NSInteger) adjustTitle:(NSString *)strTitle inypos:(NSInteger)inypos label:(UILabel *)label;
{
    CGRect rect = label.frame;
    CGRect recttext = [strTitle boundingRectWithSize:CGSizeMake(rect.size.width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{ NSFontAttributeName : label.font }
                                             context:nil];
    rect.size = recttext.size;
    rect.size.height += 3;
    rect.origin.y = inypos;
    label.frame = rect;
    inypos += rect.size.height + 6;
    return inypos;
}

-(void) refreshComponsetForTableView
{
    NSInteger iHeight;
    if (bShowPermission)
    {
        tblComment.hidden = YES;
        viewTextComment.hidden = YES;
        viewPermission.hidden = NO;
        CGRect rect = viewPermission.frame;
        iHeight = rect.origin.y + rect.size.height;
        [covFriends reloadData];
        [covGroups reloadData];
    }
    else
    {
        [arrHeights removeAllObjects];
        [tblComment reloadData];
     
        CGRect rect = tblComment.frame;
        if ([arrComments count] > 0)
        {
            rect.size.height = 55 * ([arrComments count] > 7 ? 7 : [arrComments count]);
            rect.size.height += [self getTableHeight];
            if (arrComments.count >= 7)
                rect.size.height += 50;
        }
        else
            rect.size.height = 0;
        
        tblComment.frame = rect;
        
        iHeight = rect.origin.y + rect.size.height;
        
        
        if (iHeight < (iScreenHeight - 45 - 72 - 46))
            iHeight = (iScreenHeight - 45 - 72 - 46);
        
        viewTextComment.frame = CGRectMake(0, iHeight, 320, 45);
        iHeight += 45;
    }
    
    iHeight += 5;
    [scView setContentSize:CGSizeMake(320, iHeight)];
    if (bShowPermission)
        [scView scrollRectToVisible:viewPermission.frame animated:YES];
    else
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationDelay:0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        tblComment.hidden = NO;
        viewTextComment.hidden = NO;
        viewPermission.hidden = YES;
        [UIView commitAnimations];
    }
}

-(NSInteger) getTableHeight
{
    NSInteger iHeight = 0;
    for (int i = 0; i < arrHeights.count; i++)
    {
        NSString *str = [arrHeights objectAtIndex:i];
        iHeight += ([str integerValue] - 55);
    }
    
    return iHeight;
}

- (IBAction)processPermission:(id)sender
{
    if ([pinfo isMyBucket])
    {
        [self.delegate processShowPermission:pinfo];
        return;
    }
    
    bShowPermission = !bShowPermission;
    if (bShowPermission)
    {
        CGRect rect = viewPermission.frame;
        rect.origin.y = viewButton.frame.size.height + viewButton.frame.origin.y;
        viewPermission.frame = rect;
        viewPermission.hidden = NO;
        [self refreshComponsetForTableView];
    }
    else
    {
        viewPermission.hidden = YES;
        [self refreshComponsetForTableView];
    }
}

- (IBAction)processFavorite:(id)sender
{
    if (pinfo)
    {
        if ([pinfo isFavorite])
            [[AppDelegate sharedInstance] favoritePhoto:[pinfo getPhotoIDToString] type:@"0"];
        else
            [[AppDelegate sharedInstance] favoritePhoto:[pinfo getPhotoIDToString] type:@"1"];
        
        [pinfo setFavoriteFlag:![pinfo isFavorite]];
        [btnFavorite setSelected:[pinfo isFavorite]];
    }
}

- (IBAction)processLike:(id)sender
{
    if (pinfo)
    {
        if ([pinfo isLiked])
            [[AppDelegate sharedInstance] likePhoto:[pinfo getPhotoIDToString] type:@"0"];
        else
            [[AppDelegate sharedInstance] likePhoto:[pinfo getPhotoIDToString] type:@"1"];
        
        [pinfo setLikedFlag:![pinfo isLiked]];
        [btnLikeCount setTitle:[NSString stringWithFormat:@"%d likes", (int)[pinfo getLikeCount]] forState:UIControlStateNormal];
        [btnLike setSelected:[pinfo isLiked]];
    }
}


- (IBAction)processShowComment:(id)sender
{
    [self.delegate processShowComment:self.pinfo comments:arrComments];
}

- (IBAction)processSaveAction:(id)sender
{
    [self.delegate processSavePermission:arrGroups arrFriends:arrFamilys photoinfo:pinfo parentflag:NO];
}

- (NSMutableArray *) getGroups
{
    return arrGroups;
}

- (NSMutableArray *) getFamilies
{
    return arrFamilys;
}

- (IBAction)processHideKeyboard:(id)sender
{
    [self.txtComment resignFirstResponder];
}

- (IBAction)processFullScreenAction:(id)sender
{
    [self.delegate processFullScreen:self.pinfo index:self.tag];
}

- (IBAction)processMoreAction:(id)sender
{
    [self.delegate processMore:self.pinfo index:self.tag];
}

- (IBAction)processLikeUserAction:(id)sender
{
    [self.delegate processLikeView:self.pinfo];
}


-(void)requestFinished:(ASIHTTPRequest *)request
{
    [refreshControl endRefreshing];
    NSString    *value = [request responseString];
    NSLog(@"Value = %@", value);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if ([[AppDelegate sharedInstance] isCheckedError:status message:[json objectForKey:@"message"]])
        return;
    if (status == 200)
    {
        if (request.tag == TYPE_GET_COMMENT)
        {
            if (pinfo)
            {
                //[self refreshComments:[json objectForKey:@"comments"] initflag:YES];
                //[self refreshComponsetForTableView];
            }
        }
        else if (request.tag == TYPE_REFRESH_PHOTOINFO)
        {
            if ([pinfo getPhotoID] == [[json objectForKey:@"photoid"] integerValue])
            {
                [pinfo initWithJsonData:[json objectForKey:@"photoinfo"]];
                [self updatedPermission];
            }
        }
        else if (request.tag == TYPE_GET_MORE_COMMENTS)
        {
            
        }
    }
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    [refreshControl endRefreshing];
}

-(void) setViewActivated
{
    self.btnComment.selected = NO;
    if ([pinfo isMyBucket])
    {
        [self refreshCollectionView];
    }
    else if ([pinfo isBucketPhoto])
    {
        [pinfo refreshBucketInfo];
        [arrGroups removeAllObjects];
        [arrFamilys removeAllObjects];
        for (FriendInfoStruct *finfo in [pinfo getShareUserInfo])
        {
            if ([pinfo isBucketPhoto] && [finfo getUserID] == [pinfo getBucketOwnerUserID])
                continue;
            
            [arrFamilys addObject:finfo];
        }
        
        for (GroupInfoStruct *ginfo in [pinfo getShareGroupInfo])
            [arrGroups addObject:ginfo];
        if (bShowPermission)
            [self refreshComponsetForTableView];
    }
    [refreshControl endRefreshing];
    
    if ([arrComments count] > 0 && [pinfo isNewComment])
        [[AppDelegate sharedInstance] viewComment:[pinfo getPhotoIDToString] commentid:[Utils getStringFromInteger:[self getLatestCommentID]]
                viewedphoto:[pinfo isViewed]];
    else if (![pinfo isViewed])
        [[AppDelegate sharedInstance] viewPhoto:[pinfo getPhotoIDToString]];
    
    [btnFlag setSelected:[pinfo isFlaged]];
    [pinfo setViewed:YES];
    [pinfo setNewCommentFlag:NO];
}

-(NSInteger) getLatestCommentID
{
    NSInteger commentid = 0;
    for (CommentInfoStruct *cinfo in arrComments)
    {
        if ([cinfo getCommentID] > commentid)
            commentid = [cinfo getCommentID];
    }
    
    return commentid;
}

-(void) refreshCollectionView
{
    if ([pinfo isMyBucket])
    {
        [self.pinfo refreshBucketInfo];
        [self initWithViewData:self.pinfo index:self.tag];
        return;
    }
    
    if (!btnFlag.hidden)
        btnFlag.selected = [pinfo isFlaged];

    if (bShowPermission)
    {
        [covFriends reloadData];
        [covGroups reloadData];
    }
    else
    {
        [arrHeights removeAllObjects];
        [self refreshComponsetForTableView];
    }
}

-(void) refreshComponent
{
    bShowPermission = NO;
    [self refreshComponsetForTableView];
}

-(void) updatedPermission
{
    bShowPermission = NO;
    [self initWithViewData:pinfo index:self.tag];
}

-(void) showPermission
{
    bShowPermission = YES;
    CGRect rect = viewPermission.frame;
    rect.origin.y = viewButton.frame.size.height + viewButton.frame.origin.y;
    viewPermission.frame = rect;
    viewPermission.hidden = NO;
    [self refreshComponsetForTableView];
}

-(BOOL) isChanged
{
    if (![pinfo isMyPhoto] || [pinfo isBucketPhoto])
        return NO;
    
    if (arrGroups.count != [pinfo getShareGroupInfo].count)
        return YES;
    
    for (GroupInfoStruct *ginfo in [pinfo getShareGroupInfo])
    {
        BOOL bExist = NO;
        for (GroupInfoStruct *gtinfo in arrGroups)
        {
            if ([ginfo getGroupID] == [gtinfo getGroupID])
            {
                bExist = YES;
                break;
            }
        }
        
        if (!bExist)
            return YES;
    }
    
    if ([pinfo getShareUserInfo].count != arrFamilys.count)
        return YES;
    
    for (FriendInfoStruct *finfo in [pinfo getShareUserInfo])
    {
        BOOL bExist = NO;
        for (FriendInfoStruct *ftinfo in arrFamilys)
        {
            if ([finfo getUserID] == [ftinfo getUserID])
            {
                bExist = YES;
                break;
            }
        }
        
        if (!bExist && [finfo getUserID] != [[AppDelegate sharedInstance].objUserInfo getUserID])
            return YES;
    }
    
    return NO;
}

-(void) ignorePermission
{
    [arrGroups removeAllObjects];
    [arrFamilys removeAllObjects];
    for (FriendInfoStruct *finfo in [pinfo getShareUserInfo])
    {
        if ([pinfo isBucketPhoto] && [finfo getUserID] == [pinfo getBucketOwnerUserID])
            continue;
        
        [arrFamilys addObject:finfo];
    }
    
    for (GroupInfoStruct *ginfo in [pinfo getShareGroupInfo])
        [arrGroups addObject:ginfo];
    if (bShowPermission)
        [self refreshComponsetForTableView];
}

- (IBAction)processFlag:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if ([btn isSelected])
    {
        [AppDelegate showMessage:@"You already flagged this photo." withTitle:@"Information"];
        return;
    }
    
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"Are you sure you want to flag this photo as inappropriate ?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = TYPE_FLAG_PHOTO;
    [alertview show];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (bShowOnlyPermission)
    {
        if(collectionView == covFriends)
            return [arrFamilys count];
        
        return 0;
    }
    
    if(collectionView == covFriends)
        return [arrFamilys count] + 1;
    
    return [arrGroups count] + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (bShowOnlyPermission)
    {
        if(collectionView == covFriends)
        {
            FriendsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"friendsCollectionCell" forIndexPath:indexPath];
            cell.addView.hidden = YES;
            cell.mainView.hidden = NO;
            cell.actBtn.hidden = YES;
            
            FriendInfoStruct *info = [arrFamilys objectAtIndex:indexPath.row];
            cell.nameLbl.text = [info getUserName];
            [cell.photoView sd_setImageWithURL:[info getPhotoURL] placeholderImage:[Utils getDefaultProfileImage]];
            return cell;
        }
        else
        {
            GroupViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"groupCollectionCell" forIndexPath:indexPath];
            cell.addView.hidden = YES;
            cell.mainView.hidden = NO;
            cell.actBtn.hidden = YES;
            cell.titleLbl.font = [UIFont fontWithName:@"Helvetica" size:11];
            
            GroupInfoStruct *info = [arrGroups objectAtIndex:indexPath.row];
            cell.titleLbl.text = [info getGroupNameToShow];
            return cell;
        }
    }
    else
    {
        if(collectionView == covFriends)
        {
            FriendsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"friendsCollectionCell" forIndexPath:indexPath];
            if(indexPath.row == 0)
            {
                cell.addView.hidden = NO;
                cell.mainView.hidden = YES;
                
                if ([[cell.addBtn actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] < 1)
                    [cell.addBtn addTarget:self action:@selector(onAddFriend:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                cell.addView.hidden = YES;
                cell.mainView.hidden = NO;
                cell.actBtn.hidden = NO;
                cell.actBtn.tag = indexPath.row;
                
                if ([[cell.actBtn actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] < 1)
                    [cell.actBtn addTarget:self action:@selector(onPeoleShowRemove:) forControlEvents:UIControlEventTouchUpInside];
                
                FriendInfoStruct *info = [arrFamilys objectAtIndex:indexPath.row - 1];
                info = [[AppDelegate sharedInstance] findFriendInfo:[info getUserID]];
                cell.nameLbl.text = [info getUserName];
                [cell.photoView sd_setImageWithURL:[info getPhotoURL] placeholderImage:[Utils getDefaultProfileImage]];
            }
            
            return cell;
        }
        else
        {
            GroupViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"groupCollectionCell" forIndexPath:indexPath];
            if(indexPath.row == 0)
            {
                cell.addView.hidden = NO;
                cell.mainView.hidden = YES;
                cell.mainBtn.tag = indexPath.row;
                if ([[cell.addBtn actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] < 1)
                    [cell.addBtn addTarget:self action:@selector(onAddGroup:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                cell.addView.hidden = YES;
                cell.mainView.hidden = NO;
                
                cell.actBtn.tag = indexPath.row - 1;
                cell.titleLbl.font = [UIFont fontWithName:@"Helvetica" size:11];
                
                if ([[cell.actBtn actionsForTarget:self forControlEvent:UIControlEventTouchUpInside] count] < 1)
                {
                    [cell.actBtn addTarget:self action:@selector(onGroupShowRemove:) forControlEvents:UIControlEventTouchUpInside];
                }
                
                GroupInfoStruct *info = [arrGroups objectAtIndex:indexPath.row - 1];
                cell.titleLbl.text = [info getGroupNameToShow];
            }
            
            return cell;
        }
    }
    
    return nil;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtComment resignFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        return;
    
    if (alertView.tag == 0x600)
    {
        [arrFamilys removeObjectAtIndex:iCurrentIndex];
        [covFriends reloadData];
    }
    else if (alertView.tag == 0x500)
    {
        [arrGroups removeObjectAtIndex:iCurrentIndex];
        [self.covGroups reloadData];
    }
    else if (alertView.tag == TYPE_FLAG_PHOTO)
    {
        [pinfo setSpamFlag:YES];
        btnFlag.selected = YES;
        
        [[AppDelegate sharedInstance] flagPhoto:[pinfo getPhotoIDToString] type:1 content:@"Spam"];
    }
}

//For Group
- (IBAction)onAddGroup:(id)sender
{
    [self.delegate processAddGroups:arrGroups];
}

- (IBAction)onGroupShowRemove:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag;
    GroupInfoStruct *info = [arrGroups objectAtIndex:iCurrentIndex];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Are you sure you want to remove \"%@\" circle?", [info getGroupName]] delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x500;
    [alertview show];
}

- (IBAction)onAddFriend:(id)sender
{
    [self.delegate processAddFamilys:arrFamilys];
}

//For Peopl
- (IBAction)onPeoleShowRemove:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    iCurrentIndex = btn.tag - 1;
    FriendInfoStruct *info = [arrFamilys objectAtIndex:iCurrentIndex];
    NSString *strMessage;
    if ([pinfo isBucketPhoto])
        strMessage = [NSString stringWithFormat:@"Are you sure you want to remove %@ from the %@ group album?  Note: All photos %@ added to this group album will also be deleted.", [info getUserName], [pinfo getBucketName], [info getUserName]];
    else
        strMessage = [NSString stringWithFormat:@"Are you sure you want to remove %@ from this photo permission?", [info getUserName]];
    
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:strMessage delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.tag = 0x600;
    [alertview show];
}

-(void) dealloc
{
    [rrequest clearDelegatesAndCancel];
}


@end
