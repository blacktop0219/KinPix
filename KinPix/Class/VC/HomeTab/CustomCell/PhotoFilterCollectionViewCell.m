//
//  PhotoFilterCollectionViewm
//  Zinger
//
//  Created by Tianming on 27/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "PhotoFilterCollectionViewCell.h"

#define WIDTH_TITLE     136
#define WIDTH_TAG       107
#define WIDTH_IMAGE     147

@implementation PhotoFilterCollectionViewCell
{
    PhotoInfoStruct *photoinfo;
    UIImage *imgPermissionNormal;
    UIImage *imgPermissionViewOnly;
}

@synthesize ivPhoto, viewMain, delegate, btnLikeCount;
@synthesize viewButton, viewTag, viewTitle, viewTime;
@synthesize lblNew, lblTag, lblTime, lblTitle;
@synthesize lblTagTitle, btnComment, btnDelete, btnFavorite, btnFlag;
@synthesize btnLike, btnLikeUser, btnPermission;

- (void)awakeFromNib
{
    [AppDelegate processFeedView:viewMain feedimage:ivPhoto];
    [AppDelegate processNewLabel:lblNew];

    [self makeTopBorder:viewButton];
    [self makeTopBorder:viewTag];
    [self makeTopBorder:viewTime];
    
    imgPermissionNormal = [UIImage imageNamed:@"btn_small_permission_normal.png"];
    imgPermissionViewOnly = [UIImage imageNamed:@"btn_small_permission_disable.png"];
    
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:viewTime.bounds byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(5.0, 5.0)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    viewTime.layer.mask = maskLayer;
    
    [self.viewMain removeFromSuperview];
    [self addSubview:self.viewMain];
    
}

-(void) makeTopBorder:(UIView *)view
{
    CGSize mainViewSize = self.viewButton.bounds.size;
    CGFloat borderWidth = 0.5;
    UIColor *borderColor = [UIColor lightGrayColor];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, mainViewSize.width, borderWidth)];
    topView.opaque = YES;
    topView.backgroundColor = borderColor;
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [view addSubview:topView];
}

-(void) initWithPhotoInfo:(PhotoInfoStruct *)pinfo index:(NSInteger)index
{
    if (!pinfo)
        return;
    
    photoinfo = pinfo;
    CGRect rect = ivPhoto.frame;
    float fheight = rect.size.width * [pinfo getHeight] / [pinfo getWidth];
    float ypos = 0;
    rect.size.height = fheight;
    ivPhoto.frame = rect;
    ypos = rect.size.height + rect.origin.y;
    
    if ([pinfo getTitle].length > 0)
    {
        viewTitle.hidden = NO;
        lblTitle.text = [pinfo getTitle];
        NSInteger yheight = [self adjustLabel:2 label:lblTitle width:WIDTH_TITLE];
        rect = viewTitle.frame;
        rect.size.height = yheight;
        rect.origin.y = ypos;
        viewTitle.frame = rect;
        ypos += rect.size.height;
    }
    else
    {
        viewTitle.hidden = YES;
    }
    
    //lblTime.text = [pinfo.get]
    rect = viewButton.frame;
    rect.origin.y = ypos;
    viewButton.frame = rect;
    ypos += rect.size.height;
    
    if ([pinfo getTag].length > 0)
    {
        viewTag.hidden = NO;
        lblTag.text = [pinfo getTag];
        NSInteger yheight = [self adjustLabel:2 label:lblTag width:WIDTH_TAG];
        rect = viewTag.frame;
        rect.size.height = yheight;
        rect.origin.y = ypos;
        viewTag.frame = rect;
        ypos += rect.size.height;
    }
    else
    {
        viewTag.hidden = YES;
    }
    
    rect = viewTime.frame;
    rect.origin.y = ypos;
    viewTime.frame = rect;
    ypos += rect.size.height;
    
    [btnLikeCount setTitle:[NSString stringWithFormat:@"%d likes", (int)[pinfo getLikeCount]] forState:UIControlStateNormal];
    //ivUnread.hidden = ![pinfo isNewComment];
    lblNew.hidden = [pinfo isViewed];
    
    btnPermission.selected = NO;
    btnPermission.hidden = ![pinfo isMyPhoto];
    [btnPermission setImage:imgPermissionNormal forState:UIControlStateNormal];
    if ([pinfo isBucketPhoto])
    {
        [pinfo refreshBucketInfo];
        if ([pinfo isMyBucket])
        {
            if ([pinfo isSharedPhoto])
                btnPermission.selected = [pinfo isSharedPhoto];
        }
        else
        {
            [btnPermission setImage:imgPermissionViewOnly forState:UIControlStateNormal];
        }
    }
    else
    {
        if ([pinfo isMyPhoto])
            btnPermission.selected = [pinfo isMySharedPhoto];
    }
    
    btnDelete.hidden = ![pinfo isMyPhoto];
    btnFlag.hidden = [pinfo isMyPhoto];
    [btnLike setSelected:[pinfo isLiked]];
    [btnComment setSelected:[pinfo isNewComment]];
    [btnFavorite setSelected:[pinfo isFavorite]];
    [btnFlag setSelected:[pinfo isFlaged]];
    [ivPhoto sd_setImageWithURL:[pinfo getPhotoThumbURL] placeholderImage:nil];
    [lblTime setText:[pinfo getPostTime]];
    self.tag = index;
    
    rect = viewMain.frame;
    rect.size.height = ypos;
    viewMain.frame = rect;
}

-(NSInteger) adjustLabel:(NSInteger)inypos label:(UILabel *)label width:(NSInteger)width
{
    NSString *str = label.text;
    CGRect rect = label.frame;
    CGRect recttext = [str boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{ NSFontAttributeName : label.font }
                                             context:nil];
    rect.size = recttext.size;
    rect.origin.y = inypos;
    label.frame = rect;
    inypos += rect.size.height + 3;
    return inypos;
}

+(NSInteger) getItemHeight:(PhotoInfoStruct *)pinfo
{
    float ypos = WIDTH_IMAGE * [pinfo getHeight] / [pinfo getWidth];
    if ([pinfo getTitle].length > 0)
        ypos += [self getLabelHeight:2 string:[pinfo getTitle] width:WIDTH_TITLE];
    
    // button and time size
    ypos = ypos + 26 + 25;
    
    if ([pinfo getTag].length > 0)
        ypos += [self getLabelHeight:2 string:[pinfo getTag] width:WIDTH_TAG];
    
    return ypos;
}

+(NSInteger) getLabelHeight:(NSInteger)inypos string:(NSString *)string width:(NSInteger)width
{
    UIFont *font = [AppDelegate getAppSystemFont:11];
    CGRect recttext = [string boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{ NSFontAttributeName : font }
                                        context:nil];
    return inypos + recttext.size.height + 3;
}

- (IBAction)processFavoriteAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = ![btn isSelected];
    [photoinfo setFavoriteFlag:[btn isSelected]];
    if ([photoinfo isFavorite])
        [[AppDelegate sharedInstance] favoritePhoto:[photoinfo getPhotoIDToString] type:@"1"];
    else
        [[AppDelegate sharedInstance] favoritePhoto:[photoinfo getPhotoIDToString] type:@"0"];
}

- (IBAction)processLikeAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    btn.selected = ![btn isSelected];
    [photoinfo setLikedFlag:btn.selected];
    if ([photoinfo isLiked])
        [[AppDelegate sharedInstance] likePhoto:[photoinfo getPhotoIDToString] type:@"1"];
    else
        [[AppDelegate sharedInstance] likePhoto:[photoinfo getPhotoIDToString] type:@"0"];
    
    [btnLikeCount setTitle:[NSString stringWithFormat:@"%d likes", (int)[photoinfo getLikeCount]] forState:UIControlStateNormal];
}


- (IBAction)processCommentAction:(id)sender
{
    if (delegate)
        [delegate processComment:photoinfo];
}


- (IBAction)processMoreAction:(id)sender
{
    if (delegate)
        [delegate processMore:photoinfo index:self.tag];
}

- (IBAction)processFlagAction:(id)sender
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

- (IBAction)processLikeViewAction:(id)sender
{
    if (delegate)
        [delegate processLikeView:photoinfo];
}

- (IBAction)processPermissionViewAction:(id)sender
{
    if (delegate)
        [delegate processPermission:photoinfo index:self.tag];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        return;
    
    if (alertView.tag == TYPE_FLAG_PHOTO)
    {
        [photoinfo setSpamFlag:YES];
        btnFlag.selected = YES;
        
        [[AppDelegate sharedInstance] flagPhoto:[photoinfo getPhotoIDToString] type:1 content:@"Spam"];
    }
}

@end
