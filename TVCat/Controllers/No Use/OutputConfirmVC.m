//
//  OutputConfirmVC.m
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputConfirmVC.h"
#import "Defines.h"

@interface OutputConfirmVC ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat currentBottom;

@end

@implementation OutputConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"产值确认";
    
    // 添加一个返回按钮，返回到最开始的流程详情
    self.navBar.leftMarginOfLeftItem = 0;
    self.navBar.marginOfFluidItem = -7;
    UIButton *closeBtn = HNCloseButton(34, self, @selector(backToPage));
    [self.navBar addFluidBarItem:closeBtn atPosition:FluidBarItemPositionTitleLeft];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.scrollView];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // 项目
    UILabel *label1 = AWCreateLabel(CGRectMake(15, 15, self.contentView.width - 30,
                                               30),
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, YES),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label1];
    
    label1.text = [NSString stringWithFormat:@"%@%@", [self.params[@"area"] areaName],
                   [self.params[@"project"] projectName]];
    
    // 合同
    UILabel *label2 = AWCreateLabel(CGRectMake(15, label1.bottom + 5,
                                               self.contentView.width - 30,
                                               50),
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(15, NO),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label2];
    label2.numberOfLines = 2;
    label2.adjustsFontSizeToFitWidth = YES;
    
    label2.text = self.params[@"item"][@"contractname"];
    
    // 产值
    UILabel *planLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:planLabel];
    
    NSString *planMoney = [NSString stringWithFormat:@"%@\n当月计划产值",
                           HNFormatMoney(self.params[@"item"][@"curmonthplan"], @"万")];
    planLabel.numberOfLines = 2;
    
    NSRange range1 = [planMoney rangeOfString:@"万"];
//    range.length = range.location;
//    range.location = 0;
    NSRange range2 = NSMakeRange(0, range1.location);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:planMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(10, NO)}
                    range:range1];
    
    planLabel.attributedText = string;
    [planLabel sizeToFit];
    
    planLabel.position = CGPointMake(15, label2.bottom + 10);
    
    // 实际产值
    UILabel *realLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:realLabel];
    NSString *realMoney = [NSString stringWithFormat:@"%@\n实际产值",
                           HNFormatMoney(self.params[@"item"][@"curmonthfact"], @"万")];
    realLabel.numberOfLines = 2;
    
    range1 = [realMoney rangeOfString:@"万"];
    range2 = NSMakeRange(0, range1.location);
    
    string = [[NSMutableAttributedString alloc] initWithString:realMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(10, NO)}
                    range:range1];
    
    realLabel.attributedText = string;
    [realLabel sizeToFit];
    
    realLabel.center = CGPointMake(self.contentView.width / 2.0, planLabel.midY);
    
    // 截止本月产值
    UILabel *totalLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(74, 74, 74));
    
    [self.scrollView addSubview:totalLabel];
    
    NSString *totalMoney = [NSString stringWithFormat:@"%@\n截止本月产值",
                           HNFormatMoney(self.params[@"item"][@"contractfactoutvalue"], @"万")];
    totalLabel.numberOfLines = 2;
    
    range1 = [totalMoney rangeOfString:@"万"];
    range2 = NSMakeRange(0, range1.location);
    
    string = [[NSMutableAttributedString alloc] initWithString:totalMoney];
    [string addAttributes:@{ NSFontAttributeName: AWCustomFont(@"PingFang SC", 18),
                             NSForegroundColorAttributeName: MAIN_THEME_COLOR
                             }
                    range:range2];
    [string addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(10, NO)}
                    range:range1];
    
    totalLabel.attributedText = string;
    [totalLabel sizeToFit];
    
    totalLabel.center = CGPointMake(self.contentView.width - 15 - totalLabel.width / 2.0, planLabel.midY);
    
    // 水平线
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
                                                             color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
                                                            inView:self.scrollView];
    line.position = CGPointMake(0, totalLabel.bottom + 30);
    
    self.currentBottom = line.bottom + 30;
    
    [self loadData];
}

- (void)backToPage
{
    NSArray *controllers = [self.navigationController viewControllers];
    if ( controllers.count > 1 ) {
        [self.navigationController popToViewController:controllers[1] animated:YES];
    }
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询合同楼栋APP",
              @"param1": [self.params[@"item"][@"contractid"] description] ?: @""
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
//    NSLog(@"result: %")
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"楼栋数据为空" offset:CGPointMake(0,20)];
        } else {
            [self showRoom:result[@"data"]];
        }
    }
}

- (void)showRoom:(NSArray *)data
{
    NSInteger cols = self.contentView.width > 320 ? 3 : 2;
    
    CGFloat width = (self.contentView.width - 15 * ( cols + 1 )) / cols;
    
    CGFloat bottom = 0;
    for (int i=0; i<data.count; i++) {
        
        UIButton *btn = AWCreateImageButton(nil, self, @selector(btnClicked:));
        [self.scrollView addSubview:btn];
        
        btn.cornerRadius = 12;
        
        btn.frame = CGRectMake(0, 0, width, width * 0.682);
        
        int dtx = i % cols;
        int dty = i / cols;
        
        btn.position = CGPointMake(15 + dtx * ( width + 15 ),
                                   self.currentBottom + ( width * 0.682 + 15 ) * dty);
        
        id item = data[i];
        
        UILabel *label = AWCreateLabel(CGRectInset(btn.bounds, 10, 0),
                                       [NSString stringWithFormat:@"%@\n(%d)",
                                        [item[@"building_name"] description], HNIntegerFromObject(item[@"roomnodenum"], 0)],
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(16, NO),
                                       AWColorFromRGB(74, 74, 74));
        [btn addSubview:label];
        label.numberOfLines = 3;
        label.adjustsFontSizeToFitWidth = YES;
        
        btn.userData = item;
        
        btn.backgroundColor = AWColorFromRGB(241, 241, 241);
        
        bottom = btn.bottom + 15;
        
    }
    
    self.scrollView.contentSize = CGSizeMake(self.contentView.width,
                                             bottom);
}

- (void)btnClicked:(UIButton *)sender
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"OutputJDConfirmVC"
                                                                params:@{
                                                                         @"area": self.params[@"area"],
                                                                         @"project": self.params[@"project"],
                                                                         @"item": self.params[@"item"],
                                                                         @"building": sender.userData,
                                                                         }];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
