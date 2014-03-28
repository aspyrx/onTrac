//
//  OnTracExtensions.m
//  onTrac
//
//  Created by Stan Zhang on 10/25/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import "OnTracExtensions.h"
#import "GPXElementSubclass.h"

@implementation OnTracExtensions {
    NSString *timeWalkValue;
    NSString *timeBikeValue;
    NSString *timeCarValue;
    NSString *timeBusValue;
    NSString *timeTrainValue;
    NSString *timeSubwayValue;
    NSString *timeMovingValue;
    NSString *timeStoppedValue;
    NSString *totalTimeValue;
    
    NSString *distanceWalkValue;
    NSString *distanceBikeValue;
    NSString *distanceCarValue;
    NSString *distanceBusValue;
    NSString *distanceTrainValue;
    NSString *distanceSubwayValue;
    NSString *totalDistanceValue;
    
    NSString *averageSpeedValue;
    NSString *carbonEmissionsValue;
    NSString *carbonAvoidanceValue;
    NSString *caloriesBurnedValue;
}

- (id)initWithXMLElement:(GPXXMLElement *)element parent:(GPXElement *)parent {
    self = [super initWithXMLElement:element parent:parent];
    if (self) {
        timeWalkValue = [self textForSingleChildElementNamed:@"timeWalk" xmlElement:element required:YES];
        timeBikeValue = [self textForSingleChildElementNamed:@"timeBike" xmlElement:element required:YES];
        timeCarValue = [self textForSingleChildElementNamed:@"timeCar" xmlElement:element required:YES];
        timeBusValue = [self textForSingleChildElementNamed:@"timeBus" xmlElement:element required:YES];
        timeTrainValue = [self textForSingleChildElementNamed:@"timeTrain" xmlElement:element required:YES];
        timeSubwayValue = [self textForSingleChildElementNamed:@"timeSubway" xmlElement:element required:YES];
        timeMovingValue = [self textForSingleChildElementNamed:@"timeMoving" xmlElement:element required:YES];
        timeStoppedValue = [self textForSingleChildElementNamed:@"timeStopped" xmlElement:element required:YES];
        totalTimeValue = [self textForSingleChildElementNamed:@"totalTime" xmlElement:element required:YES];
        
        distanceWalkValue = [self textForSingleChildElementNamed:@"distanceWalk" xmlElement:element required:YES];
        distanceBikeValue = [self textForSingleChildElementNamed:@"distanceBike" xmlElement:element required:YES];
        distanceCarValue = [self textForSingleChildElementNamed:@"distanceCar" xmlElement:element required:YES];
        distanceBusValue = [self textForSingleChildElementNamed:@"distanceBus" xmlElement:element required:YES];
        distanceTrainValue = [self textForSingleChildElementNamed:@"distanceTrain" xmlElement:element required:YES];
        distanceSubwayValue = [self textForSingleChildElementNamed:@"distanceSubway" xmlElement:element required:YES];
        totalDistanceValue = [self textForSingleChildElementNamed:@"totalDistance" xmlElement:element required:YES];
        
        averageSpeedValue = [self textForSingleChildElementNamed:@"averageSpeed" xmlElement:element required:YES];
        carbonEmissionsValue = [self textForSingleChildElementNamed:@"carbonEmissions" xmlElement:element required:YES];
        carbonAvoidanceValue = [self textForSingleChildElementNamed:@"carbonAvoidance" xmlElement:element required:YES];
        caloriesBurnedValue = [self textForSingleChildElementNamed:@"caloriesBurned" xmlElement:element required:YES];
    }
    return self;
}

+ (NSString *)tagName {
    return @"extensions";
}

- (NSTimeInterval)timeWalk {
    return [GPXType decimal:timeWalkValue];
}

- (void)setTimeWalk:(NSTimeInterval)timeWalk {
    timeWalkValue = [GPXType valueForDecimal:timeWalk];
}

- (NSTimeInterval)timeBike {
    return [GPXType decimal:timeBikeValue];
}

- (void)setTimeBike:(NSTimeInterval)timeBike {
    timeBikeValue = [GPXType valueForDecimal:timeBike];
}

- (NSTimeInterval)timeCar {
    return [GPXType decimal:timeCarValue];
}

- (void)setTimeCar:(NSTimeInterval)timeCar {
    timeCarValue = [GPXType valueForDecimal:timeCar];
}

- (NSTimeInterval)timeBus {
    return [GPXType decimal:timeBusValue];
}

- (void)setTimeBus:(NSTimeInterval)timeBus {
    timeBusValue = [GPXType valueForDecimal:timeBus];
}

- (NSTimeInterval)timeTrain {
    return [GPXType decimal:timeTrainValue];
}

- (void)setTimeTrain:(NSTimeInterval)timeTrain {
    timeTrainValue = [GPXType valueForDecimal:timeTrain];
}

- (NSTimeInterval)timeSubway {
    return [GPXType decimal:timeSubwayValue];
}

- (void)setTimeSubway:(NSTimeInterval)timeSubway {
    timeSubwayValue = [GPXType valueForDecimal:timeSubway];
}

- (NSTimeInterval)timeMoving {
    return [GPXType decimal:timeMovingValue];
}

- (void)setTimeMoving:(NSTimeInterval)timeMoving {
    timeMovingValue = [GPXType valueForDecimal:timeMoving];
}

- (NSTimeInterval)timeStopped {
    return [GPXType decimal:timeStoppedValue];
}

- (void)setTimeStopped:(NSTimeInterval)timeStopped {
    timeStoppedValue = [GPXType valueForDecimal:timeStopped];
}

- (NSTimeInterval)totalTime {
    return [GPXType decimal:totalTimeValue];
}

- (void)setTotalTime:(NSTimeInterval)totalTime {
    totalTimeValue = [GPXType valueForDecimal:totalTime];
}

- (CGFloat)distanceWalk {
    return [GPXType decimal:distanceWalkValue];
}

- (void)setDistanceWalk:(CGFloat)distanceWalk {
    distanceWalkValue = [GPXType valueForDecimal:distanceWalk];
}

- (CGFloat)distanceBike {
    return [GPXType decimal:distanceBikeValue];
}

- (void)setDistanceBike:(CGFloat)distanceBike {
    distanceBikeValue = [GPXType valueForDecimal:distanceBike];
}

- (CGFloat)distanceCar {
    return [GPXType decimal:distanceCarValue];
}

- (void)setDistanceCar:(CGFloat)distanceCar {
    distanceCarValue = [GPXType valueForDecimal:distanceCar];
}

- (CGFloat)distanceBus {
    return [GPXType decimal:distanceBusValue];
}

- (void)setDistanceBus:(CGFloat)distanceBus {
    distanceBusValue = [GPXType valueForDecimal:distanceBus];
}

- (CGFloat)distanceTrain {
    return [GPXType decimal:distanceTrainValue];
}

- (void)setDistanceTrain:(CGFloat)distanceTrain {
    distanceTrainValue = [GPXType valueForDecimal:distanceTrain];
}

- (CGFloat)distanceSubway {
    return [GPXType decimal:distanceSubwayValue];
}

- (void)setDistanceSubway:(CGFloat)distanceSubway {
    distanceSubwayValue = [GPXType valueForDecimal:distanceSubway];
}

- (CGFloat)totalDistance {
    return [GPXType decimal:totalDistanceValue];
}

- (void)setTotalDistance:(CGFloat)totalDistance {
    totalDistanceValue = [GPXType valueForDecimal:totalDistance];
}

- (CGFloat)averageSpeed {
    return [GPXType decimal:averageSpeedValue];
}

- (void)setAverageSpeed:(CGFloat)averageSpeed {
    averageSpeedValue = [GPXType valueForDecimal:averageSpeed];
}

- (CGFloat)carbonEmissions {
    return [GPXType decimal:carbonEmissionsValue];
}

- (void)setCarbonEmissions:(CGFloat)carbonEmissions {
    carbonEmissionsValue = [GPXType valueForDecimal:carbonEmissions];
}

- (CGFloat)carbonAvoidance {
    return [GPXType decimal:carbonAvoidanceValue];
}

- (void)setCarbonAvoidance:(CGFloat)carbonAvoidance {
    carbonAvoidanceValue = [GPXType valueForDecimal:carbonAvoidance];
}

- (CGFloat)caloriesBurned {
    return [GPXType decimal:caloriesBurnedValue];
}

- (void)setCaloriesBurned:(CGFloat)caloriesBurned {
    caloriesBurnedValue = [GPXType valueForDecimal:caloriesBurned];
}

- (void)addChildTagToGpx:(NSMutableString *)gpx indentationLevel:(NSInteger)indentationLevel {
    [super addChildTagToGpx:gpx indentationLevel:indentationLevel];
    
    [self gpx:gpx addPropertyForValue:timeWalkValue tagName:@"timeWalk" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:timeBikeValue tagName:@"timeBike" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:timeCarValue tagName:@"timeCar" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:timeBusValue tagName:@"timeBus" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:timeTrainValue tagName:@"timeTrain" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:timeSubwayValue tagName:@"timeSubway" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:timeMovingValue tagName:@"timeMoving" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:timeStoppedValue tagName:@"timeStopped" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:totalTimeValue tagName:@"totalTime" indentationLevel:indentationLevel];
    
    [self gpx:gpx addPropertyForValue:distanceWalkValue tagName:@"distanceWalk" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:distanceBikeValue tagName:@"distanceBike" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:distanceCarValue tagName:@"distanceCar" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:distanceBusValue tagName:@"distanceBus" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:distanceTrainValue tagName:@"distanceTrain" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:distanceSubwayValue tagName:@"distanceSubway" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:totalDistanceValue tagName:@"totalDistance" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:averageSpeedValue tagName:@"averageSpeed" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:carbonEmissionsValue tagName:@"carbonEmissions" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:carbonAvoidanceValue tagName:@"carbonAvoidance" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:caloriesBurnedValue tagName:@"caloriesBurned" indentationLevel:indentationLevel];
}

@end
