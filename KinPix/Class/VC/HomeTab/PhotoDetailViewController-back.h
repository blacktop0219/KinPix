//
//  PhotoDetailViewController.h
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailView.h"
#import "MWPhotoBrowser.h"
#import "HPGrowingTextView.h"


@interface PhotoDetailViewController : TabParentViewController<UIAlertViewDelegate, MWPhotoBrowserDelegate, UIScrollViewDelegate,  PhotoDetailActionDelegate, HPGrowingTextViewDelegate>

@property (strong, nonatomic) IBOutlet DetailView *viewDetail;
@property (weak, nonatomic) IBOutlet UIScrollView *scMain;

@property (strong, nonatomic)   NSMutableArray     *arrViewPhotos;
@property                       NSInteger   iCurrentIdx;

- (IBAction)processBack:(id)sender;

@end
