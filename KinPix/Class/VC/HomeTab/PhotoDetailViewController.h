//
//  PhotoDetailViewController.h
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EBPhotoPages/EBPhotoPagesController.h>
#import "HPGrowingTextView.h"
#import "DetailView.h"

@interface PhotoDetailViewController : TabParentViewController<UIAlertViewDelegate, EBPhotoPagesDataSource, EBPhotoPagesDelegate,
                    UIScrollViewDelegate,  PhotoDetailActionDelegate, HPGrowingTextViewDelegate>

@property (strong, nonatomic) IBOutlet DetailView *viewDetail;
@property (weak, nonatomic) IBOutlet UIScrollView *scMain;

@property (strong, nonatomic)   NSMutableArray     *arrViewPhotos;
@property                       NSInteger   iCurrentIdx;
@property                       BOOL        bShowPermission;

- (IBAction)processBack:(id)sender;
- (BOOL) isChanged;
- (void) processSaveAction;
@end
