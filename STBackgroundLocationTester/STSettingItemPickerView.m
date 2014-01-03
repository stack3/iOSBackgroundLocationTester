//
//  STSettingItemPickerView.m
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import "STSettingItemPickerView.h"

@interface STSettingItemPickerView () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation STSettingItemPickerView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        UINib *nib = [UINib nibWithNibName:NSStringFromClass([STSettingItemPickerView class]) bundle:nil];
        UIView *view = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
        view.frame = self.bounds;
        view.translatesAutoresizingMaskIntoConstraints = YES;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:view];

        _items = [NSMutableArray arrayWithCapacity:100];
        
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        
        _okButton.backgroundColor = [UIColor colorWithRed:102/255.0 green:153/255.0 blue:255/255.0 alpha:1.0];
        _okButton.tintColor = [UIColor whiteColor];
        [_okButton addTarget:self action:@selector(didTapOKButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

- (void)setItems:(NSArray *)items
{
    _items = items;
    [_pickerView reloadAllComponents];
}

- (void)setSelectedIntValue:(NSInteger)selectedIntValue
{
    for (int i = 0; i < _items.count; i++) {
        STSettingItem *item = [_items objectAtIndex:i];
        if (item.intValue == selectedIntValue) {
            [_pickerView selectRow:i inComponent:0 animated:NO];
            return;
        }
    }

    [_pickerView selectRow:0 inComponent:0 animated:NO];
}

- (void)showWithAnimatedFor:(STSettingItemPickerFor)pickerFor
{
    _pickerFor = pickerFor;
    
    self.alpha = 0;
    self.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hideWithAnimated
{
    self.alpha = 1.0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

- (void)didTapOKButton
{
    [self hideWithAnimated];
    
    NSInteger row = [_pickerView selectedRowInComponent:0];
    STSettingItem *item = [_items objectAtIndex:row];
    [_delegate settingItemPickerView:self didDismissWithItem:item];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _items.count;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    STSettingItem *item = [_items objectAtIndex:row];
    return item.title;
}

@end
