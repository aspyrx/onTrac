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
static NSString *kTracksDirectory = @"Documents/Tracks/";
static NSString *kSettingsDirectory = @"Documents/Settings/";
static NSString *kSettingsFileName = @"settings.plist";
static NSString *kSelectedTracksFileName = @"selectedTracks.plist";

// notification names
static NSString *kNotificationUpdateSelectedTracks = @"updateSelectedTracks";
static NSString *kNotificationSetRecordingStatus = @"setRecordingStatus";
static NSString *kNotificationRecordingStateChanged = @"recordingStateChanged";

// userinfo dictionary keys
static NSString *kUserInfoKeyTrackName = @"trackName";
static NSString *kUserInfoKeyTrackDescription = @"trackDescription";
static NSString *kUserInfoKeyRecordingState = @"recordingState";

// settings dictionary keys
static NSString *kSettingsKeyUseMetric = @"useMetric";
static NSString *kSettingsKeyDataSuffix = @"dataSuffix";
static NSString *kSettingsKeyEmissionsPerMeter = @"emissionsPerMeter";
static NSString *kSettingsKeyUserCarEmissionsPerMeter = @"userCarEmissionsPerMeter";
static NSString *kSettingsKeyMaxWalkBikeSpeed = @"maxWalkBikeSpeed";
static NSString *kSettingsKeyTransportMode = @"transportMode";
static NSString *kSettingsKeyMapMode = @"mapMode";
static NSString *kSettingsKeyFollowLocation = @"followLocation";

// text for units
static NSString *kUnitTextKilometer = @" km";
static NSString *kUnitTextMile = @" mi";
static NSString *kUnitTextKPH = @" km/h";
static NSString *kUnitTextMPH = @" mph";
static NSString *kUnitTextKG = @" kg";
static NSString *kUnitTextLBS = @" lbs";
static NSString *kUnitTextLiter = @" L";
static NSString *kUnitTextGallon = @" gal";
static NSString *kUnitTextCalorie = @" Cal";
static NSString *kUnitTextPercent = @"%";

// text for data suffixes
static NSString *kDataSuffixAvoidancePercent = @"emissions";
static NSString *kDataSuffixCO2Emitted = @"CO2 emitted";
static NSString *kDataSuffixCO2Avoided = @"CO2 saved";
static NSString *kDataSuffixGas = @"gas used";
static NSString *kDataSuffixCalories = @"burned";

// transport modes
enum transport_mode_t {
    TransportModeCar,
    TransportModeBus,
    TransportModeTrain,
    TransportModeSubway
};

// recording states
enum recording_state_t {
    RecordingStateOff,
    RecordingStatePaused,
    RecordingStateRunning
};

// help texts
static NSString *kHelpAvoidancePercent = @"The amount of your emissions compared to the emissions of the average American car travelling the same distance. Lower is better.";
static NSString *kHelpCO2Emitted = @"The amount of carbon emitted during the trip. Lower is better.";
static NSString *kHelpCO2Avoided = @"The amount of carbon saved by using transport modes more efficient than driving the average American car. Higher is better.";
static NSString *kHelpGas = @"The equivalent amount of gasoline consumed to emit the same amount of carbon. Lower is better.";
static NSString *kHelpCalories = @"The amount of calories burned while walking, running, or biking during the trip.";
static NSString *kHelpMaxWalkBikeSpeed = @"Your maximum walking/running/biking speed. When your speed passes this value, your transport mode will be detected as driving/public transit.";

// kg CO_2 / L, emissions from 1 L gasoline
static CGFloat const kEmissionsMassPerLiterGas = 2.3477;
// kg CO_2 / kWh, emissions per generated kWh
static CGFloat const kEmissionsMassPerKWH = 0.5534;
// kg CO_2 / hour, emissions for powering a home for 1 hour
static CGFloat const kEmissionsPerHomeHour = 0.54282;

static double const kEmissionsMassPerMeterCar = 0.0002717653201;
static double const kEmissionsMassPerMeterBus = 0.0001657655687;
static double const kEmissionsMassPerMeterTrain = 0.0000893668117;
static double const kEmissionsMassPerMeterSubway = 0.0000366488502;

#endif
