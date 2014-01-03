//
//  STSettingItem.m
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import "STSettingItem.h"

@implementation STSettingItem

+ (instancetype)settingItemWithTitle:(NSString *)title intValue:(NSInteger)intValue;
{
    STSettingItem *item = [[STSettingItem alloc] init];
    item.title = title;
    item.intValue = intValue;
    return item;
}

+ (instancetype)settingItemFromArray:(NSArray *)items intValue:(NSInteger)intValue
{
    for (STSettingItem *item in items) {
        if (item.intValue == intValue) {
            return item;
        }
    }
    return nil;
}

@end
