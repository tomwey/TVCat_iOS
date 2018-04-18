//
//  DMButton.m
//  HN_ERP
//
//  Created by tomwey on 20/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DMButton.h"
#import "Defines.h"

@interface DMButton ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *caretView;

@end
@implementation DMButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if ( self = [super initWithFrame:frame] ) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                           action:@selector(tap)]];
    }
    return self;
}

- (void)tap
{
    if ( self.selectBlock ) {
        self.selectBlock(self);
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.label.text = title;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.caretView.frame = CGRectMake(0, 0, 6, 6);
    
    self.caretView.position = CGPointMake(self.width - 5 - self.caretView.width,
                                          self.height - 5 - self.caretView.height);
    
    self.label.frame = CGRectMake(5, 0,
                                  self.caretView.left - 5,
                                  self.height);
}

- (UILabel *)label
{
    if ( !_label ) {
        _label = AWCreateLabel(CGRectZero,
                               nil,
                               NSTextAlignmentCenter,
                               AWSystemFontWithSize(14, NO),
                               AWColorFromRGB(88, 88, 88));
        [self addSubview:_label];
    }
    
    return _label;
}

- (UIImageView *)caretView
{
    if ( !_caretView ) {
        _caretView = AWCreateImageView(@"icon_caret.png");
        _caretView.image = [[UIImage imageNamed:@"icon_caret.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _caretView.tintColor = AWColorFromHex(@"#999999");
        [self addSubview:_caretView];
    }
    return _caretView;
}

@end
