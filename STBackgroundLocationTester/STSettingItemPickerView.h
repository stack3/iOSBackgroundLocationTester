//
//  STSettingItemPickerView.h
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSettingItem.h"

typedef enum {
    STSettingItemPickerForDistanceFilter,
    STSettingItemPickerForDesiredAccuracy,
    STSettingItemPickerForActivityType
} STSettingItemPickerFor;

@protocol STSettingItemPickerViewDelegate;

@interface STSettingItemPickerView : UIView

@property (nonatomic, readonly) STSettingItemPickerFor pickerFor;
@property (strong, nonatomic) NSArray *items;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) id<STSettingItemPickerViewDelegate> delegate;

- (void)setTitle:(NSString *)title;
- (void)setSelectedIntValue:(NSInteger)selectedIntValue;
- (void)showWithAnimatedFor:(STSettingItemPickerFor)pickerFor;
- (void)hideWithAnimated;

@end

@protocol STSettingItemPickerViewDelegate <NSObject>

- (void)settingItemPickerView:(STSettingItemPickerView *)sender didDismissWithItem:(STSettingItem *)item;

@end