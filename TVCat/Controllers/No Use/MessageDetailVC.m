//
//  MessageDetailVC.m
//  HN_Vendor
//
//  Created by tomwey on 21/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "MessageDetailVC.h"
#import "Defines.h"

@interface MessageDetailVC () <UIWebViewDelegate>

@end

@implementation MessageDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentView.backgroundColor = AWColorFromRGB(247, 247, 247);
    
    self.navBar.title = @"消息";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:webView];
    
    [webView removeGrayBackground];
    
    webView.delegate = self;
    
    NSString *html = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"msg.tpl" ofType:nil]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil];
    
    NSString *content =
    [self.params[@"msgcontent"] stringByReplacingOccurrencesOfString:@"\\s+"
                                             withString:@"<br>"
                                                options:NSRegularExpressionSearch // 注意里要选择这个枚举项,这个是用来匹配正则表达式的
                                                  range:NSMakeRange (0, [self.params[@"msgcontent"] description].length)];
    
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    
    //[self.params[@"msgcontent"] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    html = [html stringByReplacingOccurrencesOfString:@"${title}" withString:self.params[@"msgtheme"]];
    html = [html stringByReplacingOccurrencesOfString:@"${content}" withString:content];
    
    if ( [self.params[@"msgtypeid"] integerValue] == 10 ||
         [self.params[@"msgtypeid"] integerValue] == 20) {
        NSString *more = @"<div class=\"more\">点击查看</div>";
        html = [html stringByReplacingOccurrencesOfString:@"${more}" withString:more];
    } else {
        html = [html stringByReplacingOccurrencesOfString:@"${more}" withString:@""];
    }
    
    [webView loadHTMLString:html baseURL:nil];
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    [self markViewMsg];
}

- (void)markViewMsg
{
    if ( [self.params[@"islook"] boolValue] == NO ) {
        id userInfo = [[UserService sharedInstance] currentUser];
        [[self apiServiceWithName:@"APIService"]
         POST:nil params:@{
                           @"dotype": @"GetData",
                           @"funname": @"供应商查看消息APP",
                           @"param1": [userInfo[@"supid"] ?: @"0" description],
                           @"param2": userInfo[@"loginname"] ?: @"",
                           @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
                           @"param4": [self.params[@"supmsgid"] ?: @"0" description],
                           } completion:^(id result, NSError *error) {
                               if (!error) {
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"kNeedLoadUnreadCountNotification" object:nil];
                                   [[NSNotificationCenter defaultCenter] postNotificationName:@"kHasNewMessageNotification"
                                                                                       object:nil];
                               }
                           }];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ( [[request.URL absoluteString] hasPrefix:@"hn-msg://"] ) {
        NSLog(@"%d", navigationType);
        
//        contractid = 2192676;
//        contractname = "\U201c\U5408\U80fd.\U73cd\U5b9d\U9526\U57ce\U9879\U76ee\U4e00\U671f\U201d\U300a\U5efa\U8bbe\U5de5\U7a0b\U65bd\U5de5\U5408\U540c\U300b\U8865\U5145\U534f\U8bae";
//        islook = 1;
//        memo = NULL;
//        msgcolor = "#67ABE5";
//        msgcontent = NULL;
//        msgobjectid = 82;
//        msgtheme = "\U60a8\U6709\U4e00\U7b14\U6307\U4ee4\U5df2\U5ba1\U6279\U5b8c\U6210";
//        msgtypeid = 10;
//        msgtypename = "\U53d8\U66f4\U5ba1\U6279";
//        "project_id" = 1291426;
//        "project_name" = "\U73cd\U5b9d\U9526\U57ce\U4e00\U671f";
//        supmsgid = 4272;
//        validbegindate = "2018-01-10T00:00:00+08:00";
        
//        供应商查询变更指令详情APP
        if ( [self.params[@"msgtypeid"] integerValue] == 10 ||
             [self.params[@"msgtypeid"] integerValue] == 20 ) {
            [self loadData];
        }
        
        return NO;
    }
    return YES;
}

- (void)loadData
{
    NSString *funname = nil;
    if ( [self.params[@"msgtypeid"] integerValue] == 10 ) {
        funname = @"供应商查询变更指令详情APP";
    } else if ( [self.params[@"msgtypeid"] integerValue] == 20 ) {
        funname = @"供应商变更签证明细APP";
    }
    
    if ( !funname ) {
        return;
    }
    
    [HNProgressHUDHelper showHUDAddedTo:self.contentView animated:YES];
    
    __weak typeof(self) me = self;
    
    id userInfo = [[UserService sharedInstance] currentUser];
    
    [[self apiServiceWithName:@"APIService"]
     POST:nil
     params:@{
              @"dotype": @"GetData",
              @"funname": funname,
              @"param1": [userInfo[@"supid"] ?: @"0" description],
              @"param2": [userInfo[@"loginname"] ?: @"" description],
              @"param3": [userInfo[@"symbolkeyid"] ?: @"0" description],
              @"param4": [self.params[@"msgobjectid"] ?: @"0" description],
              } completion:^(id result, NSError *error) {
                  [me handleResult:result error:error];
              }];
}

- (void)handleResult:(id)result error:(NSError *)error
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
    
    if ( error ) {
        [self.contentView showHUDWithText:@"加载基础数据出错" succeed:NO];
    } else {
        if ( [result[@"rowcount"] integerValue] == 0 ) {
            [self.contentView showHUDWithText:@"未找到变更数据" succeed:NO];
        } else {
            id item = [result[@"data"] firstObject];
            
            NSString *pageName = nil;
            if ( [self.params[@"msgtypeid"] integerValue] == 10 ) {
                pageName = @"DeclareFormVC";
            } else if ( [self.params[@"msgtypeid"] integerValue] == 20 ) {
                pageName = @"SignFormVC";
            }
            
            if (pageName) {
                UIViewController *vc = [[AWMediator sharedInstance] openVCWithName:pageName
                                                                            params:item];
                [self presentViewController:vc animated:YES completion:nil];
            }
            
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [HNProgressHUDHelper hideHUDForView:self.contentView animated:YES];
}

@end
