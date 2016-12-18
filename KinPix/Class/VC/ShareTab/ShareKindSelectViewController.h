//
//  ShareKindSelectViewController.h
//  KinPix
//
//  Created by Piao Dev on 23/02/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareKindSelectViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *btnShareAlbum;
@property (weak, nonatomic) IBOutlet UIButton *btnShareBucket;


@property (weak, nonatomic) IBOutlet UIView *viewBucketInfo;
@property (weak, nonatomic) IBOutlet UIView *viewAlbumInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnAlbumInfo;
@property (weak, nonatomic) IBOutlet UIButton *btnBucketInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblAlbumTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAlbumInfo;
@property (weak, nonatomic) IBOutlet UILabel *lblBucketTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblBucketInfo;


- (IBAction)processOptionSelected:(id)sender;
- (IBAction)processNextAction:(id)sender;
- (IBAction)processCancelAction:(id)sender;
- (IBAction)processBackAction:(id)sender;

@end
