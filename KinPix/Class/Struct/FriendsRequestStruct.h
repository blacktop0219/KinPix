//
//  FriendsRequestStruct.h
//  Zinger
//
//  Created by Tianming on 25/12/14.
//  Copyright (c) 2014 Piao Dev Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendsRequestStruct : NSObject

{
    NSInteger iUserID;
    NSString *strFirstName;
    NSString *strLastName;
    NSString *strPhotoUrl;
    
    BOOL bMale;
    BOOL bCompany;
}

-(void) initWithJSonData:(NSDictionary *)dict;

- (BOOL) isMale;
- (BOOL) isCompany;
-(NSString *) getUserIDToString;
-(NSInteger) getUserID;
-(NSString *) getPhotoStringURL;
-(NSURL *) getPhotoURL;
-(NSString *) getUserName;

@end
