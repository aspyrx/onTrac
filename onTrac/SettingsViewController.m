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
#import "AboutViewController.h"

#define MPG_PER_100KMPL 235.2
@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    NSMutableDictionary *settings;
}

#pragma mark - UITableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // set navbar items
        self.title = @"Settings";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
        self.tapView = [[UIView alloc] initWithFrame:self.tableView.frame];
        self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
        [self.tapView addGestureRecognizer:self.tapRecognizer];
        [self.view addSubview:self.tapView];
        [self.tapView setHidden:YES];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // set navbar properties
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    // load settings
    settings = [[Utils loadSettings] mutableCopy];
    
    // reload tableview
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;
    else if (section == 1)
        return 1;
    else if (section == 2)
        return 2;
    else if (section == 3)
        return 3;
    else if (section == 4)
        return 1;
    else if (section == 5)
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
        BOOL useMetric = [[settings objectForKey:@(kSettingsKeyUseMetric)] boolValue];
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
            BOOL useMetric = [[settings objectForKey:@(kSettingsKeyUseMetric)] boolValue];
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = [@"Fuel Efficiency (" stringByAppendingString:(useMetric ? @"L/100km)" : @"mpg)")];
            
            // create text field
            // TODO: fix positioning in iOS 6.1
            UITextField *fuelEfficiencyField = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - ([self respondsToSelector:@selector(topLayoutGuide)] ? 96 : 110), 0, 80, cell.contentView.frame.size.height)];
            fuelEfficiencyField.adjustsFontSizeToFitWidth = YES;
            fuelEfficiencyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            CGFloat efficiency = [[settings objectForKey:@(kSettingsKeyFuelEfficiency)] floatValue];
            fuelEfficiencyField.text = [NSString stringWithFormat:@"%.1f", (useMetric ? efficiency : 1 / efficiency * MPG_PER_100KMPL)];
            fuelEfficiencyField.textColor = [UIColor colorWithRed:0.0f green:0.478f blue:1.0f alpha:1.0f];
            fuelEfficiencyField.textAlignment = NSTextAlignmentRight;
            fuelEfficiencyField.keyboardType = UIKeyboardTypeDecimalPad;
            fuelEfficiencyField.borderStyle = UITextBorderStyleNone;
            [fuelEfficiencyField addTarget:self action:@selector(fuelEfficiencyFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [fuelEfficiencyField addTarget:self action:@selector(fuelEfficiencyFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            
            [cell.contentView addSubview:fuelEfficiencyField];
            
            return cell;
        }
    } else if (indexPath.section == 2) {
        // Displayed Data cells
        NSString *dataSuffix = [settings objectForKey:@(kSettingsKeyDataSuffix)];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Carbon emissions";
            cell.accessoryType = ([dataSuffix isEqualToString:@(kDataSuffixCO2)] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Gasoline usage";
            cell.accessoryType = ([dataSuffix isEqualToString:@(kDataSuffixGas)] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        }
        return cell;
    } else if (indexPath.section == 3) {
        // Map Mode cells
        MKMapType mapMode = [[settings objectForKey:@(kSettingsKeyMapMode)] unsignedIntegerValue];
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
            if ([[settings objectForKey:@(kSettingsKeyFollowLocation)]boolValue])
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
            [settings setObject:[NSNumber numberWithBool:NO] forKey:@(kSettingsKeyUseMetric)];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 1) {
            [settings setObject:[NSNumber numberWithBool:YES] forKey:@(kSettingsKeyUseMetric)];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            [settings setObject:@(kDataSuffixCO2) forKey:@(kSettingsKeyDataSuffix)];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]].accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 1) {
            [settings setObject:@(kDataSuffixGas) forKey:@(kSettingsKeyDataSuffix)];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]].accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [settings setObject:[NSNumber numberWithUnsignedInteger:MKMapTypeStandard] forKey:@(kSettingsKeyMapMode)];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]].accessoryType = UITableViewCellAccessoryNone;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]].accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 1) {
            [settings setObject:[NSNumber numberWithUnsignedInteger:MKMapTypeSatellite] forKey:@(kSettingsKeyMapMode)];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]].accessoryType = UITableViewCellAccessoryNone;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]].accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 2) {
            [settings setObject:[NSNumber numberWithUnsignedInteger:MKMapTypeHybrid] forKey:@(kSettingsKeyMapMode)];
            [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]].accessoryType = UITableViewCellAccessoryNone;
            [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]].accessoryType = UITableViewCellAccessoryNone;
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

- (void)viewTapped:(id)sender {
    if ([self.activeField isFirstResponder])
        [self.activeField resignFirstResponder];
    [self.tapView setHidden:YES];
}

- (void)fuelEfficiencyFieldEditingDidBegin:(id)sender {
    self.activeField = sender;
    [self.tapView setHidden:NO];
}

- (void)fuelEfficiencyFieldEditingDidEnd:(id)sender {
    self.activeField = nil;
    UITextField *field = sender;
    if (field.text) {
        BOOL useMetric = [[settings objectForKey:@(kSettingsKeyUseMetric)] boolValue];
        CGFloat efficiency = [[[NSNumberFormatter new] numberFromString:field.text] floatValue];
        [settings setObject:[NSNumber numberWithFloat:(useMetric ? efficiency : 1 / (efficiency / MPG_PER_100KMPL))] forKey:@(kSettingsKeyFuelEfficiency)];
    } else [settings setObject:[NSNumber numberWithFloat:9.484f] forKey:@(kSettingsKeyFuelEfficiency)];
}

- (void)followLocationSwitchChanged:(id)sender {
    UISwitch *followLocationControl = sender;
    [settings setObject:[NSNumber numberWithBool:[followLocationControl isOn]] forKey:@(kSettingsKeyFollowLocation)];
}

- (void)cancelButtonPressed:(id)sender {
    // dismiss options view without saving changes
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveButtonPressed:(id)sender {
    // create Settings directory if necessary
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *settingsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@(kSettingsDirectory)];
    if (![fileManager fileExistsAtPath:settingsDirectory]) {
        [fileManager createDirectoryAtPath:settingsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
        if (error)
            NSLog(@"Error creating Settings directory: %@", error);
    }
    
    // save settings to plist file, dismiss options view
    [settings writeToFile:[settingsDirectory stringByAppendingPathComponent:@(kSettingsFileName)] atomically:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
