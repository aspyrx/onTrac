//
//  TracksViewController.m
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import "TracksViewController.h"
#import "Defines.h"
#import "Utils.h"
#import "GPX.h"
#import "OnTracExtensions.h"
#import "TrackDetailViewController.h"
#import "SaveViewController.h"

@interface TracksViewController ()

@end


@implementation TracksViewController {
    int recordingState;
    NSMutableArray *gpxFilePaths;
    NSMutableArray *gpxRoots;
    NSMutableDictionary *selectedTrackPaths;
    NSString *dataSuffix;
    NSString *dataUnitText;
}

#pragma mark UITableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // set navbar items
        self.title = @"Tracks";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(popController:)];
        self.navigationItem.rightBarButtonItem = [self editButtonItem];
        
        // register for notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordingStateChanged:) name:kNotificationRecordingStateChanged object:nil];
        
        // update units
        [self updateUnits];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // load saved GPX file paths
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    gpxFilePaths = [NSMutableArray arrayWithArray:[[fileManager contentsOfDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:kTracksDirectory] error:&error] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.gpx'"]]];
    for (int i = 0; i < [gpxFilePaths count]; i++) {
        gpxFilePaths[i] = [[NSHomeDirectory() stringByAppendingPathComponent:kTracksDirectory] stringByAppendingPathComponent:gpxFilePaths[i]];
    }
    gpxRoots = [NSMutableArray new];
    for (NSString *path in gpxFilePaths)
        [gpxRoots addObject:[GPXParser parseGPXAtPath:path]];
    
    // create Settings directory if necessary
    NSString *settingsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:kSettingsDirectory];
    if (![fileManager fileExistsAtPath:settingsDirectory]) {
        [fileManager createDirectoryAtPath:settingsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
            NSLog(@"Error creating Settings directory: %@", error);
    }
    
    // load selected track paths
    selectedTrackPaths = [NSMutableDictionary dictionaryWithContentsOfFile:[settingsDirectory stringByAppendingPathComponent:kSelectedTracksFileName]];
    
    // update units
    [self updateUnits];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // table has 2 sections
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        if (recordingState > kRecordingOff) return 2;
        else return 1;
    else if (section == 1)
        // section 1 has as many rows as there are track files
        return [gpxFilePaths count];
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1)
        // section 1 header
        return @"Saved Tracks";
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UITableViewCell *recordCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (recordingState > kRecordingOff) {
                // recording running/paused, label for saving current track
                recordCell.textLabel.text = @"Save Current Track";
                recordCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                // recording off, label for recording new track
                recordCell.textLabel.text = @"Record New Track";
                recordCell.accessoryType = UITableViewCellAccessoryNone;
            }
            return recordCell;
        } else if (indexPath.row == 1) {
            UITableViewCell *pauseCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            if (recordingState == kRecordingRunning) {
                // recording running, label for pausing
                pauseCell.textLabel.text = @"Pause Recording";
                pauseCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            } else {
                // recording paused, label for resuming
                pauseCell.textLabel.text = @"Resume Recording";
                pauseCell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            return pauseCell;
        }
    } else if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"TrackCell";
        UITableViewCell *trackCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!trackCell) trackCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        // load and parse appropriate gpx file
        GPXRoot *root = [gpxRoots objectAtIndex:indexPath.row];
        
        // set track cell properties
        trackCell.textLabel.text = root.metadata.name;
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"MMM d, yyyy h:mm a"];
        NSString *trackDate = [dateFormatter stringFromDate:root.metadata.time];
        trackCell.detailTextLabel.text = trackDate;
        trackCell.detailTextLabel.attributedText = [Utils attributedStringFromMass:root.metadata.extensions.carbonEmissions baseFontSize:14.0f dataSuffix:dataSuffix unitText:dataUnitText];
        
        trackCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // set appropriate icon image
        UIImage *image = [UIImage imageNamed:([selectedTrackPaths objectForKey:[NSString stringWithFormat:@"%i", indexPath.row]] ? @"eyeIcon.png" : @"slashEyeIcon.png")];
        trackCell.imageView.image = image;
        
        // create selection button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = trackCell.imageView.frame;
        [button setBackgroundColor:[UIColor clearColor]];
        [button setTag:indexPath.row];
        [button addTarget:self action:@selector(trackCellButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [trackCell addSubview:button];
        
        return trackCell;
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1)
        return true;
    else return false;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 1) {
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:[gpxFilePaths objectAtIndex:indexPath.row] error:&error];
        if (error)
            NSLog(@"Error deleting GPX file: %@", error);
        [gpxRoots removeObjectAtIndex:indexPath.row];
        [gpxFilePaths removeObjectAtIndex:indexPath.row];
        [selectedTrackPaths removeObjectForKey:[NSString stringWithFormat:@"%i", indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (recordingState > kRecordingOff) {
                // save selected tracks
                [self saveSelectedTracks];
                
                // alloc and init save view controller, set as nav controller
                SaveViewController *saveViewController = [[SaveViewController alloc] initWithNibName:@"SaveViewController" bundle:nil];
                UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:saveViewController];
                
                // present save view controller modally
                [self presentViewController:navController animated:YES completion:nil];
            } else {
                // start recording
                [self postSetRecordingStatusNotification:kRecordingRunning];
                // pop back to map view controller
                [self popController:nil];
            }
        } else if (indexPath.row == 1) {
            if (recordingState == kRecordingRunning)
                [self postSetRecordingStatusNotification:kRecordingPaused];
            else if (recordingState == kRecordingPaused)
                [self postSetRecordingStatusNotification:kRecordingRunning];
            // pop back to map view controller
            [self popController:nil];
        }
    } else if (indexPath.section == 1) {
        // save selected tracks
        [self saveSelectedTracks];
        
        // go to track detail view controller with selected track
        TrackDetailViewController *controller = [[TrackDetailViewController alloc] initWithFilePath:[gpxFilePaths objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    // deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - interface methods

- (void)trackCellButtonPressed:(id)sender {
    // get table view cell containing the sender
    id superview = [sender superview];
    while (![superview respondsToSelector:@selector(imageView)])
        superview = [superview superview];
    UITableViewCell *cell = (UITableViewCell *)superview;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (!selectedTrackPaths || ![selectedTrackPaths objectForKey:[NSString stringWithFormat:@"%i", indexPath.row]]) {
        cell.imageView.image = [UIImage imageNamed:@"eyeIcon.png"];
        if (selectedTrackPaths)
            [selectedTrackPaths setObject:[gpxFilePaths objectAtIndex:indexPath.row] forKey:[NSString stringWithFormat:@"%i", indexPath.row]];
        else
            selectedTrackPaths = [NSMutableDictionary dictionaryWithObject:[gpxFilePaths objectAtIndex:indexPath.row] forKey:[NSString stringWithFormat:@"%i", indexPath.row]];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"slashEyeIcon.png"];
        [selectedTrackPaths removeObjectForKey:[NSString stringWithFormat:@"%i", indexPath.row]];
    }
}

- (void)popController:(id)sender {
    // save selected tracks
    [self saveSelectedTracks];
    
    // post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUpdateSelectedTracks object:self];
    
    // pop back to map view controller
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - public methods

- (void)setRecordingState:(int)state {
    recordingState = state;
}

#pragma mark - private methods

- (void)saveSelectedTracks {
    // create Settings directory if necessary
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *settingsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:kSettingsDirectory];
    if (![fileManager fileExistsAtPath:settingsDirectory]) {
        [fileManager createDirectoryAtPath:settingsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
            NSLog(@"Error creating Settings directory: %@", error);
    }
    
    // write selected tracks to file
    [selectedTrackPaths writeToFile:[settingsDirectory stringByAppendingPathComponent:kSelectedTracksFileName] atomically:NO];
}

- (void)postSetRecordingStatusNotification:(int)state {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetRecordingStatus object:self userInfo:@{kUserInfoKeyRecordingState: [NSNumber numberWithInt:state]}];
}

- (void)recordingStateChanged:(NSNotification *)notification {
    recordingState = [[[notification userInfo] valueForKey:kUserInfoKeyRecordingState] intValue];
    // update tableview
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)updateUnits {
    NSDictionary *settings = [Utils loadSettings];
    // change unit labels depending on setting
    dataSuffix = [settings objectForKey:kSettingsKeyDataSuffix];
    BOOL useMetric = [[settings objectForKey:kSettingsKeyUseMetric] boolValue];
    dataUnitText = (useMetric ? kUnitTextKG : kUnitTextLBS);
    if ([dataSuffix isEqualToString:kDataSuffixGas])
        dataUnitText = (useMetric ? kUnitTextLiter : kUnitTextGallon);
}

@end
