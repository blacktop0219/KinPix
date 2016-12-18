//
//  CommentViewController.h
//  KinPix
//
//  Created by Piao Dev on 30/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "PhotoInfoStruct.h"
#import "CommentViewCell.h"

@interface CommentViewController : UIViewController<HPGrowingTextViewDelegate, UITableViewDataSource, UITableViewDelegate,
                                                        ASIHTTPRequestDelegate, CommentViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tblComment;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *aivLoading;
@property (nonatomic, retain) PhotoInfoStruct *photoinfo;

- (IBAction)processBackAction:(id)sender;
- (IBAction)processLeaveCommentAction:(id)sender;
- (IBAction)processTabAction:(id)sender;

@end
