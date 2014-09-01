//
//  MapViewController.h
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>

@class TracksViewController;

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *frontView;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *averageSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *detectedModeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *transportModeControl;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIToolbar *statisticsToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *statisticsDisplayButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *statisticsCloseButton;
@property (strong, nonatomic) TracksViewController *tracksViewController;
@property (strong, nonatomic) UINavigationController *settingsNavigationController;

- (IBAction)transportModeControlChanged:(id)sender;
- (IBAction)statisticsLabelTapped:(id)sender;
- (IBAction)showStatistics:(id)sender;
- (IBAction)hideStatistics:(id)sender;

@end
