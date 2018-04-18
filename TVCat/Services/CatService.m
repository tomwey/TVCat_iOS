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

@interface CatService ()

@property (nonatomic, copy) NSString *currentSessionID;

@property (nonatomic, strong) id appConfig;

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

- (void)sessionBeginForType:(NSInteger)type completion:(void (^)(BOOL succeed, NSError *error))completion
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
                          @"uuid": [[[UIDevice currentDevice] identifierForVendor] UUIDString],
                          @"os": [[UIDevice currentDevice] systemName],
                          @"osv": AWOSVersionString(),
                          @"model": AWDeviceName(),
                          @"screen": AWDeviceSizeString(),
                          @"uname": [[UIDevice currentDevice] name],
                          @"lang_code": AWDeviceCountryLangCode()
                          }
                 completion:^(id result, id rawData, NSError *error) {
                     if ( completion ) {
                         if ( error ) {
                             completion(NO, error);
                         } else {
                             completion(YES, nil);
                         }
                     }
                     
                     self.currentSessionID = [result[@"session_id"] description];
                 }];
            } else {
                if ( completion ) {
                    completion(NO, [NSError errorWithDomain:@"用户未注册"
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

- (void)fetchPlayerForURL:(NSString *)url completion:(void (^)(id result, NSError *error))completion
{
    [[UserService sharedInstance] loginUser:^(id user, NSError *error) {
        if ( user[@"token"] ) {
            [[self apiServiceWithName:@"APIService"]
             GET:@"media/player"
             params:@{
                      @"token": user[@"token"] ?: @"",
                      @"url": url,
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
    if (self.appConfig) {
        if ( completion ) {
            completion(self.appConfig, nil);
        }
        
        return;
    }
    
    [[self apiServiceWithName:@"APIService"]
     GET:@"app/config"
     params:nil
     completion:^(id result, id rawData, NSError *error) {
         if ( completion ) {
             if ( error ) {
                 completion(nil, error);
             } else {
                 completion(result, nil);
                 self.appConfig = result;
             }
         }
     }];
}

@end
