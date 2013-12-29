//
//  Utils.m
//  onTrac
//
//  Created by Stan Zhang on 12/26/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import "Utils.h"
#import "Defines.h"

@implementation Utils

+ (CGFloat)metersBetweenCoordinate:(CLLocationCoordinate2D)a coordinate:(CLLocationCoordinate2D)b {
    CGFloat lat1 = a.latitude * RADIANS_PER_DEGREE;
    CGFloat lat2 = b.latitude * RADIANS_PER_DEGREE;
    CGFloat lon1 = a.longitude * RADIANS_PER_DEGREE;
    CGFloat lon2 = b.longitude * RADIANS_PER_DEGREE;
    CGFloat result = acos(sin(lat1) * sin(lat2)
                          + cos(lat1) * cos(lat2)
                          * cos(lon1 - lon2)) * RADIUS_EARTH_METERS;
    return (result == NAN ? 0 : result);
}

+ (CGFloat)caloriesBurnedForDistance:(CGFloat)dist speed:(CGFloat)speed {
    // TODO: finish
    return 0;
}

+ (double)speedFromMetersSec:(double)metersSec units:(NSString *)units {
    if ([units isEqual:kUnitTextKPH]) return metersSec * 3.6;
    else if ([units isEqual:kUnitTextMPH])return metersSec * 3.6 / KILOMETERS_PER_MILE;
    else return 0;
}

+ (double)distanceFromMeters:(double)meters units:(NSString *)units {
    if ([units isEqual:kUnitTextKilometer]) return meters / 1000;
    else if ([units isEqual:kUnitTextMile]) return meters / 1000 / KILOMETERS_PER_MILE;
    else return 0;
}

+ (double)massFromKilograms:(double)kg units:(NSString *)units {
    if ([units isEqual:kUnitTextKG]) return kg;
    else if ([units isEqual:kUnitTextLBS]) return kg * POUNDS_PER_KILOGRAM;
    else return 0;
}

+ (double)volumeFromLiters:(double)liters units:(NSString *)units {
    if ([units isEqual:kUnitTextLiter]) return liters;
    else if ([units isEqual:kUnitTextGallon]) return liters * GALLONS_PER_LITER;
    else return 0;
}

+ (double)meanOf:(NSArray *)array {
    // empty array
    if (![array count]) return 0;
    
    double runningTotal = 0.0;
    
    // get total of all members of array
    for (NSNumber *number in array)
        runningTotal += [number doubleValue];
    
    // return mean
    return runningTotal / [array count];
}

+ (double)standardDeviationOf:(NSArray *)array {
    // empty array
    if (![array count]) return 0;
    
    double mean = [self meanOf:array];
    double sumOfSquaredDifferences = 0.0;
    
    // get sum of squared differences for each number
    for (NSNumber *number in array) {
        double valueOfNumber = [number doubleValue];
        double difference = valueOfNumber - mean;
        sumOfSquaredDifferences += difference * difference;
    }
    
    // return standard deviation
    return sqrt(sumOfSquaredDifferences / [array count]);
}

+ (NSString *)timeStringFromSeconds:(int)s {
    return [NSString stringWithFormat:@"%.2d:%.2d:%.2d", (s / 3600) % 24, (s / 60) % 60, s % 60];
}

+ (NSDictionary *)loadSettings {
    // load settings
    NSString *settingsPath = [[NSHomeDirectory() stringByAppendingPathComponent:kSettingsDirectory] stringByAppendingPathComponent:kSettingsFileName];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:settingsPath];
    if (!settings) {
        // use defaults if there was an error (e.g. settings file not created yet)
        settings = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kSettingsFileName ofType:nil]];
        
        // create settings file
        [settings writeToFile:settingsPath atomically:NO];
    }
    return settings;
}

+ (NSAttributedString *)attributedStringFromMass:(CGFloat)mass baseFontSize:(CGFloat)size dataSuffix:(NSString *)dataSuffix unitText:(NSString *)unitText {
    UIFont *numberFont = [UIFont systemFontOfSize:size];
    UIFont *suffixFont = [UIFont systemFontOfSize:0.8 * size];
    NSMutableAttributedString *suffixString = [[NSMutableAttributedString alloc]
                                               initWithString:[NSString stringWithFormat:@"%@ %@", unitText, dataSuffix]
                                               attributes:@{NSFontAttributeName: suffixFont}];
    CGFloat number = 0.0f;
    if ([dataSuffix isEqualToString:kDataSuffixCO2]) {
        number = [Utils massFromKilograms:mass units:unitText];
        
        // add subscript to the "2" in CO2
        UIFont *subscriptFont = [UIFont systemFontOfSize:0.6 * size];
        NSRange range = NSMakeRange([suffixString length] - 1, 1);
        [suffixString beginEditing];
        [suffixString addAttribute:NSFontAttributeName value:subscriptFont range:range];
        [suffixString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-2.0] range:range];
        [suffixString endEditing];
    } else if ([dataSuffix isEqualToString:kDataSuffixGas]) {
        number = [Utils volumeFromLiters:mass / kEmissionsMassPerLiterGas units:unitText];
    }
    
    NSAttributedString *numberString = [[NSAttributedString alloc]
                                        initWithString:[NSString stringWithFormat:@"%.2f ", number]
                                        attributes:@{NSFontAttributeName: numberFont,
                                                     NSForegroundColorAttributeName: [self colorForEmissions:mass]}];
    [suffixString insertAttributedString:numberString atIndex:0];
    
    return suffixString;
}

+ (UIColor *)colorForEmissions:(CGFloat)mass {
    return (mass < 0.1
            ? [UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0]
            : (mass < 10
               ? [UIColor orangeColor]
               : [UIColor colorWithRed:0.8 green:0 blue:0 alpha:1.0]));
}

@end
