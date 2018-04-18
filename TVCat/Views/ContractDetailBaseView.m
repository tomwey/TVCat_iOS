//
//  ContractDetailBaseView.m
//  HN_Vendor
//
//  Created by tomwey on 25/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "ContractDetailBaseView.h"
#import "Defines.h"

@interface ContractDetailBaseView ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat currentTop;

@end

@implementation ContractDetailBaseView

- (void)startLoadingData
{
    [HNProgressHUDHelper showHUDAddedTo:self.superview animated:YES];
    
    id userInfo = [[UserService sharedInstance] currentUser];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商查询合同总体信息APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              @"param4": [self.userData[@"contractid"] description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.superview animated:YES];
    
    if ( error ) {
        [self showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self showHUDWithText:@"无数据显示" offset:CGPointMake(0,20)];
        } else {
            [self showContents:result[@"data"]];
        }
    }
    
//    addsigndate = NULL;
//    addsignmoney = 0;
    
//    contracttotalmoney = "1681393.39";
    
//    signdate = "2017-05-12T00:00:00+08:00";
//    signmoney = "1681393.39";
    
//    debitamount = 0;
    
//    issettled = 0;
//    settlemoney = NULL;
    
//    paidamount = 0;
//    payableamount = 0;
//    unpaidamount = 0;
    
//    resignmoney = NULL;
//
//    showpayableamount = 0;

//    visamoney = NULL;
//    visanum = 0;
}

- (void)showContents:(NSArray *)data
{
    id item = [data firstObject];
    
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    [self addInfo1:item];
    
//    [self addInfo2:item];
    
    [self addInfo3:item];
    
    [self addInfo4:item];
    
    self.scrollView.contentSize = CGSizeMake(AWFullScreenWidth(), self.currentTop);
}

- (void)addInfo1:(id)item
{
    UILabel *titleLabel = AWCreateLabel(CGRectMake(15, 15, self.width - 30,
                                                   30),
                                        @"合同签约",
                                        NSTextAlignmentLeft,
                                        AWSystemFontWithSize(12, YES),
                                        AWColorFromRGB(51, 51, 51));
    [self.scrollView addSubview:titleLabel];
    
    UILabel *label1 = [self addLabelValue:item[@"contracttotalmoney"]
                                  forName:@"合同总金额"
                                     date:nil
                                    color:MAIN_THEME_COLOR];
    label1.position = CGPointMake(15, titleLabel.bottom + 10);
    
    UILabel *label2 = [self addLabelValue:item[@"signmoney"]
                                  forName:@"主合同金额"
                                     date:HNDateFromObject(item[@"signdate"], @"T")
                                    color:AWColorFromRGB(74, 144, 226)];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.position = CGPointMake(label1.right, titleLabel.bottom + 10);
    
    UILabel *label3 = [self addLabelValue:item[@"addsignmoney"]
                                  forName:@"补充合同金额"
                                     date:HNDateFromObject(item[@"addsigndate"], @"T")
                                    color:AWColorFromRGB(74, 74, 74)];
    label3.textAlignment = NSTextAlignmentRight;
    label3.position = CGPointMake(self.width - 15 - label3.width, titleLabel.bottom + 10);
    
    self.currentTop = label3.bottom + 10;
}

- (UILabel *)addLabelValue:(id)moneyVal
                   forName:(NSString *)name
                      date:(id)date
                     color: (UIColor *)color
{
    UILabel *label1 = AWCreateLabel(CGRectZero,
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(12, NO), AWColorFromRGB(153, 153, 153));
    label1.numberOfLines = 3;
    label1.adjustsFontSizeToFitWidth = YES;
    
    [self.scrollView addSubview:label1];
    
    CGFloat width = ( self.scrollView.width - 30 ) / 3.0;
    label1.frame = CGRectMake(0, 0,width, 60);
    
    NSString *money = [HNFormatMoney2(moneyVal, nil) stringByReplacingOccurrencesOfString:@"元" withString:@""];
    if ( [moneyVal isKindOfClass:[NSString class]] ) {
        money = moneyVal;
        if ( [money isEqualToString:@"NULL"] ) {
            money = @"--";
        }
    }
    
    NSString *string = [NSString stringWithFormat:@"%@\n%@\n%@", money, name, date ?: @""];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];
    [attr addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 16),
                           NSForegroundColorAttributeName: color,
                           }
                  range:[string rangeOfString:money]];
    
    label1.attributedText = attr;
    
    return label1;
}

- (void)gotoPayList
{
    void (^block)(NSInteger type) = self.userData[@"forwardMoreBlock"];
    if (block) {
        block(1);
    }
}

- (void)gotoDeclareList
{
    void (^block)(NSInteger type) = self.userData[@"forwardMoreBlock"];
    if (block) {
        block(2);
    }
}

- (void)addInfo2:(id)item
{
    //
    
    UILabel *titleLabel = AWCreateLabel(CGRectMake(15, self.currentTop + 10, self.width - 30,
                                                   30),
                                        @"付款",
                                        NSTextAlignmentLeft,
                                        AWSystemFontWithSize(12, YES),
                                        AWColorFromRGB(51, 51, 51));
    [self.scrollView addSubview:titleLabel];
//    ›
    UILabel *moreLabel = AWCreateLabel(CGRectMake(0, 0, 70, 30),
                                       @"更多明细",
                                       NSTextAlignmentRight,
                                       AWSystemFontWithSize(12, NO),
                                       AWColorFromRGB(153, 153, 153));
    [self.scrollView addSubview:moreLabel];
    moreLabel.center = CGPointMake(self.width - 15 - moreLabel.width / 2,
                                   titleLabel.midY);
    
    UILabel *label1 = [self addLabelValue:item[@"showoutamount"]//item[@"unpaidamount"]
                                  forName:@"累计完成产值"//@"累计未付"
                                     date:nil
                                    color:MAIN_THEME_COLOR];
    label1.position = CGPointMake(15, titleLabel.bottom + 10);
    
//    UILabel *label2 = [self addLabelValue:item[@"payableamount"]
//                                  forName:@"累计完成产值"
//                                     date:nil
//                                    color:AWColorFromRGB(74, 144, 226)];
//    label2.textAlignment = NSTextAlignmentCenter;
//    label2.position = CGPointMake(label1.right, titleLabel.bottom + 10);
    
    UILabel *label3 = [self addLabelValue:item[@"paidamount"]
                                  forName:@"累计已付"
                                     date:nil
                                    color:AWColorFromRGB(74, 74, 74)];
    label3.textAlignment = NSTextAlignmentRight;
    label3.position = CGPointMake(self.width - 15 - label3.width, titleLabel.bottom + 10);
    
    UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self.scrollView addSubview:progress];
    progress.frame = CGRectMake(15, label3.bottom + 5, self.width - 30 - 60, 18);
    progress.progressTintColor = MAIN_THEME_COLOR;
    progress.trackTintColor = AWColorFromHex(@"#e6e6e6");
    progress.progress = HNFloatFromObject(item[@"showoutamount"], 0) == 0 ? 0 :
    HNFloatFromObject(item[@"paidamount"], 0) / HNFloatFromObject(item[@"showoutamount"], 0);
    
    UILabel *progressLabel = AWCreateLabel(CGRectMake(0, 0, 60, 30),
                                           nil,
                                           NSTextAlignmentRight,
                                           AWSystemFontWithSize(12, NO),
                                           AWColorFromRGB(153, 153, 153));
    [self.scrollView addSubview:progressLabel];
    
    progressLabel.center = CGPointMake(self.width - 15 - progressLabel.width / 2,
                                       progress.midY);
    
    progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(progress.progress * 100)];
    
    self.currentTop = progressLabel.bottom;
    
    UIButton *btn = AWCreateImageButton(nil, self, @selector(gotoPayList));
    [self.scrollView addSubview:btn];
    btn.frame = CGRectMake(10, titleLabel.top, self.width - 20, progressLabel.bottom - titleLabel.top);
//    btn.backgroundColor = AWColorFromRGBA(0, 0, 0, 0.3);
}

- (void)addInfo3:(id)item
{
    // ›
    UILabel *titleLabel = AWCreateLabel(CGRectMake(15, self.currentTop + 10, self.width - 30,
                                                   30),
                                        @"签证（已审批且未签订补充合同）",
                                        NSTextAlignmentLeft,
                                        AWSystemFontWithSize(12, YES),
                                        AWColorFromRGB(51, 51, 51));
    [self.scrollView addSubview:titleLabel];
    
    UILabel *moreLabel = AWCreateLabel(CGRectMake(0, 0, 70, 30),
                                       @"更多明细",
                                       NSTextAlignmentRight,
                                       AWSystemFontWithSize(12, NO),
                                       AWColorFromRGB(153, 153, 153));
    [self.scrollView addSubview:moreLabel];
    moreLabel.center = CGPointMake(self.width - 15 - moreLabel.width / 2,
                                   titleLabel.midY);
    
    UILabel *label1 = [self addLabelValue:item[@"visamoney"]
                                  forName:@"累计签证金额"
                                     date:nil
                                    color:MAIN_THEME_COLOR];
    label1.position = CGPointMake(15, titleLabel.bottom + 10);
    
    UILabel *label3 = [self addLabelValue:item[@"visanum"]
                                  forName:@"累计签证笔数"
                                     date:nil
                                    color:AWColorFromRGB(74, 74, 74)];
    label3.textAlignment = NSTextAlignmentRight;
    label3.position = CGPointMake(self.width - 15 - label3.width, titleLabel.bottom + 10);
    
    self.currentTop = label3.bottom + 10;
    
    UIButton *btn = AWCreateImageButton(nil, self, @selector(gotoDeclareList));
    [self.scrollView addSubview:btn];
    btn.frame = CGRectMake(10, titleLabel.top, self.width - 20, label3.bottom - titleLabel.top);
}

- (void)addInfo4:(id)item
{
    UILabel *titleLabel = AWCreateLabel(CGRectMake(15, self.currentTop + 10, self.width - 30,
                                                   30),
                                        @"结算",
                                        NSTextAlignmentLeft,
                                        AWSystemFontWithSize(12, YES),
                                        AWColorFromRGB(51, 51, 51));
    [self.scrollView addSubview:titleLabel];
    
    UILabel *label1 = [self addLabelValue:item[@"settlemoney"]
                                  forName:@"结算金额"
                                     date:nil
                                    color:MAIN_THEME_COLOR];
    label1.position = CGPointMake(15, titleLabel.bottom + 10);
    
    UILabel *label3 = [self addLabelValue:[item[@"issettled"] boolValue] ? @"已结算" : @"未结算"
                                  forName:@"结算状态"
                                     date:nil
                                    color:AWColorFromRGB(74, 74, 74)];
    label3.textAlignment = NSTextAlignmentRight;
    label3.position = CGPointMake(self.width - 15 - label3.width, titleLabel.bottom + 10);
    
    self.currentTop = label3.bottom + 10;
}

- (UIScrollView *)scrollView
{
    if ( !_scrollView ) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = self.bounds;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

@end
