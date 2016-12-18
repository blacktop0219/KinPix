//
//  LikeUserViewCell.h
//  Zinger
//
//  Created by Piao Dev on 20/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikerInfoStruct.h"

@interface LikeUserViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ivUser;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

-(void) initWithLikeData:(LikerInfoStruct *)info;

@end
