//
//  TransportModeViewController.m
//  onTrac
//
//  Created by Stan Zhang on 12/30/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
//

#import "TransportModeViewController.h"
#import "Defines.h"
#import "SettingsViewController.h"

@interface TransportModeViewController ()

@end

@implementation TransportModeViewController {
    BOOL useMetric;
    enum transport_mode_t mode;
    double emissionsPerMeter;
    double userCarEmissionsPerMeter;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // set navbar items
        self.title = @"Transport Mode";
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        
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
    
    // get settings
    NSArray *controllers = self.navigationController.viewControllers;
    NSMutableDictionary *settings = ((SettingsViewController *) [controllers objectAtIndex:[controllers count] - 2]).settings;
    useMetric = [[settings objectForKey:kSettingsKeyUseMetric] boolValue];
    mode = [[settings objectForKey:kSettingsKeyTransportMode] intValue];
    emissionsPerMeter = [[settings objectForKey:kSettingsKeyEmissionsPerMeter] doubleValue];
    userCarEmissionsPerMeter = [[settings objectForKey:kSettingsKeyUserCarEmissionsPerMeter] doubleValue];
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return (mode == TransportModeCar ? 5 : 4);
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        NSUInteger isCar = (mode == TransportModeCar ? 1 : 0);
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Car";
            cell.accessoryType = (isCar ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (isCar == 1 && indexPath.row == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"Gas Mileage (%@)", (useMetric ? @"L/100km" : @"mpg")];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UITextField *efficiencyField = [[UITextField alloc] initWithFrame:CGRectMake(cell.contentView.frame.size.width - ([self respondsToSelector:@selector(topLayoutGuide)] ? 96 : 110), 0, 80, cell.contentView.frame.size.height)];
            double efficiency = userCarEmissionsPerMeter * 100000 / kEmissionsMassPerLiterGas;
            efficiencyField.text = [NSString stringWithFormat:@"%.2f", (useMetric ? efficiency : 1 / efficiency * MPG_PER_100KMPL)];
            efficiencyField.textColor = [UIColor colorWithRed:0.0f green:0.478f blue:1.0f alpha:1.0f];
            efficiencyField.adjustsFontSizeToFitWidth = YES;
            efficiencyField.textAlignment = NSTextAlignmentRight;
            efficiencyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            efficiencyField.keyboardType = UIKeyboardTypeDecimalPad;
            efficiencyField.borderStyle = UITextBorderStyleNone;
            [efficiencyField addTarget:self action:@selector(efficiencyFieldEditingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
            [efficiencyField addTarget:self action:@selector(efficiencyFieldEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
            
            [cell.contentView addSubview:efficiencyField];
        } else if (indexPath.row == 1 + isCar) {
            cell.textLabel.text = @"Bus";
            cell.accessoryType = (mode == TransportModeBus ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 2 + isCar) {
            cell.textLabel.text = @"Train";
            cell.accessoryType = (mode == TransportModeTrain ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        } else if (indexPath.row == 3 + isCar) {
            cell.textLabel.text = @"Subway";
            cell.accessoryType = (mode == TransportModeSubway ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
        }
        return cell;
    } else return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger isCar = (mode == TransportModeCar ? 1 : 0);
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            mode = TransportModeCar;
            emissionsPerMeter = userCarEmissionsPerMeter;
        } else if (indexPath.row == 1 + isCar) {
            mode = TransportModeBus;
            emissionsPerMeter = kEmissionsMassPerMeterBus;
        } else if (indexPath.row == 2 + isCar) {
            mode = TransportModeTrain;
            emissionsPerMeter = kEmissionsMassPerMeterTrain;
        } else if (indexPath.row == 3 + isCar) {
            mode = TransportModeSubway;
            emissionsPerMeter = kEmissionsMassPerMeterSubway;
        }
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
}

#pragma mark - interface methods

- (void)doneButtonPressed:(id)sender {
    NSArray *controllers = self.navigationController.viewControllers;
    SettingsViewController *controller = ((SettingsViewController *) [controllers objectAtIndex:[controllers count] - 2]);
    [controller.settings setObject:[NSNumber numberWithInt:mode] forKey:kSettingsKeyTransportMode];
    [controller.settings setObject:[NSNumber numberWithDouble:emissionsPerMeter] forKey:kSettingsKeyEmissionsPerMeter];
    [controller.settings setObject:[NSNumber numberWithDouble:userCarEmissionsPerMeter] forKey:kSettingsKeyUserCarEmissionsPerMeter];
    [controller.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewTapped:(id)sender {
    if ([self.activeField isFirstResponder])
        [self.activeField resignFirstResponder];
    [self.tapView setHidden:YES];
}

- (void)efficiencyFieldEditingDidBegin:(id)sender {
    self.activeField = sender;
    [self.tapView setHidden:NO];
}

- (void)efficiencyFieldEditingDidEnd:(id)sender {
    self.activeField = nil;
    UITextField *field = sender;
    double num = [[[NSNumberFormatter new] numberFromString:field.text] doubleValue];
    if (num > 0) {
        emissionsPerMeter =
        userCarEmissionsPerMeter = (useMetric ? num : 1 / (num / MPG_PER_100KMPL)) * kEmissionsMassPerLiterGas / 100000;
    } else emissionsPerMeter = userCarEmissionsPerMeter = kEmissionsMassPerMeterCar;
}

@end
