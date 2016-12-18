//
//  ParseData.h
//  Zinger
//
//  Created by Piao Dev on 14/01/15.
//  Copyright (c) 2015 Piao Dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseData : NSObject

+(void) parsePhotoInfo:(NSArray *) arrparam destination:(NSMutableArray *)destination breqinit:(BOOL)breqinit;
+(void) parseLikeInfo:(NSArray *) arrparam destination:(NSMutableArray *)destination breqinit:(BOOL)breqinit;

@end
