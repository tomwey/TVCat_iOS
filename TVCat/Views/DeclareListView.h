//
//  DeclareListView.h
//  HN_Vendor
//
//  Created by tomwey on 20/12/2017.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeclareListView : UIView

- (void)startLoading:(void (^)(BOOL succeed, NSError *error))completion;

@end
