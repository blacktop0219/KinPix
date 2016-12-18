//
//  DetailView.h
//  Zinger
//
//  Created by Piao Dev on 14/01/15.
//  Copyright (c) 2015 Piao Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HPGrowingTextView.h"

@protocol PhotoDetailActionDelegate <NSObject>

- (void)processMore:(PhotoInfoStruct *)info index:(NSInteger)index;
- (void)processLikeView:(PhotoInfoStruct *)info;
- (void)processFullScreen:(PhotoInfoStruct *)info index:(NSInteger)index;
- (void)processShowPermission:(PhotoInfoStruct *)info;
- (void)processAddFamilys:(NSMutableArray *)arrFamilys;
- (void)processAddGroups:(NSMutableArray *)arrGroups;
- (void)processSavePermission:(NSMutableArray *)arrGroups arrFriends:(NSMutableArray *)arrFriends photoinfo:(PhotoInfoStruct *)photoinfo parentflag:(BOOL)parentflag;
-(void) processShowComment:(PhotoInfoStruct *)info comments:(NSMutableArray *)arrComments;
@end

@interface DetailView : UIView <ASIHTTPRequestDelegate>

@property (strong, nonatomic) PhotoInfoStruct *pinfo;

@property (nonatomic, strong) UIView *containerView;

@property (weak, nonatomic) IBOutlet UIScrollView *scView;
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UITableView *tblComment;

@property (weak, nonatomic) IBOutlet UIView *viewButton;
@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UIView *viewComment;
@property (weak, nonatomic) IBOutlet UIView *viewPermission;
@property (weak, nonatomic) IBOutlet UIView *viewMoveButtons;
@property (weak, nonatomic) IBOutlet UIView *viewGroup;

@property (weak, nonatomic) IBOutlet UIButton *btnFavorite;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;
@property (weak, nonatomic) IBOutlet UIButton *btnFlag;
@property (weak, nonatomic) IBOutlet UIButton *btnMain;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnComment;
@property (weak, nonatomic) IBOutlet UIButton *btnPermission;
@property (weak, nonatomic) IBOutlet UIButton *btnLikeCount;

@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTagTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTagValue;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblGroupName;
@property (weak, nonatomic) IBOutlet UILabel *lblShareKind;
@property (weak, nonatomic) IBOutlet UILabel *lblSharedBy;

// Bucket Option
@property (weak, nonatomic) IBOutlet UILabel *lblBucketOwner;
@property (weak, nonatomic) IBOutlet UILabel *lblBucketOwnerValue;

@property (weak, nonatomic) IBOutlet UICollectionView *covFriends;
@property (weak, nonatomic) IBOutlet UICollectionView *covGroups;

@property (strong, nonatomic) HPGrowingTextView *txtComment;
@property (strong, nonatomic) UIView *viewTextComment;
@property (strong, nonatomic) UIButton *doneBtn;

@property (weak, nonatomic) id<PhotoDetailActionDelegate>delegate;

- (IBAction)processPermission:(id)sender;
- (IBAction)processFavorite:(id)sender;
- (IBAction)processLike:(id)sender;
- (IBAction)processFlag:(id)sender;
- (IBAction)processMoreAction:(id)sender;
- (IBAction)processFullScreenAction:(id)sender;
- (IBAction)processLikeUserAction:(id)sender;
- (IBAction)processShowComment:(id)sender;
- (IBAction)processSaveAction:(id)sender;
- (IBAction)processHideKeyboard:(id)sender;

-(void) initWithViewData:(PhotoInfoStruct *)info index:(NSInteger)index;
//-(void) refreshComments:(NSArray *)array initflag:(BOOL)initflag;
-(void) setViewActivated;
-(void) refreshCollectionView;
-(void) refreshComponent;
-(void) updatedPermission;
-(void) showPermission;
-(BOOL) isChanged;
-(void) ignorePermission;

- (NSMutableArray *) getGroups;
- (NSMutableArray *) getFamilies;


@end
