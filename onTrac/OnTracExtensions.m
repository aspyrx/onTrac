//
//  OnTracExtensions.m
//  onTrac
//
//  Created by Stan Zhang on 10/25/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import "OnTracExtensions.h"
#import "GPXElementSubclass.h"

@implementation OnTracExtensions {
    NSString *timeMovingValue;
    NSString *timeStoppedValue;
    NSString *totalTimeValue;
    NSString *totalDistanceValue;
    NSString *averageSpeedValue;
    NSString *carbonEmissionsValue;
}

- (id)initWithXMLElement:(GPXXMLElement *)element parent:(GPXElement *)parent {
    self = [super initWithXMLElement:element parent:parent];
    if (self) {
        timeMovingValue = [self textForSingleChildElementNamed:@"timeMoving" xmlElement:element required:YES];
        timeStoppedValue = [self textForSingleChildElementNamed:@"timeStopped" xmlElement:element required:YES];
        totalTimeValue = [self textForSingleChildElementNamed:@"totalTime" xmlElement:element required:YES];
        totalDistanceValue = [self textForSingleChildElementNamed:@"totalDistance" xmlElement:element required:YES];
        averageSpeedValue = [self textForSingleChildElementNamed:@"averageSpeed" xmlElement:element required:YES];
        carbonEmissionsValue = [self textForSingleChildElementNamed:@"carbonEmissions" xmlElement:element required:YES];
    }
    return self;
}

+ (NSString *)tagName {
    return @"extensions";
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

- (void)addChildTagToGpx:(NSMutableString *)gpx indentationLevel:(NSInteger)indentationLevel {
    [super addChildTagToGpx:gpx indentationLevel:indentationLevel];
    
    [self gpx:gpx addPropertyForValue:timeMovingValue tagName:@"timeMoving" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:timeStoppedValue tagName:@"timeStopped" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:totalTimeValue tagName:@"totalTime" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:totalDistanceValue tagName:@"totalDistance" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:averageSpeedValue tagName:@"averageSpeed" indentationLevel:indentationLevel];
    [self gpx:gpx addPropertyForValue:carbonEmissionsValue tagName:@"carbonEmissions" indentationLevel:indentationLevel];
}

@end
