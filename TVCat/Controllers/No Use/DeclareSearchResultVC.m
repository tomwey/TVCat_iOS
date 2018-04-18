//
//  DeclareSearchResultVC.m
//  HN_Vendor
//
//  Created by tomwey on 21/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "DeclareSearchResultVC.h"
#import "Defines.h"

@interface DeclareSearchResultVC ()

@property (nonatomic, strong) DeclareListView *listView;

@end

@implementation DeclareSearchResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"搜索结果";
    
//    NSLog(@"%@", self.params);
    
    NSString *state = @"-1";
    if ( self.params[@"state"] ) {
        if ( self.params[@"state"][@"value"] ) {
            state = [self.params[@"state"][@"value"] description];
        }
    }
    
    NSString *beginTime = @"";
    NSString *endTime = @"";
    if ( self.params[@"publish_date.1"] ) {
        beginTime = HNDateFromObject(self.params[@"publish_date.1"], @" ");
    }
    
    if ( self.params[@"publish_date.2"] ) {
        endTime = HNDateFromObject(self.params[@"publish_date.2"], @" ");
    }
    
    NSString *projectID = @"0";
    if ( self.params[@"project"] ) {
        projectID = [self.params[@"project"][@"value"] description];
    }
    
    __weak typeof(self) me = self;
    self.listView.userData = @{
                               @"keyword" : self.params[@"keyword"] ?: @"",
                               @"state": state,
                               @"begin_time": beginTime,
                               @"end_time": endTime,
                               @"owner": me,
                               @"project_id": projectID,
                               @"funname": self.userData[@"funname"] ?: @""
                               };
    
    [self.listView startLoading:^(BOOL succeed, NSError *error) {
        
    }];
}

- (DeclareListView *)listView
{
    if ( !_listView ) {
        _listView = [[DeclareListView alloc] init];
        [self.contentView addSubview:_listView];
        
        _listView.frame = self.contentView.bounds;
    }
    return _listView;
}

@end
