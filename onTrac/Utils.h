//
//  Utils.h
//  onTrac
//
//  Created by Stan Zhang on 12/26/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Utils : NSObject

+ (CGFloat)metersBetweenCoordinate:(CLLocationCoordinate2D)a coordinate:(CLLocationCoordinate2D)b;
+ (CGFloat)caloriesBurnedForDistance:(CGFloat)dist speed:(CGFloat)speed;
+ (double)speedFromMetersSec:(double)metersSec units:(NSString *)units;
+ (double)distanceFromMeters:(double)meters units:(NSString *)units;
+ (double)massFromKilograms:(double)kg units:(NSString *)units;
+ (double)volumeFromLiters:(double)liters units:(NSString *)units;
+ (double)meanOf:(NSArray *)array;
+ (double)standardDeviationOf:(NSArray *)array;
+ (NSString *)timeStringFromSeconds:(int)s;
+ (NSDictionary *)loadSettings;
+ (NSAttributedString *)attributedStringFromMass:(CGFloat)mass baseFontSize:(CGFloat)size dataSuffix:(NSString *)dataSuffix unitText:(NSString *)unitText;
+ (UIColor *)colorForEmissions:(CGFloat)mass;

@end
