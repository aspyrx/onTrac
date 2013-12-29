//
//  OnTracExtensions.h
//  onTrac
//
//  Created by Stan Zhang on 10/25/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import "GPXExtensions.h"

@interface OnTracExtensions : GPXExtensions

@property (nonatomic, assign) NSTimeInterval timeMoving;
@property (nonatomic, assign) NSTimeInterval timeStopped;
@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) CGFloat totalDistance;
@property (nonatomic, assign) CGFloat averageSpeed;
@property (nonatomic, assign) CGFloat carbonEmissions;

@end
