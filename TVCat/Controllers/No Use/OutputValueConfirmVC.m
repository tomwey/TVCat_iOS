//
//  OutputValueConfirmVC.m
//  HN_ERP
//
//  Created by tomwey on 24/10/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "OutputValueConfirmVC.h"
#import "Defines.h"

#import "NTMonthYearPicker.h"

#import "UploadImageControl.h"

@interface OutputValueConfirmVC () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) CGFloat currentBottom;

@property (nonatomic, strong) NSDate *currentDate;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NTMonthYearPicker *datePicker;

@property (nonatomic, weak) UIButton *dateButton;

@property (nonatomic, weak) UILabel *planLabel;
@property (nonatomic, weak) UILabel *realLabel;
@property (nonatomic, weak) UILabel *totalLabel;

@property (nonatomic, weak) UIButton *doneBtn;
@property (nonatomic, weak) UIButton *resetBtn;

@property (nonatomic, assign) CGRect keyboardFrame;
@property (nonatomic, weak) UITextView *confirmDescText;

@property (nonatomic, weak) UploadImageControl *uploadControl;

@property (nonatomic, weak) UILabel *currentValueLabel;

@property (nonatomic, assign) NSInteger beginValue;

@property (nonatomic, weak) UISlider *slider;

@end

@implementation OutputValueConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"按工程量进度确认";
    
    // 添加一个返回按钮，返回到最开始的流程详情
    self.navBar.leftMarginOfLeftItem = 0;
    self.navBar.marginOfFluidItem = -7;
    UIButton *closeBtn = HNCloseButton(34, self, @selector(backToPage));
    [self.navBar addFluidBarItem:closeBtn atPosition:FluidBarItemPositionTitleLeft];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.currentDate = [NSDate date];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy年M月";
    
    UIButton *commitBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width - 30,
                                                        50),
                                             @"产值确认",
                                             [UIColor whiteColor],
                                             self,
                                             @selector(btnClicked:));
    [self.contentView addSubview:commitBtn];
    
    commitBtn.backgroundColor = MAIN_THEME_COLOR;
    commitBtn.position = CGPointMake(15, self.contentView.height - 50 - 15);
    
    commitBtn.cornerRadius = 25;
    
    self.doneBtn = commitBtn;
    
    commitBtn.userData = @{ @"type": @"1" };
    
//    UIButton *commitBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
//                                                        50),
//                                             @"产值确认",
//                                             [UIColor whiteColor],
//                                             self,
//                                             @selector(doConfirm));
//    [self.contentView addSubview:commitBtn];
//    commitBtn.backgroundColor = MAIN_THEME_COLOR;
//    commitBtn.position = CGPointMake(0, self.contentView.height - 50);
//    
//    self.doneBtn = commitBtn;
//    
//    UIButton *moreBtn = AWCreateTextButton(CGRectMake(0, 0, self.contentView.width / 2,
//                                                      50),
//                                           @"取消确认",
//                                           IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR,
//                                           self,
//                                           @selector(cancelConfirm));
//    [self.contentView addSubview:moreBtn];
//    moreBtn.backgroundColor = [UIColor whiteColor];
//    moreBtn.position = CGPointMake(commitBtn.right, self.contentView.height - 50);
//    
//    self.resetBtn = moreBtn;
//    
//    UIView *hairLine = [AWHairlineView horizontalLineWithWidth:moreBtn.width
//                                                         color:IOS_DEFAULT_CELL_SEPARATOR_LINE_COLOR
//                                                        inView:moreBtn];
//    hairLine.position = CGPointMake(0,0);
//    
//    moreBtn.left = 0;
//    commitBtn.left = moreBtn.right;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self loadData];
    
    if ( [self hasConfirmAbility] == NO ) {
        [self.navigationController.view showHUDWithText:@"您只有查看权限" offset:CGPointMake(0,20)];
        
        commitBtn.hidden = YES;
    }
}

- (BOOL)hasConfirmAbility
{
    NSArray *abilities = [AppManager sharedInstance].manAbilities[@"产值确认"];
    return abilities.count > 1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.confirmDescText resignFirstResponder];
}

- (void)btnClicked:(UIButton *)sender
{
    if ( [sender.userData[@"type"] isEqualToString:@"1"] ) {
        [self doConfirm];
    } else {
        [self cancelConfirm];
    }
}

- (void)doConfirm
{
    //    @iOutNodeID bigint,--节点类型ID
    //    @iContractPayNodeID bigint,--节点ID
    //    @sRoomIDs varchar(200),--楼栋ID
    //    @dBeginValue decimal(18,2),--开始工程量
    //    @dEndValue decimal(18,2),--结束工程量
    //    @sMemo varchar(2000),--说麦
    //    @sAnnexIDs varchar(200),--附件ID,多个附件以逗号间隔
    //    @iConfirmType int, ---1 确认  -1 取消确认
    //    @iManID bigint,--操作人员ID
    
    // 检查提交数据
//    if ( !self.currentConfirmFloor ) {
//        [self.contentView showHUDWithText:@"产值确认楼层必选" offset:CGPointMake(0,20)];
//        return;
//    }
//    
    NSString *beginVal = [@(self.beginValue) description];
    
    NSInteger value = [self.currentValueLabel.text integerValue];
    
    if ( value <= self.beginValue ) {
        [self.contentView showHUDWithText:@"产值确认完成进度必须设置" offset:CGPointMake(0,20)];
        return;
    }
    
    NSString *endVal   = [@(value) description];
    
    NSString *confirmDesc = [self.confirmDescText.text trim];
    if ( confirmDesc.length == 0 ) {
        [self.contentView showHUDWithText:@"进度说明不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    //    NSString *annexIDs = @"";
    NSArray *IDs = self.uploadControl.attachmentIDs;
    if ( IDs.count == 0 ) {
        [self.contentView showHUDWithText:@"至少需要上传一张图片" offset:CGPointMake(0,20)];
        return;
    }
    
    NSString *annexIDs = [IDs componentsJoinedByString:@","];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
//    contractpaynodeid
    NSString *outNodeId = [[self.params[@"floor"][@"outnodeid"] description] isEqualToString:@"NULL"] ? @"0" : [self.params[@"floor"][@"outnodeid"] description];
    NSString *payOutNodeId = [[self.params[@"floor"][@"contractpaynodeid"] description] isEqualToString:@"NULL"] ? @"0" : [self.params[@"floor"][@"contractpaynodeid"] description];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认保存确认产值APP",
              @"param1": [self.params[@"floor"][@"contractid"] description],
              @"param2": outNodeId,
              @"param3": payOutNodeId,
              @"param4": [self.params[@"floor"][@"roomids"] description],
              @"param5": beginVal,
              @"param6": endVal,
              @"param7": confirmDesc,
              @"param8": annexIDs,
              @"param9": @"1",
              @"param10": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult4:result error:error];
              }];
}

- (void)cancelConfirm
{
    // 检查提交数据
    NSInteger value = [self.currentValueLabel.text integerValue];
    
    if ( value == self.beginValue ) {
        [self.contentView showHUDWithText:@"取消确认完成进度必须设置" offset:CGPointMake(0,20)];
        return;
    }
    
    if ( value > self.beginValue ) {
        [self.contentView showHUDWithText:@"取消确认完成进度必须小于当前完成进度" offset:CGPointMake(0,20)];
        return;
    }
    
    NSString *endVal   = [@(self.beginValue) description];
    NSString *beginVal = [@(value) description];
    
    NSString *confirmDesc = [self.confirmDescText.text trim];
    
    if ( confirmDesc.length == 0 ) {
        [self.contentView showHUDWithText:@"进度说明不能为空" offset:CGPointMake(0,20)];
        return;
    }
    
    //    NSString *annexIDs = @"";
    NSArray *IDs = self.uploadControl.attachmentIDs;
    NSString *annexIDs = [IDs componentsJoinedByString:@","] ?: @"";
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    NSString *outNodeId = [[self.params[@"floor"][@"outnodeid"] description] isEqualToString:@"NULL"] ? @"0" : [self.params[@"floor"][@"outnodeid"] description];
    NSString *payOutNodeId = [[self.params[@"floor"][@"contractpaynodeid"] description] isEqualToString:@"NULL"] ? @"0" : [self.params[@"floor"][@"contractpaynodeid"] description];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认保存确认产值APP",
              @"param1": [self.params[@"floor"][@"contractid"] description],
              @"param2": outNodeId,
              @"param3": payOutNodeId,
              @"param4": [self.params[@"floor"][@"roomids"] description],
              @"param5": endVal,
              @"param6": beginVal,
              @"param7": confirmDesc,
              @"param8": annexIDs,
              @"param9": @"-1",
              @"param10": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult5:result error:error];
              }];
}

- (void)backToPage
{
    NSArray *controllers = [self.navigationController viewControllers];
    if ( controllers.count > 1 ) {
        [self.navigationController popToViewController:controllers[1] animated:YES];
    }
}

- (void)handleResult4:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView: self.contentView animated:YES];
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {        
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"产值确认失败" succeed:NO];
        } else {
            id item = [result[@"data"] firstObject];
            
            NSInteger type = [item[@"hinttype"] integerValue];
            if (type == 1) {
                [self.navigationController.view showHUDWithText:item[@"hint"] succeed:YES];
                
                [self.navigationController popViewControllerAnimated:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kOutputDidConfirmNotification"
                                                                    object:nil];
            } else {
                [self.contentView showHUDWithText:item[@"hint"] succeed:NO];
            }
        }

    }
}

- (void)handleResult5:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView: self.contentView animated:YES];
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"产值取消确认失败" succeed:NO];
        } else {
            id item = [result[@"data"] firstObject];
            
            NSInteger type = [item[@"hinttype"] integerValue];
            if (type == 1) {
                [self.navigationController.view showHUDWithText:item[@"hint"] succeed:YES];
                
                [self.navigationController popViewControllerAnimated:YES];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kOutputDidConfirmNotification"
                                                                    object:nil];
            } else {
                [self.contentView showHUDWithText:item[@"hint"] succeed:NO];
            }
        }
        
    }
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dc = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth
                                       fromDate:self.currentDate];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询楼栋产值APP",
              @"param1": [self.params[@"item"][@"contractid"] description] ?: @"",
              @"param2": [self.params[@"building"][@"building_id"] description] ?: @"",
              @"param3": [@(dc.year) description],
              @"param4": [@(dc.month) description],
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
            //            [self showRoom:result[@"data"]];
            [self showContent:result[@"data"]];
        }
    }
}

- (void)showContent:(id)data
{
    
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    
    if ( !self.scrollView ) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:self.scrollView];
        
        [self.contentView bringSubviewToFront:self.doneBtn];
        
        self.scrollView.height -= self.doneBtn.height;
        
        self.scrollView.delegate = self;
    }
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // 项目
    UILabel *label1 = AWCreateLabel(CGRectMake(15, 15, self.contentView.width - 30,
                                               30),
                                    nil,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(16, YES),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label1];
    
    label1.text = [NSString stringWithFormat:@"%@%@：%@", [self.params[@"area"] areaName],
                   [self.params[@"project"] projectName], self.params[@"building"][@"building_name"]];
    
    UIButton *dateBtn = AWCreateTextButton(CGRectMake(0, 0, 90,34),
                                           [[self.dateFormatter stringFromDate:self.currentDate] stringByAppendingString:@"▾"],
                                           AWColorFromRGB(74, 74, 74),
                                           self,
                                           @selector(openDatePicker));
    [self.scrollView addSubview:dateBtn];
    
    self.dateButton = dateBtn;
    
    dateBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
    
    //    [dateBtn setImage:[UIImage imageNamed:@"icon_caret.png"] forState:UIControlStateNormal];
    //    [dateBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
    
    label1.width -= 95;
    
    dateBtn.center = CGPointMake(self.contentView.width - 15 - dateBtn.width / 2, label1.midY);
    
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
    
    id item = [data firstObject];
    
    // 产值
    UILabel *planLabel = AWCreateLabel(CGRectZero,
                                       nil,
                                       NSTextAlignmentCenter,
                                       AWSystemFontWithSize(14, NO),
                                       AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:planLabel];
    
    self.planLabel = planLabel;
    
    NSString *planMoney = [NSString stringWithFormat:@"%@\n当月计划产值",
                           HNFormatMoney(item[@"curmonthplan"], @"万")];
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
    
    realLabel.numberOfLines = 2;
    
    NSString *realMoney = [NSString stringWithFormat:@"%@\n实际产值",
                           HNFormatMoney(item[@"curmonthfact"], @"万")];
    
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
    
//    self.params[@"floor"][@"nodecurendvalue"];
    
    NSString *totalMoney = [NSString stringWithFormat:@"%@\n截止本月产值",
                            HNFormatMoney(item[@"contractfactoutvalue"], @"万")];
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
    
    self.currentBottom = line.bottom + 20;
    
    // 节点名称
    UILabel *label = AWCreateLabel(CGRectMake(15, self.currentBottom,
                                              self.contentView.width - 30,
                                              30),
                                   self.params[@"floor"][@"outnodename"],
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(16, NO),
                                   AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label];
    
//    NSString *currVal = [NSString stringWithFormat:@"%@%%",
//                         @(HNIntegerFromObject(self.params[@"floor"][@"nodecurendvalue"], 0))];
    
    self.beginValue = HNIntegerFromObject(self.params[@"floor"][@"nodecurendvalue"], 0);
    
//    NSString *suffix = [NSString stringWithFormat:@" 完成%@%%", @(HNIntegerFromObject(self.params[@"floor"][@"nodecurendvalue"], 0))];
//    
//    NSString *str = [NSString stringWithFormat:@"%@%@", self.params[@"floor"][@"outnodename"],suffix];
//    NSRange range = [str rangeOfString:suffix];
//    NSInteger length = range.length;
////    NSInteger loc = range.location;
//    
////    range.location = loc + length + 1;
//    range.length = suffix.length + length;
    
//    NSMutableAttributedString *val = [[NSMutableAttributedString alloc] initWithString:str];
//    [val addAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(16, NO),
//                          NSForegroundColorAttributeName: MAIN_THEME_COLOR }
//                 range:range];

    label.text = self.params[@"floor"][@"outnodename"];
    
    self.currentBottom = label.bottom + 10;
    
    self.scrollView.contentSize = CGSizeMake(self.contentView.width,
                                             self.currentBottom);
    
//    [self loadPayFloorNode];
    if ( [self.params[@"floor"][@"hasoutvalue"] boolValue] ) {
        [self showOutValue];
    } else {
        [self showOtherUI];
    }

}

- (void)showOutValue
{
    [HNProgressHUDHelper showHUDAddedTo: self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询合同付款节点APP",
              @"param1": [self.params[@"floor"][@"contractid"] description],
              @"param2": [self.params[@"floor"][@"contractpaynodeid"] description],
//              @"param3": [self.params[@"floor"][@"roomids"] description],
              } completion:^(id result, NSError *error) {
                  [me handleResult3:result error:error];
              }];
}

- (void)handleResult3:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    //    NSLog(@"result: %")
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
        
        [self showContent3:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self showContent3:@[]];
        } else {
            [self showContent3:result[@"data"]];
        }
    }
}

- (void)showOtherUI
{
    // 显示输入进度
    UILabel *label = AWCreateLabel(CGRectMake(15, self.currentBottom,
                                              93,
                                              30),
                                   @"完成进度",
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(14, NO),
                                   AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label];
    
    UILabel *label1 = AWCreateLabel(CGRectMake(0, 0, 40, 30),
                          @"100%",
                          NSTextAlignmentRight,
                          AWSystemFontWithSize(14, NO),
                          AWColorFromRGB(74, 74, 74));
    
    [self.scrollView addSubview:label1];
    
    label1.position = CGPointMake(self.contentView.width - 15 - label1.width,
                                 self.currentBottom);
    
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0,
                                                                  label1.left - label.right - 10,
                                                                  20)];
    [self.scrollView addSubview:slider];
    self.slider = slider;
    
    slider.center = CGPointMake(label1.left - 5 - slider.width / 2,
                                label1.midY);
    
    slider.minimumValue = HNIntegerFromObject(self.params[@"floor"][@"minnum"], 0);
    slider.maximumValue = HNIntegerFromObject(self.params[@"floor"][@"maxnum"], 0);
    slider.value = HNIntegerFromObject(self.params[@"floor"][@"nodecurendvalue"], 0);
    slider.minimumTrackTintColor = MAIN_THEME_COLOR;
    
    [slider addTarget:self
               action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(touchEnded:)
     forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    UILabel *label2 = AWCreateLabel(CGRectMake(0, 0, 35, 30),
                                    [NSString stringWithFormat:@"%@%%", @(slider.value)],
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(74, 74, 74));
    
    [self.scrollView addSubview:label2];
    
    self.currentValueLabel = label2;
    
    label2.position = CGPointMake(slider.left - label2.width,
                                         self.currentBottom);
    
    self.currentBottom = label.bottom + 30;
    
    // 添加输入说明
    [self addConfirmDesc];
    
    // 添加上传图片
    [self addUploadFiles];
    
    self.scrollView.contentSize = CGSizeMake(self.contentView.width,
                                             self.currentBottom);
}

- (BOOL)supportsSwipeToBack
{
    return NO;
}

- (void)touchEnded:(UISlider *)sender
{
    NSInteger currentVal = self.beginValue; //[self.currentValueLabel.text integerValue];
    if ( sender.value < currentVal ) {
        [self checkIsCancel:sender.value];
    } else {
        [self setCanCancel:NO];
    }
}

- (void)checkIsCancel:(NSInteger)value
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id user = [[UserService sharedInstance] currentUser];
    NSString *manID = [user[@"man_id"] description];
    manID = manID ?: @"0";
    
    NSString *nodeId = HNStringFromObject(self.params[@"floor"][@"outnodeid"], @"0");
    NSString *payNodeId = HNStringFromObject(self.params[@"floor"][@"contractpaynodeid"], @"0");
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认判断是否允许撤销产值APP",
              @"param1": [self.params[@"floor"][@"contractid"] description],
              @"param2": nodeId,
              @"param3": payNodeId,
              @"param4": [self.params[@"floor"][@"roomids"] description],
              @"param5": [@(value) description],
              @"param6": manID,
              } completion:^(id result, NSError *error) {
                  [me handleResult6:result error:error];
              }];
}

- (void)handleResult6:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:@"判断是否允许撤销产值出错，请重试" succeed:NO];
        // 不能取消
        
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
        
        [self setCanCancel:NO];
        
        self.slider.value = self.beginValue;//[self.currentValueLabel.text integerValue];
        self.currentValueLabel.text = [NSString stringWithFormat:@"%@%%", @((int)self.slider.value)];
    } else {
        id item = [result[@"data"] firstObject];
        if ( item && [item[@"hinttype"] integerValue] == 1 ) {
            [self setCanCancel:YES];
        } else {
            // 不能取消
            [self setCanCancel:NO];
            
            [self.contentView showHUDWithText:item[@"hint"] offset:CGPointMake(0, 20)];
            
            self.slider.value = self.beginValue;//[self.currentValueLabel.text integerValue];
            self.currentValueLabel.text = [NSString stringWithFormat:@"%@%%", @((int)self.slider.value)];
        }
    }
}

- (void)setCanCancel:(BOOL)flag
{
    if ( flag ) {
        self.doneBtn.userData = @{ @"type": @"0" };
        self.doneBtn.layer.borderColor = MAIN_THEME_COLOR.CGColor;
        self.doneBtn.layer.borderWidth = 0.6;
        self.doneBtn.backgroundColor = [UIColor whiteColor];
        [self.doneBtn setTitleColor:MAIN_THEME_COLOR forState:UIControlStateNormal];
        
        [self.doneBtn setTitle:@"取消确认" forState:UIControlStateNormal];
    } else {
        self.doneBtn.userData = @{ @"type": @"1" };
        self.doneBtn.layer.borderColor = MAIN_THEME_COLOR.CGColor;
        self.doneBtn.layer.borderWidth = 0.6;
        self.doneBtn.backgroundColor = MAIN_THEME_COLOR;
        [self.doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.doneBtn setTitle:@"产值确认" forState:UIControlStateNormal];
    }
}

- (void)valueChanged:(UISlider *)slider
{
    [slider setValue:((int)((slider.value + 2.5) / 5) * 5) animated:NO];
    
    self.currentValueLabel.text = [NSString stringWithFormat:@"%@%%", @((int)slider.value)];
}

- (void)showContent3:(id)data
{
//    if ([data count] == 0) {
//        [self showOtherUI];
//    } else {
    
    NSString *str1 = nil;
    NSString *str2 = nil;
    if ([data count] == 0) {
        str1 = [NSString stringWithFormat:@"节点产值: -- 万"];
        str2 = [NSString stringWithFormat:@"节点应付: -- 万"];
    } else {
        id item = [data firstObject];
        str1 = [NSString stringWithFormat:@"节点产值: %@", HNFormatMoney(item[@"outamount"], @"万")];
        str2 = [NSString stringWithFormat:@"节点应付: %@", HNFormatMoney(item[@"nodeamount"], @"万")];
    }
    
    UILabel *label1 = AWCreateLabel(CGRectMake(15, self.currentBottom,
                                               self.contentView.width - 30,
                                               30),
                                    str1,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label1];
    
    UILabel *label2 = AWCreateLabel(label1.frame,
                                    str2,
                                    NSTextAlignmentLeft,
                                    AWSystemFontWithSize(14, NO),
                                    AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label2];
    
    label2.top = label1.bottom;
    
    self.currentBottom = label2.bottom + 5;
    
    [self showOtherUI];
//    label2.left = self.contentView.width - 15 - label2.width;
//    }
    
}

- (void)loadPayFloorNode
{
    [HNProgressHUDHelper showHUDAddedTo: self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"产值确认查询合同楼栋应付节点楼层APP",
              @"param1": [self.params[@"floor"][@"contractid"] description],
              @"param2": [self.params[@"floor"][@"outnodeid"] description],
              @"param3": [self.params[@"floor"][@"roomids"] description],
              } completion:^(id result, NSError *error) {
                  [me handleResult2:result error:error];
              }];
}

- (void)handleResult2:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    //    NSLog(@"result: %")
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"应付节点数据为空" offset:CGPointMake(0,20)];
        } else {
            //            [self showRoom:result[@"data"]];
            [self showContent2:result[@"data"]];
        }
    }
}

- (void)showContent2:(NSArray *)data
{
    NSLog(@"name: %@", self.params[@"floor"][@"moneytypename"]);
    
    //    confirmbase = 10;
    //    contractid = 2194031;
    //    contractpaynodeid = NULL;
    //    maxnum = 18;
    //    minnum = 1;
    //    moneytypeid = 20;
    //    moneytypename = "\U8fdb\U5ea6\U6b3e";
    //    nodecurendvalue = NULL;
    //    nodenumberunit = "\U5c42";
    //    ordertype = 1;
    //    outnodeid = 5;
    //    outnodename = "\U9884\U7559\U9884\U57cb";
    //    pricebase = 10;
    //    roomids = 1042;
    //    roomname = "1\U680b";
    
//    NSInteger maxNum = HNIntegerFromObject(self.params[@"floor"][@"maxnum"], 0);
//    NSInteger minNum = HNIntegerFromObject(self.params[@"floor"][@"minnum"], 0);
//    
//    NSInteger currNum = HNIntegerFromObject(self.params[@"floor"][@"nodecurendvalue"], 0);
//    
//    self.currValue = currNum;
//    
//    NSInteger orderType = HNIntegerFromObject(self.params[@"floor"][@"ordertype"], 0);
//    self.orderType = orderType;
//    
//    NSInteger startFloor, endFloor;
//    if ( orderType == 1 ) {
//        startFloor = MIN(minNum, maxNum);
//        endFloor   = MAX(minNum, maxNum);
//    } else {
//        startFloor = MAX(minNum, maxNum);
//        endFloor   = MIN(minNum, maxNum);
//    }
//    
//    [self addNodes:startFloor endFloor:endFloor type:orderType currVal:currNum];
    
//    confirmbase = 50;
//    contractid = 2194031;
//    contractpaynodeid = NULL;
//    hasoutvalue = 1;
//    maxnum = 100;
//    minnum = 0;
//    moneytypeid = 20;
//    moneytypename = "\U8fdb\U5ea6\U6b3e";
//    nodecurendvalue = NULL;
//    nodenumberunit = "%";
//    ordertype = 1;
//    outnodeid = 6;
//    outnodename = "\U9632\U6c34\U5de5\U7a0b";
//    pricebase = 50;
//    roomids = 1042;
//    roomname = "1\U680b";
    
    
}

- (void)addConfirmDesc
{
    UITextView *textView = [[UITextView alloc] init];
    [self.scrollView addSubview:textView];
    
    self.confirmDescText = textView;
    
    textView.frame = CGRectMake(15, self.currentBottom,
                                self.contentView.width - 30,
                                60);
    
    self.currentBottom = textView.bottom + 10;
    
    textView.placeholder = @"输入进度说明";
    
    textView.layer.borderColor = AWColorFromRGB(216, 216, 216).CGColor;
    textView.layer.borderWidth = 0.6;
}

- (void)addUploadFiles
{
    UILabel *label = AWCreateLabel(CGRectMake(15,
                                              self.currentBottom,
                                              78, 25),
                                   @"上传图片",
                                   NSTextAlignmentLeft,
                                   AWSystemFontWithSize(15, NO),
                                   AWColorFromRGB(74, 74, 74));
    [self.scrollView addSubview:label];
    
    UploadImageControl *uploadControl = [[UploadImageControl alloc] init];
    [self.scrollView addSubview:uploadControl];
    
    self.uploadControl = uploadControl;
    
    uploadControl.frame = CGRectMake(label.right + 5, self.currentBottom,
                                     self.contentView.width - label.right - 20,
                                     60);
    
    uploadControl.owner = self;
    
    __weak typeof(self) me = self;
    uploadControl.didUploadedImagesBlock = ^(UploadImageControl *sender) {
        me.currentBottom = uploadControl.bottom + 30;
        
        me.scrollView.contentSize = CGSizeMake(me.contentView.width,
                                                 me.currentBottom);
    };
    
    self.currentBottom = uploadControl.bottom + 30;
}

- (void)keyboardWillShow:(NSNotification *)noti
{
    CGRect keyboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationOptions = [noti.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    self.keyboardFrame = keyboardFrame;
    
    //    [self updateSearchBoxPosition];
    
    self.scrollView.contentInset          =
    self.scrollView.scrollIndicatorInsets =
    UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0);
    
    CGRect r = [self.contentView convertRect:self.confirmDescText.frame
                                    fromView:self.scrollView];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptions
                     animations:
     ^{
         [self.scrollView scrollRectToVisible:r animated:NO];
     } completion:nil];
    
}

- (void)keyboardWillHide:(NSNotification *)noti
{
    CGFloat duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger animationOptions = [noti.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:animationOptions
                     animations:
     ^{
         self.scrollView.contentInset          =
         self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
     } completion:nil];
}

- (void)openDatePicker
{
    self.datePicker.superview.top = self.contentView.height;
    
    [UIView animateWithDuration:.3 animations:^{
        [self.contentView viewWithTag:1011].alpha = 0.6;
        self.datePicker.superview.top = self.contentView.height - self.datePicker.superview.height;
    }];
}

- (void)cancel
{
    [UIView animateWithDuration:.3 animations:^{
        [self.contentView viewWithTag:1011].alpha = 0.0;
        self.datePicker.superview.top = self.contentView.height;
    }];
}

- (void)done
{
    [self cancel];
    
    self.currentDate = self.datePicker.date;
    
    [self.dateButton setTitle:[[self.dateFormatter stringFromDate:self.currentDate]
                               stringByAppendingString:@"▾"] forState:UIControlStateNormal];
    
    [self loadData];
}

- (NTMonthYearPicker *)datePicker
{
    if ( !_datePicker ) {
        UIView *maskView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:maskView];
        maskView.backgroundColor = [UIColor blackColor];
        maskView.alpha = 0.0;
        maskView.tag = 1011;
        [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)]];
        
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width,
                                                                     260)];
        [self.contentView addSubview:container];
        
        container.backgroundColor = [UIColor whiteColor];
        
        UIToolbar *toolbar = [[UIToolbar alloc] init];
        toolbar.frame = CGRectMake(0, 0, container.width, 44);
        [container addSubview:toolbar];
        
        UIBarButtonItem *cancel =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                      target:self
                                                      action:@selector(cancel)];
        
        UIBarButtonItem *space =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
        
        UIBarButtonItem *done =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                      target:self
                                                      action:@selector(done)];
        
        
        toolbar.items = @[cancel, space, done];
        
        _datePicker = [[NTMonthYearPicker alloc] init];
        [container addSubview:_datePicker];
        
        [NSCalendar currentCalendar];
        
        _datePicker.frame = CGRectMake(0, toolbar.bottom,
                                       container.width,
                                       container.height - toolbar.height);
        _datePicker.maximumDate = [NSDate date];
        //        _datePicker.minimumDate =
        _datePicker.date = [NSDate date];
    }
    
    [self.contentView bringSubviewToFront:[self.contentView viewWithTag:1011]];
    [self.contentView bringSubviewToFront:_datePicker.superview];
    
    return _datePicker;
}


@end
