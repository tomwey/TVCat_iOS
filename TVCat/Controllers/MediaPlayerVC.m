//
//  MediaPlayerVC.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "MediaPlayerVC.h"
#import "Defines.h"

@interface MediaPlayerVC ()

@end

@implementation MediaPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBar.title = @"开始播放";
    
    [[self apiServiceWithName:@"APIService"]
     GET:@"media/player"
     params:@{
              @"url": self.params[@"url"] ?: @"",
              @"token": @"",
              } completion:^(id result, id rawData, NSError *error) {
                  NSLog(@"result: %@", result);
              }];
}

@end
