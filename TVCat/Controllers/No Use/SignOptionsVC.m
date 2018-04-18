//
//  SignOptionsVC.m
//  HN_Vendor
//
//  Created by tomwey on 16/03/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "SignOptionsVC.h"
#import "Defines.h"

@interface SignOptionsVC () <UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) AWTableViewDataSource *dataSource;

@end

@implementation SignOptionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"选择指令/变更";
    
    [self addLeftItemWithView:HNCloseButton(34, self, @selector(close))];
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openDetail:)
                                                 name:@"kOpenSignItemDetailNotification"
                                               object:nil];
}

- (void)openDetail:(NSNotification *)noti
{
    id item = noti.object;
    
    UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:@"DeclareFormVC" params:item];
    vc.userData = @"1";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadData
{
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": @"供应商可发起签证的变更列表APP",
              @"param1": self.params[@"contract_id"],
              @"param2": @"40",
              @"param3": @"0"
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if (error) {
        [self.tableView showErrorOrEmptyMessage:error.domain reloadDelegate:nil];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.tableView showErrorOrEmptyMessage:@"无数据显示" reloadDelegate:nil];
            self.dataSource.dataSource = nil;
        } else {
//
            id selectedItem = self.params[@"item"];
            if ( !selectedItem ) {
                self.dataSource.dataSource = result[@"data"];
            } else {
                NSMutableArray *temp = [NSMutableArray array];
                for (id item in result[@"data"]) {
                    NSMutableDictionary *dict = [item mutableCopy];
                    dict[@"selected"] = @([[item[@"supchangeid"] description] isEqualToString:selectedItem[@"value"]]);
                    [temp addObject:dict];
                }
                self.dataSource.dataSource = temp;
            }
            
        }
        
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.dataSource.dataSource[indexPath.row];
    id selectedItem = self.params[@"item"];
    
    if ( [[item[@"supchangeid"] description] isEqualToString:selectedItem[@"value"]]) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    void (^selectCallback)(id data) = self.params[@"selectCallback"];
    
    if (selectCallback) {
        selectCallback(item);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self close];
    });
//    [self close];
}

- (void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableView *)tableView
{
    if ( !_tableView ) {
        _tableView = [[UITableView alloc] initWithFrame:self.contentView.bounds
                                                  style:UITableViewStylePlain];
        [self.contentView addSubview:_tableView];
        
        _tableView.dataSource = self.dataSource;
        _tableView.delegate   = self;
        _tableView.rowHeight = 94;
        
        [_tableView removeBlankCells];
    }
    return _tableView;
}

- (AWTableViewDataSource *)dataSource
{
    if ( !_dataSource ) {
        _dataSource = AWTableViewDataSourceCreate(nil, @"SignOptionCell", @"cell.id");
    }
    return _dataSource;
}

@end
