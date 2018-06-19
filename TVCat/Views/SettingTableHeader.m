//
//  SettingTableHeader.m
//  RTA
//
//  Created by tangwei1 on 16/10/10.
//  Copyright © 2016年 tomwey. All rights reserved.
//

#import "SettingTableHeader.h"
#import "Defines.h"

@interface SettingTableHeader ()

@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel     *nickname;
@property (nonatomic, strong) UILabel     *idLabel;
@property (nonatomic, strong) UIImageView *arrowView;

@property (nonatomic, weak, readwrite) UIView *scrollZoomableView;

@property (nonatomic, strong) UIButton *expireButton;

@end

@implementation SettingTableHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        UIImageView *bgView = AWCreateImageView(nil);
        [self addSubview:bgView];
        bgView.image = nil;//AWImageNoCached(@"setting-header.png");
        bgView.backgroundColor = MAIN_THEME_COLOR;
        self.frame = bgView.frame = CGRectMake(0, 0, AWFullScreenWidth(), 200);
        bgView.contentMode = UIViewContentModeScaleAspectFill;
        bgView.clipsToBounds = YES;
        
        bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.scrollZoomableView = bgView;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)]];
    }
    return self;
}

- (void)tap:(UIGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self];
    if ( CGRectContainsPoint(self.avatarView.frame, location) ||
        CGRectContainsPoint(self.nickname.frame, location)) {
        if ( self.didSelectCallback ) {
            self.didSelectCallback(self);
        }
    }
}

- (void)setCurrentUser:(id)currentUser
{
    _currentUser = currentUser;
    
//    NSURL *url = !!currentUser.avatar ? [NSURL URLWithString:currentUser.avatar] : nil;
//    [self.avatarView setImageWithURL:currentUser[@"avatar"] placeholderImage:[UIImage imageNamed:@"default_avatar.png"]];
    
//    [HNImageHelper imageForName:currentUser[@"supname"]
//                          manID:[currentUser[@"supid"] integerValue]
//                           size:CGSizeMake(60, 60)
//                completionBlock:^(UIImage *anImage, NSError *error) {
//                    if ( anImage ) {
//                        self.avatarView.image = anImage;
//                    }
//                }];
    
    
    self.nickname.text = currentUser[@"nickname"];
    
    self.idLabel.text = [NSString stringWithFormat:@"ID: %@", currentUser[@"id"]];
    
    [self.avatarView setImageWithURL:[NSURL URLWithString:currentUser[@"avatar"]]];
    //currentUser ? [currentUser formatUsername] : @"唐伟";
    
    [self.expireButton setTitle:currentUser[@"left_days"] forState:UIControlStateNormal];
    
    CGSize size = [currentUser[@"left_days"] sizeWithAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(14, NO) }];
    
    self.expireButton.frame = CGRectMake(0, 0, size.width + 20, 34);
//    [self.expireButton sizeToFit];
    
//    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.center = CGPointMake(self.width / 2, self.height / 2 - 30);
    
//    self.arrowView.center  = CGPointMake(self.width - 15 - self.arrowView.width / 2, self.avatarView.midY);
    
    self.nickname.frame    = CGRectMake(0, 0, self.width - 60, 25);
    self.nickname.center   = CGPointMake(self.width / 2, self.avatarView.bottom + self.nickname.height / 2);
    
    self.idLabel.frame  = self.nickname.frame;
//    self.idLabel.height = 25;
    self.idLabel.top = self.nickname.bottom - 5;
    
//    self.expireButton.frame = CGRectMake(0, 0, 80, 40);
//    [self.expireButton sizeToFit];
    
    CGSize size = [self.currentUser[@"left_days"] sizeWithAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(14, NO) }];
    
    self.expireButton.frame = CGRectMake(0, 0, size.width + 20, 34);
    self.expireButton.center = CGPointMake(self.width / 2, self.height - self.expireButton.height / 2 - 10);
}

- (UIButton *)expireButton
{
    if ( !_expireButton ) {
        _expireButton = AWCreateTextButton(CGRectZero,
                                           nil,
                                           [UIColor whiteColor],
                                           self,
                                           @selector(btnClicked:));
        [self addSubview:_expireButton];
        
        _expireButton.layer.borderColor = [UIColor whiteColor].CGColor;
        _expireButton.layer.borderWidth = 0.88;
        
        _expireButton.cornerRadius = 8;
        
        [_expireButton titleLabel].font = AWSystemFontWithSize(14, NO);
    }
    return _expireButton;
}

- (void)btnClicked:(id)sender
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"NewVIPChargeVC"
                                                                params:nil];
    [AWAppWindow().rootViewController presentViewController:vc animated:YES completion:nil];
}

- (UIImageView *)avatarView
{
    if ( !_avatarView ) {
        _avatarView = AWCreateImageView(@"default_avatar.png");
        [self addSubview:_avatarView];
        _avatarView.frame = CGRectMake(0, 0, 60, 60);
        _avatarView.cornerRadius = _avatarView.height / 2;
    }
    return _avatarView;
}

- (UILabel *)nickname
{
    if ( !_nickname ) {
        _nickname = AWCreateLabel(CGRectZero, @"请登录",
                                  NSTextAlignmentCenter,
                                  AWSystemFontWithSize(14, NO),
                                  /*AWColorFromRGB(131, 131, 131)*/[UIColor whiteColor]);
        [self addSubview:_nickname];
//        _nickname.backgroundColor = [UIColor blackColor];
//        _nickname.alpha = 0.7;
        
//        _nickname.cornerRadius = 6;
    }
    return _nickname;
}

- (UILabel *)idLabel
{
    if ( !_idLabel ) {
        _idLabel = AWCreateLabel(CGRectZero, nil,
                                  NSTextAlignmentCenter,
                                  AWSystemFontWithSize(14, NO),
                                  /*AWColorFromRGB(131, 131, 131)*/[UIColor whiteColor]);
        [self addSubview:_idLabel];
        //        _nickname.backgroundColor = [UIColor blackColor];
        //        _nickname.alpha = 0.7;
        
        //        _nickname.cornerRadius = 6;
    }
    return _idLabel;
}

@end
