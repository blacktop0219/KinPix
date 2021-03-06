//
//  TGCameraAuthorizationViewController.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 20/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "TGCameraAuthorizationViewController.h"

@interface TGCameraAuthorizationViewController ()

- (IBAction)closeTapped;

@end



@implementation TGCameraAuthorizationViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if(IS_IPHONE_5)
        self = [super initWithNibName:@"TGCameraAuthorizationViewController" bundle:nibBundleOrNil];
    else
        self = [super initWithNibName:@"TGCameraAuthorizationViewController_iPhone4" bundle:nibBundleOrNil];
    
    if (self)
    {
        
    }
    
    return self;
}

-(BOOL) shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -
#pragma mark - Actions

- (IBAction)closeTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end