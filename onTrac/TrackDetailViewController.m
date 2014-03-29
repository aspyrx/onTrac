//
//  TrackDetailViewController.m
//  onTrac
//
//  Created by Stan Zhang on 11/28/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import "TrackDetailViewController.h"
#import "Defines.h"
#import "Utils.h"
#import "GPX.h"
#import "OnTracExtensions.h"

@interface TrackDetailViewController ()

@end

@implementation TrackDetailViewController {
    GPXRoot *gpx;
    NSString *distanceUnitText;
    NSString *speedUnitText;
    NSString *massUnitText;
    NSString *volumeUnitText;
    UIFont *nameFont;
    UIFont *descFont;
    BOOL hasDesc;
    BOOL showHelp;
    CGFloat emissions;
    CGFloat avoidance;
}

- (id)initWithFilePath:(NSString *)filePath {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Track Details";
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(helpButtonPressed:)];
        
        self.filePath = filePath;
        gpx = [Utils rootWithMetadataAtPath:self.filePath];
        NSDictionary *settings = [Utils loadSettings];
        // change unit labels depending on setting
        if ([[settings objectForKey:kSettingsKeyUseMetric] boolValue]) {
            distanceUnitText = kUnitTextKilometer;
            speedUnitText = kUnitTextKPH;
            massUnitText = kUnitTextKG;
            volumeUnitText = kUnitTextLiter;
        } else {
            distanceUnitText = kUnitTextMile;
            speedUnitText = kUnitTextMPH;
            massUnitText = kUnitTextLBS;
            volumeUnitText = kUnitTextGallon;
        }
        
        nameFont = [UIFont systemFontOfSize:16.0];
        descFont = [UIFont systemFontOfSize:14.0];
        hasDesc = [gpx.metadata.desc length] > 0;
        
        emissions = gpx.metadata.extensions.carbonEmissions;
        avoidance = gpx.metadata.extensions.carbonAvoidance;
        
        showHelp = false;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return (hasDesc ? 7 : 6);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
        // track name
        return 1;
    else if (section == 1)
        // footprint data
        return (showHelp ? 10 : 5);
    else if (section == 2)
        // equivalences
        return 2;
    else if (hasDesc && section == 3)
        // description
        return 1;
    else if (section == (hasDesc ? 4 : 3))
        // track details
        return 5;
    else if (section == (hasDesc ? 5 : 4))
        // time details
        return 6;
    else if (section == (hasDesc ? 6 : 5))
        // distance details
        return 6;
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Return the header for each section.
    if (section == 0) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"EEE, MMM d, YYYY h:mm a"];
        return [dateFormatter stringFromDate:gpx.metadata.time];
    } else if (section == 2)
        return @"Your footprint was equal to...";
    else if (hasDesc && section == 3)
        return @"Track Description";
    else if (section == (hasDesc ? 4 : 3))
        return @"More Details";
    else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = gpx.metadata.name;
        cell.textLabel.font = nameFont;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        return cell;
    } else if (indexPath.section == 1) {
        if (!showHelp || indexPath.row % 2 == 0) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"dataDisplayCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            if (indexPath.row == 0) {
                    cell.textLabel.text = @"Ratio";
                    cell.detailTextLabel.attributedText = [Utils attributedStringFromNumber:(emissions / (gpx.metadata.extensions.totalDistance * kEmissionsMassPerMeterCar)) * 100 baseFontSize:18.0f dataSuffix:kDataSuffixAvoidancePercent unitText:kUnitTextPercent];
            } else if (indexPath.row == (showHelp ? 2 : 1)) {
                    cell.textLabel.text = @"Emissions";
                    cell.detailTextLabel.attributedText = [Utils attributedStringFromNumber:emissions baseFontSize:18.0f dataSuffix:kDataSuffixCO2Emitted unitText:massUnitText];
            } else if (indexPath.row == (showHelp ? 4 : 2)) {
                    cell.textLabel.text = @"Avoidance";
                    cell.detailTextLabel.attributedText = [Utils attributedStringFromNumber:avoidance baseFontSize:18.0f dataSuffix:kDataSuffixCO2Avoided unitText:massUnitText];
            } else if (indexPath.row == (showHelp ? 6 : 3)) {
                    cell.textLabel.text = @"Gasoline";
                    cell.detailTextLabel.attributedText = [Utils attributedStringFromNumber:emissions baseFontSize:18.0f dataSuffix:kDataSuffixGas unitText:volumeUnitText];
            } else if (indexPath.row == (showHelp ? 8 : 4)) {
                    cell.textLabel.text = @"Calories";
                    cell.detailTextLabel.attributedText = [Utils attributedStringFromNumber:gpx.metadata.extensions.caloriesBurned baseFontSize:18.0f dataSuffix:kDataSuffixCalories unitText:kUnitTextCalorie];
            }
            return cell;
        } else {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dataDisplayCellCaption"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.textColor = [UIColor darkGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:11.5f];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            switch (indexPath.row) {
                case 1:
                    cell.textLabel.text = kHelpAvoidancePercent;
                    break;
                case 3:
                    cell.textLabel.text = kHelpCO2Emitted;
                    break;
                case 5:
                    cell.textLabel.text = kHelpCO2Avoided;
                    break;
                case 7:
                    cell.textLabel.text = kHelpGas;
                    break;
                case 9:
                    cell.textLabel.text = kHelpCalories;
                    break;
            }
            return cell;
        }
    } else if (indexPath.section == 2) {
        static NSString *cellIdentifier = @"equivalenceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIFont *titleFont = [UIFont systemFontOfSize:12.0];
        UIFont *numberFont = [UIFont systemFontOfSize:17.0];
        UIFont *suffixFont = [UIFont systemFontOfSize:13.0];
        switch (indexPath.row) {
            case 0: {
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                                   initWithString:@"...powering a home for "
                                                   attributes:@{NSFontAttributeName: titleFont}];
                NSAttributedString *number = [[NSAttributedString alloc]
                                              initWithString:[NSString stringWithFormat:@"%.1f", emissions / kEmissionsPerHomeHour]
                                              attributes:@{NSFontAttributeName: numberFont,
                                                           NSForegroundColorAttributeName: [Utils colorForNumber:emissions dataSuffix:kDataSuffixCO2Emitted]}];
                NSAttributedString *suffix = [[NSAttributedString alloc]
                                              initWithString:@" hours"
                                              attributes:@{NSFontAttributeName: suffixFont}];
                [text appendAttributedString:number];
                [text appendAttributedString:suffix];
                cell.textLabel.attributedText = text;
                return cell;
            } case 1: {
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                                   initWithString:@"...leaving a lightbulb on for "
                                                   attributes:@{NSFontAttributeName: titleFont}];
                NSAttributedString *number = [[NSAttributedString alloc]
                                              initWithString:[NSString stringWithFormat:@"%.1f", emissions / kEmissionsMassPerKWH * 5 / 3]
                                              attributes:@{NSFontAttributeName: numberFont,
                                                           NSForegroundColorAttributeName: [Utils colorForNumber:emissions dataSuffix:kDataSuffixCO2Emitted]}];
                NSAttributedString *suffix = [[NSAttributedString alloc]
                                              initWithString:@" days"
                                              attributes:@{NSFontAttributeName: suffixFont}];
                [text appendAttributedString:number];
                [text appendAttributedString:suffix];
                cell.textLabel.attributedText = text;
                return cell;
            }
        }
    } else if (hasDesc && indexPath.section == 3) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = gpx.metadata.desc;
        cell.textLabel.font = descFont;
        return cell;
    } else if (indexPath.section == (hasDesc ? 4 : 3)) {
        static NSString *cellIdentifier = @"detailsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [Utils distanceFromMeters:gpx.metadata.extensions.totalDistance units:distanceUnitText], distanceUnitText];
                cell.textLabel.text = @"Total Distance";
                return cell;
            case 1:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.totalTime];
                cell.textLabel.text = @"Total Time";
                return cell;
            case 2:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeMoving];
                cell.textLabel.text = @"Time Moving";
                return cell;
            case 3:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeStopped];
                cell.textLabel.text = @"Time Stopped";
                return cell;
            case 4:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [Utils speedFromMetersSec:gpx.metadata.extensions.averageSpeed units:speedUnitText], speedUnitText];
                cell.textLabel.text = @"Average Speed";
                return cell;
        }
    } else if (indexPath.section == (hasDesc ? 5 : 4)) {
        static NSString *cellIdentifier = @"timeDetailsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeWalk];
                cell.textLabel.text = @"Time Walking";
                return cell;
            case 1:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeBike];
                cell.textLabel.text = @"Time Biking";
                return cell;
            case 2:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeCar];
                cell.textLabel.text = @"Time Driving";
                return cell;
            case 3:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeBus];
                cell.textLabel.text = @"Time on Bus";
                return cell;
            case 4:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeTrain];
                cell.textLabel.text = @"Time on Train";
                return cell;
            case 5:
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeSubway];
                cell.textLabel.text = @"Time on Subway";
                return cell;
        }
    } else if (indexPath.section == (hasDesc ? 6 : 5)) {
        static NSString *cellIdentifier = @"distanceDetailsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [Utils distanceFromMeters:gpx.metadata.extensions.distanceWalk units:distanceUnitText], distanceUnitText];
                cell.textLabel.text = @"Distance Walking";
                return cell;
            case 1:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [Utils distanceFromMeters:gpx.metadata.extensions.distanceBike units:distanceUnitText], distanceUnitText];
                cell.textLabel.text = @"Distance Biking";
                return cell;
            case 2:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [Utils distanceFromMeters:gpx.metadata.extensions.distanceCar units:distanceUnitText], distanceUnitText];
                cell.textLabel.text = @"Distance Driving";
                return cell;
            case 3:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [Utils distanceFromMeters:gpx.metadata.extensions.distanceBus units:distanceUnitText], distanceUnitText];
                cell.textLabel.text = @"Distance on Bus";
                return cell;
            case 4:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [Utils distanceFromMeters:gpx.metadata.extensions.distanceTrain units:distanceUnitText], distanceUnitText];
                cell.textLabel.text = @"Distance on Train";
                return cell;
            case 5:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f%@", [Utils distanceFromMeters:gpx.metadata.extensions.distanceSubway units:distanceUnitText], distanceUnitText];
                cell.textLabel.text = @"Distance on Subway";
                return cell;
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat defaultHeight = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        return MAX(defaultHeight, [gpx.metadata.name sizeWithFont:nameFont constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 120, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    } else if (showHelp && indexPath.section == 1 && indexPath.row % 2 == 1) {
        UIFont *font = [UIFont systemFontOfSize:11.5f];
        switch (indexPath.row) {
            case 1:
                return MAX(defaultHeight, [kHelpAvoidancePercent sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20);
            case 3:
                return MAX(defaultHeight, [kHelpCO2Emitted sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20);
            case 5:
                return MAX(defaultHeight, [kHelpCO2Avoided sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20);
            case 7:
                return MAX(defaultHeight, [kHelpGas sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20);
            case 9:
                return MAX(defaultHeight, [kHelpCalories sizeWithFont:font constrainedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20);
            default:
                return defaultHeight;
        }
    } else if (hasDesc && indexPath.section == 3) {
        return MAX(defaultHeight, [gpx.metadata.desc sizeWithFont:descFont constrainedToSize:CGSizeMake(self.tableView.frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height + 20);
    } else return defaultHeight;
}

#pragma mark - interface methods

- (void)helpButtonPressed:(id)sender {
    showHelp = !showHelp;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

@end
