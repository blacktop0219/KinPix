//
//Copyright (c) 2011, Tim Cinel
//All rights reserved.
//
//Redistribution and use in source and binary forms, with or without
//modification, are permitted provided that the following conditions are met:
//* Redistributions of source code must retain the above copyright
//notice, this list of conditions and the following disclaimer.
//* Redistributions in binary form must reproduce the above copyright
//notice, this list of conditions and the following disclaimer in the
//documentation and/or other materials provided with the distribution.
//* Neither the name of the <organization> nor the
//names of its contributors may be used to endorse or promote products
//derived from this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
//DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import <objc/message.h>

#import "ActionSheetMonthPicker.h"
#import "CDatePickerViewEx.h"

@interface ActionSheetMonthPicker()
@property (nonatomic, assign) UIDatePickerMode datePickerMode;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) CDatePickerViewEx *objdatePicker;
@end

@implementation ActionSheetMonthPicker

+ (id)showPickerWithTitle:(NSString *)title
           datePickerMode:(UIDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate
                   target:(id)target action:(SEL)action origin:(id)origin {
    ActionSheetMonthPicker *picker = [[ActionSheetMonthPicker alloc] initWithTitle:title datePickerMode:datePickerMode selectedDate:selectedDate target:target action:action origin:origin];
    [picker showActionSheetPicker];
    return picker;
}

+ (id)showPickerWithTitle:(NSString *)title
           datePickerMode:(UIDatePickerMode)datePickerMode
             selectedDate:(NSDate *)selectedDate
                doneBlock:(ActionDateDoneBlock)doneBlock
              cancelBlock:(ActionDateCancelBlock)cancelBlock
                   origin:(UIView*)view
{
    ActionSheetMonthPicker* picker = [[ActionSheetMonthPicker alloc] initWithTitle:title
                                                                  datePickerMode:datePickerMode
                                                                    selectedDate:selectedDate
                                                                       doneBlock:doneBlock
                                                                     cancelBlock:cancelBlock
                                                                          origin:view];
    [picker showActionSheetPicker];
    return picker;
}


- (id)initWithTitle:(NSString *)title datePickerMode:(UIDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate target:(id)target action:(SEL)action origin:(id)origin
{
    self = [self initWithTitle:title datePickerMode:datePickerMode selectedDate:selectedDate target:target action:action origin:origin cancelAction:nil];
    return self;
}

- (id)initWithTitle:(NSString *)title datePickerMode:(UIDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate target:(id)target action:(SEL)action origin:(id)origin cancelAction:(SEL)cancelAction
{
    self = [super initWithTarget:target successAction:action cancelAction:cancelAction origin:origin];
    if (self) {
        self.title = title;
        self.datePickerMode = datePickerMode;
        self.selectedDate = selectedDate;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
               datePickerMode:(UIDatePickerMode)datePickerMode
                 selectedDate:(NSDate *)selectedDate
                    doneBlock:(ActionDateDoneBlock)doneBlock
                  cancelBlock:(ActionDateCancelBlock)cancelBlock
                       origin:(UIView*)origin
{
    self = [self initWithTitle:title datePickerMode:datePickerMode selectedDate:selectedDate target:nil action:nil origin:origin];
    if (self) {
        self.onActionSheetDone = doneBlock;
        self.onActionSheetCancel = cancelBlock;
    }
    return self;
}

- (UIView *)configuredPickerView
{
    CGRect datePickerFrame = CGRectMake(0, 30, self.viewSize.width, 230);
    _objdatePicker = [[CDatePickerViewEx alloc] initWithFrame:datePickerFrame];
    
    // if datepicker is set with a date in countDownMode then
    // 1h is added to the initial countdown
    if (!self.selectedDate)
        self.selectedDate = [NSDate date];
    [_objdatePicker selectDate:self.selectedDate];
    
    //need to keep a reference to the picker so we can clear the DataSource / Delegate when dismissing (not used in this picker, but just in case somebody uses this as a template for another picker)
    self.pickerView = _objdatePicker;
    
    return _objdatePicker;
}

- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)action origin:(id)origin
{
    if (self.onActionSheetDone)
    {
        if (self.datePickerMode == UIDatePickerModeCountDownTimer)
            self.onActionSheetDone(self, @(((UIDatePicker *)self.pickerView).countDownDuration), origin);
        else
            self.onActionSheetDone(self, self.objdatePicker.date, origin);

        return;
    }
    else if ([target respondsToSelector:action])
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if (self.datePickerMode == UIDatePickerModeCountDownTimer) {
            [target performSelector:action withObject:@(((UIDatePicker *)self.pickerView).countDownDuration) withObject:origin];
            
        } else {
            [target performSelector:action withObject:_objdatePicker.date withObject:origin];
        }
#pragma clang diagnostic pop
    else
        NSAssert(NO, @"Invalid target/action ( %s / %s ) combination used for ActionSheetPicker", object_getClassName(target), sel_getName(action));
}

- (void)notifyTarget:(id)target didCancelWithAction:(SEL)cancelAction origin:(id)origin
{
    if (self.onActionSheetCancel)
    {
        self.onActionSheetCancel(self);
        return;
    }
    else
        if ( target && cancelAction && [target respondsToSelector:cancelAction] )
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [target performSelector:cancelAction withObject:origin];
#pragma clang diagnostic pop
        }
}


- (void)customButtonPressed:(id)sender {
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
    NSInteger index = button.tag;
    NSAssert((index >= 0 && index < self.customButtons.count), @"Bad custom button tag: %zd, custom button count: %zd", index, self.customButtons.count);
    NSDictionary *buttonDetails = (self.customButtons)[(NSUInteger) index];
    NSAssert(buttonDetails != NULL, @"Custom button dictionary is invalid");
    
    ActionType actionType = (ActionType) [buttonDetails[kActionType] integerValue];
    switch (actionType) {
        case Value: {
            NSAssert([self.pickerView respondsToSelector:@selector(setDate:animated:)], @"Bad pickerView for ActionSheetMonthPicker, doesn't respond to setDate:animated:");
            NSDate *itemValue = buttonDetails[kButtonValue];
            UIDatePicker *picker = (UIDatePicker *)self.pickerView;
            if (self.datePickerMode != UIDatePickerModeCountDownTimer)
            {
                [picker setDate:itemValue animated:YES];
            }
            break;
        }
            
        case Block:
        case Selector:
            [super customButtonPressed:sender];
            break;

        default:
            NSAssert(false, @"Unknown action type");
            break;
    }
}

@end