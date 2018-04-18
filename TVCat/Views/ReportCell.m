//
//  ReportCell.m
//  HN_Vendor
//
//  Created by tomwey on 03/01/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "ReportCell.h"
#import "Defines.h"

@interface ReportCell ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *projLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *stateLabel;

@end

@implementation ReportCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.titleLabel.text = [NSString stringWithFormat:@"[%@] %@", data[@"typename"], data[@"theme"]];
    
    self.projLabel.text = data[@"project_name"];
    
    self.timeLabel.text = HNDateTimeFromObject(data[@"create_date"], @"T");
    
    // 设置状态
    NSString *stateName = nil;
    UIColor *color = nil;
    
    if ( [data[@"state_num"] integerValue] == 0 ) {
        stateName = @"未提报";
        color = AWColorFromRGB(100, 100, 100);
    } else if ([data[@"state_num"] integerValue] == 10) {
        stateName = @"受理中";
        color = MAIN_THEME_COLOR;
    } else if ([data[@"state_num"] integerValue] == 40) {
        stateName = @"已处理";
        color = AWColorFromRGB(116, 182, 102);
    } else if ([data[@"state_num"] integerValue] == 80) {
        stateName = @"已作废";
        color = AWColorFromRGB(201,92,84);
    }
    
    self.stateLabel.text = stateName;
    self.stateLabel.textColor = color;
    self.stateLabel.layer.borderColor = color.CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(15, 5, self.width - 15 - 60, 30);
    
    self.projLabel.frame =
    self.timeLabel.frame = CGRectMake(0, 0, self.titleLabel.width / 2.0, 30);
    
    self.projLabel.width -= 5;
    self.timeLabel.width += 5;
    
    self.projLabel.position = CGPointMake(15, self.height - 5 - self.projLabel.height);
    self.timeLabel.position = CGPointMake(self.projLabel.right, self.projLabel.top);
    
    [self.stateLabel sizeToFit];
    self.stateLabel.width += 6;
    self.stateLabel.height += 6;
    self.stateLabel.position = CGPointMake(self.width - 15 - self.stateLabel.width,
                                           self.height / 2 - self.stateLabel.height / 2);
}

- (UILabel *)titleLabel
{
    if ( !_titleLabel ) {
        _titleLabel = AWCreateLabel(CGRectZero, nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromHex(@"#333333"));
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)projLabel
{
    if ( !_projLabel ) {
        _projLabel = AWCreateLabel(CGRectZero, nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(12, NO),
                                    AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_projLabel];
        
        _projLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _projLabel;
}

- (UILabel *)timeLabel
{
    if ( !_timeLabel ) {
        _timeLabel = AWCreateLabel(CGRectZero, nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(12, NO),
                                    AWColorFromHex(@"#999999"));
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UILabel *)stateLabel
{
    if ( !_stateLabel ) {
        _stateLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentCenter,
                                    AWSystemFontWithSize(11, NO),
                                    nil);
        [self.contentView addSubview:_stateLabel];
        
        _stateLabel.cornerRadius = 2;
        _stateLabel.layer.borderWidth = 0.6;
    }
    return _stateLabel;
}

@end
