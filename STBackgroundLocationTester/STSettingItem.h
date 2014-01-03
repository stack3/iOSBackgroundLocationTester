//
//  STSettingItem.h
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STSettingItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (nonatomic) NSInteger intValue;

+ (instancetype)settingItemWithTitle:(NSString *)title intValue:(NSInteger)intValue;
+ (instancetype)settingItemFromArray:(NSArray *)items intValue:(NSInteger)intValue;

@end
