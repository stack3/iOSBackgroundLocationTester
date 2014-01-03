//
//  STSettings.m
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import "STSettings.h"

@implementation STSettings

+ (instancetype)sharedSettings
{
    static dispatch_once_t onceToken;
    static STSettings *instance = nil;
    
    dispatch_once(&onceToken, ^{
        instance = [[STSettings alloc] init];
        [instance load];
    });
    
    return instance;
}

- (void)save
{
    _lastUpdatedAt = [NSDate date];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithInteger:_locationServiceType] forKey:@"locationServiceType"];
    [ud setObject:[NSNumber numberWithDouble:_distanceFilter] forKey:@"distanceFilter"];
    [ud setObject:[NSNumber numberWithDouble:_desiredAccuracy] forKey:@"desiredAccuracy"];
    [ud setObject:[NSNumber numberWithInteger:_activityType] forKey:@"activityType"];
    [ud setObject:_lastUpdatedAt forKey:@"lastUpdatedAt"];
    [ud synchronize];
}

- (void)load
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    if ([ud objectForKey:@"locationServiceType"] != nil) {
        _locationServiceType = (STLocationServiceType)[ud integerForKey:@"locationServiceType"];
    } else {
        _locationServiceType = STLocationServiceTypeStandard;
    }
    
    if ([ud objectForKey:@"distanceFilter"] != nil) {
        _distanceFilter = [ud doubleForKey:@"distanceFilter"];
    } else {
        _distanceFilter = kCLDistanceFilterNone;
    }
    
    if ([ud objectForKey:@"distanceFilter"] != nil) {
        _desiredAccuracy = [ud doubleForKey:@"desiredAccuracy"];
    } else {
        _desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    if ([ud objectForKey:@"activityType"] != nil) {
        _activityType = [ud integerForKey:@"activityType"];
    } else {
        _activityType = CLActivityTypeOther;
    }

    if ([ud objectForKey:@"lastUpdatedAt"] != nil) {
        _lastUpdatedAt = [ud objectForKey:@"lastUpdatedAt"];
    } else {
        _lastUpdatedAt = nil;
    }
}

- (void)reset
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [ud dictionaryRepresentation];
    for (id key in dict) {
        [ud removeObjectForKey:key];
    }
    [ud synchronize];
    
    [self load];
}

@end
