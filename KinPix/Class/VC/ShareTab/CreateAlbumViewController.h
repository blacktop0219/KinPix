//
//  CreateAlbumViewController.h
//  Zinger
//
//  Created by QingHou on 11/20/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UpdateAlbumDelegate <NSObject>

-(void) updateAlbum:(AlbumInfoStruct *)info;

@end

@interface CreateAlbumViewController : TabParentViewController

@property (weak, nonatomic) UIViewController *shareViewController;
@property (weak, nonatomic) IBOutlet UITextField *txtAlbumName;
@property (weak, nonatomic) IBOutlet UISwitch *swiExpiryDate;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;
@property (weak, nonatomic) IBOutlet UIButton *btnCalender;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (weak, nonatomic) AlbumInfoStruct *info;
@property (weak, nonatomic) NSMutableArray *arrAlbumArray;
@property (nonatomic) BOOL bShareMode;

- (IBAction)onBack:(id)sender;
- (IBAction)onCreate:(id)sender;
- (IBAction)processCalendar:(id)sender;
- (IBAction)processExpiryAction:(id)sender;
- (IBAction)processTabAction:(id)sender;

@property (weak, nonatomic) id<UpdateAlbumDelegate> albumdelegate;

@end
