//
//  VIPChargeListVC.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "VIPChargeListVC.h"
#import "Defines.h"

@interface VIPChargeListVC () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation VIPChargeListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"VIP充值记录";
    
    __weak typeof(self) me = self;
    [self addRightItemWithTitle:@"新增"
                titleAttributes:@{ NSFontAttributeName: AWSystemFontWithSize(15, NO) }
                           size:CGSizeMake(60, 40)
                    rightMargin:5
                       callback:^{
                           [me newCharge];
                       }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"kVIPActiveSuccessNotification"
                                               object:nil];
    [self loadData];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [[CatService sharedInstance] fetchVIPChargeList:^(id result, NSError *error) {
        [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
        
        if ( error ) {
            [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
        } else {
            if ( [result count] == 0 ) {
                [self.tableView showErrorOrEmptyMessage:@"暂无充值记录" reloadDelegate:nil];
            } else {
                self.dataSource = result;
            }
            
            [self.tableView reloadData];
        }
    }];
}

- (void)newCharge
{
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"NewVIPChargeVC"
                                                                params:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell.id"];
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"cell.id"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    id item = self.dataSource[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"激活码：%@", item[@"code"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 激活", item[@"active_time"]];
    
    cell.textLabel.font = AWSystemFontWithSize(15, NO);
    cell.textLabel.textColor = AWColorFromHex(@"#333333");
    
    cell.detailTextLabel.font = AWSystemFontWithSize(13, NO);
    cell.detailTextLabel.textColor = AWColorFromHex(@"#999999");
    
    return cell;
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self;
        
        _tableView.rowHeight = 60;
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

@end
