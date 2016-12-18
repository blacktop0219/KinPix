//
//  PhotoActionDelegate.h
//  Zinger
//
//  Created by Piao Dev on 20/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoActionDelegate <NSObject>

- (void)processComment:(PhotoInfoStruct *)info;
- (void)processPermission:(PhotoInfoStruct *)info index:(NSInteger)index;
- (void)processMore:(PhotoInfoStruct *)info index:(NSInteger)index;
- (void)processLikeView:(PhotoInfoStruct *)info;

@end
