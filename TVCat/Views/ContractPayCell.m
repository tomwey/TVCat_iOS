//
//  ContractPayCell.m
//  HN_Vendor
//
//  Created by tomwey on 26/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContractPayCell.h"
#import "Defines.h"

@interface ContractPayCell ()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *unpaidLabel;
@property (nonatomic, strong) UILabel *paidLabel;
@property (nonatomic, strong) UILabel *payableLabel;

@end

@implementation ContractPayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    self.timeLabel.text = data[@"moneytypename"];
    
    [self addLabelValue:data[@"showoutamount"]//data[@"unpaidamount"]
               forLabel:self.unpaidLabel
                forName:@"产值"//@"未付"
                  color:MAIN_THEME_COLOR];
    
//    [self addLabelValue:data[@"showoutamount"]
//               forLabel:self.payableLabel
//                forName:@"产值"
//                  color:AWColorFromRGB(74, 144, 226)];
    
    [self addLabelValue:data[@"paidamount"]
               forLabel:self.paidLabel
                forName:@"已付"
                  color:AWColorFromRGB(74, 74, 74)];
}

- (void)addLabelValue:(id)moneyVal
             forLabel:(UILabel *)label
              forName:(NSString *)name
                color: (UIColor *)color
{
    NSString *money = [HNFormatMoney2(moneyVal, nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    if ( [moneyVal isKindOfClass:[NSString class]] ) {
        money = moneyVal;
        if ( [money isEqualToString:@"NULL"] ) {
            money = @"--";
        }
    }
    
    NSString *string = [NSString stringWithFormat:@"%@\n%@", money, name];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];
    [attr addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 16),
                           NSForegroundColorAttributeName: color,
                           }
                  range:[string rangeOfString:money]];
    
    label.attributedText = attr;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.timeLabel.frame = CGRectMake(15, 10, 200, 30);
    
    CGFloat width = ( self.width - 30 ) / 3;
    self.payableLabel.frame =
    self.paidLabel.frame    =
    self.unpaidLabel.frame  =
    CGRectMake(0, 0, width, 50);
    
    self.unpaidLabel.position = CGPointMake(15, self.timeLabel.bottom);
    self.payableLabel.position = CGPointMake(self.unpaidLabel.right, self.timeLabel.bottom);
    self.paidLabel.position = CGPointMake(self.width - 15 - width, self.timeLabel.bottom);
}

- (UILabel *)timeLabel
{
    if ( !_timeLabel ) {
        _timeLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(12, YES),
                                   AWColorFromRGB(51, 51, 51));
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

- (UILabel *)unpaidLabel
{
    if ( !_unpaidLabel ) {
        _unpaidLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(12, NO),
                                   AWColorFromRGB(153, 153, 153));
        [self.contentView addSubview:_unpaidLabel];
        
        _unpaidLabel.numberOfLines = 2;
        
        _unpaidLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _unpaidLabel;
}

- (UILabel *)paidLabel
{
    if ( !_paidLabel ) {
        _paidLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(12, NO),
                                   AWColorFromRGB(153, 153, 153));
        [self.contentView addSubview:_paidLabel];
        
        _paidLabel.numberOfLines = 2;
        
        _paidLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _paidLabel;
}

- (UILabel *)payableLabel
{
    if ( !_payableLabel ) {
        _payableLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentCenter,
                                   AWSystemFontWithSize(12, NO),
                                   AWColorFromRGB(153, 153, 153));
        [self.contentView addSubview:_payableLabel];
        
        _payableLabel.numberOfLines = 2;
        
        _payableLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _payableLabel;
}

@end
