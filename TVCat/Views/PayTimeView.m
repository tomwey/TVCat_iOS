//
//  PayTimeView.m
//  HN_Vendor
//
//  Created by tomwey on 03/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "PayTimeView.h"
#import "Defines.h"

@interface PayTimeView ()

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UIButton *beginDateButton;
@property (nonatomic, strong) UIButton *endDateButton;

@property (nonatomic, strong) UILabel *separatorLabel;

@property (nonatomic, strong) NSDateFormatter *dateFormater;

@end

@implementation PayTimeView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)]];
    }
    return self;
}

- (void)close
{
    AWSetAllTouchesDisabled(YES);
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.contentView.top = -self.contentView.height;
    } completion:^(BOOL finished) {
        AWSetAllTouchesDisabled(NO);
        [self removeFromSuperview];
    }];
}

- (UILabel *)separatorLabel
{
    if ( !_separatorLabel ) {
        _separatorLabel = AWCreateLabel(CGRectMake(0, 0, 30, 40),
                                        @"—", NSTextAlignmentCenter,
                                        AWSystemFontWithSize(14, NO),
                                        AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_separatorLabel];
    }
    return _separatorLabel;
}

- (UIButton *)beginDateButton
{
    if ( !_beginDateButton ) {
        _beginDateButton = AWCreateTextButton(CGRectZero,
                                              @"设置开始日期",
                                              AWColorFromRGB(88, 88, 88),
                                              self,
                                              @selector(beginClick));
        [self.contentView addSubview:_beginDateButton];
        
        _beginDateButton.titleLabel.font = AWSystemFontWithSize(14, NO);
        
        _beginDateButton.layer.borderWidth = 0.6;
        _beginDateButton.layer.borderColor = AWColorFromHex(@"#999999").CGColor;
    }
    return _beginDateButton;
}

- (void)beginClick
{
    [self openDatePicker:self.beginDateButton];
}

- (UIButton *)endDateButton
{
    if ( !_endDateButton ) {
        _endDateButton = AWCreateTextButton(CGRectZero,
                                              @"设置结束日期",
                                              AWColorFromRGB(88, 88, 88),
                                              self,
                                              @selector(endClick));
        [self.contentView addSubview:_endDateButton];
        
        _endDateButton.titleLabel.font = AWSystemFontWithSize(14, NO);
        
        _endDateButton.layer.borderWidth = 0.6;
        _endDateButton.layer.borderColor = AWColorFromHex(@"#999999").CGColor;
    }
    return _endDateButton;
}

- (void)endClick
{
    [self openDatePicker:self.endDateButton];
}

- (UIButton *)resetButton
{
    if ( !_resetButton ) {
        _resetButton = AWCreateTextButton(CGRectZero,
                                          @"重置",
                                          MAIN_THEME_COLOR,
                                          self,
                                          @selector(reset));
        [self.contentView addSubview:_resetButton];
        
        _resetButton.layer.borderWidth = 0.6;
        _resetButton.layer.borderColor = MAIN_THEME_COLOR.CGColor;
        
        _resetButton.titleLabel.font = AWSystemFontWithSize(14, NO);
        
    }
    return _resetButton;
}

- (void)openDatePicker:(UIButton *)button
{
    DatePicker *picker = [[DatePicker alloc] init];
    picker.frame = self.superview.bounds;
    [picker showPickerInView:self.superview];
    picker.currentSelectedDate = button.userData ?: [NSDate date];
    
    __weak typeof(self) me = self;
    picker.didSelectDateBlock = ^(DatePicker *sender, NSDate *selectedDate) {
        [button setTitle:[me.dateFormater stringFromDate:selectedDate] forState:UIControlStateNormal];
        button.userData = selectedDate;
    };
}

- (void)reset
{
    self.beginDateButton.userData = nil;
    self.endDateButton.userData   = nil;
    
    [self.beginDateButton setTitle:@"设置开始日期" forState:UIControlStateNormal];
    [self.endDateButton setTitle:@"设置结束日期" forState:UIControlStateNormal];
}

- (UIButton *)okButton
{
    if ( !_okButton ) {
        _okButton = AWCreateTextButton(CGRectZero,
                                          @"确定",
                                          [UIColor whiteColor],
                                          self,
                                          @selector(confirm));
        [self.contentView addSubview:_okButton];
        
        _okButton.titleLabel.font = AWSystemFontWithSize(14, NO);
        
        _okButton.backgroundColor = MAIN_THEME_COLOR;
        
    }
    return _okButton;
}

- (void)setBeginDate:(NSString *)beginDate
{
    _beginDate = beginDate;
    
    self.beginDateButton.userData = [self.dateFormater dateFromString:beginDate];
    if ( beginDate ) {
        [self.beginDateButton setTitle:beginDate forState:UIControlStateNormal];
    }
}

- (void)setEndDate:(NSString *)endDate
{
    _endDate = endDate;
    
    self.endDateButton.userData = [self.dateFormater dateFromString:endDate];
    if ( endDate ) {
        [self.endDateButton setTitle:endDate forState:UIControlStateNormal];
    }
}

- (void)confirm
{
    NSString *currentBeginDate = [self.dateFormater stringFromDate:self.beginDateButton.userData];
    NSString *currentEndDate = [self.dateFormater stringFromDate:self.endDateButton.userData];
    
    NSString *temp1 = currentBeginDate ?: @"";
    NSString *temp2 = currentEndDate ?: @"";
    
    NSString *temp3 = self.beginDate ?: @"";
    NSString *temp4 = self.endDate ?: @"";
    
    if ( [[temp1 stringByAppendingString:temp2] isEqualToString:[temp3 stringByAppendingString:temp4]] ) {
        [self close];
        return;
    }
    
//    if ( !currentEndDate && !currentBeginDate ) {
//        [self close];
//        return;
//    }
//
//    if ( [self.beginDate isEqualToString:currentBeginDate] &&
//        [self.endDate isEqualToString:currentEndDate]) {
//        [self close];
//        return;
//    }
    
    if ( currentBeginDate && currentEndDate && [currentBeginDate compare:currentEndDate options:NSNumericSearch] == NSOrderedDescending ) {
        [self.superview showHUDWithText:@"开始日期不能大于结束日期" offset:CGPointMake(0,20)];
        return;
    }
    
    if ( self.didSelectDate ) {
        self.didSelectDate(self, self.beginDateButton.userData, self.endDateButton.userData);
    }
    
    [self close];
}

- (NSDateFormatter *)dateFormater
{
    if ( !_dateFormater ) {
        _dateFormater = [[NSDateFormatter alloc] init];
        _dateFormater.dateFormat = @"yyyy-MM-dd";
    }
    return _dateFormater;
}

- (void)showInView:(UIView *)superView atPosition:(CGPoint)position
{
    if ( !self.superview ) {
        [superView addSubview:self];
    }
    
    self.frame = superView.bounds;
    
    self.maskView.frame = CGRectMake(0, position.y, self.width, self.height - position.y);
    self.maskView.alpha = 0.0;
    
    self.contentView.top = -self.contentView.height;
    
    CGFloat width = (self.contentView.width - 30 - self.separatorLabel.width) / 2.0;
    self.beginDateButton.frame =
    self.endDateButton.frame   =
    self.resetButton.frame     =
    self.okButton.frame        =
    CGRectMake(15, 15, width, 40);
    
    self.separatorLabel.center    = CGPointMake(self.contentView.width / 2, self.beginDateButton.midY);
    self.endDateButton.position   = CGPointMake(self.separatorLabel.right, 15);
    
    self.resetButton.position = CGPointMake(self.beginDateButton.left, self.beginDateButton.bottom + 20);
    self.okButton.position    = CGPointMake(self.endDateButton.left, self.beginDateButton.bottom  + 20);
    
    [self bringSubviewToFront:self.contentView];
    
    AWSetAllTouchesDisabled(YES);
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.6;
        self.contentView.top = position.y;
//        self.contentView.height = 126;
    } completion:^(BOOL finished) {
        AWSetAllTouchesDisabled(NO);
    }];
}

- (UIView *)contentView
{
    if ( !_contentView ) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, AWFullScreenWidth(), 130)];
        [self addSubview:_contentView];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        _maskView.backgroundColor = [UIColor blackColor];
    }
    return _maskView;
}

@end
