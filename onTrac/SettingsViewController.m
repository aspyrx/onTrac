//
//  SettingsViewController.m
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import <MapKit/MKTypes.h>
#import "SettingsViewController.h"
#import "Defines.h"
#import "Utils.h"
#import "TransportModeViewController.h"
#import "AboutViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

#pragma mark - UITableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // set navbar items
        self.title = @"Settings";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // set navbar properties
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    if (self.settings == nil)
        // load settings
        self.settings = [[Utils loadSettings] mutableCopy];
    
    // reload tableview
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        // Unit cells
        return 2;
    else if (section == 1)
        // Transport mode cell
        return 1;
    else if (section == 2)
        // Displayed data cells
        return 4;
    else if (section == 3)
        // Map mode cells
        return 3;
    else if (section == 4)
        // Follow location cell
        return 1;
    else if (section == 5)
        // About cell
        return 1;
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Units";
    else if (section == 2)
        return @"Displayed Data";
    else if (section == 3)
        return @"Map Mode";
    else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // Unit cells
        BOOL useMetric = [[self.settings objectForKey:kSettingsKeyUseMetric] boolValue];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Imperial";
            cell.accessoryType = (useMetric ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark);
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Metric";
            cell.accessoryType = (useMetric ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        }
        return cell;
    } else if (indexPath.section == 1) {
        // Fuel Efficiency cell
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.textLabel.text = @"Transport Mode";
            NSString *detailText;
            enum transport_mode_t mode = [[self.settings objectForKey:kSettingsKeyTransportMode] intValue];
            switch (mode) {
                case TransportModeCar:
                    detailText = @"Car";
                    break;
                case TransportModeBus:
                    detailText = @"Bus";
                    break;
                case TransportModeTrain:
                    detailText = @"Train";
                    break;
                case TransportModeSubway:
                    detailText = @"Subway";
                    break;
            }
            cell.detailTextLabel.text = detailText;
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.0f green:0.478f blue:1.0f alpha:1.0f];
            return cell;
        }
    } else if (indexPath.section == 2) {
        // Displayed Data cells
        NSString *dataSuffix = [self.settings objectForKey:kSettingsKeyDataSuffix];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Carbon emissions";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixCO2Emitted] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Carbon avoidance";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixCO2Avoided] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Gasoline usage";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixGas] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Calories";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixCalories] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        }
        return cell;
    } else if (indexPath.section == 3) {
        // Map Mode cells
        MKMapType mapMode = [[self.settings objectForKey:kSettingsKeyMapMode] unsignedIntegerValue];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Standard";
            cell.accessoryType = (mapMode == 0 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Satellite";
            cell.accessoryType = (mapMode == 1 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Hybrid";
            cell.accessoryType = (mapMode == 2 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        }
        return cell;
    } else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            // Follow Location cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"Follow Location";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // set up UISwitch for toggling
            UISwitch *switchView = [UISwitch new];
            cell.accessoryView = switchView;
            
            // depending on saved value, set switch position
            if ([[self.settings objectForKey:kSettingsKeyFollowLocation]boolValue])
                [switchView setOn:YES animated:NO];
            else [switchView setOn:NO animated:NO];
            
            // add selector method
            [switchView addTarget:self action:@selector(followLocationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            // About cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"About";
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self.settings setObject:[NSNumber numberWithBool:NO] forKey:kSettingsKeyUseMetric];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 1) {
            [self.settings setObject:[NSNumber numberWithBool:YES] forKey:kSettingsKeyUseMetric];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TransportModeViewController *viewController = [[TransportModeViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:viewController animated:YES];
        }
    } else if (indexPath.section == 2) {
        NSString *value = [self.settings objectForKey:kSettingsKeyDataSuffix];
        NSUInteger oldRow = ([value isEqualToString:kDataSuffixCO2Emitted]
                             ? 0
                             : ([value isEqualToString:kDataSuffixCO2Avoided]
                                ? 1
                                : ([value isEqualToString:kDataSuffixGas]
                                   ? 2
                                   : 3)));
        if (oldRow != indexPath.row) {
            [self.settings setObject:(indexPath.row == 0
                                      ? kDataSuffixCO2Emitted
                                      : (indexPath.row == 1
                                         ? kDataSuffixCO2Avoided
                                         : (indexPath.row == 2
                                            ? kDataSuffixGas
                                            : kDataSuffixCalories))) forKey:kSettingsKeyDataSuffix];
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldRow inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
        }
    } else if (indexPath.section == 3) {
        enum MKMapType value = [[self.settings objectForKey:kSettingsKeyMapMode] intValue];
        NSUInteger oldRow;
        switch (value) {
            case MKMapTypeStandard:
                oldRow = 0;
                break;
            case MKMapTypeSatellite:
                oldRow = 1;
                break;
            case MKMapTypeHybrid:
                oldRow = 2;
                break;
        }
        if (oldRow != indexPath.row) {
            switch (indexPath.row) {
                case 0:
                    value = MKMapTypeStandard;
                    break;
                case 1:
                    value = MKMapTypeSatellite;
                    break;
                case 2:
                    value = MKMapTypeHybrid;
                    break;
            }
            [self.settings setObject:[NSNumber numberWithInt:value] forKey:kSettingsKeyMapMode];
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldRow inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
        }
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            // alloc and init about view controller
            AboutViewController *aboutViewController = [[AboutViewController alloc] init];
            
            // push about view controller
            [self.navigationController pushViewController:aboutViewController animated:YES];
        }
    }
    
    // deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - interface methods

- (void)followLocationSwitchChanged:(id)sender {
    UISwitch *followLocationControl = sender;
    [self.settings setObject:[NSNumber numberWithBool:[followLocationControl isOn]] forKey:kSettingsKeyFollowLocation];
}

- (void)cancelButtonPressed:(id)sender {
    // dismiss options view without saving changes
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveButtonPressed:(id)sender {
    // create Settings directory if necessary
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *settingsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:kSettingsDirectory];
    if (![fileManager fileExistsAtPath:settingsDirectory]) {
        [fileManager createDirectoryAtPath:settingsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
            NSLog(@"Error creating Settings directory: %@", error);
    }
    
    // save settings to plist file, dismiss options view
    [self.settings writeToFile:[settingsDirectory stringByAppendingPathComponent:kSettingsFileName] atomically:NO];
    self.settings = [[Utils loadSettings] mutableCopy];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
