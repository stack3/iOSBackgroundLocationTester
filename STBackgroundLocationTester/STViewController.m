//
//  STViewController.m
//  STBackgroundLocationTester
//
//  Created by EIMEI on 2014/01/02.
//  Copyright (c) 2014年 stack3. All rights reserved.
//

#import "STViewController.h"
#import <MapKit/MapKit.h>
#import "STSettingsViewController.h"
#import "STSettings.h"
#import "STLogCell.h"
#import "NSDate+ST.h"

#define _STCellId @"Cell"
#define _STCellForHeighId @"CellForHeight"

@interface STViewController () <CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
/** copyで始めるとリンクエラーになってしまうので、ちょっとまどろっこしい名前に */
@property (weak, nonatomic) IBOutlet UIButton *logsToCopyButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *locationLogs;
@property (strong, nonatomic) NSMutableArray *logs;
@property (strong, nonatomic) STLogCell *cellForHeight;
@property (nonatomic) BOOL isUpdatingLocation;
@property (nonatomic) float batteryLevelWhenStarted;
@property (strong, nonatomic) MKPointAnnotation *lastAnnotation;
@property (strong, nonatomic) NSDate *viewDisappearedAt;

@end

@implementation STViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationLogs = [NSMutableArray arrayWithCapacity:100];
    _logs = [NSMutableArray arrayWithCapacity:100];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _locationManager.delegate = self;
    
    _mapView.delegate = self;
    
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([STLogCell class]) bundle:nil];
    [_tableView registerNib:nib forCellReuseIdentifier:_STCellId];
    [_tableView registerNib:nib forCellReuseIdentifier:_STCellForHeighId];
    
    _cellForHeight = [_tableView dequeueReusableCellWithIdentifier:_STCellForHeighId];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    _noticeLabel.hidden = YES;
    _noticeLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    _noticeLabel.textColor = [UIColor whiteColor];
    
    UIDevice *device = [UIDevice currentDevice];
    _messageLabel.text = [NSString stringWithFormat:@"Battery Level: %.1f", device.batteryLevel];
    
    [_startButton addTarget:self action:@selector(didTapStartButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(didTapSettingsButton)];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (_isUpdatingLocation) {
        STSettings *settings = [STSettings sharedSettings];
        if ((settings.lastUpdatedAt != nil) &&
            (settings.lastUpdatedAt.timeIntervalSince1970 > _viewDisappearedAt.timeIntervalSince1970)) {
            [self stop];
            [self start];
            [self showNoticeMessage:@"Restarted because settings was changed."];
        }
    }
}
            
- (void)viewDidDisappear:(BOOL)animated
{
    _viewDisappearedAt = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)start
{
    STSettings *settings = [STSettings sharedSettings];

    _locationManager.distanceFilter = settings.distanceFilter;
    _locationManager.desiredAccuracy = settings.desiredAccuracy;
    _locationManager.activityType = settings.activityType;
    
    if (settings.locationServiceType & STLocationServiceTypeStandard) {
        [_locationManager startUpdatingLocation];
    }
    if (settings.locationServiceType & STLocationServiceTypeSignificant) {
        [_locationManager startMonitoringSignificantLocationChanges];
    }
    
    [_locationLogs removeAllObjects];
    [_logs removeAllObjects];
    [_tableView reloadData];
    [_mapView removeAnnotations:_mapView.annotations];
    
    UIDevice *device = [UIDevice currentDevice];
    _batteryLevelWhenStarted = device.batteryLevel;
    
    [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
    [_logsToCopyButton addTarget:self action:@selector(didTapCopyLogsButton) forControlEvents:UIControlEventTouchUpInside];

    _isUpdatingLocation = YES;
}

- (void)stop
{
    [_locationManager stopMonitoringSignificantLocationChanges];
    [_locationManager stopUpdatingLocation];
    
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    
    _isUpdatingLocation = NO;
}

- (void)didTapSettingsButton
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *con = [sb instantiateViewControllerWithIdentifier:@"STSettingsViewController"];
    [self.navigationController pushViewController:con animated:YES];
}

- (void)didTapStartButton
{
    if (_isUpdatingLocation) {
        [self stop];
    } else {
        [self start];
    }
}

- (void)didTapCopyLogsButton
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    NSMutableString *string = [NSMutableString stringWithCapacity:1000];
    for (NSString *log in _logs) {
        [string appendString:log];
        [string appendString:@"----------\n"];
    }
    [pb setString:string];
}

- (void)appendLog:(NSString *)text
{
    NSMutableString *logString = [NSMutableString stringWithCapacity:100];
    [logString appendString:[[NSDate date] st_formatDateTime]];
    [logString appendString:@" "];
    [logString appendString:text];
    [logString appendString:@"\n"];
    [_logs addObject:logString];
    [_tableView reloadData];
    
    if (_batteryLevelWhenStarted >= 0) {
        UIDevice *device = [UIDevice currentDevice];
        _messageLabel.text = [NSString stringWithFormat:@"Battery Level Start: %.1f Current: %.1f", _batteryLevelWhenStarted, device.batteryLevel];
    } else {
        _messageLabel.text = @"Battery Unknown";
    }
}

- (void)showNoticeMessage:(NSString *)message
{
    _noticeLabel.text = message;
    _noticeLabel.hidden = NO;
    
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _noticeLabel.hidden = YES;
    });
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.lastObject;
    [_locationLogs addObject:location];
    
    NSString *stringState = [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground ? @"BG" : @"FG";
    NSInteger number = _locationLogs.count;
    NSMutableString *log = [NSMutableString stringWithCapacity:100];
    [log appendFormat:@"[%ld] %@\n", (long)number, stringState];
    [log appendFormat:@"Location: %f, %f\n", location.coordinate.latitude, location.coordinate.longitude];
    [log appendFormat:@"Ttimestamp: %@\n", [location.timestamp st_formatDateTime]];
    [log appendFormat:@"Accuracy: %f, %f", location.horizontalAccuracy, location.verticalAccuracy];
    [self appendLog:log];
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500);
    _mapView.region = region;
    //
    // Remove lastAnnotation temporary to change the color.
    //
    MKPointAnnotation *previousAnnotation = nil;
    if (_lastAnnotation) {
        [_mapView removeAnnotation:_lastAnnotation];
        previousAnnotation = _lastAnnotation;
    }
    //
    // Add annotation for current location.
    // The color will be green.
    //
    _lastAnnotation = [[MKPointAnnotation alloc] init];
    _lastAnnotation.coordinate = location.coordinate;
    _lastAnnotation.title = [NSString stringWithFormat:@"%ld", (long)number];
    [_mapView addAnnotation:_lastAnnotation];
    
    if (previousAnnotation) {
        // The color will be red.
        [_mapView addAnnotation:previousAnnotation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self appendLog:[NSString stringWithFormat:@"Error %@", error.localizedDescription]];
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    [self appendLog:@"Paused location updates."];
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    [self appendLog:@"Resume location updates."];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _logs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    STLogCell *cell = [_tableView dequeueReusableCellWithIdentifier:_STCellId forIndexPath:indexPath];
    cell.logLabel.text = [_logs objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cellForHeight.logLabel.text = [_logs objectAtIndex:indexPath.row];
    [_cellForHeight.contentView setNeedsLayout];
    [_cellForHeight.contentView layoutIfNeeded];
    CGSize size = [_cellForHeight.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *reuseId = @"Pin";
    MKPinAnnotationView *pin = (MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:reuseId];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
        pin.canShowCallout = YES;
    }
    
    if (annotation == _lastAnnotation) {
        pin.pinColor = MKPinAnnotationColorGreen;
    } else {
        pin.pinColor = MKPinAnnotationColorRed;
    }
    
    return pin;
}

@end
