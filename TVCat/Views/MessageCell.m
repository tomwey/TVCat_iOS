//
//  MessageCell.m
//  HN_ERP
//
//  Created by tomwey on 1/18/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MessageCell.h"
#import "Defines.h"

@interface MessageCell ()

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) id state;

@property (nonatomic, strong) UIView *dotView;

@end

@implementation MessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
//        self.separatorInset = UIEdgeInsetsMake(0, 70, 0, 0);
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView <AWTableDataConfig> *sender, id selectedData))selectBlock
{
    self.titleLabel.text = data[@"msgtheme"];
    self.bodyLabel.text = [NSString stringWithFormat:@"%@ %@", data[@"project_name"], HNDateFromObject(data[@"validbegindate"], @"T")];
    
    self.state = data;
    
    self.stateLabel.text = data[@"msgtypename"];
    self.stateLabel.backgroundColor = AWColorFromHex(data[@"msgcolor"]);
    
    self.dotView.hidden = [data[@"islook"] boolValue];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    self.stateLabel.backgroundColor = AWColorFromHex(self.state[@"msgcolor"]);
    
    self.dotView.backgroundColor = AWColorFromHex(@"#f53d3d");
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    
    self.stateLabel.backgroundColor = AWColorFromHex(self.state[@"msgcolor"]);
    
    self.dotView.backgroundColor = AWColorFromHex(@"#f53d3d");
    
//    self.badge.backgroundColor = [UIColor redColor];
//    self.badge.textColor = [UIColor whiteColor];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.iconView.center = CGPointMake(15 + self.iconView.width / 2,
//                                       self.height / 2);
    
    self.stateLabel.center = CGPointMake(self.width - 15 - self.stateLabel.width / 2.0,
                                         self.height / 2);
    
    self.titleLabel.frame = CGRectMake(15,
                                       10,
                                       self.stateLabel.left - 15 - 10, 50);
    
    [self.titleLabel sizeToFit];
    
    self.bodyLabel.frame = self.titleLabel.frame;
    self.bodyLabel.height = 30;
    self.bodyLabel.width  = self.stateLabel.left - 15 - 10;
    self.bodyLabel.top = self.height - self.bodyLabel.height - 5;
    
    self.dotView.center = CGPointMake(8, 18);
}

- (UIImageView *)iconView
{
    if ( !_iconView ) {
        _iconView = AWCreateImageView(nil);
        _iconView.frame = CGRectMake(0, 0, 48, 48);
        _iconView.cornerRadius = _iconView.height / 2;
        [self.contentView addSubview:_iconView];
    }
    return _iconView;
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    [UIColor blackColor]);
        [self.contentView addSubview:_titleLabel];
        
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UILabel *)bodyLabel
{
    if ( !_bodyLabel ) {
        _bodyLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(13, NO),
                                    AWColorFromRGB(181,181,181));
        [self.contentView addSubview:_bodyLabel];
    }
    return _bodyLabel;
}

- (UILabel *)stateLabel
{
    if ( !_stateLabel ) {
        _stateLabel = AWCreateLabel(CGRectMake(0, 0, 60, 24),
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(10, NO),
                                   [UIColor whiteColor]);
        [self.contentView addSubview:_stateLabel];
        
        _stateLabel.cornerRadius = 2;
    }
    return _stateLabel;
}

- (UIView *)dotView
{
    if ( !_dotView ) {
        _dotView = [[UIView alloc] init];
        [self.contentView addSubview:_dotView];
        
        _dotView.frame = CGRectMake(0, 0, 6, 6);
        _dotView.cornerRadius = _dotView.height / 2.0;
        
        _dotView.backgroundColor = AWColorFromHex(@"#f53d3d");
    }
    return _dotView;
}

@end
