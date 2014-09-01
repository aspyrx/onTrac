//
//  AppDelegate.h
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2013 aspyrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
//#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic, readonly) CLLocationManager *sharedLocationManager;
@property (strong, nonatomic, readonly) CMMotionManager *sharedMotionManager;

@end
