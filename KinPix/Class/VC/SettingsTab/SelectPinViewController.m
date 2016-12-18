//
//  SelectPinViewController.m
//  Zinger
//
//  Created by QingHou on 11/4/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "SelectPinViewController.h"
#import "SharePinViewController.h"

@interface SelectPinViewController ()

@end

@implementation SelectPinViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self hideButtons];
    // Do any additional setup after loading the view.
    
    if(self.type == 0)
    {
        self.titleLbl.text = @"Share Pin Via Email";
        [self.enterPinBtn setImage:[UIImage imageNamed:@"enterEmailBtn"] forState:UIControlStateNormal];
    }
    else
    {
        self.titleLbl.text = @"Share Pin Via SMS";
        [self.enterPinBtn setImage:[UIImage imageNamed:@"enterPhoneBtn"] forState:UIControlStateNormal];
    }
    
    [self.coverView.layer setBorderWidth:0.6];
    [self.coverView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SharePinViewController *VC = (SharePinViewController*)[segue destinationViewController];
    
    if([segue.identifier isEqualToString:@"goSharePin1"])
    {
        VC.type = self.type;
        
        if([self.contactStr length] > 0)
            VC.contactStr = self.contactStr;
    }
    
    self.contactStr = @"";
}


- (IBAction)onLocalContacts:(id)sender {
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    if(self.type == 0)
        picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]];
    else
        picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    
    [self presentViewController:picker animated:YES completion:nil];

}


- (IBAction)onBack:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - 
#pragma mark - ABPeoplePickerNavigationController Delegate

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    NSString* name = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    
    NSLog(@"name = %@", name);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    return NO;
}

//For iOS8
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    if(property == kABPersonPhoneProperty || property == kABPersonEmailProperty)
    {
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        
        self.contactStr = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(multi, identifier));


    }

    [self performSegueWithIdentifier:@"goSharePin1" sender:nil];
}

//For iOS7
- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    if(property == kABPersonPhoneProperty || property == kABPersonEmailProperty)
    {
        ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
        
        self.contactStr = (__bridge NSString *)(ABMultiValueCopyValueAtIndex(multi, identifier));
                
    }
    
    [self performSegueWithIdentifier:@"goSharePin1" sender:nil];


    return NO;
}


- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
