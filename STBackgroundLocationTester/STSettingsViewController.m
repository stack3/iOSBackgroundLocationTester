//
//  STSettingsViewController.m
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import "STSettingsViewController.h"
#import "STSettings.h"
#import "STSettingItemPickerView.h"

@interface STSettingsViewController () <STSettingItemPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *locationServiceControl;
@property (weak, nonatomic) IBOutlet UIButton *distanceFilterButton;
@property (weak, nonatomic) IBOutlet UIButton *desiredAccuracyButton;
@property (weak, nonatomic) IBOutlet UIButton *activityTypeButton;
@property (weak, nonatomic) IBOutlet STSettingItemPickerView *itemPickerView;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (strong, nonatomic) NSMutableArray *distanceFilterItems;
@property (strong, nonatomic) NSMutableArray *desiredAccuracyItems;
@property (strong, nonatomic) NSMutableArray *activityTypeItems;

@end

@implementation STSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settings";
    
    _distanceFilterItems = [NSMutableArray arrayWithCapacity:10];
    [_distanceFilterItems addObject:[STSettingItem settingItemWithTitle:@"None" intValue:kCLDistanceFilterNone]];
    [_distanceFilterItems addObject:[STSettingItem settingItemWithTitle:@"100m" intValue:100]];
    [_distanceFilterItems addObject:[STSettingItem settingItemWithTitle:@"500m" intValue:500]];
    [_distanceFilterItems addObject:[STSettingItem settingItemWithTitle:@"1km" intValue:1*1000]];
    [_distanceFilterItems addObject:[STSettingItem settingItemWithTitle:@"3km" intValue:3*1000]];
    [_distanceFilterItems addObject:[STSettingItem settingItemWithTitle:@"5km" intValue:5*1000]];
    
    _desiredAccuracyItems = [NSMutableArray arrayWithCapacity:10];
    [_desiredAccuracyItems addObject:[STSettingItem settingItemWithTitle:@"Best for Navigation" intValue:kCLLocationAccuracyBestForNavigation]];
    [_desiredAccuracyItems addObject:[STSettingItem settingItemWithTitle:@"Best" intValue:kCLLocationAccuracyBest]];
    [_desiredAccuracyItems addObject:[STSettingItem settingItemWithTitle:@"Nearest 10 meters" intValue:kCLLocationAccuracyNearestTenMeters]];
    [_desiredAccuracyItems addObject:[STSettingItem settingItemWithTitle:@"100 meters" intValue:kCLLocationAccuracyHundredMeters]];
    [_desiredAccuracyItems addObject:[STSettingItem settingItemWithTitle:@"1 kilometer" intValue:kCLLocationAccuracyKilometer]];
    [_desiredAccuracyItems addObject:[STSettingItem settingItemWithTitle:@"3 kilometers" intValue:kCLLocationAccuracyThreeKilometers]];
    
    _activityTypeItems = [NSMutableArray arrayWithCapacity:10];
    [_activityTypeItems addObject:[STSettingItem settingItemWithTitle:@"Other" intValue:CLActivityTypeOther]];
    [_activityTypeItems addObject:[STSettingItem settingItemWithTitle:@"Automotive Navigation" intValue:CLActivityTypeAutomotiveNavigation]];
    [_activityTypeItems addObject:[STSettingItem settingItemWithTitle:@"Fitness" intValue:CLActivityTypeFitness]];
    [_activityTypeItems addObject:[STSettingItem settingItemWithTitle:@"Other Navigation" intValue:CLActivityTypeOtherNavigation]];
    
    [_locationServiceControl addTarget:self action:@selector(didChangeLocationService) forControlEvents:UIControlEventValueChanged];
    [_distanceFilterButton addTarget:self action:@selector(didTapDistanceFilterButton) forControlEvents:UIControlEventTouchUpInside];
    [_desiredAccuracyButton addTarget:self action:@selector(didTapDesiredAccuracyButton) forControlEvents:UIControlEventTouchUpInside];
    [_activityTypeButton addTarget:self action:@selector(didTapActivityTypeButton) forControlEvents:UIControlEventTouchUpInside];
    
    _itemPickerView.hidden = YES;
    _itemPickerView.delegate = self;
    
    [_resetButton addTarget:self action:@selector(didTapResetButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateSubviews
{
    STSettings *settings = [STSettings sharedSettings];
    
    if (settings.locationServiceType & STLocationServiceTypeStandard) {
        _locationServiceControl.selectedSegmentIndex = 0;
    } else if (settings.locationServiceType & STLocationServiceTypeSignificant) {
        _locationServiceControl.selectedSegmentIndex = 1;
    } else if (settings.locationServiceType & STLocationServiceTypeBoth) {
        _locationServiceControl.selectedSegmentIndex = 2;
    } else {
        _locationServiceControl.selectedSegmentIndex = 0;
    }
    
    STSettingItem *settingItem;
    settingItem = [STSettingItem settingItemFromArray:_distanceFilterItems intValue:settings.distanceFilter];
    if (settingItem) {
        [_distanceFilterButton setTitle:settingItem.title forState:UIControlStateNormal];
    }
    
    settingItem = [STSettingItem settingItemFromArray:_desiredAccuracyItems intValue:settings.desiredAccuracy];
    if (settingItem) {
        [_desiredAccuracyButton setTitle:settingItem.title forState:UIControlStateNormal];
    }
    
    settingItem = [STSettingItem settingItemFromArray:_activityTypeItems intValue:settings.activityType];
    if (settingItem) {
        [_activityTypeButton setTitle:settingItem.title forState:UIControlStateNormal];
    }
}

- (void)didChangeLocationService
{
    STSettings *settings = [STSettings sharedSettings];
    if (_locationServiceControl.selectedSegmentIndex == 0) {
        settings.locationServiceType = STLocationServiceTypeStandard;
    } else if (_locationServiceControl.selectedSegmentIndex == 1) {
        settings.locationServiceType = STLocationServiceTypeSignificant;
    } else {
        settings.locationServiceType = STLocationServiceTypeBoth;
    }
    [settings save];
}

- (void)didTapDistanceFilterButton
{
    STSettings *settings = [STSettings sharedSettings];
    
    _itemPickerView.items = _distanceFilterItems;
    
    [_itemPickerView setTitle:@"Distance Filter"];
    [_itemPickerView setSelectedIntValue:settings.distanceFilter];
    [_itemPickerView showWithAnimatedFor:STSettingItemPickerForDistanceFilter];
}

- (void)didTapDesiredAccuracyButton
{
    STSettings *settings = [STSettings sharedSettings];
    
    _itemPickerView.items = _desiredAccuracyItems;
    
    [_itemPickerView setTitle:@"Desired Accuracy"];
    [_itemPickerView setSelectedIntValue:settings.desiredAccuracy];
    [_itemPickerView showWithAnimatedFor:STSettingItemPickerForDesiredAccuracy];
}

- (void)didTapActivityTypeButton
{
    STSettings *settings = [STSettings sharedSettings];
    
    _itemPickerView.items = _activityTypeItems;
    
    [_itemPickerView setTitle:@"Activity Type"];
    [_itemPickerView setSelectedIntValue:settings.activityType];
    [_itemPickerView showWithAnimatedFor:STSettingItemPickerForActivityType];
}

- (void)didTapResetButton
{
    STSettings *settings = [STSettings sharedSettings];
    [settings reset];
    
    [self updateSubviews];
}

#pragma mark - STSettingItemPickerViewDelegate

- (void)settingItemPickerView:(STSettingItemPickerView *)sender didDismissWithItem:(STSettingItem *)item
{
    STSettings *settings = [STSettings sharedSettings];
    if (sender.pickerFor == STSettingItemPickerForDistanceFilter) {
        settings.distanceFilter = item.intValue;
        [_distanceFilterButton setTitle:item.title forState:UIControlStateNormal];
    } else if (sender.pickerFor == STSettingItemPickerForDesiredAccuracy) {
        settings.desiredAccuracy = item.intValue;
        [_desiredAccuracyButton setTitle:item.title forState:UIControlStateNormal];
    } else if (sender.pickerFor == STSettingItemPickerForActivityType) {
        settings.activityType = item.intValue;
        [_activityTypeButton setTitle:item.title forState:UIControlStateNormal];
    }
    [settings save];
}

@end
