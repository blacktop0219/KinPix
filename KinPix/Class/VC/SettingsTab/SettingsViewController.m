//
//  LeftViewController.m
//  Pineapple
//
//  Created by QingHou on 7/2/14.
//  Copyright (c) 2014 QingHou. All rights reserved.
//

#import "SettingsViewController.h"
#import "LeftTableViewCell.h"
#import "MyProfileViewController.h"
#import "MyPinViewController.h"
#import "HtmlViewController.h"
#import "LegalViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.
    
    self.m_tableView.backgroundColor = [UIColor whiteColor];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.m_tableView.hidden = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"leftTableCell";
    
    LeftTableViewCell   *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSArray *txtArray_eng = [NSArray arrayWithObjects:@"Search", @"My Trending Photos", @"About",@"My Profile",@"My Pin",@"Help and Contact Us" ,@"Legal", @"Feedback",@"In-App Purchase Options",@"Log Out", nil];

    cell.titleLbl.text = [txtArray_eng objectAtIndex:indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSArray *storyboardIDArray = [NSArray arrayWithObjects:@"searchPhotoVC", @"trendingView", @"htmlView", @"myProfileView", @"myPinView", @"htmlView", @"legalView", @"htmlView", @"premiumView", @"logoutView", nil];
    UIViewController *vc = [[AppDelegate sharedInstance] getUIViewController:[storyboardIDArray objectAtIndex:indexPath.row]];
    if(indexPath.row == 2 || indexPath.row == 5 || indexPath.row == 7)
    {
        HtmlViewController *htmlVC = (HtmlViewController*)vc;
        
        if(indexPath.row == 2)
            htmlVC.type = 1;
        else if (indexPath.row == 5)
            htmlVC.type = 2;
        else if (indexPath.row == 7)
            htmlVC.type = 3;
    }
    else if(indexPath.row == 6)
    {
        LegalViewController *legalVC= (LegalViewController*)vc;
        legalVC.b_shouldAccept = NO;
        legalVC.b_tabBased = YES;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 }
 

- (IBAction)processBack:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
