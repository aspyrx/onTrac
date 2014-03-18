//
//  MapViewController.h
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@class TracksViewController;
@class XBCurlView;

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *frontView;
@property (weak, nonatomic) IBOutlet UIView *tapCurlView;
@property (weak, nonatomic) IBOutlet UIView *tapUncurlView;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *displayedDataLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transportModeControl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *curlImageView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) XBCurlView *curlView;
@property (strong, nonatomic) TracksViewController *tracksViewController;
@property (strong, nonatomic) UINavigationController *settingsNavigationController;

- (IBAction)transportModeControlChanged:(id)sender;
- (IBAction)tapCurlViewTapped:(id)sender;
- (IBAction)tapUncurlViewTapped:(id)sender;

@end
