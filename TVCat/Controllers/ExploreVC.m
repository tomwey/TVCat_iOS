//
//  ExploreVC.m
//  TVCat
//
//  Created by tomwey on 18/04/2018.
//  Copyright © 2018 tomwey. All rights reserved.
//

#import "ExploreVC.h"
#import "Defines.h"

@interface ExploreVC ()

@end

@implementation ExploreVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ( self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) {
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现"
                                                        image:[UIImage imageNamed:@"tab_explore.png"]
                                                selectedImage:[UIImage imageNamed:@"tab_explore.png"]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navBar.title = @"发现";
    
    [self addLeftItemWithView:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
