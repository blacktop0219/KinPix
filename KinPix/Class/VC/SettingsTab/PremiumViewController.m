//
//  PremiumViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "PremiumViewController.h"
#import "PurchaseCellItem.h"
#import "IAPManager.h"

#import "AWSCore.h"

@interface PremiumViewController ()
{
    NSString *strPrice1;
    NSString *strPrice2;
    NSString *strPrice3;
    NSInteger iSelectedDate;
    NSInteger iCurPurchaseType;
    NSInteger iRemSec;
}
@end

@implementation PremiumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    
    strPrice1 = @"$1.99";
    strPrice2 = @"$2.99";
    strPrice3 = @"$3.99";
    
    [self getProductIDs];
    [self processNewLabel:self.viewCheck1];
    [self processNewLabel:self.viewCheck2];
    [self processNewLabel:self.viewLimitBar];
    [self processNewLabel:self.btnDelete];
    
    [self.viewHelp.layer setCornerRadius:7.0];
    self.viewHelp.layer.borderColor = mainColor.CGColor;
    self.viewHelp.layer.borderWidth = 0.7f;
    
    iCurPurchaseType = 0;
    iRemSec = 0;
    iSelectedDate = 0;
    
    [self processLoadingInfo];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.request clearDelegatesAndCancel];
}

-(void) processLoadingInfo
{
    self.lblCurPhotoCount.text = @"";
    self.lblExpiryDate.text = @"";
    self.lblRemainCount.text = @"";
    [self showHUD:@"Loading..."];
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_GET_APP_USAGE] tag:TYPE_GET_APP_USAGE delegate:self];
    [self.request startAsynchronous];
}

-(void) processNewLabel:(UIView *) lblNew
{
    NSInteger radius = lblNew.frame.size.height / 2;
    [lblNew.layer setCornerRadius:radius];
    lblNew.layer.masksToBounds = YES;
}

-(void) getProductIDs
{
    NSArray *arrProducts = [[NSArray alloc] initWithObjects:KEY_IAP_PACKAGE2, KEY_IAP_PACKAGE5, KEY_IAP_PACKAGE10, nil];
    NSSet *productIdentifiers = [NSSet setWithArray:arrProducts];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
}

#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
    if ([products count] > 0)
    {
        for (int i = 0; i < 3; i ++)
        {
            SKProduct *product = [products objectAtIndex:i];
            
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString *localizedMoneyString = [numberFormatter stringFromNumber:product.price];
            
            if ([product.productIdentifier isEqualToString:KEY_IAP_PACKAGE2])
                strPrice1 = localizedMoneyString;
            else if ([product.productIdentifier isEqualToString:KEY_IAP_PACKAGE5])
                strPrice2 = localizedMoneyString;
            else if ([product.productIdentifier isEqualToString:KEY_IAP_PACKAGE10])
                strPrice3 = localizedMoneyString;
        }
        
        [self.tblPurchase reloadData];
    }
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
        NSInteger allphoto;
        NSDictionary *dict = [json objectForKey:@"usage"];
        iCurPurchaseType = [[dict objectForKey:@"level"] integerValue];
        iRemSec = [[dict objectForKey:@"diffsec"] integerValue];
        allphoto = [[dict objectForKey:@"photocount"] integerValue];
        
        [self refreshUserInfo:iCurPurchaseType timesec:iRemSec photocount:allphoto];
        if (request.tag == TYPE_DELETE_DUR_PHOTOS)
        {
            NSInteger delphotos = [[dict objectForKey:@"delphotos"] integerValue];
            NSString *strMsg = @"No deleted photo.";
            if (delphotos > 1)
                strMsg = [NSString stringWithFormat:@"%d photos deleted", (int)delphotos];
            else if (delphotos > 0)
                strMsg = [NSString stringWithFormat:@"1 photo deleted"];
                
            [AppDelegate showMessage:strMsg withTitle:@"Information"];
        }
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideHUD];
}

-(void) refreshUserInfo:(NSInteger)level timesec:(NSInteger)timesec photocount:(NSInteger)photocount
{
    if (timesec < 0)
    {
        iCurPurchaseType = 0;
        level = 0;
    }
    
    NSInteger iMaxPhotoCount = 500;
    switch (level)
    {
        case 0:
            self.lblCurrentPackage.text = @"Free(500 Photos)";
            self.lblExpiryDate.text = @"No Expiry";
            self.lblMaxCount.text = @"500";
            iMaxPhotoCount = 500;
            break;
            
        case 1:
            self.lblCurrentPackage.text = @"+2 Package(2,000 Photos)";
            self.lblExpiryDate.text = [Utils getDateStrFromOffset:(int)timesec];
            self.lblMaxCount.text = @"2,000";
            iMaxPhotoCount = 2000;
            break;
            
        case 2:
            self.lblCurrentPackage.text = @"+5 Package(5,000 Photos)";
            self.lblExpiryDate.text = [Utils getDateStrFromOffset:(int)timesec];
            self.lblMaxCount.text = @"5,000";
            iMaxPhotoCount = 5000;
            break;
            
        case 3:
            self.lblCurrentPackage.text = @"+10 Package(10,000 Photos)";
            self.lblExpiryDate.text = [Utils getDateStrFromOffset:(int)timesec];
            self.lblMaxCount.text = @"10,000";
            iMaxPhotoCount = 10000;
            break;
    }
    
    self.lblCurPhotoCount.text = [Utils getStringFromInteger:photocount];
    self.lblRemainCount.text = [NSString stringWithFormat:@"%d", (int)(iMaxPhotoCount - photocount)];
    
    float flocation = self.viewLimitLocation.frame.origin.x + (self.viewLimitLocation.frame.size.width * photocount / iMaxPhotoCount);
    CGRect rect = self.viewLimitBar.frame;
    rect.origin.x = flocation - rect.size.width / 2;
    self.viewLimitBar.frame = rect;
    
    rect = self.lblCurPhotoCount.frame;
    rect.origin.x = flocation - rect.size.width / 2;
    self.lblCurPhotoCount.frame = rect;
    
    [self.tblPurchase reloadData];
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
#pragma mark-tableview delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PurchaseCellItem *cell = [tableView dequeueReusableCellWithIdentifier:@"purchaseCellItem"];
    cell.btnPrice.tag = indexPath.row;
    if (indexPath.row == 0)
    {
        cell.lblTitle.text = @"+2 Package";
        cell.lblDescription.text = @"1 year of private cloud storage for up to 2,000 photos.";
        cell.lblPrice.text = strPrice1;
    }
    else if (indexPath.row == 1)
    {
        cell.lblTitle.text = @"+5 Package";
        cell.lblDescription.text = @"1 year of private cloud storage for up to 5,000 photos.";
        cell.lblPrice.text = strPrice2;
    }
    else
    {
        cell.lblTitle.text = @"+10 Package";
        cell.lblDescription.text = @"1 year of private cloud storage for up to 10,000 photos.";
        cell.lblPrice.text = strPrice3;
    }
    
    return cell;
}


- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)processPurchase:(id)sender
{
    NSInteger iPurChaseIndex = ((UIButton *)sender).tag;
    if (iCurPurchaseType > (iPurChaseIndex + 1))
    {
        [AppDelegate showMessage:@"You can purchase only higher level." withTitle:@"Error"];
        return;
    }
    
    [self showHUD:@"Processing..."];
    NSString *strProductID;
    if (iPurChaseIndex == 0)
        strProductID = KEY_IAP_PACKAGE2;
    else if (iPurChaseIndex == 1)
        strProductID = KEY_IAP_PACKAGE5;
    else
        strProductID = KEY_IAP_PACKAGE10;
    [[IAPManager sharedIAPManager] purchaseProductForId:strProductID
                                             completion:^(SKPaymentTransaction *transaction) {
                                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                 [self processRegisterPurchaseStatus:iPurChaseIndex transactionid:transaction.transactionIdentifier];
                                                 [self processSuccessPurchaseForAWS:iPurChaseIndex productid:strProductID transaction:transaction];
                                             } error:^(NSError *err) {
                                                 [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                 [self hideHUD];
                                                 NSLog(@"An error occured while purchasing: %@", err.localizedDescription);
                                             }];
}

-(void) processRegisterPurchaseStatus:(NSInteger)iPurChaseIndex transactionid:(NSString *)transactionid
{
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_APP_PURCHARSED] tag:TYPE_APP_PURCHASED delegate:self];
    [self.request setPostValue:[NSString stringWithFormat:@"%d", (int)iPurChaseIndex + 1] forKey:@"type"];
    [self.request setPostValue:[NSString stringWithFormat:@"%@", transactionid] forKey:@"transid"];
    [self.request startAsynchronous];
}

-(void) processSuccessPurchaseForAWS:(NSInteger)idx productid:(NSString *)productid transaction:(SKPaymentTransaction *)transaction
{
    AWSMobileAnalytics* insights = [AWSMobileAnalytics mobileAnalyticsForAppId:[NSString stringWithFormat:@"%@-%@", KEY_AMAZON_ANALYTICS,NSStringFromSelector(_cmd)]];
    // get the event client for the builder
    id<AWSMobileAnalyticsEventClient> eventClient = insights.eventClient;
    
    double fprice;
    if (idx == 0)
        fprice = 1.99;
    else if (idx == 1)
        fprice = 2.99;
    else
        fprice = 3.99;
    
    // create a builder that can record purchase events from Apple
    AWSMobileAnalyticsAppleMonetizationEventBuilder* builder = [AWSMobileAnalyticsAppleMonetizationEventBuilder builderWithEventClient:eventClient];
    
    // set the product id of the purchased item (obtained from the SKPurchaseTransaction object)
    [builder withProductId:productid];
    
    // set the item price and price locale (obtained from the SKProduct object)
    [builder withItemPrice:fprice
            andPriceLocale:[NSLocale systemLocale]];
    
    // set the quantity of item(s) purchased (obtained from the SKPurchaseTransaction object)
    [builder withQuantity:1];
    
    // set the transactionId of the transaction (obtained from the SKPurchaseTransaction object)
    [builder withTransactionId:transaction.transactionIdentifier];
    
    // build the monetization event
    id<AWSMobileAnalyticsEvent> purchaseEvent = [builder build];
    
    // add any additional metrics/attributes and record
    [eventClient recordEvent:purchaseEvent];
    
    //submit the event
    [eventClient submitEvents];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    //batchedEvents should be empty if all events has been sent successfully.
}


- (IBAction)processSearchAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1 day", @"1 month", @"6 months", @"1 year", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag)
        return;
    
    NSString *strDate = @"Select";
    if (buttonIndex == 0)
    {
        strDate = @"1 day";
        iSelectedDate = 1;
    }
    else if (buttonIndex == 1)
    {
        strDate = @"1 month";
        iSelectedDate = 30;
    }
    else if (buttonIndex == 2)
    {
        strDate = @"6 months";
        iSelectedDate = 180;
    }
    else if (buttonIndex == 3)
    {
        strDate = @"1 year";
        iSelectedDate = 365;
    }
//    else if (buttonIndex == 4)
//    {
//        strDate = @"1 hour";
//        iSelectedDate = 10000;
//    }
    
    self.lblDuration.text = strDate;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self isParentAlertView:alertView.tag])
    {
        [super alertView:alertView clickedButtonAtIndex:buttonIndex];
        return;
    }
    
    if (buttonIndex == 1)
        return;
    
    [self showHUD:@"Deleting..."];
    [self.request clearDelegatesAndCancel];
    self.request = [[AppDelegate sharedInstance] getDefaultRequest:[Utils getEventFunctionURL:FUNC_EVENT_DELETE_DUR_PHOTO] tag:TYPE_DELETE_DUR_PHOTOS delegate:self];
    [self.request setPostValue:[NSString stringWithFormat:@"%d", (int)iSelectedDate] forKey:@"duration"];
    [self.request startAsynchronous];
}

- (IBAction)processDeleteAction:(id)sender
{
    if ([self.lblDuration.text isEqualToString:@"Select"])
    {
        [AppDelegate showMessage:@"Please select duration for delete photos." withTitle:@"Error"];
        return;
    }
    
    NSString *strMessage = [NSString stringWithFormat:@"Are you sure you want to delete all your photos older than %@?", self.lblDuration.text];
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Confirm" message:strMessage delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    alertview.delegate = self;
    [alertview show];
}

@end
