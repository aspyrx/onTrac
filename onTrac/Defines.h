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

// file paths
#define kTracksDirectory "Documents/Tracks/"
#define kSettingsDirectory "Documents/Settings/"
#define kSettingsFileName "settings.plist"
#define kSelectedTracksFileName "selectedTracks.plist"

// notification names
#define kNotificationUpdateSelectedTracks "updateSelectedTracks"
#define kNotificationSetRecordingStatus "setRecordingStatus"
#define kNotificationRecordingStateChanged "recordingStateChanged"

// userinfo dictionary keys
#define kUserInfoKeyTrackName "trackName"
#define kUserInfoKeyTrackDescription "trackDescription"
#define kUserInfoKeyRecordingState "recordingState"

// settings dictionary keys
#define kSettingsKeyDataSuffix "dataSuffix"
#define kSettingsKeyUseMetric "useMetric"
#define kSettingsKeyMapMode "mapMode"
#define kSettingsKeyFollowLocation "followLocation"
#define kSettingsKeyFuelEfficiency "fuelEfficiency"

// recording states
#define kRecordingRunning 2
#define kRecordingPaused 1
#define kRecordingOff 0

// text for units
#define kUnitTextKilometer "km"
#define kUnitTextMile "mi"
#define kUnitTextKPH "km/h"
#define kUnitTextMPH "mph"
#define kUnitTextKG "kg"
#define kUnitTextLBS "lbs"
#define kUnitTextLiter "L"
#define kUnitTextGallon "gal"

// text for data suffixes
#define kDataSuffixCO2 "CO2"
#define kDataSuffixGas "gas"

// kg CO_2 / L, emissions from 1 L gasoline
#define kEmissionsMassPerLiterGas 2.3477
// kg CO_2 / kWh, emissions per generated kWh
#define kEmissionsMassPerKWH 0.5534
// kg CO_2 / hour, emissions for powering a home for 1 hour
#define kEmissionsPerHomeHour 0.54282

#endif
