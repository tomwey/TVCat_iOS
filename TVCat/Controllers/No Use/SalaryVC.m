//
//  SalaryVC.m
//  HN_ERP
//
//  Created by tomwey on 4/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "SalaryVC.h"
#import "Defines.h"
#import "NTMonthYearPicker.h"

@interface SalaryVC () <UITableViewDataSource>

@property (nonatomic, strong) NTMonthYearPicker *datePicker;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation SalaryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"我的工资";
    
    UILabel *coomingSoon = AWCreateLabel(CGRectZero,
                                         @"敬请期待...",
                                         NSTextAlignmentCenter, nil, [UIColor blackColor]);
    [self.contentView addSubview:coomingSoon];
    coomingSoon.frame = CGRectMake(0, 168, self.contentView.width, 40);
    
    /*
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy年M月";
    
    __weak typeof(self) weakSelf = self;
    [self addRightItemWithTitle:[self.dateFormatter stringFromDate:[NSDate date]]
                titleAttributes:@{
                                  NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                           size:CGSizeMake(80, 40)
                    rightMargin:10 callback:^{
                        [weakSelf openPicker];
                    }];
    
    [self loadData];*/
    /**
     工资年月
     项目类型：基本工资，社保，住房公积金
     基本工资包括：
     基本工资
     岗位绩效工资
     固定加班轮班补贴
     环境补贴
     固定工资
     实际出勤天数
     应出勤天数
     出勤工资
     交通、通讯补贴
     餐费
     税前合计
     当月社保
     当月公积金
     个人所得税
     扣税合计
     税后合计
     */
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    id dict = @{ @"label" : @"基本工资",
                 @"value" : @(2000) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"岗位绩效工资",
              @"value" : @(1500) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"固定加班轮班补贴",
              @"value" : @(1800) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"环境补贴",
              @"value" : @(200) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"固定工资",
              @"value" : @(1000) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"实际出勤天数",
              @"value" : @(20) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"应出勤天数",
              @"value" : @(22) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"出勤工资",
              @"value" : @(5000) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"交通、通讯补贴",
              @"value" : @(300) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"餐费",
              @"value" : @(500) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"税前合计",
              @"value" : @(6500) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"当月社保",
              @"value" : @(1200) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"当月公积金",
              @"value" : @(800) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"个人所得税",
              @"value" : @(500) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"扣税合计",
              @"value" : @(-1600) };
    [self.dataSource addObject:dict];
    
    dict = @{ @"label" : @"税后合计",
              @"value" : @(4500) };
    [self.dataSource addObject:dict];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        [self.tableView reloadData];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id item = self.dataSource[indexPath.row];
    
    cell.textLabel.text = [item[@"label"] description];
    cell.detailTextLabel.text = [item[@"value"] description];
    
    return cell;
}

- (void)openPicker
{
//    [self.contentView bringSubviewToFront:self.datePicker];
    
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
        _datePicker.minimumDate =
        _datePicker.date = [NSDate date];
    }
    
    [self.contentView bringSubviewToFront:[self.contentView viewWithTag:1011]];
    [self.contentView bringSubviewToFront:_datePicker.superview];
    
    return _datePicker;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        [_tableView removeBlankCells];
        
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end
