//
//  GroupSelectionViewController.m
//  Zinger
//
//  Created by Tianming on 02/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import "GroupSelectionViewController.h"

@interface GroupSelectionViewController ()
{
    NSMutableArray *arrGroups;
    //NSMutableArray *arrBuckets;
    NSMutableArray *arrGroupChecked;
    //NSMutableArray *arrBucketChecked;
}
@end

@implementation GroupSelectionViewController

@synthesize tblGroup, strGroupIds;
//@synthesize strBucketIds;

- (void)viewDidLoad
{
    [super viewDidLoad];
    arrGroups = [AppDelegate sharedInstance].arrMyGroups;
    arrGroupChecked = [[NSMutableArray alloc] init];
    NSArray *arrtmp = nil;
    if (strGroupIds.length > 0)
        arrtmp = [strGroupIds componentsSeparatedByString:@","];
    for (GroupInfoStruct *ginfo in arrGroups)
    {
        if (arrtmp)
        {
            BOOL bExist = NO;
            for (NSString *strId in arrtmp)
            {
                if ([strId integerValue] == [ginfo getGroupID])
                {
                    [arrGroupChecked addObject:@"1"];
                    bExist = YES;
                    break;
                }
            }
            
            if (bExist)
                continue;
        }
        
        [arrGroupChecked addObject:@"0"];
    }
    
    
    //arrBuckets = [[NSMutableArray alloc] init];
    //arrBucketChecked = [[NSMutableArray alloc] init];
    //[Utils copyArray:[AppDelegate sharedInstance].arrMyBucket desarray:arrBuckets];
    //for (NSObject *obj in [AppDelegate sharedInstance].arrFriendBucket)
    //    [arrBuckets addObject:obj];
    
    arrtmp = nil;
//    if (strBucketIds.length > 0)
//        arrtmp = [strBucketIds componentsSeparatedByString:@","];
//    for (BucketInfoStruct *ginfo in arrBuckets)
//    {
//        if (arrtmp)
//        {
//            BOOL bExist = NO;
//            for (NSString *strId in arrtmp)
//            {
//                if ([strId integerValue] == [ginfo getBucketID])
//                {
//                    [arrBucketChecked addObject:@"1"];
//                    bExist = YES;
//                    break;
//                }
//            }
//            
//            if (bExist)
//                continue;
//        }
//        
//        [arrBucketChecked addObject:@"0"];
//    }
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //if (section == 0)
        return [arrGroups count];
    
    //return [arrBuckets count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (section == 0)
//        return @"Groups";
//    
//    return @"Buckets";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self saveItemState:indexPath.section index:indexPath.row checkstate:NO];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self saveItemState:indexPath.section index:indexPath.row checkstate:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void) saveItemState:(NSInteger)section index:(NSInteger)index checkstate:(BOOL)checkstate
{
    NSMutableArray *arrtarget;
    if (section == 0)
        arrtarget = arrGroupChecked;
//    else
//        arrtarget = arrBucketChecked;
    
    if (arrtarget.count > index)
    {
        NSString *strValue = checkstate ? @"1" : @"0";
        [arrtarget replaceObjectAtIndex:index withObject:strValue];
    }
}

-(BOOL) isChecked:(NSInteger)section index:(NSInteger)index
{
    NSMutableArray *arrtarget;
    if (section == 0)
        arrtarget = arrGroupChecked;
//    else
//        arrtarget = arrBucketChecked;
    
    if (arrtarget.count > index)
    {
        NSString *str = [arrtarget objectAtIndex:index];
        return [str isEqualToString:@"1"];
    }
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"groupSelectCell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] init];
    }
    if (indexPath.section == 0)
    {
        if (indexPath.row < [arrGroups count])
        {
            GroupInfoStruct *info = [arrGroups objectAtIndex:indexPath.row];
            cell.textLabel.text = [info getGroupName];
        }
    }
//    else
//    {
//        if (indexPath.row < [arrBuckets count])
//        {
//            BucketInfoStruct *info = [arrBuckets objectAtIndex:indexPath.row];
//            cell.textLabel.text = [info getBucketName:NO];
//        }
//    }
    
    if ([self isChecked:indexPath.section index:indexPath.row])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (IBAction)processCancelAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)processApplyAction:(id)sender
{
    NSMutableArray *arrFilter = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrGroups count];i++)
    {
        if ([self isChecked:0 index:i])
            [arrFilter addObject:[arrGroups objectAtIndex:i]];
    }
    
//    NSMutableArray *arrFilterBucket = [[NSMutableArray alloc] init];
//    for (int i = 0; i < [arrBuckets count];i++)
//    {
//        if ([self isChecked:1 index:i])
//            [arrFilterBucket addObject:[arrBuckets objectAtIndex:i]];
//    }
    if ([arrFilter count] < 1
           // && [arrFilterBucket count] < 1
        )
    {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please select circles for filter." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        return;
    }
    
    [self.controlView processGroupFilter: arrFilter];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
