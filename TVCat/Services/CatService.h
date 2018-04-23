//
//  StoreService.h
//  HN_ERP
//
//  Created by tomwey on 1/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SessionType) {
    SessionTypeLaunch = 1,
    SessionTypeResume = 2
};

@interface CatService : NSObject

+ (instancetype)sharedInstance;

- (void)sessionBeginForType:(NSInteger)type completion:(void (^)(id result, NSError *error))completion;

- (void)sessionEnd:(void (^)(BOOL succeed, NSError *error))completion;

- (void)fetchPlayerForURL:(NSString *)url
                     mpid:(id)mpid
               completion:(void (^)(id result, NSError *error))completion;
- (void)fetchUserProfile:(void (^)(id result, NSError *error))completion;

//- (void)checkVersion:(void (^)(id result, NSError *error))completion;

- (void)fetchAppConfig:(void (^)(id result, NSError *error))completion;

- (void)fetchVIPChargeList:(void (^)(id result, NSError *error))completion;

- (void)activeVIPCode:(NSString *)code completion:(void (^)(id result, NSError *error))completion;

- (void)saveHistory:(NSDictionary *)params completion:(void (^)(id result, NSError *error))completion;

- (void)loadHistoriesForPage:(NSInteger)pageNum
                    pageSize:(NSInteger)pageSize
                  completion:(void (^)(id result, NSError *error))completion;

@property (nonatomic, strong, readonly) id appConfig;

@end
