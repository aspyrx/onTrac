//
//  SettingsViewController.m
//  onTrac
//
//  Created by Stan Zhang on 6/10/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import <MapKit/MKTypes.h>
#import "SettingsViewController.h"
#import "Defines.h"
#import "Utils.h"
#import "TransportModeViewController.h"
#import "AboutViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController {
    BOOL useBike;
    BOOL didPopToMainScreen;
}

#pragma mark - UITableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // set navbar items
        self.title = @"Settings";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
        
        didPopToMainScreen = true;
        
        // init tap view and gesture recognizer
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
    if (didPopToMainScreen) {
        self.settings = [[Utils loadSettings] mutableCopy];
        didPopToMainScreen = false;
        useBike = [[self.settings objectForKey:kSettingsKeyUseBike] boolValue];
    }
    
    // reload tableview
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        // Unit cells
        return 2;
    else if (section == 1)
        // Transport mode and cycling speed cells
        return (useBike ? 5 : 4);
    else if (section == 2)
        // Weight cell
        return 1;
    else if (section == 3)
        // Displayed data cells
        return 5;
    else if (section == 4)
        // Map mode cells
        return 3;
    else if (section == 5)
        // Follow location cell
        return 1;
    else if (section == 6)
        // About cell
        return 2;
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return @"Units";
    else if (section == 3)
        return @"Displayed Data";
    else if (section == 4)
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
        if (indexPath.row == 0) {
            // Transport Mode cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
            cell.textLabel.text = @"Transport Mode";
            NSString *detailText;
            enum transport_mode_t mode = [[self.settings objectForKey:kSettingsKeyTransportMode] intValue];
            switch (mode) {
                case TransportModeWalk:
                    detailText = @"Walk";
                    break;
                case TransportModeBike:
                    detailText = @"Bike";
                    break;
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
        } else if (indexPath.row == 1) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            BOOL useMetric = [[self.settings objectForKey:kSettingsKeyUseMetric] boolValue];
            cell.textLabel.text = [NSString stringWithFormat:@"Max walk speed (%@)", (useMetric ? @"km/h" : @"mph")];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - ([self respondsToSelector:@selector(topLayoutGuide)] ? 96 : 110), 0, 80, cell.contentView.frame.size.height)];
            double speed = [[self.settings objectForKey:kSettingsKeySpeedMaxWalk] doubleValue];
            field.text = [NSString stringWithFormat:@"%.2f", [Utils speedFromMetersSec:speed units:(useMetric ? kUnitTextKPH : kUnitTextMPH)]];
            field.textColor = [UIColor colorWithRed:0.0f green:0.478f blue:1.0f alpha:1.0f];
            field.adjustsFontSizeToFitWidth = YES;
            field.textAlignment = NSTextAlignmentRight;
            field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            field.keyboardType = UIKeyboardTypeDecimalPad;
            field.borderStyle = UITextBorderStyleNone;
            [field addTarget:self action:@selector(speedMaxWalkFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [field addTarget:self action:@selector(speedMaxWalkFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            
            [cell.contentView addSubview:field];
            return cell;
        } else if (indexPath.row == 2) {
            // Use Bike cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"Bike Mode";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            // set up UISwitch for toggling
            UISwitch *switchView = [UISwitch new];
            cell.accessoryView = switchView;
            
            // depending on saved value, set switch position
            if ([[self.settings objectForKey:kSettingsKeyUseBike] boolValue])
                [switchView setOn:YES animated:NO];
            else [switchView setOn:NO animated:NO];
            
            // add selector method
            [switchView addTarget:self action:@selector(useBikeSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            return cell;
        } else if (useBike && indexPath.row == 3) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            BOOL useMetric = [[self.settings objectForKey:kSettingsKeyUseMetric] boolValue];
            cell.textLabel.text = [NSString stringWithFormat:@"Max bike speed (%@)", (useMetric ? @"km/h" : @"mph")];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - ([self respondsToSelector:@selector(topLayoutGuide)] ? 96 : 110), 0, 80, cell.contentView.frame.size.height)];
            double speed = [[self.settings objectForKey:kSettingsKeySpeedMaxBike] doubleValue];
            field.text = [NSString stringWithFormat:@"%.2f", [Utils speedFromMetersSec:speed units:(useMetric ? kUnitTextKPH : kUnitTextMPH)]];
            field.textColor = [UIColor colorWithRed:0.0f green:0.478f blue:1.0f alpha:1.0f];
            field.adjustsFontSizeToFitWidth = YES;
            field.textAlignment = NSTextAlignmentRight;
            field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            field.keyboardType = UIKeyboardTypeDecimalPad;
            field.borderStyle = UITextBorderStyleNone;
            [field addTarget:self action:@selector(speedMaxBikeFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [field addTarget:self action:@selector(speedMaxBikeFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            
            [cell.contentView addSubview:field];
            return cell;
        } else if (indexPath.row == (useBike ? 4 : 3)) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:11.5f];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.text = kHelpMaxWalkBikeSpeed;
            return cell;
        }
    } else if (indexPath.section == 2) {
        // Weight cell
        if (indexPath.row == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            BOOL useMetric = [[self.settings objectForKey:kSettingsKeyUseMetric] boolValue];
            cell.textLabel.text = [NSString stringWithFormat:@"Weight (%@)", (useMetric ? @"kg" : @"lbs")];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - ([self respondsToSelector:@selector(topLayoutGuide)] ? 96 : 110), 0, 80, cell.contentView.frame.size.height)];
            double weight = [[self.settings objectForKey:kSettingsKeyWeight] doubleValue];
            field.text = [NSString stringWithFormat:@"%.2f", [Utils massFromKilograms:weight units:(useMetric ? kUnitTextKG : kUnitTextLBS)]];
            field.textColor = [UIColor colorWithRed:0.0f green:0.478f blue:1.0f alpha:1.0f];
            field.adjustsFontSizeToFitWidth = YES;
            field.textAlignment = NSTextAlignmentRight;
            field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            field.keyboardType = UIKeyboardTypeDecimalPad;
            field.borderStyle = UITextBorderStyleNone;
            field.secureTextEntry = YES;
            [field addTarget:self action:@selector(weightFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [field addTarget:self action:@selector(weightFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            
            [cell.contentView addSubview:field];
            
            return cell;
        }
    } else if (indexPath.section == 3) {
        // Displayed Data cells
        NSString *dataSuffix = [self.settings objectForKey:kSettingsKeyDataSuffix];
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Percent emissions";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixAvoidancePercent] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Carbon emissions";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixCO2Emitted] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Carbon avoidance";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixCO2Avoided] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Gasoline usage";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixGas] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Calories";
            cell.accessoryType = ([dataSuffix isEqualToString:kDataSuffixCalories] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        }
        return cell;
    } else if (indexPath.section == 4) {
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
    } else if (indexPath.section == 5) {
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
    } else if (indexPath.section == 6) {
        if (indexPath.row == 0) {
            // About cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"About";
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        } else if (indexPath.row == 1) {
            // Reset Settings cell
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.textLabel.text = @"Reset Settings";
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
    } else if (indexPath.section == 3) {
        NSString *value = [self.settings objectForKey:kSettingsKeyDataSuffix];
        NSUInteger oldRow = ([value isEqualToString:kDataSuffixAvoidancePercent]
                             ? 0
                             : ([value isEqualToString:kDataSuffixCO2Emitted]
                                ? 1
                                : ([value isEqualToString:kDataSuffixCO2Avoided]
                                   ? 2
                                   : ([value isEqualToString:kDataSuffixGas]
                                      ? 3
                                      : 4))));
        if (oldRow != indexPath.row) {
            [self.settings setObject:(indexPath.row == 0
                                      ? kDataSuffixAvoidancePercent
                                      : (indexPath.row == 1
                                         ? kDataSuffixCO2Emitted
                                         : (indexPath.row == 2
                                            ? kDataSuffixCO2Avoided
                                            : (indexPath.row == 3
                                               ? kDataSuffixGas
                                               : kDataSuffixCalories)))) forKey:kSettingsKeyDataSuffix];
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldRow inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
        }
    } else if (indexPath.section == 4) {
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
            [[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldRow inSection:4]] setAccessoryType:UITableViewCellAccessoryNone];
        }
    } else if (indexPath.section == 6) {
        if (indexPath.row == 0) {
            // alloc and init about view controller
            AboutViewController *aboutViewController = [[AboutViewController alloc] init];
            
            // push about view controller
            [self.navigationController pushViewController:aboutViewController animated:YES];
        } else if (indexPath.row == 1) {
            // show alert confirmation
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Reset Settings" message:@"Are you sure you want to reset all settings to their default value?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alertView show];
        }
    }
    
    // deselect row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat defaultHeight = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (indexPath.section == 1 && indexPath.row == ([[self.settings objectForKey:kSettingsKeyUseBike] boolValue] ? 4 : 3)) {
        return MAX(defaultHeight, [kHelpMaxWalkBikeSpeed sizeWithFont:[UIFont systemFontOfSize:11.5f] constrainedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20);
    } else return defaultHeight;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        [Utils deleteSettings];
        self.settings = [[Utils loadSettings] mutableCopy];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - interface methods

- (void)viewTapped:(id)sender {
    if ([self.activeField isFirstResponder])
        [self.activeField resignFirstResponder];
    [self.tapView setHidden:YES];
}

- (void)speedMaxWalkFieldEditingDidBegin:(id)sender {
    self.activeField = sender;
    [self.tapView setHidden:NO];
}

- (void)speedMaxWalkFieldEditingDidEnd:(id)sender {
    self.activeField = nil;
    UITextField *field = sender;
    double num = [[[NSNumberFormatter new] numberFromString:field.text] doubleValue];
    BOOL useMetric = [[self.settings objectForKey:kSettingsKeyUseMetric] boolValue];
    if (num > 0) {
        [self.settings setObject:[NSNumber numberWithDouble:(useMetric ? num / 3.6 : num * 0.44704)] forKey:kSettingsKeySpeedMaxWalk];
    } else [self.settings setObject:[NSNumber numberWithDouble:8.9408] forKey:kSettingsKeySpeedMaxWalk];
}

- (void)useBikeSwitchChanged:(id)sender {
    UISwitch *useBikeControl = sender;
    useBike = [useBikeControl isOn];
    [self.settings setObject:[NSNumber numberWithBool:useBike] forKey:kSettingsKeyUseBike];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)speedMaxBikeFieldEditingDidBegin:(id)sender {
    self.activeField = sender;
    [self.tapView setHidden:NO];
}

- (void)speedMaxBikeFieldEditingDidEnd:(id)sender {
    self.activeField = nil;
    UITextField *field = sender;
    double num = [[[NSNumberFormatter new] numberFromString:field.text] doubleValue];
    BOOL useMetric = [[self.settings objectForKey:kSettingsKeyUseMetric] boolValue];
    if (num > 0) {
        [self.settings setObject:[NSNumber numberWithDouble:(useMetric ? num / 3.6 : num * 0.44704)] forKey:kSettingsKeySpeedMaxBike];
    } else [self.settings setObject:[NSNumber numberWithDouble:8.9408] forKey:kSettingsKeySpeedMaxBike];
}

- (void)weightFieldEditingDidBegin:(id)sender {
    self.activeField = sender;
    [self.tapView setHidden:NO];
}

- (void)weightFieldEditingDidEnd:(id)sender {
    self.activeField = nil;
    UITextField *field = sender;
    double num = [[[NSNumberFormatter new] numberFromString:field.text] doubleValue];
    BOOL useMetric = [[self.settings objectForKey:kSettingsKeyUseMetric] boolValue];
    if (num > 0) {
        [self.settings setObject:[NSNumber numberWithDouble:(useMetric ? num : num * POUNDS_PER_KILOGRAM)] forKey:kSettingsKeyWeight];
    } else [self.settings setObject:[NSNumber numberWithDouble:65] forKey:kSettingsKeyWeight];
}

- (void)followLocationSwitchChanged:(id)sender {
    UISwitch *followLocationControl = sender;
    [self.settings setObject:[NSNumber numberWithBool:[followLocationControl isOn]] forKey:kSettingsKeyFollowLocation];
}

- (void)cancelButtonPressed:(id)sender {
    // dismiss options view without saving changes
    [self dismissViewControllerAnimated:YES completion:nil];
    
    didPopToMainScreen = true;
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
    
    didPopToMainScreen = true;
}

@end
