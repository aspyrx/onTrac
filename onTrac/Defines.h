//
//  Defines.h
//  onTrac
//
//  Created by Stan Zhang on 10/15/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#ifndef onTrac_Defines_h
#define onTrac_Defines_h

// unit conversions
#define KILOMETERS_PER_MILE 1.60934
#define POUNDS_PER_KILOGRAM 2.20462
#define GALLONS_PER_LITER 0.2642
#define RADIUS_EARTH_METERS 6371000
#define RADIANS_PER_DEGREE 0.01745329
#define MPG_PER_100KMPL 235.2

// file paths
static NSString * const kTracksDirectory = @"Documents/Tracks/";
static NSString * const kSettingsDirectory = @"Documents/Settings/";
static NSString * const kSettingsFileName = @"settings.plist";
static NSString * const kSelectedTracksFileName = @"selectedTracks.plist";

// notification names
static NSString * const kNotificationUpdateSelectedTracks = @"updateSelectedTracks";
static NSString * const kNotificationSetRecordingStatus = @"setRecordingStatus";
static NSString * const kNotificationRecordingStateChanged = @"recordingStateChanged";

// userinfo dictionary keys
static NSString * const kUserInfoKeyTrackName = @"trackName";
static NSString * const kUserInfoKeyTrackDescription = @"trackDescription";
static NSString * const kUserInfoKeyRecordingState = @"recordingState";

// settings dictionary keys
static NSString * const kSettingsKeyDataSuffix = @"dataSuffix";
static NSString * const kSettingsKeyUseMetric = @"useMetric";
static NSString * const kSettingsKeyMapMode = @"mapMode";
static NSString * const kSettingsKeyFollowLocation = @"followLocation";
static NSString * const kSettingsKeyFuelEfficiency = @"fuelEfficiency";

// recording states
static NSUInteger const kRecordingRunning = 2;
static NSUInteger const kRecordingPaused = 1;
static NSUInteger const kRecordingOff = 0;

// text for units
static NSString * const kUnitTextKilometer = @"km";
static NSString * const kUnitTextMile = @"mi";
static NSString * const kUnitTextKPH = @"km/h";
static NSString * const kUnitTextMPH = @"mph";
static NSString * const kUnitTextKG = @"kg";
static NSString * const kUnitTextLBS = @"lbs";
static NSString * const kUnitTextLiter = @"L";
static NSString * const kUnitTextGallon = @"gal";

// text for data suffixes
static NSString * const kDataSuffixCO2 = @"CO2";
static NSString * const kDataSuffixGas = @"gas";

// kg CO_2 / L, emissions from 1 L gasoline
static CGFloat const kEmissionsMassPerLiterGas = 2.3477;
// kg CO_2 / kWh, emissions per generated kWh
static CGFloat const kEmissionsMassPerKWH = 0.5534;
// kg CO_2 / hour, emissions for powering a home for 1 hour
static CGFloat const kEmissionsPerHomeHour = 0.54282;

// calories burned / m at given speeds

#endif
