//
//  OnTracExtensions.h
//  onTrac
//
//  Created by Stan Zhang on 10/25/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import "GPXExtensions.h"

@interface OnTracExtensions : GPXExtensions

@property (nonatomic, assign) NSTimeInterval timeWalk;
@property (nonatomic, assign) NSTimeInterval timeBike;
@property (nonatomic, assign) NSTimeInterval timeCar;
@property (nonatomic, assign) NSTimeInterval timeBus;
@property (nonatomic, assign) NSTimeInterval timeTrain;
@property (nonatomic, assign) NSTimeInterval timeSubway;
@property (nonatomic, assign) NSTimeInterval timeMoving;
@property (nonatomic, assign) NSTimeInterval timeStopped;
@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) CGFloat distanceWalk;
@property (nonatomic, assign) CGFloat distanceBike;
@property (nonatomic, assign) CGFloat distanceCar;
@property (nonatomic, assign) CGFloat distanceBus;
@property (nonatomic, assign) CGFloat distanceTrain;
@property (nonatomic, assign) CGFloat distanceSubway;
@property (nonatomic, assign) CGFloat totalDistance;
@property (nonatomic, assign) CGFloat averageSpeed;
@property (nonatomic, assign) CGFloat carbonEmissions;
@property (nonatomic, assign) CGFloat carbonAvoidance;
@property (nonatomic, assign) CGFloat caloriesBurned;

@end
