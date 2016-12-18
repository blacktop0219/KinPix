//
//  SettingsViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "HtmlViewController.h"
#import <MessageUI/MessageUI.h>

@interface HtmlViewController () <UIWebViewDelegate, MFMailComposeViewControllerDelegate>

@end


@implementation HtmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.
    
    if(self.type == 1) //About Us
    {
        NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
        NSString *displayVersionNumber = [NSString stringWithFormat:@"Version : "];
        displayVersionNumber = [displayVersionNumber stringByAppendingFormat: @"%@.%@",version, build];
        
        self.versionLbl.text = displayVersionNumber;
        
        self.versionLbl.hidden = NO;
    }
    else if (self.type == 2)
    {
        self.versionLbl.text = @"Help and Contact Us";
    }
    else if (self.type == 3)
    {
        self.versionLbl.text = @"Feedback";
    }
    
    [self getContent];
    
    [self.webView.layer setBorderWidth:0.6];
    [self.webView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
}

-(void) viewWillAppear:(BOOL)animated
{
    self.webView.delegate = self;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.request clearDelegatesAndCancel];
    [self.webView stopLoading];
    self.webView.delegate = nil;
}

- (void) getContent
{
    ASIFormDataRequest *request = [[AppDelegate sharedInstance] getGeneralHttpRequest:[Utils getEventFunctionURL:FUNC_EVENT_SITEINFO] delegate:self];
    
    [request setPostValue:[NSString stringWithFormat:@"%d", self.type] forKey:@"type"];
    [request startAsynchronous];
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
    if(status == 200)
    {
        NSString *content =[NSString stringWithFormat:@"<html>%@</html>" ,[json objectForKey:@"content"]];
        
        [self.webView loadHTMLString:content baseURL:nil];
    
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)inType
{
    if ([request.URL.scheme isEqualToString:@"mailto"])
    {
        // make sure this device is setup to send email
        if ([MFMailComposeViewController canSendMail]) {
            // create mail composer object
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            
            // make this view the delegate
            mailer.mailComposeDelegate = self;
            
            // set recipient
            [mailer setToRecipients:[NSArray arrayWithObject:request.URL.resourceSpecifier]];
            
            // generate message body
            NSString *body = @"";
            
            // add to users signature
            [mailer setMessageBody:body isHTML:NO];
            
            // present user with composer screen
            [self presentViewController:mailer animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Mail Accounts" message:@"Please set up a Mail account in order to send email." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        // don't load url in this webview
        return NO;
    }
    
    if ( inType == UIWebViewNavigationTypeLinkClicked )
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}



@end
