//
//  PayListVC.m
//  HN_Vendor
//
//  Created by tomwey on 26/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "PayListVC.h"
#import "Defines.h"
#import "PayTimeView.h"

@interface PayListVC () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@property (nonatomic, strong) DMButton *moneyButton;
@property (nonatomic, strong) DMButton *payButton;

@property (nonatomic, strong) UIView *topbar;

@property (nonatomic, assign) NSInteger counter;

@property (nonatomic, strong) NSArray *moneyData;
@property (nonatomic, strong) NSArray *payData;

@property (nonatomic, strong) PayTimeView *timeView;

@property (nonatomic, copy) NSString *beginDateString;
@property (nonatomic, copy) NSString *endDateString;

@property (nonatomic, copy) NSString *changeVal;

@property (nonatomic, weak) UIButton *timeBtn;

@end

@implementation PayListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = [self.params[@"moneytypename"] stringByAppendingString:@"明细"];
    
    [self addLeftItemWithView:HNCloseButton(34, self, @selector(close))];
    
    [self initHeaderCaption];
    
    [self loadData];
    
//    [self startLoadingData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    id userInfo = [[UserService sharedInstance] currentUser];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商查询合同付款列表APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              @"param4": [self.params[@"contractid"] ?: @"0" description],
              @"param5": @"0",
              @"param6": @"0",
              @"param7": @"",
              @"param8": @"",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error needHideSpinner:NO];
              }];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商取值列表数据查询APP",
              @"param1": @"支付方式",
              } completion:^(id result, NSError *error) {
                  [me loadDone1:result error:error];
              }];
    
//    [[self apiServiceWithName:@"APIService"]
//     POST:nil
//     params:@{
//              @"dotype": @"GetData",
//              @"funname": @"供应商取值列表数据查询APP",
//              @"param1": @"款项类型",
//              } completion:^(id result, NSError *error) {
//                  [me loadDone2:result error:error];
//              }];
}

- (void)loadDone1:(id)result error:(NSError *)error
{
    if ( [result[@"rowcount"] integerValue] > 0 ) {
        NSArray *data = result[@"data"];
        NSMutableArray *temp = [NSMutableArray array];
        [temp addObject:@{ @"name": @"全部", @"value": @"0" }];
        for (id item in data) {
            [temp addObject:@{ @"name": item[@"dic_name"] ?: @"", @"value": item[@"dic_value"] ?: @"" }];
        }
        
        self.payData = [temp copy];
    }
    [self loadDone];
}

- (void)loadDone2:(id)result error:(NSError *)error
{
    if ( [result[@"rowcount"] integerValue] > 0 ) {
//        NSArray *data = result[@"data"];
        NSArray *data = result[@"data"];
        NSMutableArray *temp = [NSMutableArray array];
        for (id item in data) {
            [temp addObject:@{ @"name": item[@"dic_name"] ?: @"", @"value": item[@"dic_value"] ?: @"" }];
        }
        
        self.moneyData = [temp copy];
    }
    [self loadDone];
}

- (void)loadDone
{
    if ( ++self.counter == 2 ) {
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    }
}

- (void)initHeaderCaption
{
    self.payButton.frame = self.payButton.frame = CGRectMake(0, 0, self.contentView.width / 2,40);
//    self.payButton.left = self.moneyButton.right;
    
    AWHairlineView *line = [AWHairlineView horizontalLineWithWidth:self.contentView.width
                                                             color:AWColorFromHex(@"#e6e6e6")
                                                            inView:self.topbar];
    line.position = CGPointMake(0, self.payButton.bottom - 1);
    
    line = [AWHairlineView verticalLineWithHeight:self.payButton.height - 10
                                            color:AWColorFromHex(@"#e6e6e6")
                                           inView:self.topbar];
    line.position = CGPointMake(self.payButton.right, 5);
    
//    line = [AWHairlineView verticalLineWithHeight:self.moneyButton.height - 10
//                                            color:AWColorFromHex(@"#e6e6e6")
//                                           inView:self.topbar];
//    line.position = CGPointMake(self.payButton.right, 5);
    
    UIButton *timeBtn = AWCreateTextButton(self.payButton.frame,
                                           @"支付时间",
                                           AWColorFromRGB(88,88,88),
                                           self,
                                           @selector(btnClicked:));
    [self.topbar addSubview:timeBtn];
    self.timeBtn = timeBtn;
    
    timeBtn.titleLabel.font = AWSystemFontWithSize(14, NO);
    
    timeBtn.left = self.payButton.right;
    
}

- (void)btnClicked:(UIButton *)sender
{
    [self.timeView close];
    
    self.timeView = [[PayTimeView alloc] init];
    
    self.timeView.beginDate = self.beginDateString;
    self.timeView.endDate   = self.endDateString;
    
    [self.timeView showInView:self.contentView atPosition:CGPointMake(0, self.topbar.bottom)];
    
    static NSDateFormatter *df;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"yyyy-MM-dd";
    });
    
    __weak typeof(self) me = self;
    self.timeView.didSelectDate = ^(PayTimeView *sender, NSDate *beginDate, NSDate *endDate) {
        me.beginDateString = [df stringFromDate:beginDate];
        me.endDateString   = [df stringFromDate:endDate];
        
        [me markTimeButton];
        
        [me startLoadingData];
    };
    
    [self.contentView bringSubviewToFront:self.topbar];
}

- (void)markTimeButton
{
    self.changeVal = [NSString stringWithFormat:@"%@%@",
                      self.beginDateString ?: @"",
                      self.endDateString ?: @""];
    if ( self.changeVal.length == 0 ) {
        [self.timeBtn setTitleColor:AWColorFromRGB(88, 88, 88) forState:UIControlStateNormal];
    } else {
        [self.timeBtn setTitleColor:MAIN_THEME_COLOR forState:UIControlStateNormal];
    }
}

- (void)openPickerForData:(NSArray *)data sender:(DMButton *)sender
{
    [self.timeView close];
    
    if ( data.count == 0 ) {
        return;
    }
    
    UIView *superView = self.contentView;
    
    SelectPicker *picker = [[SelectPicker alloc] init];
    picker.frame = superView.bounds;
    
    id currentOption = sender.userData;
    
//    NSMutableArray *temp = [[NSMutableArray alloc] initWithCapacity:data.count];
//    for (int i=0; i<data.count; i++) {
//        id dict = data[i];
//        [temp addObject:@{  }];
//    }
    
    picker.options = [data copy];
    
    picker.currentSelectedOption = currentOption;
    
    [picker showPickerInView:superView];
    
    __weak typeof(self) me = self;
    picker.didSelectOptionBlock = ^(SelectPicker *inSender, id selectedOption, NSInteger index) {
        
        if ( sender == me.moneyButton ) {
            
            if ( ![selectedOption isEqualToDictionary:me.moneyButton.userData] ) {
                sender.userData = data[index];
//                me.moneyButton.title = data[index][@"name"];
                [me startLoadingData];
            }
            
        } else if ( sender == me.payButton ) {
            
            if ( ![selectedOption isEqualToDictionary:me.payButton.userData] ) {
                sender.userData = data[index];
//                me.payButton.title = data[index][@"name"];
                [me startLoadingData];
            }
        }
        
        sender.title = selectedOption[@"name"];
        
    };
}

- (UIView *)topbar
{
    if ( !_topbar ) {
        _topbar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.width,
                                                           40)];
        [self.contentView addSubview:_topbar];
        _topbar.backgroundColor = [UIColor whiteColor];
    }
    return _topbar;
}

- (DMButton *)moneyButton
{
    if ( !_moneyButton ) {
        _moneyButton = [[DMButton alloc] init];
        [self.topbar addSubview:_moneyButton];
        
        __weak typeof(self) me = self;
        _moneyButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.moneyData sender:sender];
        };
        
        _moneyButton.title = @"全部";
    }
    return _moneyButton;
}

- (DMButton *)payButton
{
    if ( !_payButton ) {
        _payButton = [[DMButton alloc] init];
        [self.topbar addSubview:_payButton];
        
        __weak typeof(self) me = self;
        _payButton.selectBlock = ^(DMButton *sender) {
            [me openPickerForData:me.payData sender:sender];
        };
        
        _payButton.title = @"全部";
    }
    return _payButton;
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startLoadingData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    id userInfo = [[UserService sharedInstance] currentUser];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商查询合同付款列表APP",
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              @"param4": [self.params[@"contractid"] ?: @"0" description],
              @"param5": [self.params[@"moneytypeid"] ?: @"0" description],
              @"param6": [self.payButton.userData[@"value"] ?: @"0" description],
              @"param7": self.beginDateString ?: @"",
              @"param8": self.endDateString ?: @"",
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error needHideSpinner:YES];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error needHideSpinner:(BOOL)flag
{
    if (flag) {
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    }
    
    if ( error ) {
        [self.contentView showHUDWithText:error.localizedDescription succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:@"无数据显示" reloadDelegate:nil];
            self.dataSource.dataSource = nil;
        } else {
            [self.tableView removeErrorOrEmptyTips];
            self.dataSource.dataSource = result[@"data"];
        }

        [self.tableView reloadData];
    }
    
    [self loadDone];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        
        _tableView.top = self.topbar.bottom;
        _tableView.height -= self.topbar.height;
        
        [_tableView removeBlankCells];
        
        [self.contentView addSubview:_tableView];
        
        _tableView.rowHeight = 70;
        
        _tableView.separatorColor = AWColorFromHex(@"#e6e6e6");
    }
    return _tableView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"PayListVC" params:self.dataSource.dataSource[indexPath.row]];
//
//    UIViewController *owner = self.userData[@"owner"];
//    [owner presentViewController:vc animated:YES completion:nil];
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"ContractPayCell2", @"cell.id");
    }
    return _dataSource;
}

@end
