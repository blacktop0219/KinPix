//
//  CustomSharePhotoCell.m
//  Zinger
//
//  Created by QingHou on 11/14/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "CustomSharePhotoCell.h"

@implementation CustomSharePhotoCell
{
    BOOL bHasFocus;
}

@synthesize ivImage;
@synthesize txtTag;
@synthesize viewTag, viewTitle;

- (void)awakeFromNib
{
    // Initialization code
    [AppDelegate processPhotoView:ivImage];
    
    viewTag.layer.cornerRadius = 3.0;
    viewTag.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewTag.layer.borderWidth = 0.5f;
    
    viewTitle.layer.cornerRadius = 3.0;
    viewTitle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    viewTitle.layer.borderWidth = 0.5f;
    
    self.tokens = [NSMutableArray array];
    
    txtTag.dataSource = self;
    txtTag.delegate = self;
    txtTag.textField.placeholder = @"Enter here";
    [txtTag reloadData];
    
    UITapGestureRecognizer *tapEdit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processTabEditAction)];
    [tapEdit setNumberOfTapsRequired:1];
    [txtTag addGestureRecognizer:tapEdit];
}

- (void) processTabEditAction
{
    [self.controller onTouch:nil];
    bHasFocus = YES;
    [self.txtTag.textField becomeFirstResponder];
    
}

-(BOOL) hasFocus
{
    return bHasFocus;
}

-(void) completeToken
{
    if (self.txtTag.textField.text.length > 0)
    {
        [self tokenField:self.txtTag didReturnWithText:self.txtTag.textField.text];
    }
}

-(void) setFocused:(BOOL)flag
{
    bHasFocus = flag;
    if (flag)
        [txtTag.textField becomeFirstResponder];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - ZFTokenField DataSource

- (CGFloat)lineHeightForTokenInField:(ZFTokenField *)tokenField
{
    return 20;
}

- (NSUInteger)numberOfTokenInField:(ZFTokenField *)tokenField
{
    return self.tokens.count;
}

- (UIView *)tokenField:(ZFTokenField *)tokenField viewForTokenAtIndex:(NSUInteger)index
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"TokenView" owner:nil options:nil];
    UIView *view = nibContents[0];
    UILabel *label = (UILabel *)[view viewWithTag:2];
    UIButton *button = (UIButton *)[view viewWithTag:3];
    
    [button addTarget:self action:@selector(processDeleteTag:) forControlEvents:UIControlEventTouchUpInside];
    
    label.text = self.tokens[index];
    CGSize size = [label sizeThatFits:CGSizeMake(1000, 20)];
    view.frame = CGRectMake(0, 0, size.width + 20, 20);
    return view;
}

#pragma mark - ZFTokenField Delegate

- (CGFloat)tokenMarginInTokenInField:(ZFTokenField *)tokenField
{
    return 3;
}

- (void)tokenField:(ZFTokenField *)tokenField didReturnWithText:(NSString *)text
{
    if (text.length < 1 || [text isEqualToString:@" "])
        return;
    
    NSString* result = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (result.length < 1)
        return;
    
    [self.tokens addObject:result];
    [tokenField reloadData];
}

- (void)tokenFieldDidBeginEditing:(ZFTokenField *)tokenField
{
    bHasFocus = YES;
}

- (void)tokenFieldDidEndEditing:(ZFTokenField *)tokenField
{
    bHasFocus = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(processEditFinished) userInfo:nil repeats:NO];
}

-(void) processEditFinished
{
    if (![txtTag.textField isFirstResponder])
    {
        if ([txtTag.textField.text length] > 0)
        {
            NSString* result = [txtTag.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self.tokens addObject:result];
            [txtTag reloadData];
        }
    }
}

- (void)tokenField:(ZFTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{
    [self.tokens removeObjectAtIndex:index];
}

- (BOOL)tokenFieldShouldEndEditing:(ZFTokenField *)textField
{
    return YES;
}

- (void)processDeleteTag:(UIButton *)tokenButton
{
    NSUInteger index = [self.txtTag indexOfTokenView:tokenButton.superview];
    if (index != NSNotFound) {
        [self.tokens removeObjectAtIndex:index];
        [self.txtTag reloadData];
    }
}

-(void) setTagArray:(NSMutableArray *)array
{
    [self.tokens removeAllObjects];
    for (NSString *token in array)
        [self.tokens addObject:token];
    
    [self.txtTag reloadData];
}

@end
