//
//  STSettings.h
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    STLocationServiceTypeStandard = 1,
    STLocationServiceTypeSignificant = 1 << 1,
    STLocationServiceTypeBoth = STLocationServiceTypeStandard|STLocationServiceTypeSignificant
} STLocationServiceType;

@interface STSettings : NSObject

@property (nonatomic) STLocationServiceType locationServiceType;
@property (nonatomic) CLLocationDistance distanceFilter;
@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) CLActivityType activityType;
@property (nonatomic, readonly) NSDate *lastUpdatedAt;

+ (instancetype)sharedSettings;
- (void)save;
- (void)load;
- (void)reset;

@end
