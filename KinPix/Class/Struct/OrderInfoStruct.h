//
//  OrderInfoStruct.h
//  KinPix
//
//  Created by Piao Dev on 27/01/15.
//  Copyright (c) 2015 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderInfoStruct : NSObject
{
    NSInteger iLastPhotoID;
    NSInteger iUserID;
    NSString *strName;
    NSInteger iBucketID;
    NSInteger iUnreadCount;
    
    NSMutableArray *arrPhotos;
}


-(id) initWithJsonData:(NSDictionary *)dict;

-(BOOL) isMyOrder;
-(BOOL) isBucketOrder;

-(NSInteger) getUnreadCount;
-(NSInteger) getUserID;
-(NSInteger) getBucektID;
-(NSString *) getName;
-(NSString *) getUnreadCountToString;
-(NSMutableArray *) getOrderPhotos;

-(void) addOwnPhotos:(NSMutableArray *)array;

@end
