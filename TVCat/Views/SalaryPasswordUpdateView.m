//
//  SalaryPasswordUpdateView.m
//  HN_ERP
//
//  Created by tomwey on 4/25/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SalaryPasswordUpdateView.h"
#import "Defines.h"

@interface SalaryPasswordUpdateView ()

@property (nonatomic, strong) UIView *boxView;

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *okButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *currentPasswordField;
@property (nonatomic, strong) UITextField *passwordField1;
@property (nonatomic, strong) UITextField *passwordField2;

@property (nonatomic, copy) void (^doneCallback)(id inputData);

- (void)show;

@end

@implementation SalaryPasswordUpdateView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.frame = AWFullScreenBounds();
    }
    return self;
}

- (void)show
{
//    self.maskView.alpha = 0.0;
    
    [self.currentPasswordField becomeFirstResponder];
    
    self.boxView.center = CGPointMake(self.width / 2,
                                      - self.boxView.height / 2);
    [UIView animateWithDuration:.3 animations:^{
//        self.maskView.alpha = 0.6;
        self.boxView.center = CGPointMake(self.width / 2,
                                          self.boxView.height / 2 + 88);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [self.currentPasswordField resignFirstResponder];
    [self.passwordField1 resignFirstResponder];
    [self.passwordField2 resignFirstResponder];
    
    [UIView animateWithDuration:.3 animations:^{
//        self.maskView.alpha = 0.0;
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
      doneCallback:(void (^)(id inputData))doneCallback;
{
    SalaryPasswordUpdateView *view = [[SalaryPasswordUpdateView alloc] init];
    [superView addSubview:view];
    [superView bringSubviewToFront:view];
    
    view.doneCallback = doneCallback;

    [view show];
    
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.okButton.frame = self.cancelButton.frame;
    self.okButton.left  = self.cancelButton.right + 20;
    
    self.passwordField2.top = self.okButton.top - 15 - self.passwordField2.height;
    self.passwordField1.top = self.passwordField2.top - 10 - self.passwordField1.height;
    self.currentPasswordField.top = self.passwordField1.top - 10 - self.currentPasswordField.height;
    
    self.titleLabel.top = self.currentPasswordField.top - 15 - self.titleLabel.height;
    
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
        id dict = @{ @"old_password": self.currentPasswordField.text ?: @"",
                     @"new_password1": self.passwordField1.text ?: @"",
                     @"new_password2": self.passwordField2.text ?: @"", };
        self.doneCallback(dict);
    }
    [self dismiss];
}

- (void)cancel
{
    [self dismiss];
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
        _titleLabel.text = @"修改密码";
    }
    return _titleLabel;
}

- (UITextField *)currentPasswordField
{
    if ( !_currentPasswordField ) {
        _currentPasswordField = [[AWTextField alloc] init];
        [self.boxView addSubview:_currentPasswordField];
        _currentPasswordField.placeholder = @"旧密码";
        _currentPasswordField.returnKeyType = UIReturnKeyNext;
        
        _currentPasswordField.secureTextEntry = YES;
        
        [_currentPasswordField addTarget:self
                                  action:@selector(tapReturn:)
             forControlEvents:UIControlEventEditingDidEndOnExit];
        
        _currentPasswordField.frame = self.titleLabel.frame;
        _currentPasswordField.top = self.cancelButton.top - 15 - _currentPasswordField.height;
    }
    return _currentPasswordField;
}

- (UITextField *)passwordField1
{
    if ( !_passwordField1 ) {
        _passwordField1 = [[AWTextField alloc] init];
        [self.boxView addSubview:_passwordField1];
        _passwordField1.placeholder = @"新密码";
        _passwordField1.returnKeyType = UIReturnKeyNext;
        
        _passwordField1.secureTextEntry = YES;
        
        [_passwordField1 addTarget:self
                            action:@selector(tapReturn:)
                        forControlEvents:UIControlEventEditingDidEndOnExit];
        
        _passwordField1.frame = self.titleLabel.frame;
        _passwordField1.top = self.cancelButton.top - 15 - _passwordField1.height;
    }
    return _passwordField1;
}

- (UITextField *)passwordField2
{
    if ( !_passwordField2 ) {
        _passwordField2 = [[AWTextField alloc] init];
        [self.boxView addSubview:_passwordField2];
        _passwordField2.placeholder = @"确认新密码";
        _passwordField2.returnKeyType = UIReturnKeyDone;
        
        _passwordField2.secureTextEntry = YES;
        
        [_passwordField2 addTarget:self
                            action:@selector(tapReturn:)
                        forControlEvents:UIControlEventEditingDidEndOnExit];
        
        _passwordField2.frame = self.titleLabel.frame;
        _passwordField2.top = self.cancelButton.top - 15 - _passwordField2.height;
    }
    return _passwordField2;
}

- (void)tapReturn:(UITextField *)sender
{
    if ( sender == self.currentPasswordField ) {
        [self.passwordField1 becomeFirstResponder];
    } else if ( sender == self.passwordField1 ) {
        [self.passwordField2 becomeFirstResponder];
    } else {
        [self done];
    }
}

- (UIView *)boxView
{
    if ( !_boxView ) {
        _boxView = [[UIView alloc] init];
        [self addSubview:_boxView];
        _boxView.backgroundColor = [UIColor whiteColor];
        _boxView.frame = CGRectMake(0, 0, 260, 220);
        
        _boxView.layer.cornerRadius = 8;
        _boxView.clipsToBounds = YES;
    }
    return _boxView;
}

@end
