//
//  CreateBucketViewController.h
//  Zinger
//
//  Created by Tianming on 09/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BucketInfoStruct.h"


@interface BucketPermissionViewController : TabParentViewController

@property (weak, nonatomic) IBOutlet UICollectionView *covFriends;

@property BucketInfoStruct *objInfo;

- (IBAction)processBackAction:(id)sender;

@end
