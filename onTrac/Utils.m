//
//  Utils.m
//  onTrac
//
//  Created by Stan Zhang on 12/26/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import "Utils.h"
#import "Defines.h"
#import "GPX.h"

@implementation Utils

+ (CGFloat)speedBetweenLocation:(CLLocation *)oldLocation location:(CLLocation *)newLocation {
    return [Utils metersBetweenCoordinate:oldLocation.coordinate coordinate:newLocation.coordinate] / (newLocation.timestamp.timeIntervalSinceReferenceDate - oldLocation.timestamp.timeIntervalSinceReferenceDate);
}

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

+ (double)caloriesBurnedForMode:(enum transport_mode_t)mode time:(NSTimeInterval)time speed:(double)speed weight:(double)weight {
    if ((speed < 1.1176 && mode == TransportModeWalk) || mode == TransportModeCar || mode == TransportModeBus) {
        return 1.5 * weight * (time / 3600);
    } else if (speed >= 1.1176 && mode == TransportModeWalk) {
        return (-3.9 + 2.3 * (speed * 3.6 / KILOMETERS_PER_MILE)) * weight * (time / 3600);
    } else if (mode == TransportModeTrain || mode == TransportModeSubway) {
        return 2 * weight * (time / 3600);
    } else if (mode == TransportModeBike) {
        return 8 * weight * (time / 3600);
    } else return 0;
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

+ (BOOL)deleteSettings {
    // check if settings file exists
    NSString *settingsPath = [[NSHomeDirectory() stringByAppendingPathComponent:kSettingsDirectory] stringByAppendingPathComponent:kSettingsFileName];
    NSFileManager *fileManager = [NSFileManager new];
    if ([fileManager fileExistsAtPath:settingsPath]) {
        NSError *error;
        [fileManager removeItemAtPath:settingsPath error:&error];
        if (error) {
            NSLog(@"%@%@", @"Error removing item at path: ", settingsPath);
            return false;
        } else return true;
    } else return true;
}

+ (NSAttributedString *)attributedStringFromNumber:(CGFloat)num baseFontSize:(CGFloat)size dataSuffix:(NSString *)dataSuffix unitText:(NSString *)unitText {
    UIFont *numberFont = [UIFont systemFontOfSize:size];
    UIFont *suffixFont = [UIFont systemFontOfSize:0.8 * size];
    NSMutableAttributedString *suffixString = [[NSMutableAttributedString alloc]
                                               initWithString:[NSString stringWithFormat:@"%@ %@", unitText, dataSuffix]
                                               attributes:@{NSFontAttributeName: suffixFont}];
    CGFloat number = 0.0f;
    UIColor *numberColor = [Utils colorForNumber:num dataSuffix:dataSuffix];
    if ([dataSuffix isEqualToString:kDataSuffixAvoidancePercent]) {
        number = (isnan(num) ? 0 : num);
    } else if ([dataSuffix isEqualToString:kDataSuffixCO2Emitted]
               || [dataSuffix isEqualToString:kDataSuffixCO2Avoided]) {
        number = [Utils massFromKilograms:num units:unitText];
        
        // add subscript to the "2" in CO2
        UIFont *subscriptFont = [UIFont systemFontOfSize:0.6 * size];
        NSRange range = [suffixString.string rangeOfString:@"2"];
        [suffixString beginEditing];
        [suffixString addAttribute:NSFontAttributeName value:subscriptFont range:range];
        [suffixString addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:-2.0] range:range];
        [suffixString endEditing];
    } else if ([dataSuffix isEqualToString:kDataSuffixGas]) {
        number = [Utils volumeFromLiters:num / kEmissionsMassPerLiterGas units:unitText];
    } else if ([dataSuffix isEqualToString:kDataSuffixCalories]) {
        number = num;
    }
    
    NSAttributedString *numberString = [[NSAttributedString alloc]
                                        initWithString:[NSString stringWithFormat:@"%.2f", number]
                                        attributes:@{NSFontAttributeName: numberFont,
                                                     NSForegroundColorAttributeName: numberColor}];
    [suffixString insertAttributedString:numberString atIndex:0];
    
    return suffixString;
}

+ (UIColor *)colorForNumber:(CGFloat)num dataSuffix:(NSString *)dataSuffix {
    if ([dataSuffix isEqualToString:kDataSuffixAvoidancePercent]) {
        return (num < 100 ? [UIColor colorWithRed:0.0f green:0.8f blue:0.0f alpha:1.0f]
                : (num < 105 ? [UIColor orangeColor]
                   : [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f]));
    } else if ([dataSuffix isEqualToString:kDataSuffixCO2Emitted] || [dataSuffix isEqualToString:kDataSuffixGas]) {
        return (num < 0.1
                ? [UIColor colorWithRed:0.0f green:0.8f blue:0.0f alpha:1.0f]
                : (num < 10
                   ? [UIColor orangeColor]
                   : [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f]));
    } else if ([dataSuffix isEqualToString:kDataSuffixCO2Avoided]) {
        return (num > 0
                ? [UIColor colorWithRed:0.0f green:0.8f blue:0.0f alpha:1.0f]
                : [UIColor colorWithRed:0.8f green:0.0f blue:0.0f alpha:1.0f]);
    } else if ([dataSuffix isEqualToString:kDataSuffixCalories]) {
        return [UIColor colorWithRed:0.0f green:0.8f blue:0.0f alpha:1.0f];
    } else return nil;
}

+ (GPXRoot *)rootWithMetadataAtPath:(NSString *)path {
    // get gpx string at path
    NSError *error;
    NSString *gpxString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error reading GPX from file: %@", error);
        return nil;
    }
    
    // get range of metadata closing tag
    NSRange tagRange = [gpxString rangeOfString:@"</metadata>"];
    // truncate string to metadata tag, append gpx closing tag
    gpxString = [[gpxString substringToIndex:tagRange.location + tagRange.length] stringByAppendingString:@"</gpx>"];
    // parse and return
    return [GPXParser parseGPXWithString:gpxString];
}

@end
