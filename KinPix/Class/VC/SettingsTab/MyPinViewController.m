//
//  MyPinViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "MyPinViewController.h"
#import "SelectPinViewController.h"

@interface MyPinViewController ()

@end

@implementation MyPinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.
    
    AppDelegate *delegate = [AppDelegate sharedInstance];
    
    self.pinLbl.text = delegate.objUserInfo.strPinCode;
    
    [self.coverView.layer setBorderWidth:0.6];
    [self.coverView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];

}


- (IBAction)sendEmail:(id)sender {
}

- (IBAction)sendSMS:(id)sender {
}

- (IBAction)copyClipboard:(id)sender {
    
    [UIPasteboard generalPasteboard].string = self.pinLbl.text;
}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    SelectPinViewController *VC = (SelectPinViewController*)[segue destinationViewController];
    
    if([segue.identifier isEqualToString:@"goSharePinEmail"])
    {
        VC.type = 0;
    }
    else if([segue.identifier isEqualToString:@"sharePinViaSms"])
    {
        VC.type = 1;
    }
}
@end
