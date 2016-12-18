//
//  SharePhotoViewController.m
//  Zinger
//
//  Created by QingHou on 11/14/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "PhotoPropertiesViewController.h"
#import "CustomSharePhotoCell.h"

#define  cellHeight 128

@interface PhotoPropertiesViewController ()
{
    UITextField *txtLastSelected;
    UIImage *imgDefault;
}
@end

@implementation PhotoPropertiesViewController

@synthesize photoinfo;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    self.tableView.scrollEnabled = NO;
    if (!imgDefault)
        imgDefault = [UIImage imageNamed:@"img_emptyphoto.png"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutView];
    [self.tableView reloadData];
}

- (void) layoutView
{
    NSInteger posy;
    CGRect rect = self.tableView.frame;
    rect.size.height = cellHeight ;
    self.tableView.frame = rect;
    posy = rect.origin.y + rect.size.height;
    
    rect.origin.y = posy + 12;
    self.scrollView.contentSize = CGSizeMake(320, rect.origin.y + rect.size.height + 20);
}

#pragma mark - TableView data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomSharePhotoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomSharePhotoCell" forIndexPath:indexPath];
    
    cell.btnPopover.tag = indexPath.row;
    cell.svTag.tag = indexPath.row;
   
     [cell.ivImage sd_setImageWithURL:[photoinfo getPhotoURL] placeholderImage:imgDefault options:SDWebImageProgressiveDownload];
    cell.txtTitle.text = [photoinfo getTitle];
    cell.txtTitle.tag = 0x100;
    [cell setTagArray:[photoinfo getTagArray]];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - Navigation

- (IBAction)onTouch:(id)sender
{
    [txtLastSelected resignFirstResponder];
    CustomSharePhotoCell *cell = (CustomSharePhotoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.txtTag removeFocus];
    [cell.txtTitle resignFirstResponder];
}

- (IBAction)processBackAction:(id)sender
{
    if (self.bModalView)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)processSaveAction:(id)sender
{
    [self showHUD:@"Saving..."];
    CustomSharePhotoCell *cell = (CustomSharePhotoCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell completeToken];
    ASIFormDataRequest *request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getPhotoFunctionURL:FUNC_PHOTO_SAVE_PROPERTIES] tag:TYPE_SAVE_PROPERTIES delegate:self];
    [request setPostValue:cell.txtTitle.text forKey:@"title"];
    
    NSString *strTag = @"";
    for (NSString *str in cell.tokens)
    {
        if (strTag.length < 1)
            strTag = str;
        else
            strTag = [strTag stringByAppendingFormat:@" %@", str];
    }
    
    [request setPostValue:strTag forKey:@"tag"];
    [request setPostValue:[photoinfo getPhotoIDToString] forKey:@"photoid"];
    [request startAsynchronous];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouch:nil];
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
        if (request.tag == TYPE_SAVE_PROPERTIES)
        {
            if ([photoinfo getPhotoID] == [[json objectForKey:@"photoid"] integerValue])
            {
                [photoinfo initWithJsonData:[json objectForKey:@"photoinfo"]];
                if (self.veiwDetail)
                    [self.veiwDetail updatedPermission];
                [self processBackAction:nil];
            }
            
        }
    }
    else
    {
        [AppDelegate showMessage:@"Save failed." withTitle:@"Error"];
    }
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

@end
