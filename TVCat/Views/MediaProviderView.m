//
//  MediaProviderView.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "MediaProviderView.h"
#import "Defines.h"

@interface MediaProviderView ()

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation MediaProviderView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)]];
    }
    return self;
}

- (void)setData:(id)data
{
    _data = data;
    
    self.iconView.image = nil;
    [self.iconView setImageWithURL:[NSURL URLWithString:data[@"icon"]]];
    
    self.nameLabel.text = data[@"name"];
}

- (void)tap
{
    if ( self.didSelectMediaBlock ) {
        self.didSelectMediaBlock(self);
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconView.center = CGPointMake(self.width / 2.0, self.height / 2.0 - 10);
    
    self.nameLabel.frame = CGRectMake(0, self.height - 40, self.width, 30);
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = AWCreateImageView(nil);
        [self addSubview:_iconView];
        _iconView.frame = CGRectMake(0, 0, 32, 32);
    }
    return _iconView;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromHex(@"#666666"));
        [self addSubview:_nameLabel];
    }
    return _nameLabel;
}

@end
