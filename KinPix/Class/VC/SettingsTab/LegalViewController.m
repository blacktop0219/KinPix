//
//  LegalViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "LegalViewController.h"

@interface LegalViewController ()

@end

@implementation LegalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.webView.layer setBorderWidth:0.6];
    [self.webView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];

    [self hideButtons];
    if(self.b_shouldAccept == YES)
    {
        self.acceptBtn.hidden = NO;
    }
    else
    {
        self.acceptBtn.hidden = YES;
        
        CGRect rect = self.webView.frame;
        
        float yOfset = 0;
        
        if(self.b_tabBased == NO)
            yOfset = 30;
        
        if(IS_IPHONE_5)
            rect.size.height = 357 + yOfset;
        else
            rect.size.height = 269 + yOfset;
        
        self.webView.frame = rect;
    }
    
    self.type = 5;
    //self.termsContent = [AppDelegate sharedInstance].strTerms;
    //self.privacyContent = [AppDelegate sharedInstance].strPrivacy;

    if ([self.termsContent length] < 1)
        [self getContent];
    else
        [self onTerms:nil];
    
    if (self.bShowPrivacy)
        [self onPrivacy:nil];
    else
        [self onTerms:nil];
    
    //[[AppDelegate sharedInstance] updatePolicyViewState];
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
    [request setPostValue:@"contents" forKey:@"type"];
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
        self.termsContent = [json objectForKey:@"terms_content"];
        self.privacyContent = [json objectForKey:@"privacy_content"];
        if(self.type == 5)
            [self.webView loadHTMLString:self.termsContent baseURL:nil];
        else
            [self.webView loadHTMLString:self.privacyContent baseURL:nil];
        
    }
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

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (IBAction)onTerms:(id)sender {
    self.type = 5;
    
    [self.privacyBtn setBackgroundImage:[UIImage imageNamed:@"btn4.png"] forState:UIControlStateNormal];
    [self.privacyBtn setTitleColor:mainColor forState:UIControlStateNormal];
    
    [self.termsBtn setBackgroundImage:[UIImage imageNamed:@"btn6.png"] forState:UIControlStateNormal];
    [self.termsBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    if([self.termsContent length] > 0)
        [self.webView loadHTMLString:self.termsContent baseURL:nil];
    else
        [self.webView loadHTMLString:@"" baseURL:nil ];
    
    //[AppDelegate sharedInstance].bShowTerms = YES;
}

- (IBAction)onPrivacy:(id)sender {

    self.type = 4;
    
    [self.termsBtn setBackgroundImage:[UIImage imageNamed:@"btn4.png"] forState:UIControlStateNormal];
    [self.termsBtn setTitleColor:mainColor forState:UIControlStateNormal];

    [self.privacyBtn setBackgroundImage:[UIImage imageNamed:@"btn6.png"] forState:UIControlStateNormal];
    [self.privacyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    if([self.privacyContent length] > 0)
        [self.webView loadHTMLString:self.privacyContent baseURL:nil];
    else
    {
        [self.webView loadHTMLString:@"" baseURL:nil ];
    }
    
    //[AppDelegate sharedInstance].bShowPrivacy = YES;
}

- (IBAction)onAccept:(id)sender {
    
    [self goTabBarController];
}
@end

