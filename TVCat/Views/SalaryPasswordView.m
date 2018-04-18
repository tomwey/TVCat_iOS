//
//  SalaryPasswordView.m
//  HN_ERP
//
//  Created by tomwey on 4/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SalaryPasswordView.h"
#import "Defines.h"

@interface SalaryPasswordView ()

@property (nonatomic, strong) UIView *boxView;
@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, copy) void (^doneCallback)(NSString *string);
@property (nonatomic, copy) void (^editCallback)(void);

- (void)show;

@end

@implementation SalaryPasswordView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.frame = AWFullScreenBounds();
    }
    return self;
}

- (void)show
{
    self.maskView.alpha = 0.0;
    
    [self.textField becomeFirstResponder];
    
    self.boxView.center = CGPointMake(self.width / 2,
                                      - self.boxView.height / 2);
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.6;
        self.boxView.center = CGPointMake(self.width / 2,
                                          self.boxView.height / 2 + 88);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [self.textField resignFirstResponder];
    
    [UIView animateWithDuration:.3 animations:^{
        self.maskView.alpha = 0.0;
        self.boxView.center = CGPointMake(self.width / 2, - self.boxView.height);
    } completion:^(BOOL finished) {
        //
        if ( self.didDismissBlock ) {
            self.didDismissBlock();
        }
        [self removeFromSuperview];
    }];
}

+ (instancetype)showInView:(UIView *)superView
              doneCallback:(void (^)(NSString *))doneCallback
              editCallback:(void (^)(void))editCallback
{
    SalaryPasswordView *view = [[SalaryPasswordView alloc] init];
    
    [superView addSubview:view];
    
    [superView bringSubviewToFront:view];
    
    view.doneCallback = doneCallback;
    view.editCallback = editCallback;
    
    [view show];
    
    return view;
}

- (void)openKeyboard
{
    [self.textField becomeFirstResponder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.okButton.frame = self.cancelButton.frame;
    self.okButton.left  = self.cancelButton.right + 20;
    
    self.editButton.frame = CGRectMake(self.boxView.width - 5 - 60,
                                   5,
                                   60,
                                   30);
    
    self.titleLabel.top = self.textField.top - 10 - self.titleLabel.height;
    
}

- (UIButton *)cancelButton
{
    if ( !_cancelButton ) {
        _cancelButton = AWCreateTextButton(CGRectZero,
                                           @"取消",
                                           [UIColor whiteColor],
                                           self,
                                           @selector(cancel));
        [self.boxView addSubview:_cancelButton];
        
        _cancelButton.backgroundColor = AWColorFromRGB(198, 198, 198);
        _cancelButton.cornerRadius = 6;
        
        CGFloat padding = 20;
        CGFloat width   = (self.boxView.width - padding * 3) / 2;
        
        _cancelButton.frame = CGRectMake(padding,
                                         self.boxView.height - 15 - 40,
                                         width,
                                         40);
    }
    return _cancelButton;
}

- (UIButton *)okButton
{
    if ( !_okButton ) {
        _okButton = AWCreateTextButton(CGRectZero,
                                           @"确定",
                                           [UIColor whiteColor],
                                           self,
                                           @selector(done));
        [self.boxView addSubview:_okButton];
        
        _okButton.backgroundColor = MAIN_THEME_COLOR;
        _okButton.cornerRadius = 6;
        
        
        
    }
    return _okButton;
}

- (void)done
{
    if ( self.doneCallback ) {
        self.doneCallback(self.textField.text);
    }
    [self dismiss];
}

- (void)cancel
{
    [self dismiss];
}

- (void)edit
{
    if ( self.editCallback ) {
        self.editCallback();
    }
}

- (UIButton *)editButton
{
    if ( !_editButton ) {
        _editButton = AWCreateTextButton(CGRectZero,
                                           @"修改密码",
                                           MAIN_THEME_COLOR,
                                           self,
                                           @selector(edit));
        [self.boxView addSubview:_editButton];
        
        _editButton.layer.borderWidth = 0.5;
        _editButton.layer.borderColor = MAIN_THEME_COLOR.CGColor;
        
        _editButton.titleLabel.font = AWSystemFontWithSize(12, NO);
    }
    return _editButton;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(18, YES),
                                    AWColorFromRGB(58, 58, 58));
        [self.boxView addSubview:_titleLabel];
        
        _titleLabel.frame = CGRectMake(20, 25,
                                       self.boxView.width - 40,
                                       37);
        _titleLabel.text = @"输入查询密码";
    }
    return _titleLabel;
}

- (UITextField *)textField
{
    if ( !_textField ) {
        _textField = [[AWTextField alloc] init];
        [self.boxView addSubview:_textField];
        _textField.placeholder = @"输入密码";
        _textField.returnKeyType = UIReturnKeyDone;
        
        _textField.secureTextEntry = YES;
        
        [_textField addTarget:self
                       action:@selector(done)
             forControlEvents:UIControlEventEditingDidEndOnExit];
        
        _textField.frame = self.titleLabel.frame;
        _textField.top = self.cancelButton.top - 15 - _textField.height;
    }
    return _textField;
}

- (UIView *)boxView
{
    if ( !_boxView ) {
        _boxView = [[UIView alloc] init];
        [self addSubview:_boxView];
        _boxView.backgroundColor = [UIColor whiteColor];
        _boxView.frame = CGRectMake(0, 0, 260, 180);
        
        _boxView.layer.cornerRadius = 8;
        _boxView.clipsToBounds = YES;
    }
    return _boxView;
}

- (UIView *)maskView
{
    if ( !_maskView ) {
        _maskView = [[UIView alloc] init];
        [self addSubview:_maskView];
        _maskView.backgroundColor = [UIColor blackColor];
        _maskView.frame = self.bounds;
        
        _maskView.autoresizingMask =
            UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _maskView.alpha = 0.0;
        [self sendSubviewToBack:_maskView];
    }
    return _maskView;
}

@end
