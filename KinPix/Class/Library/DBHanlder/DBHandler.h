//
//  ContentsModel.h
//  SentisApp
//
//  Created by IThelp on 11/1/12.
//  Copyright (c) 2012 IThelp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>


@interface DBHandler : NSObject


-(void)insertFriendsList:(NSMutableArray *)list replace:(BOOL)replace;
-(NSMutableArray *)getFriendsList:(NSString *)strKeyword;

@end
