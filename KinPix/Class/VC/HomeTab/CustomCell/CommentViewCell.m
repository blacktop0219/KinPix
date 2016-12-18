//
//  CommentViewCell.m
//  Zinger
//
//  Created by Tianming on 20/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import "CommentViewCell.h"

#define WIDTH_COMMENT   238
#define POSY_COMMENT    27
#define MIN_HEIGHT      17

@implementation CommentViewCell

- (void)awakeFromNib
{
    [AppDelegate processUserImage:self.ivUser];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) initWithCommentData:(CommentInfoStruct *)info
{
    self.lblTime.text = [Utils getTimeString:[info getTimeSec]];
    self.lblUserName.text = [info getUserName];
    self.lblComment.text = [info getCommentText];
    
    CGRect recttext = [[info getCommentText] boundingRectWithSize:CGSizeMake(WIDTH_COMMENT, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{ NSFontAttributeName : self.lblComment.font }
                                        context:nil];
    CGRect rect = self.lblComment.frame;
    rect.size.height = recttext.size.height > MIN_HEIGHT ? recttext.size.height : recttext.size.height + 2;
    self.lblComment.frame = rect;
    
    rect = self.frame;
    rect.size.height = POSY_COMMENT + self.lblComment.frame.size.height + 7;
    self.frame = rect;
    
    UIImage *imgUser = [Utils getDefaultProfileImage];
    [self.ivUser sd_setImageWithURL:[info getUserPhotoURL] placeholderImage:imgUser options:SDWebImageProgressiveDownload];
}

+(NSInteger) getItemHeight:(CommentInfoStruct *)info
{
    UIFont *font = [AppDelegate getAppSystemFont:11];
    CGRect recttext = [[info getCommentText] boundingRectWithSize:CGSizeMake(WIDTH_COMMENT, CGFLOAT_MAX)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{ NSFontAttributeName : font }
                                           context:nil];
    NSInteger height = recttext.size.height > MIN_HEIGHT ? recttext.size.height : recttext.size.height + 2;
    height = POSY_COMMENT + height + 7;
    return height > 41 ? height : 41;
}

@end
