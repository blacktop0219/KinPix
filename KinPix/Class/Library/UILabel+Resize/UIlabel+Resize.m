//
//  UIlabel+Resize.m
//  Sam
//
//  Created by QingHou on 7/9/14.
//  Copyright (c) 2014 QingHou. All rights reserved.
//

#import "UIlabel+Resize.h"

@implementation UILabel (Resize)

-(void) sizeToFitHeight
{
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          
                                          self.font, NSFontAttributeName,
                                          
                                          self.textColor, NSForegroundColorAttributeName,
                                          
                                          nil];
    
    
    NSLog(@"%@", self.text);
    
    CGRect text_size = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 9000.0)
                        
                                               options:NSStringDrawingUsesLineFragmentOrigin //NSStringDrawingUsesFontLeading
                        
                                            attributes:attributesDictionary
                        
                                               context:nil];
    
    CGRect newFrame = self.frame;
    //    newFrame.size.height = expectedLabelSize.height;
    newFrame.size.width = text_size.size.width;
    newFrame.size.height = text_size.size.height;
    
    self.frame = newFrame;
    
    
}

@end
