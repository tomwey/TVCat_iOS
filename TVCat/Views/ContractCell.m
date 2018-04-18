//
//  ContractCell.m
//  HN_Vendor
//
//  Created by tomwey on 20/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContractCell.h"
#import "Defines.h"

@interface ContractCell ()

@property (nonatomic, strong) UILabel *noLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *projNameNoLabel;

@end

@implementation ContractCell

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.noLabel.text = data[@"contractphyno"];
    
    self.nameLabel.text = data[@"contractname"];
    
    // 设置金额
    NSString *money = HNFormatMoney2(data[@"contractmoney"], nil);
    NSString *string = [@"签约金额: " stringByAppendingString:money];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttributes:@{
                              NSFontAttributeName: AWCustomFont(@"PingFang SC", 20),
                              NSForegroundColorAttributeName: MAIN_THEME_COLOR,
                              } range:[string rangeOfString:money]];
    self.moneyLabel.attributedText = attrStr;
    
    // 设置状态
    NSString *stateName = nil;
    UIColor *color = nil;
    
    if ( [data[@"appstatus"] integerValue] == 40 ) {
        stateName = @"执行中";
        color = MAIN_THEME_COLOR;
    } else if ([data[@"appstatus"] integerValue] == 50) {
        stateName = @"已结算";
        color = AWColorFromRGB(116, 182, 102);
    } else if ([data[@"appstatus"] integerValue] == 70) {
        stateName = @"已解除";
        color = AWColorFromRGB(201, 92, 84);
    }
    self.stateLabel.text = data[@"appstatusdesc"];
    self.stateLabel.textColor = color;
    self.stateLabel.layer.borderColor = color.CGColor;
    
    self.timeLabel.text = HNDateFromObject(data[@"signdate"], @"T");
    self.projNameNoLabel.text = data[@"project_name"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.noLabel.frame = CGRectMake(15, 10, self.width - 30, 30);
    
    self.nameLabel.frame = CGRectMake(15, self.noLabel.bottom, self.noLabel.width,
                                      50);
    [self.nameLabel sizeToFit];
    
    self.projNameNoLabel.frame = self.noLabel.frame;
    
    self.projNameNoLabel.top = self.height - 10 - self.projNameNoLabel.height;
    
    self.timeLabel.frame = self.projNameNoLabel.frame;
    
    self.moneyLabel.frame = self.noLabel.frame;
    self.moneyLabel.top = self.timeLabel.top - self.moneyLabel.height;
    
    [self.stateLabel sizeToFit];
    self.stateLabel.width += 6;
    self.stateLabel.height += 6;
    self.stateLabel.position = CGPointMake(self.noLabel.right - self.stateLabel.width,
                                           self.moneyLabel.midY - self.stateLabel.height / 2);
}

- (UILabel *)noLabel
{
    if ( !_noLabel ) {
        _noLabel = AWCreateLabel(CGRectZero,
                                 nil,
                                 NSTextAlignmentLeft,
                                 AWSystemFontWithSize(14, NO),
                                 AWColorFromRGB(186, 186, 186));
        [self.contentView addSubview:_noLabel];
        
        _noLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _noLabel;
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                 nil,
                                 NSTextAlignmentLeft,
                                 AWSystemFontWithSize(15, NO),
                                 AWColorFromRGB(51, 51, 51));
        [self.contentView addSubview:_nameLabel];
        
        _nameLabel.numberOfLines = 2;
    }
    return _nameLabel;
}

- (UILabel *)moneyLabel
{
    if ( !_moneyLabel ) {
        _moneyLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(12, NO),
                                   self.noLabel.textColor);
        [self.contentView addSubview:_moneyLabel];
    }
    return _moneyLabel;
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

- (UILabel *)projNameNoLabel
{
    if ( !_projNameNoLabel ) {
        _projNameNoLabel = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(14, NO),
                                    self.noLabel.textColor);
        [self.contentView addSubview:_projNameNoLabel];
    }
    return _projNameNoLabel;
}

- (UILabel *)timeLabel
{
    if ( !_timeLabel ) {
        _timeLabel = AWCreateLabel(CGRectZero,
                                         nil,
                                         NSTextAlignmentRight,
                                         AWSystemFontWithSize(14, NO),
                                         self.noLabel.textColor);
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

@end
