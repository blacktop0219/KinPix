//
//  CommentViewCell.h
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CommentViewCellDelegate <NSObject>

-(void) commentVeiwCellMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface CommentViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblComment;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@property (weak, nonatomic) id<CommentViewCellDelegate> delegate;

-(void) initWithCommentData:(CommentInfoStruct *)info;

+(NSInteger) getItemHeight:(CommentInfoStruct *)info;

@end
