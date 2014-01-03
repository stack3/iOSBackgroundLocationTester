//
//  NSDate+ST.m
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import "NSDate+ST.h"

@implementation NSDate (ST)

- (NSString *)st_formatDateTime;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd HH:mm:ss"];
    return [formatter stringFromDate:self];
}

@end
