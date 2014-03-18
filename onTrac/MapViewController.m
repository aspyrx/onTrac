//
//  MapViewController.m
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import "MapViewController.h"
#import "Utils.h"
#import "Defines.h"
#import "GPX.h"
#import "XBCurlView.h"
#import "CrumbPath.h"
#import "CrumbPathView.h"
#import "TrackAnnotation.h"
#import "OnTracExtensions.h"
#import "SettingsViewController.h"
#import "TracksViewController.h"
#import "TrackDetailViewController.h"

// seconds, length of page curl animation
static CGFloat const kCurlAnimationDuration = 0.5;

// meters, min distance between location updates
static CGFloat const kMinDistance = 1.0;

// number of stats updates without location updates until current speed is assumed to be 0
static NSUInteger const kStatsUpdatesUntilCurrentSpeedReset = 5;
// number of stats updates without location update until recording stopped
static NSUInteger const kStatsUpdatesUntilRecordingStop = 300;

// seconds, time between accelerometer updates while stopped
static NSTimeInterval const kAccelerometerUpdateIntervalStopped = 0.2;
// number of samples from which to calculate standard deviation while stopped
static NSUInteger const kAccelMagnitudeSamplesStopped = 50;
// threshold which the standard deviation must pass to start recording
static CGFloat const kStandardDeviationStartThreshold = 0.1;
// number of samples which must remain above this threshold to start recording
static NSUInteger const kStandardDeviationSamplesAboveStartThreshold = 30;

// seconds, time between accelerometer updates while moving
static NSTimeInterval const kAccelerometerUpdateIntervalMoving = 0.5;
// number of samples from which to calculate standard deviation while moving
static NSUInteger const kAccelMagnitudeSamplesMoving = 600;
// number of samples from which to calculate standard deviation for checking whether walking
static NSUInteger const kAccelMagnitudeSamplesWalking = 20;
// threshold below which the standard deviation must fall to stop recording
static CGFloat const kStandardDeviationStopThreshold = 0.2;
// thershold which the standard deviation must pass to be considered walking
static CGFloat const kStandardDeviationWalkingThreshold = 0.25;
// number of samples which must remain above this threshold to be considered walking
static NSUInteger const kStandardDeviationSamplesAboveWalkingThreshold = 40;
// m/s, threshold below which the speed must fall to stop recording
static CGFloat const kCurrentSpeedStopThreshold = 0.05;

// seconds, stats update interval
static NSTimeInterval const kStatsUpdateInterval = 1.0;

// m/s, maximum not driving speed
static CGFloat const kSpeedMaxNotDriving = 8.0;

// accelerometer states
static NSUInteger const kAccelerometerMoving = 2;
static NSUInteger const kAccelerometerStopped = 1;
static NSUInteger const kAccelerometerOff = 0;

@interface MapViewController ()

@end

@implementation MapViewController {
    enum recording_state_t recordingState;
    BOOL isFollowing;
    BOOL isDriving;
    BOOL shouldUpdateStatsLabels;
    int numStatsUpdatesWithoutLocationUpdate;
    int numStandardDeviationSamplesAboveThreshold;
    double accelMagStdDev;
    double walkingStdDev;
    
    NSMutableDictionary *settings;
    NSMutableArray *accelMagnitudes;
    NSTimer *statsUpdateTimer;
    
    CLLocation *oldLocation;
    NSTimeInterval lastUpdateTime; // seconds
    NSTimeInterval timeMoving; // seconds
    NSTimeInterval timeStopped; // seconds
    NSTimeInterval totalTime; // seconds
    CGFloat totalDistance; // meters
    CGFloat averageSpeed; // m/s
    int numAverageSpeedSamples;
    CGFloat currentSpeed; // m/s
    double carbonEmissions; // kg
    double carbonAvoidance; // kg
    double caloriesBurned; // calories
    double emissionsPerMeter; // kg CO2 / passenger meter traveled
    
    NSString *distanceUnitText;
    NSString *speedUnitText;
    NSString *dataSuffix;
    NSString *dataUnitText;
    
    CrumbPath *crumbs;
    CrumbPathView *crumbView;
    GPXRoot *currentGPXRoot;
    GPXBounds *currentGPXBounds;
    GPXTrack *currentGPXTrack;
    GPXTrackSegment *currentGPXTrackSegment;
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // set navbar items
        self.title = @"onTrac";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(optionsButtonPressed:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tracks" style:UIBarButtonItemStyleBordered target:self action:@selector(tracksButtonPressed:)];
        
        // alloc and init location manager
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kMinDistance;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // alloc and init motion manager
        self.motionManager = [CMMotionManager new];
        
        // alloc and init view controllers
        self.tracksViewController = [[TracksViewController alloc] initWithStyle:UITableViewStylePlain];
        self.settingsNavigationController = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped]];
        
        // register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSelectedTracks:) name:kNotificationUpdateSelectedTracks object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setRecordingStatus:) name:kNotificationSetRecordingStatus object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // alloc and init curl view
    self.curlView = [[XBCurlView alloc] initWithFrame:self.view.frame];
    self.curlView.userInteractionEnabled = NO;
    
    // set navigation controller properties
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // accelerometer test mode
    //    testMode = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // start updating stats labels
    shouldUpdateStatsLabels = YES;
    
    settings = [[Utils loadSettings] mutableCopy];
    BOOL useMetricSetting = [[settings objectForKey:kSettingsKeyUseMetric] boolValue];
    MKMapType mapModeSetting = [[settings objectForKey:kSettingsKeyMapMode] unsignedIntegerValue];
    BOOL followLocationSetting = [[settings objectForKey:kSettingsKeyFollowLocation] boolValue];
    NSString *newSuffix = [settings objectForKey:kSettingsKeyDataSuffix];
    enum transport_mode_t mode = [[settings objectForKey:kSettingsKeyTransportMode] intValue];
    
    // change unit labels depending on setting
    if (![dataSuffix isEqualToString:newSuffix]
        || ![distanceUnitText isEqualToString:(useMetricSetting ? kUnitTextKilometer : kUnitTextMile)]) {
        dataSuffix = newSuffix;
        if ([dataSuffix isEqualToString:kDataSuffixNetCO2]
            || [dataSuffix isEqualToString:kDataSuffixCO2Emitted]
            || [dataSuffix isEqualToString:kDataSuffixCO2Avoided]) {
            dataUnitText = (useMetricSetting ? kUnitTextKG : kUnitTextLBS);
        } else if ([dataSuffix isEqualToString:kDataSuffixGas]) {
            dataUnitText = (useMetricSetting ? kUnitTextLiter : kUnitTextGallon);
        } else if ([dataSuffix isEqualToString:kDataSuffixCalories]) {
            dataUnitText = kUnitTextCalorie;
        }
        
        if (useMetricSetting) {
            distanceUnitText = kUnitTextKilometer;
            speedUnitText = kUnitTextKPH;
        } else {
            distanceUnitText = kUnitTextMile;
            speedUnitText = kUnitTextMPH;
        }
        [self updateSelectedTracks:nil];
    }
    
    // change transport mode depending on setting
    [self.transportModeControl setSelectedSegmentIndex:(mode == TransportModeCar ? 0
                                                        : (mode == TransportModeBus ? 1
                                                           : (mode == TransportModeTrain ? 2
                                                              : (mode == TransportModeSubway ? 3
                                                                 : -1))))];
    
    // change map mode depending on setting
    if (self.mapView.mapType != mapModeSetting)
        self.mapView.mapType = mapModeSetting;
    
    // change user tracking mode depending on setting and whether or not recording
    if (followLocationSetting) {
        isFollowing = true;
        if (recordingState == RecordingStateRunning) self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    } else {
        self.mapView.userTrackingMode = MKUserTrackingModeNone;
        isFollowing = false;
    }
    
    // get fuel efficiency depending on setting
    emissionsPerMeter = [[settings objectForKey:kSettingsKeyEmissionsPerMeter] floatValue];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // stop updating stats labels
    shouldUpdateStatsLabels = NO;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    if (newLocation) {
        if (newLocation.horizontalAccuracy < 0.0 || newLocation.horizontalAccuracy > 100.0) {
            // GPS signal lost, add the finished track segment, begin a new one
            if (currentGPXTrack) {
                [currentGPXTrack addTracksegment:currentGPXTrackSegment];
                currentGPXTrackSegment = [currentGPXTrack newTrackSegment];
            }
        } else {
            // calculate distance
            CGFloat distance = 0;
            if (oldLocation != nil) {
                distance = [Utils metersBetweenCoordinate:oldLocation.coordinate coordinate:newLocation.coordinate];
                totalDistance += distance;
            }
            oldLocation = newLocation;
            
            // get current speed, calculate average speed
            currentSpeed = (newLocation.speed < 0 ? 0 : newLocation.speed);
            averageSpeed = (averageSpeed * numAverageSpeedSamples + currentSpeed) / (numAverageSpeedSamples++ + 1);
            
            // check if speed has passed threshold
            if (currentSpeed > kSpeedMaxNotDriving) {
                isDriving = YES;
            }
            
            // calculate carbon emissions or avoidance and calories burned
            if (isDriving) {
                carbonEmissions += distance * emissionsPerMeter;
            } else {
                caloriesBurned += [Utils caloriesBurnedForDistance:distance speed:currentSpeed];
            }
            
            carbonAvoidance += distance * (kEmissionsMassPerMeterCar - emissionsPerMeter);
            
            // record location information in GPX format
            // add newLocation as GPXTrackPoint
            GPXTrackPoint *gpxTrackPoint = [currentGPXTrackSegment newTrackpointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
            gpxTrackPoint.horizontalDilution = newLocation.horizontalAccuracy;
            gpxTrackPoint.verticalDilution = newLocation.verticalAccuracy;
            gpxTrackPoint.elevation = newLocation.altitude;
            gpxTrackPoint.time = newLocation.timestamp;
            gpxTrackPoint.desc = [NSString stringWithFormat:@"Speed: %f", currentSpeed];
            
            // compare and set new bounds if necessary
            if (!currentGPXBounds)
                currentGPXBounds = [GPXBounds boundsWithMinLatitude:newLocation.coordinate.latitude
                                                       minLongitude:newLocation.coordinate.longitude
                                                        maxLatitude:newLocation.coordinate.latitude
                                                       maxLongitude:newLocation.coordinate.longitude];
            else {
                currentGPXBounds.minLatitude = MIN(currentGPXBounds.minLatitude, newLocation.coordinate.latitude);
                currentGPXBounds.minLongitude = MIN(currentGPXBounds.minLongitude, newLocation.coordinate.longitude);
                currentGPXBounds.maxLatitude = MAX(currentGPXBounds.maxLatitude, newLocation.coordinate.latitude);
                currentGPXBounds.maxLongitude = MAX(currentGPXBounds.maxLongitude, newLocation.coordinate.longitude);
            }
            
            // update on-screen overlay
            if (!crumbs) {
                // this is the first update, create CrumbPath and add it to map
                crumbs = [[CrumbPath alloc] initWithCenterCoordinate:newLocation.coordinate];
                [self.mapView addOverlay:crumbs];
            } else {
                // subsequent update, if crumbs MKOverlay model object
                // determines current location has moved far enough,
                // use returned updateRect to update just the updated area
                MKMapRect updateRect = [crumbs addCoordinate:newLocation.coordinate];
                if (!MKMapRectIsNull(updateRect)) {
                    // update rect is non-null, get current map zoom scale
                    MKZoomScale currentZoomScale = (CGFloat)(self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width);
                    
                    // find out the line width at this zoom scale and outset the updateRect by that amount
                    CGFloat lineWidth = MKRoadWidthAtZoomScale(currentZoomScale);
                    updateRect = MKMapRectInset(updateRect, -lineWidth, -lineWidth);
                    
                    // update just the changed area
                    [crumbView setNeedsDisplayInMapRect:updateRect];
                }
            }
            
            // successful location update, reset counter
            numStatsUpdatesWithoutLocationUpdate = 0;
        }
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    TrackAnnotation *annot = (TrackAnnotation *)view.annotation;
    TrackDetailViewController *controller = [[TrackDetailViewController alloc] initWithFilePath:annot.filePath];
    [self.navigationController pushViewController:controller animated:YES];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[CrumbPath class]]) {
        if (!crumbView)
            // create crumbview if it has not been
            crumbView = [[CrumbPathView alloc] initWithOverlay:overlay];
        return crumbView;
    } else if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *polyline = overlay;
        // create and customize polyline view
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:polyline];
        //        polylineView.strokeColor = [UIColor colorWithRed:1.0 green:0.1 blue:0.1 alpha:0.9];
        CGFloat emissions = [[[NSNumberFormatter new] numberFromString:polyline.title] floatValue];
        polylineView.strokeColor = [Utils colorForEmissions:emissions];
        polylineView.lineWidth = 8.0;
        return polylineView;
    } else return nil;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[TrackAnnotation class]]) {
        // create and customize annotation for a track
        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"TrackAnnotationView"];
        if (!pinView)
            // create new pin view if necessary
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"TrackAnnotationView"];
        else pinView.annotation = annotation;
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.animatesDrop = NO;
        pinView.canShowCallout = YES;
        // add detail disclosure button to callout
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [rightButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
        pinView.rightCalloutAccessoryView = rightButton;
        return pinView;
    } else return nil;
}

#pragma mark - interface methods

- (IBAction)transportModeControlChanged:(id)sender {
    int selIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    enum transport_mode_t mode = (selIndex == 0 ? TransportModeCar
                                  : (selIndex == 1 ? TransportModeBus
                                     : (selIndex == 2 ? TransportModeTrain
                                        : (selIndex == 3 ? TransportModeSubway
                                           : -1))));
    [settings setObject:[NSNumber numberWithInt:mode] forKey:kSettingsKeyTransportMode];
    
    // create Settings directory if necessary
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *settingsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:kSettingsDirectory];
    if (![fileManager fileExistsAtPath:settingsDirectory]) {
        [fileManager createDirectoryAtPath:settingsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
            NSLog(@"Error creating Settings directory: %@", error);
    }
    
    // save settings to plist file, dismiss options view
    [settings writeToFile:[settingsDirectory stringByAppendingPathComponent:kSettingsFileName] atomically:NO];
    settings = [[Utils loadSettings] mutableCopy];
}

- (IBAction)tapCurlViewTapped:(id)sender {
    // tap curl view was touched, curl view
    self.tapCurlView.hidden = YES;
    self.curlView.opaque = NO;
    self.curlView.pageOpaque = YES;
    //    [self.curlView curlView:self.frontView cylinderPosition:CGPointMake(self.frontView.frame.size.width * 0.91, self.frontView.frame.size.height * 0.94) cylinderAngle:11 * M_PI / 16 cylinderRadius:15.0 animatedWithDuration:kCurlAnimationDuration];
    [self.curlView curlView:self.frontView cylinderPosition:CGPointMake(self.frontView.frame.size.width * 0.5, self.frontView.frame.size.height * 0.12) cylinderAngle:15 * M_PI / 16 cylinderRadius:110.0 animatedWithDuration:kCurlAnimationDuration];
}

- (IBAction)tapUncurlViewTapped:(id)sender {
    // tap uncurl view was touched, uncurl view
    self.tapCurlView.hidden = NO;
    [self.curlView uncurlAnimatedWithDuration:kCurlAnimationDuration];
}

- (void)optionsButtonPressed:(id)sender {
    // present options view controller modally
    [self presentViewController:self.settingsNavigationController animated:YES completion:nil];
}

- (void)tracksButtonPressed:(id)sender {
    // set recording state
    [self.tracksViewController setRecordingState:recordingState];
    
    // push tracks view controller onto stack
    [self.navigationController pushViewController:self.tracksViewController animated:YES];
}

#pragma mark - private methods

- (void)updateSelectedTracks:(NSNotification *)notification {
    // load currently selected track paths
    NSArray *selectedTrackFilePaths = [[NSDictionary dictionaryWithContentsOfFile:[[NSHomeDirectory() stringByAppendingPathComponent:kSettingsDirectory]stringByAppendingPathComponent:kSelectedTracksFileName]] allValues];
    
    // clear existing track annotations
    for (TrackAnnotation *removeMe in self.mapView.annotations)
        if ([removeMe isKindOfClass:[TrackAnnotation class]])
            [self.mapView removeAnnotation:removeMe];
    // clear existing polylines
    for (MKPolyline *removeMe in self.mapView.overlays)
        if ([removeMe isKindOfClass:[MKPolyline class]])
            [self.mapView removeOverlay:removeMe];
    
    if ([selectedTrackFilePaths count] > 0) {
        CLLocationCoordinate2D minCoordinate = kCLLocationCoordinate2DInvalid;
        CLLocationCoordinate2D maxCoordinate = kCLLocationCoordinate2DInvalid;
        
        for (NSString *filePath in selectedTrackFilePaths) {
            // load GPX root from file
            GPXRoot *rootFromFile = [GPXParser parseGPXAtPath:filePath];
            GPXMetadata *metadata = rootFromFile.metadata;
            // get track
            GPXTrack *track = [[rootFromFile tracks] lastObject];
            // get track segments
            NSArray *tracksegments = [track tracksegments];
            
            for (GPXTrackSegment *tracksegment in tracksegments) {
                // get track points
                NSArray *trackpoints = [tracksegment trackpoints];
                NSUInteger count = [trackpoints count];
                CLLocationCoordinate2D coordinates[count];
                
                // add each track point's coordinates to the coordinates array
                for (int i = 0; i < count; i++) {
                    GPXTrackPoint *trackpoint = trackpoints[i];
                    coordinates[i] = CLLocationCoordinate2DMake(trackpoint.latitude, trackpoint.longitude);
                }
                
                // create polyline, add to map view
                MKPolyline *trackLine = [MKPolyline polylineWithCoordinates:coordinates count:count];
                [self.mapView addOverlay:trackLine];
            }
            
            // get the first coordinate in the track
            GPXTrackPoint *firstPoint = [[[tracksegments firstObject] trackpoints] firstObject];
            CLLocationCoordinate2D firstCoord = CLLocationCoordinate2DMake(firstPoint.latitude, firstPoint.longitude);
            // create track annotation at first coordinate, add to map view
            TrackAnnotation *annotation = [[TrackAnnotation alloc]
                                           initWithFilePath:filePath
                                           title:metadata.name
                                           subtitle:[[Utils attributedStringFromNumber:([dataSuffix isEqualToString:kDataSuffixNetCO2]
                                                                                        ? metadata.extensions.carbonEmissions - metadata.extensions.carbonAvoidance
                                                                                        : ([dataSuffix isEqualToString:kDataSuffixCO2Emitted]
                                                                                           || [dataSuffix isEqualToString:kDataSuffixGas]
                                                                                           ? metadata.extensions.carbonEmissions
                                                                                           : ([dataSuffix isEqualToString:kDataSuffixCO2Avoided]
                                                                                              ? metadata.extensions.carbonAvoidance
                                                                                              : metadata.extensions.caloriesBurned)))
                                                                          baseFontSize:1.0f
                                                                            dataSuffix:dataSuffix
                                                                              unitText:dataUnitText] string]
                                           coordinate:firstCoord];
            [self.mapView addAnnotation:annotation];
            
            // load bounds
            GPXBounds *bounds = metadata.bounds;
            if (CLLocationCoordinate2DIsValid(minCoordinate)) {
                // previous minimums defined, check against current bounds and set new minimum value if necessary
                minCoordinate.latitude = MIN(minCoordinate.latitude, bounds.minLatitude);
                minCoordinate.longitude = MIN(minCoordinate.longitude, bounds.minLongitude);
            } else
                // no previous minimums defined, set current bounds as minimum
                minCoordinate = CLLocationCoordinate2DMake(bounds.minLatitude, bounds.minLongitude);
            if (CLLocationCoordinate2DIsValid(maxCoordinate)) {
                // previous maximums defined, check against current bounds and set new maximum value if necessary
                maxCoordinate.latitude = MAX(maxCoordinate.latitude, bounds.maxLatitude);
                maxCoordinate.longitude = MAX(maxCoordinate.longitude, bounds.maxLongitude);
            } else
                // no previous maximums defined, set current bounds as maximum
                maxCoordinate = CLLocationCoordinate2DMake(bounds.maxLatitude, bounds.maxLongitude);
        }
        
        if (!isFollowing || recordingState < RecordingStateRunning) {
            // currently set to not follow user location, zoom map view to fit largest bounds
            [self.mapView setRegion:[self.mapView regionThatFits: MKCoordinateRegionMake(CLLocationCoordinate2DMake((minCoordinate.latitude + maxCoordinate.latitude) / 2, (minCoordinate.longitude + maxCoordinate.longitude) / 2), MKCoordinateSpanMake((maxCoordinate.latitude - minCoordinate.latitude) * 1.1, (maxCoordinate.longitude - minCoordinate.longitude) * 1.1))] animated:YES];
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // stop updating stats labels
    shouldUpdateStatsLabels = NO;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    // start updating stats labels
    shouldUpdateStatsLabels = YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    if (recordingState > RecordingStateOff) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"EEE, MMM d h:mm a"];
        [self saveTrack:[NSNotification notificationWithName:kNotificationSetRecordingStatus
                                                      object:nil
                                                    userInfo:@{kUserInfoKeyRecordingState: [NSNumber numberWithInt:RecordingStateOff],
                                                               kUserInfoKeyTrackName: [dateFormatter stringFromDate:[NSDate date]],
                                                               kUserInfoKeyTrackDescription: @"The app was stopped while a recording was in progress."}]];
        NSLog(@"Application terminating, saving current track.");
    }
}

#pragma mark stats

- (void)updateStats {
    // set current speed to 0 if threshold passed
    if (++numStatsUpdatesWithoutLocationUpdate >= kStatsUpdatesUntilCurrentSpeedReset)
        currentSpeed = 0.0f;
    
    // calculate times
    NSTimeInterval timeSinceLastUpdate = [NSDate timeIntervalSinceReferenceDate] - lastUpdateTime;
    if (currentSpeed < kCurrentSpeedStopThreshold || recordingState < RecordingStateRunning)
        timeStopped += timeSinceLastUpdate;
    else timeMoving += timeSinceLastUpdate;
    totalTime += timeSinceLastUpdate;
    lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
    
    if (shouldUpdateStatsLabels)
        [self updateStatsLabels];
}

- (void)updateStatsLabels {
    // set label text in appropriate units
    self.totalTimeLabel.text = [Utils timeStringFromSeconds:totalTime];
    self.totalDistanceLabel.text = [NSString stringWithFormat:@"%.2f %@", [Utils distanceFromMeters:totalDistance units:distanceUnitText], distanceUnitText];
    self.averageSpeedLabel.text = [NSString stringWithFormat:@"%.2f %@", [Utils speedFromMetersSec:averageSpeed units:speedUnitText], speedUnitText];
    self.currentSpeedLabel.text = [NSString stringWithFormat:@"%.2f %@", [Utils speedFromMetersSec:currentSpeed units:speedUnitText], speedUnitText];
    self.displayedDataLabel.attributedText = [Utils attributedStringFromNumber:([dataSuffix isEqualToString:kDataSuffixNetCO2]
                                                                                ? carbonEmissions - carbonAvoidance
                                                                                :([dataSuffix isEqualToString:kDataSuffixCO2Emitted]
                                                                                  || [dataSuffix isEqualToString:kDataSuffixGas]
                                                                                  ? carbonEmissions
                                                                                  : ([dataSuffix isEqualToString:kDataSuffixCO2Avoided]
                                                                                     ? carbonAvoidance
                                                                                     : caloriesBurned)))
                                                                  baseFontSize:23.0f
                                                                    dataSuffix:dataSuffix
                                                                      unitText:dataUnitText];
}

#pragma mark accelerometer

- (void)outputAccelerationData:(CMAcceleration)acceleration {
    if (recordingState == RecordingStateRunning) {
        // add current acceleration magnitude to array
        [accelMagnitudes addObject:[NSNumber numberWithDouble:sqrt((acceleration.x * acceleration.x) + (acceleration.y * acceleration.y) + (acceleration.z * acceleration.z))]];
        
        // currently moving, check if array has too many objects and remove if necessary
        while ([accelMagnitudes count] > kAccelMagnitudeSamplesMoving)
            [accelMagnitudes removeObjectAtIndex:0];
        
        NSUInteger count = [accelMagnitudes count];
        if (count >= kAccelMagnitudeSamplesWalking && isDriving ) {
            // there are enough samples AND currently driving, take standard deviation
            walkingStdDev = [Utils standardDeviationOf:[accelMagnitudes subarrayWithRange:NSMakeRange(count - kAccelMagnitudeSamplesWalking, kAccelMagnitudeSamplesWalking)]];
            if (walkingStdDev > kStandardDeviationWalkingThreshold) {
                // standard deviation is above threshold for walking
                if (++numStandardDeviationSamplesAboveThreshold > kStandardDeviationSamplesAboveWalkingThreshold) {
                    // there are enough samples consecutively above the threshold for walking
                    isDriving = NO;
                }
            } else numStandardDeviationSamplesAboveThreshold = 0;
        }
    }
}

/* battery saving feature
 - (void)outputAccelerationData:(CMAcceleration)acceleration {
 // add current acceleration magnitude to array
 [accelMagnitudes addObject:[NSNumber numberWithDouble:sqrt((acceleration.x * acceleration.x) + (acceleration.y * acceleration.y) + (acceleration.z * acceleration.z))]];
 if (recordingState < RecordingStateRunning) {
 // currently stopped, check if array has too many objects and remove if necessary
 while ([accelMagnitudes count] > kAccelMagnitudeSamplesStopped)
 [accelMagnitudes removeObjectAtIndex:0];
 
 if ([accelMagnitudes count] >= kAccelMagnitudeSamplesStopped) {
 // there are enough magnitude of acceleration samples, take standard deviation
 accelMagStdDev = [Utils standardDeviationOf:accelMagnitudes];
 if (accelMagStdDev > kStandardDeviationStartThreshold) {
 if (++numStandardDeviationSamplesAboveThreshold > kStandardDeviationSamplesAboveStartThreshold) {
 // there are enough samples consecutively above the threshold, start recording
 numStandardDeviationSamplesAboveThreshold = 0;
 [self resumeRecording];
 NSLog(@"GPS turned on due to movement");
 }
 } else numStandardDeviationSamplesAboveThreshold = 0;
 }
 } else {
 // currently moving, check if array has too many objects and remove if necessary
 while ([accelMagnitudes count] > kAccelMagnitudeSamplesMoving)
 [accelMagnitudes removeObjectAtIndex:0];
 
 NSUInteger count = [accelMagnitudes count];
 if (count >= kAccelMagnitudeSamplesWalking && isDriving ) {
 // there are enough samples AND currently driving, take standard deviation
 walkingStdDev = [Utils standardDeviationOf:[accelMagnitudes subarrayWithRange:NSMakeRange(count - kAccelMagnitudeSamplesWalking, kAccelMagnitudeSamplesWalking)]];
 if (walkingStdDev > kStandardDeviationWalkingThreshold) {
 // standard deviation is above threshold for walking
 if (++numStandardDeviationSamplesAboveThreshold > kStandardDeviationSamplesAboveWalkingThreshold) {
 // there are enough samples consecutively above the threshold for walking
 isDriving = NO;
 }
 } else numStandardDeviationSamplesAboveThreshold = 0;
 }
 
 if (count >= kAccelMagnitudeSamplesMoving && currentSpeed < kCurrentSpeedStopThreshold && numStatsUpdatesWithoutLocationUpdate > kStatsUpdatesUntilRecordingStop) {
 // there are enough samples AND speed is below threshold, take standard deviation
 accelMagStdDev = [Utils standardDeviationOf:accelMagnitudes];
 if (accelMagStdDev < kStandardDeviationStopThreshold) {
 // standard deviation and speed fell below the thresholds, stop recording
 [self pauseRecording];
 NSLog(@"GPS turned off due to inactivity");
 }
 }
 }
 }
 */

- (void)setAccelerometerStatus:(int)status {
    [self.motionManager stopAccelerometerUpdates];
    numStandardDeviationSamplesAboveThreshold = 0;
    if (status == kAccelerometerOff) return;
    self.motionManager.accelerometerUpdateInterval = (status == kAccelerometerStopped
                                                      ? kAccelerometerUpdateIntervalStopped
                                                      : kAccelerometerUpdateIntervalMoving);
    accelMagnitudes = [[NSMutableArray alloc] initWithCapacity:kAccelMagnitudeSamplesStopped];
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        [self outputAccelerationData:accelerometerData.acceleration];
        if (error) NSLog(@"Error: %@", error);
    }];
}

#pragma mark recording

- (void)setRecordingStatus:(NSNotification *)notification {
    int state = [[[notification userInfo] valueForKey:kUserInfoKeyRecordingState] intValue];
    if (state == RecordingStateOff) [self saveTrack:notification];
    else if (state == RecordingStatePaused) [self pauseRecording];
    else if (state == RecordingStateRunning && recordingState == RecordingStateOff) [self startRecording];
    else if (state == RecordingStateRunning && recordingState == RecordingStatePaused) [self resumeRecording];
}

- (void)postRecordingStateChangedNotification:(int)state {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRecordingStateChanged object:self userInfo:@{kUserInfoKeyRecordingState: [NSNumber numberWithInt:state]}];
}

- (void)startRecording {
    // initialize variables
    currentGPXRoot = [GPXRoot rootWithCreator:@"onTrac"];
    currentGPXTrack = [currentGPXRoot newTrack];
    currentGPXTrackSegment = [currentGPXTrack newTrackSegment];
    currentGPXBounds = nil;
    oldLocation = nil;
    lastUpdateTime = [NSDate timeIntervalSinceReferenceDate];
    timeMoving =
    timeStopped =
    totalTime =
    totalDistance =
    averageSpeed =
    numAverageSpeedSamples =
    currentSpeed =
    carbonEmissions =
    carbonAvoidance =
    caloriesBurned = 0;
    isDriving = NO;
    
    // clear crumbs and crumb view, remove overlay
    [self.mapView removeOverlay:crumbs];
    crumbs = nil;
    crumbView = nil;
    
    // start updating stats
    statsUpdateTimer = [NSTimer timerWithTimeInterval:kStatsUpdateInterval target:self selector:@selector(updateStats) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:statsUpdateTimer forMode:NSDefaultRunLoopMode];
    
    // record
    [self resumeRecording];
}

- (void)resumeRecording {
    // start updating location
    [self.locationManager startUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    // start updating accelerometer at "moving" frequency
    [self setAccelerometerStatus:kAccelerometerMoving];
    
    // post notification
    recordingState = RecordingStateRunning;
    [self postRecordingStateChangedNotification:recordingState];
    NSLog(@"Recording State: %i", recordingState);
}

- (void)pauseRecording {
    // no longer driving
    isDriving = NO;
    
    // stop updating location
    [self.locationManager stopUpdatingLocation];
    self.mapView.showsUserLocation = NO;
    
    // start updating accelerometer at "stopped" frequency
    [self setAccelerometerStatus:kAccelerometerStopped];
    
    // post notification
    recordingState = RecordingStatePaused;
    [self postRecordingStateChangedNotification:recordingState];
    NSLog(@"Recording State: %i", recordingState);
}

- (void)saveTrack:(NSNotification *)notification {
    // stop updating stats
    [statsUpdateTimer invalidate];
    
    // stop updating location
    [self.locationManager stopUpdatingLocation];
    self.mapView.showsUserLocation = NO;
    
    // stop updating accelerometer
    [self setAccelerometerStatus:kAccelerometerOff];
    
    // add latest track segment
    [currentGPXTrack addTracksegment:currentGPXTrackSegment];
    
    // create Tracks directory if necessary
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tracksDirectory = [NSHomeDirectory() stringByAppendingPathComponent:kTracksDirectory];
    if (![fileManager fileExistsAtPath:tracksDirectory]) {
        [fileManager createDirectoryAtPath:tracksDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
            NSLog(@"Error creating Tracks directory: %@", error);
    }
    
    // get username from personalInfo.plist file
    //    NSString *username = [[NSDictionary dictionaryWithContentsOfFile:[NSHomeDirectory() stringByAppendingPathComponent:@"personalInfo.plist"]] objectForKey:@"username"];
    
    // create author
    GPXAuthor *author = [GPXAuthor new];
    //    author.name = username;
    author.name = @"onTrac";
    
    // create extensions
    OnTracExtensions *extensions = [OnTracExtensions new];
    extensions.timeMoving = timeMoving;
    extensions.timeStopped = timeStopped;
    extensions.totalTime = totalTime;
    extensions.totalDistance = totalDistance;
    extensions.averageSpeed = averageSpeed;
    extensions.carbonEmissions = carbonEmissions;
    extensions.carbonAvoidance = carbonAvoidance;
    extensions.caloriesBurned = caloriesBurned;
    
    // create and set metadata
    GPXMetadata *metadata = [GPXMetadata new];
    metadata.author = author;
    metadata.time = [NSDate date];
    metadata.bounds = currentGPXBounds;
    metadata.extensions = extensions;
    metadata.name = [[notification userInfo] objectForKey:kUserInfoKeyTrackName];
    metadata.desc = [[notification userInfo] objectForKey:kUserInfoKeyTrackDescription];
    currentGPXRoot.metadata = metadata;
    
    // set additional GPX track info
    currentGPXTrack.source = @"onTrac";
    
    // get current date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH.mm.ss"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    // write GPX to file
    NSString *gpxString = currentGPXRoot.gpx;
    NSString *gpxFileName = [currentDate stringByAppendingPathExtension:@"gpx"];
    [gpxString writeToFile:[tracksDirectory stringByAppendingPathComponent:gpxFileName] atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error)
        NSLog(@"Error writing GPX to file: %@", error);
    
    // post notification
    recordingState = RecordingStateOff;
    [self postRecordingStateChangedNotification:recordingState];
    NSLog(@"Recording State: %i", recordingState);
}

@end
