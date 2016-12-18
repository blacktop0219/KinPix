//
//  CommentViewController.m
//  KinPix
//
//  Created by Piao Dev on 30/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentViewCell.h"

@implementation CommentViewController
{
    UIView *viewTextComment;
    HPGrowingTextView *txtComment;
    NSMutableArray* arrHeights;
    CGPoint pointTouchStart;
    ASIFormDataRequest *leaveRequest;
    ASIFormDataRequest *reloadRequest;
    BOOL bFinalFlag;
    NSMutableArray *arrComment;
}

@synthesize tblComment, photoinfo;
@synthesize aivLoading;


-(void) viewDidLoad
{
    [self setUpTextFieldforIphone];
    
    arrComment = [photoinfo getCommentArray];
    [tblComment registerNib:[UINib nibWithNibName:@"CommentViewCell" bundle:nil] forCellReuseIdentifier:@"detailCommentViewCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    tblComment.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    bFinalFlag = NO;
    
    if ([self.photoinfo isNewComment])
        [[AppDelegate sharedInstance] viewComment:[self.photoinfo getPhotoIDToString] commentid:[Utils getStringFromInteger:[self.photoinfo getLatestCommentID]] viewedphoto:[self.photoinfo isViewed]];
    [self.photoinfo setNewCommentFlag:NO];
    [self.photoinfo setViewed:YES];
    if (arrComment.count < 10)
        [self loadComment:0 moreflag:NO];
    else
    {
        [self.aivLoading stopAnimating];
        self.aivLoading.hidden = YES;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    //[txtComment becomeFirstResponder];
}

-(BOOL) shouldAutorotate
{
    return NO;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [leaveRequest clearDelegatesAndCancel];
    [reloadRequest clearDelegatesAndCancel];
}

-(void)setUpTextFieldforIphone
{
    viewTextComment = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - 45, 320, 45)];
    txtComment = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0, 7, 250, 23)];
    
    txtComment.minNumberOfLines = 1;
    txtComment.maxNumberOfLines = 5;
    txtComment.returnKeyType = UIReturnKeyDefault; //just as an example
    txtComment.delegate = self;
    txtComment.placeholder = @"Add a comment...";
    txtComment.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 2, 0);
    [txtComment setContentInset:UIEdgeInsetsMake(6, 6, 6, 0)];
    [self.view addSubview:viewTextComment];
    txtComment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [viewTextComment addSubview:txtComment];
   
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(viewTextComment.frame.size.width - 62, 7, 55, 29);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [doneBtn setTitle:@"Send" forState:UIControlStateNormal];
    doneBtn.titleLabel.font = [AppDelegate getAppSystemFont:13];
    [doneBtn setBackgroundColor:[UIColor colorWithRed:1.0 / 255.0 green:150.f / 255.0 blue:255.f / 255.0 alpha:1.0f]];
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(processLeaveCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    [self adjustViewCorner:doneBtn corner:3];
    
    [viewTextComment addSubview:doneBtn];
    viewTextComment.backgroundColor = [UIColor colorWithRed:230.f / 255.0 green:230.f / 255.0 blue:230.f / 255.0 alpha:1.0f];
    viewTextComment.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

- (void) hideKeyboard
{
    [txtComment resignFirstResponder];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // update your model
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

-(void) commentVeiwCellMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSArray *array = [touches allObjects];
    if (array.count < 1)
        return;
    
    UITouch *touch = [array objectAtIndex:0];
    CGPoint point = [touch locationInView:nil];
    if (point.y > viewTextComment.frame.origin.y)
    {
        [txtComment resignFirstResponder];
    }
}

-(void) adjustViewCorner:(UIView *)adview corner:(NSInteger)corner
{
    adview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    adview.layer.borderWidth = 0.3;
    adview.layer.cornerRadius = corner;
    
    if ([adview isKindOfClass:[UIImageView class]])
        adview.layer.masksToBounds = YES;
}

-(void) loadComment:(NSInteger)commentid moreflag:(BOOL)moreflag
{
    [self.aivLoading startAnimating];
    self.aivLoading.hidden = NO;
    
    [reloadRequest clearDelegatesAndCancel];
    reloadRequest = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_GET_COMMENTS] tag:TYPE_GET_COMMENT delegate:self];
    [reloadRequest setPostValue:[self.photoinfo getPhotoIDToString] forKey:@"photoid"];
    [reloadRequest setPostValue:[Utils getStringFromInteger:commentid] forKey:@"commentid"];
    [reloadRequest startAsynchronous];
}

- (IBAction)processBackAction:(id)sender
{
    [self hideKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = viewTextComment.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    viewTextComment.frame = r;
    
    r = tblComment.frame;
    r.size.height = viewTextComment.frame.origin.y - r.origin.y;
    tblComment.frame = r;
    
    CGPoint point = tblComment.contentOffset;
    point.y = point.y - diff;
    tblComment.contentOffset = point;
}

- (IBAction)processLeaveCommentAction:(id)sender
{
    if ([txtComment.text length] > 0)
    {
        NSString *strComment = txtComment.text;
        [leaveRequest clearDelegatesAndCancel];
        leaveRequest = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_LEAVE_COMMENT] tag:TYPE_LEAVE_COMMENT delegate:self];
        [leaveRequest setPostValue:[photoinfo getPhotoIDToString] forKey:@"photoid"];
        [leaveRequest setPostValue:strComment forKey:@"comment"];
        if (arrComment.count > 0)
        {
            CommentInfoStruct *info = [arrComment objectAtIndex:arrComment.count - 1];
            [leaveRequest setPostValue:[info getCommentIDToString] forKey:@"commentid"];
        }
        
        [leaveRequest startAsynchronous];
        aivLoading.hidden = YES;
        txtComment.text = @"";
        CommentInfoStruct *newinfo = [[CommentInfoStruct alloc] initWithUserComment:strComment];
        [arrComment addObject:newinfo];
        
        [tblComment reloadData];
        if (arrComment.count > 3 )
        {
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: arrComment.count - 1 inSection:1];
            [self.tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        }
    }
}

- (IBAction)processTabAction:(id)sender
{
    [txtComment resignFirstResponder];
}

-(void)dismissKeyboard
{
    
}

-(void) keyboardWillShow:(NSNotification *)note
{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    // get a rect for the textView frame
    CGRect containerFrame = viewTextComment.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);
    CGRect rect = tblComment.frame;
    rect.size.height = containerFrame.origin.y - rect.origin.y;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    viewTextComment.frame = containerFrame;
    tblComment.frame = rect;
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    // get a rect for the textView frame
    CGRect containerFrame = viewTextComment.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    CGRect rect = tblComment.frame;
    rect.size.height = containerFrame.origin.y - rect.origin.y;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    // set views with new info
    viewTextComment.frame = containerFrame;
    tblComment.frame = rect;
    // commit animations
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark - tableview delegate

-(void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y > 1 || velocity.y < -1)
    {
        [self hideKeyboard];
    }
        
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
        return [arrComment count];
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        NSInteger height;
        if (arrHeights.count > indexPath.row)
        {
            height = [[arrHeights objectAtIndex:indexPath.row] integerValue];
            if (height)
                return height;
        }
        
        height = [CommentViewCell getItemHeight:[arrComment objectAtIndex:indexPath.row]];
        [arrHeights addObject:[NSString stringWithFormat:@"%d", (int)height]];
        return height;
    }
    
    if (bFinalFlag || [arrComment count] < 7)
        return 0;
    
    return 50;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        CommentInfoStruct *info = [arrComment objectAtIndex:indexPath.row];
        CommentViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCommentViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
        [cell initWithCommentData:info];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"moreCommentViewCell"];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"moreCommentViewCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.text = @"See older comments";
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
        
        cell.hidden = bFinalFlag;
        cell.textLabel.textColor = [UIColor grayColor];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
        return;
    
    NSInteger commentid;
    if (arrComment.count > 0)
    {
        CommentInfoStruct *cinfo = [arrComment objectAtIndex:0];
        commentid = [cinfo getCommentID];
    }
    
    [self loadComment:commentid moreflag:YES];
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    {
        [aivLoading stopAnimating];
        aivLoading.hidden = YES;
    }
    
    NSString    *value = [request responseString];
    NSLog(@"Value = %@", value);
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:request.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    int status = (int)[[json objectForKey:@"status"] integerValue];
    if(status == 200)
    {
        if (request.tag == TYPE_LEAVE_COMMENT)
        {
            NSInteger commentid = [[json objectForKey:@"commentid"] integerValue];
            for (int i = 0; i < [arrComment count];)
            {
                CommentInfoStruct *info = [arrComment objectAtIndex:i];
                if ([info getCommentID] < 1 || [info getCommentID] > commentid)
                {
                    [arrComment removeObject:info];
                    continue;
                }
                
                i++;
            }
            
            NSArray *arr = [json objectForKey:@"comments"];
            for (NSDictionary * odict in arr)
            {
                CommentInfoStruct *info = [[CommentInfoStruct alloc] init];
                [info initWithJsonData:odict];
                [arrComment addObject:info];
            }
            
            [tblComment reloadData];
        }
        else if (request.tag == TYPE_GET_COMMENT)
        {
            NSInteger commentid = [[json objectForKey:@"commentid"] integerValue];
            NSArray *arrComments = [json objectForKey:@"comments"];
            bFinalFlag = [arrComments count] < 1;
            [self refreshComments:arrComments commentid:commentid];
        }
    }
    else
    {
        if (request.tag == TYPE_DELETE_PHOTO)
            [AppDelegate showMessage:@"Can't delete this photo." withTitle:@"Error"];
    }
}

- (void) refreshComments:(NSArray *)arrdata commentid:(NSInteger)commentid
{
    if (commentid < 1)
    {
        [arrHeights removeAllObjects];
        [arrComment removeAllObjects];
    }
    
    for (NSDictionary *dict in arrdata)
    {
        CommentInfoStruct *cinfo = [[CommentInfoStruct alloc] init];
        [cinfo initWithJsonData:dict];
        [arrComment insertObject:cinfo atIndex:0];
        NSInteger height = [CommentViewCell getItemHeight:cinfo];
        [arrHeights insertObject:[NSString stringWithFormat:@"%d", (int)height] atIndex:0];
    }
    
    if (commentid > 0 && [arrdata count] < 15)
        bFinalFlag = YES;
    
    [tblComment reloadData];
    if (commentid > 0)
    {
        if (arrComment.count > 1)
        {
            NSIndexPath* ipath = [NSIndexPath indexPathForRow:0 inSection:1];
            [self.tblComment scrollToRowAtIndexPath:ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        }
    }
    else if (arrComment.count > 1 )
    {
        NSIndexPath* ipath = [NSIndexPath indexPathForRow: arrComment.count - 1 inSection:1];
        [self.tblComment scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
    }
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    if ([aivLoading isAnimating])
        [aivLoading stopAnimating];
    aivLoading.hidden = YES;
}

@end
