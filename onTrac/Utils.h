//
//  Utils.h
//  onTrac
//
//  Created by Stan Zhang on 12/26/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class GPXRoot;

@interface Utils : NSObject

+ (CGFloat)speedBetweenLocation:(CLLocation *)oldLocation location:(CLLocation *)newLocation;
+ (CGFloat)metersBetweenCoordinate:(CLLocationCoordinate2D)a coordinate:(CLLocationCoordinate2D)b;
+ (double)caloriesBurnedForDistance:(double)dist speed:(double)speed;
+ (double)speedFromMetersSec:(double)metersSec units:(NSString *)units;
+ (double)distanceFromMeters:(double)meters units:(NSString *)units;
+ (double)massFromKilograms:(double)kg units:(NSString *)units;
+ (double)volumeFromLiters:(double)liters units:(NSString *)units;
+ (double)meanOf:(NSArray *)array;
+ (double)standardDeviationOf:(NSArray *)array;
+ (NSString *)timeStringFromSeconds:(int)s;
+ (NSDictionary *)loadSettings;
+ (BOOL)deleteSettings;
+ (NSAttributedString *)attributedStringFromNumber:(CGFloat)num baseFontSize:(CGFloat)size dataSuffix:(NSString *)dataSuffix unitText:(NSString *)unitText;
+ (UIColor *)colorForNumber:(CGFloat)num dataSuffix:(NSString *)dataSuffix;
+ (GPXRoot *)rootWithMetadataAtPath:(NSString *)path;

@end
