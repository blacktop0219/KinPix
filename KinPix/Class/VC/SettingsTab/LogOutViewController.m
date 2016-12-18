//
//  LogOutViewController.m
//  Zinger
//
//  Created by QingHou on 10/30/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "LogOutViewController.h"

@interface LogOutViewController ()

@end

@implementation LogOutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.

    [self.coverView.layer setBorderWidth:0.6];
    [self.coverView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
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

- (IBAction)onLogOut:(id)sender
{
    AppDelegate *delegate = [AppDelegate sharedInstance];
    [delegate playAudio:s_Logout];
    
    [[AppDelegate sharedInstance] logout];
    [[AppDelegate sharedInstance] refreshUserEnvironment];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"signOut" object:nil];
    
    NSUserDefaults *userDefautls = [NSUserDefaults standardUserDefaults];
    [userDefautls setObject:@"" forKey:@"password"];
    [userDefautls synchronize];
}

- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
