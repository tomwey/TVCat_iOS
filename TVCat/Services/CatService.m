//
//  StoreService.m
//  HN_ERP
//
//  Created by tomwey on 1/20/17.
//  Copyright © 2017 tomwey. All rights reserved.
//

#import "CatService.h"
#import "Defines.h"
#import "UserService.h"
#import "FCUUID.h"

@interface CatService ()

@property (nonatomic, copy) NSString *currentSessionID;

//@property (nonatomic, strong) id appConfig;

@end

@implementation CatService

+ (instancetype)sharedInstance
{
    static CatService *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CatService alloc] init];
    });
    return instance;
}

- (NSString *)getNetworkType
{
    AFNetworkReachabilityStatus status = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    switch (status) {
        case AFNetworkReachabilityStatusUnknown:
            return @"unknown";
        case AFNetworkReachabilityStatusReachableViaWWAN:
            return @"4g";
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return @"wifi";
            
        default:
            return @"";
    }
}

- (void)sessionBeginForType:(NSInteger)type completion:(void (^)(id result, NSError *error))completion
{
    
    if (self.currentSessionID.length > 0) return;
    
    [[AWLocationManager sharedInstance] startUpdatingLocation:^(CLLocation *location, NSError *error) {
        NSString *loc = @"";
        if ( !error ) {
            loc = [NSString stringWithFormat:@"%f,%f", location.coordinate.longitude,
                   location.coordinate.latitude];
        }
        
        [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
            if ( user[@"token"] ) {
                [[self apiServiceWithName:@"APIService"]
                 POST:@"user/session/begin"
                 params:@{
                          @"token": user[@"token"] ?: @"",
                          @"type": [@(type) description],
                          @"loc": loc,
                          @"network": [self getNetworkType],
                          @"version": AWAppVersion(),
                          @"uuid": [FCUUID uuidForDevice],
                          @"os": @"iOS",
                          @"osv": AWOSVersionString(),
                          @"model": AWDeviceName(),
                          @"screen": AWDeviceSizeString(),
                          @"uname": [[UIDevice currentDevice] name],
                          @"lang_code": AWDeviceCountryLangCode()
                          }
                 completion:^(id result, id rawData, NSError *error) {
                     if ( completion ) {
                         if ( error ) {
                             completion(nil, error);
                         } else {
                             completion(result, nil);
                             
                             // 保存全局配置
                             [[NSUserDefaults standardUserDefaults] setObject:result[@"config"] forKey:@"app.config"];
                             [[NSUserDefaults standardUserDefaults] synchronize];
                         }
                     }
                     
                     self.currentSessionID = [result[@"session_id"] description];
                 }];
            } else {
                if ( completion ) {
                    completion(nil, [NSError errorWithDomain:@"用户未注册"
                                                       code:-1
                                                   userInfo:nil]);
                }
            }
        }];
    }];
}

- (void)sessionEnd:(void (^)(BOOL succeed, NSError *error))completion
{
    if (self.currentSessionID.length == 0) return;
    
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             POST:@"user/session/end"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      @"session_id": self.currentSessionID,
                      }
             completion:^(id result, id rawData, NSError *error) {
                 if ( completion ) {
                     if ( error ) {
                         completion(NO, error);
                     } else {
                         completion(YES, nil);
                     }
                 }
                 
                 if ( !error ) {
                     self.currentSessionID = nil;
                 }
             }];
        } else {
            if ( completion ) {
                completion(NO, [NSError errorWithDomain:@"用户未注册"
                                                   code:-1
                                               userInfo:nil]);
            }
        }
    }];
}

- (void)fetchPlayerForURL:(NSString *)url
                     mpid:(id)mpid
               completion:(void (^)(id result, NSError *error))completion
{
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             GET:@"media/player"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      @"url": url,
                      @"mp_id": [mpid description],
                      }
             completion:^(id result, id rawData, NSError *error) {
                 if ( completion ) {
                     if ( error ) {
                         completion(nil, error);
                     } else {
                         completion(result, nil);
                     }
                 }
             }];
        } else {
            if ( completion ) {
                completion(nil, [NSError errorWithDomain:@"用户未注册"
                                                   code:-1
                                               userInfo:nil]);
            }
        }
    }];
}

- (void)uploadPlayProgress:(NSTimeInterval)progress forUrl:(NSString *)url
{
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             POST:@"media/play/progress"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      @"url": url ?: @"",
                      @"progress": [@(progress) description],
                      }
             completion:^(id result, id rawData, NSError *error) {
                 
             }];
        } else {
            
        }
    }];
}

- (void)fetchUserProfile:(void (^)(id result, NSError *error))completion
{
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             GET:@"user/me"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      }
             completion:^(id result, id rawData, NSError *error) {
                 if ( completion ) {
                     if ( error ) {
                         completion(nil, error);
                     } else {
                         completion(result, nil);
                     }
                 }
             }];
        } else {
            if ( completion ) {
                completion(nil, [NSError errorWithDomain:@"用户未注册"
                                                    code:-1
                                                userInfo:nil]);
            }
        }
    }];
}

- (void)fetchAppConfig:(void (^)(id result, NSError *error))completion
{
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    if (self.appConfig) {
//        if ( completion ) {
//            completion(self.appConfig, nil);
//        }
//
//        return;
//    }
    
    [[self apiServiceWithName:@"APIService"]
     GET:@"app/config"
     params:nil
     completion:^(id result, id rawData, NSError *error) {
         if ( completion ) {
             if ( error ) {
                 completion(nil, error);
             } else {
                 completion(result, nil);
//                 self.appConfig = result;
                 
                 [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"app.config"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
             }
         }
     }];
}

- (id)appConfig
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"app.config"];
}

- (void)fetchVIPChargeList:(void (^)(id result, NSError *error))completion
{
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             GET:@"user/vip_charge_list"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      }
             completion:^(id result, id rawData, NSError *error) {
                 if ( completion ) {
                     if ( error ) {
                         completion(nil, error);
                     } else {
                         completion(result, nil);
                     }
                 }
             }];
        } else {
            if ( completion ) {
                completion(nil, [NSError errorWithDomain:@"用户未注册"
                                                    code:-1
                                                userInfo:nil]);
            }
        }
    }];
}

- (void)activeVIPCode:(NSString *)code completion:(void (^)(id result, NSError *error))completion
{
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             POST:@"user/vip/active"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      @"code": code
                      }
             completion:^(id result, id rawData, NSError *error) {
                 if ( completion ) {
                     if ( error ) {
                         completion(nil, error);
                     } else {
                         completion(result, nil);
                     }
                 }
             }];
        } else {
            if ( completion ) {
                completion(nil, [NSError errorWithDomain:@"用户未注册"
                                                    code:-1
                                                userInfo:nil]);
            }
        }
    }];
}

- (void)saveHistory:(NSDictionary *)params completion:(void (^)(id result, NSError *error))completion
{
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             POST:@"media/history/create"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      @"mp_id": params[@"mp_id"],
                      @"title": params[@"title"],
                      @"source_url": params[@"source_url"],
                      @"progress": params[@"progress"]
                      }
             completion:^(id result, id rawData, NSError *error) {
                 if ( completion ) {
                     if ( error ) {
                         completion(nil, error);
                     } else {
                         completion(result, nil);
                     }
                 }
             }];
        } else {
            if ( completion ) {
                completion(nil, [NSError errorWithDomain:@"用户未注册"
                                                    code:-1
                                                userInfo:nil]);
            }
        }
    }];
}

- (void)loadHistoriesForPage:(NSInteger)pageNum
                    pageSize:(NSInteger)pageSize
                  completion:(void (^)(id result, NSError *error))completion
{
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             GET:@"media/histories"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      @"page": @(pageNum),
                      @"size": @(pageSize),
                      }
             completion:^(id result, id rawData, NSError *error) {
                 if ( completion ) {
                     if ( error ) {
                         completion(nil, error);
                     } else {
                         completion(result, nil);
                     }
                 }
             }];
        } else {
            if ( completion ) {
                completion(nil, [NSError errorWithDomain:@"用户未注册"
                                                    code:-1
                                                userInfo:nil]);
            }
        }
    }];
}

@end
