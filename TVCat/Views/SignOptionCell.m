//
//  SignOptionCell.m
//  HN_Vendor
//
//  Created by tomwey on 16/03/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "SignOptionCell.h"
#import "Defines.h"

@interface SignOptionCell ()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *money1Label; // 申报金额

@property (nonatomic, strong) UILabel *money2Label; // 签证金额

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIView  *selectedView;

@end

@implementation SignOptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ( self = [super initWithStyle:style reuseIdentifier:reuseIdentifier] ) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)configData:(id)data selectBlock:(void (^)(UIView<AWTableDataConfig> *, id))selectBlock
{
    if ( [data[@"selected"] boolValue] ) {
        self.selectedView.backgroundColor = AWColorFromRGB(235, 235, 235);
    } else {
        self.selectedView.backgroundColor = [UIColor whiteColor];
    }
    
    [self configData:data];
}

- (UIColor *)colorByState:(id)state
{
    NSInteger val = [state integerValue];
    
    switch (val) {
        case 0:
        {
            return AWColorFromRGB(100,100,100);
        }
        case 5:
        {
            return AWColorFromRGB(230, 176, 95);
        }
        case 8:
        {
            return AWColorFromRGB(201, 92, 84);
        }
        case 10:
        {
            return AWColorFromRGB(116,182,102);
        }
        case 40:
        {
            return AWColorFromRGB(70, 121, 178);
        }
        case 60:
        {
            return AWColorFromRGB(118, 190, 219);
        }
        case 80:
        {
            return AWColorFromRGB(166, 166, 166);
        }
            
        default:
            break;
    }
    return nil;
}
- (void)configData:(id)data
{
    self.nameLabel.text  = data[@"changetheme"] ?: data[@"visatheme"];
    
//    if ( data[@"state_num"] ) {
//        //        self.stateLabel.hidden = NO;
//
//        //        [self updateStateInfo:data[@"state"]];
//        self.stateLabel.text = data[@"state_desc"];
//
//        UIColor *color = [self colorByState:data[@"state_num"]];
//
//        self.stateLabel.textColor = color;
//        self.stateLabel.layer.borderColor = color.CGColor;
//
//    } else {
//        //        self.stateLabel.hidden = YES;
//    }
    
    self.stateLabel.text = @"查看详情";
    self.stateLabel.textColor = AWColorFromHex(@"#666666");
    self.stateLabel.layer.borderColor = self.stateLabel.textColor.CGColor;
    
    self.stateLabel.userData = data;
    
    id obj = data[@"changedate"] ?: data[@"visadate"];
    
    self.timeLabel.text = HNDateFromObject(obj, @"T");
    
    [self setLabel:self.money1Label forData:data[@"changemoney"] prefix:@"申报" textColor: MAIN_THEME_COLOR];
    
    [self setLabel:self.money2Label forData:data[@"visamoney"] prefix:@"签证" textColor: AWColorFromRGB(74,144,226)];
}

- (void)updateStateInfo:(id)state
{
    if ( [state integerValue] == 0 ) {
        self.stateLabel.text = @"已取消";
        self.stateLabel.textColor = AWColorFromRGB(166,166,166);
        self.stateLabel.layer.borderColor = AWColorFromRGB(166,166,166).CGColor;
    } else if ([state integerValue] == 1) {
        self.stateLabel.text = @"申报已审批";
        self.stateLabel.textColor = AWColorFromRGB(74, 144, 226);
        self.stateLabel.layer.borderColor = AWColorFromRGB(74, 144, 226).CGColor;
    } else if ([state integerValue] == 2) {
        self.stateLabel.text = @"签证已审批";
        self.stateLabel.textColor = MAIN_THEME_COLOR;
        self.stateLabel.layer.borderColor = MAIN_THEME_COLOR.CGColor;
    }
}

- (void)setLabel:(UILabel *)label
         forData:(id)moneyVal
          prefix:(NSString *)prefix
       textColor:(UIColor *)color
{
    CGFloat money = [moneyVal floatValue];
    
    NSString *moneyStr = [NSString stringWithFormat:@"%.2f", money / 10000.00];
    
    NSString *string = [NSString stringWithFormat:@"%@%@万", prefix, moneyStr];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string];
    [attrStr addAttributes:@{
                             NSFontAttributeName: AWCustomFont(@"PingFang SC", 16),
                             NSForegroundColorAttributeName: color,
                             } range:[string rangeOfString:moneyStr]];
    
    label.attributedText = attrStr;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.selectedView.frame = self.bounds;
    
    [self.stateLabel sizeToFit];
    self.stateLabel.width += 10;
    self.stateLabel.height += 10;
    self.stateLabel.position = CGPointMake(self.width - 15 - self.stateLabel.width, 5);
    
    self.nameLabel.frame = CGRectMake(15,
                                      5,
                                      self.width - 10 - 98,
                                      50);
    [self.nameLabel sizeToFit];
    
    self.nameLabel.top = 15;
    self.stateLabel.top = 15;
    
    self.timeLabel.frame = CGRectMake(self.width - 15 - 82, 90 - 10 - 30, 82, 30);
    
    CGFloat width = self.timeLabel.left - 10 - 10;
    
    self.money1Label.frame = self.money2Label.frame = CGRectMake(0, 0, width / 2, 30);
    
    self.money1Label.position = CGPointMake(10 + 5, self.timeLabel.top);
    self.money2Label.position = CGPointMake(self.money1Label.right + 5, self.money1Label.top);
}

- (UILabel *)nameLabel
{
    if ( !_nameLabel ) {
        _nameLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(51, 51, 51));
        [self.contentView addSubview:_nameLabel];
        _nameLabel.numberOfLines = 2;
    }
    return _nameLabel;
}

- (UIView *)selectedView
{
    if ( !_selectedView ) {
        _selectedView = [[UIView alloc] init];
        
        [self.contentView addSubview:_selectedView];
    }
    return _selectedView;
}

- (UILabel *)money1Label
{
    if ( !_money1Label ) {
        _money1Label = AWCreateLabel(CGRectZero,
                                     nil,
                                     NSTextAlignmentLeft,
                                     AWSystemFontWithSize(12, NO),
                                     AWColorFromRGB(193, 193, 193));
        [self.contentView addSubview:_money1Label];
        
        _money1Label.adjustsFontSizeToFitWidth = YES;
    }
    return _money1Label;
}

- (UILabel *)money2Label
{
    if ( !_money2Label ) {
        _money2Label = AWCreateLabel(CGRectZero,
                                     nil,
                                     NSTextAlignmentLeft,
                                     AWSystemFontWithSize(12, NO),
                                     AWColorFromRGB(193, 193, 193));
        [self.contentView addSubview:_money2Label];
        
        _money2Label.adjustsFontSizeToFitWidth = YES;
    }
    return _money2Label;
}

- (UILabel *)timeLabel
{
    if ( !_timeLabel ) {
        _timeLabel = AWCreateLabel(CGRectZero,
                                   nil,
                                   NSTextAlignmentRight,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(193, 193, 193));
        [self.contentView addSubview:_timeLabel];
        //        _timeLabel.backgroundColor = [UIColor redColor];
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
        
        _stateLabel.userInteractionEnabled = YES;
        
        [_stateLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoDetail:)]];
        
    }
    return _stateLabel;
}

- (void)gotoDetail:(UIGestureRecognizer *)sender
{
    id item = sender.view.userData;
    
//    NSLog(@"%@", item);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kOpenSignItemDetailNotification"
                                                        object:item];
}

@end
