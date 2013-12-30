//
//  TrackDetailViewController.m
//  onTrac
//
//  Created by Stan Zhang on 11/28/13.
//  Copyright (c) 2013 caekboard. All rights reserved.
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
    CGFloat emissions;
    UIColor *numberColor;
}

- (id)initWithFilePath:(NSString *)filePath {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"Track Details";
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
        numberColor = [Utils colorForEmissions:emissions];
        
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return (hasDesc ? 5 : 4);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
        return 1;
    else if (section == 1)
        return 3;
    else if (section == 2)
        return 2;
    else if (hasDesc && section == 3)
            return 1;
    else if ((!hasDesc && section == 3) || section == 4)
        return 5;
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // Return the header for each section.
    if (section == 0) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"EEE, MMM d, YYYY h:mm a"];
        return [dateFormatter stringFromDate:gpx.metadata.time];
    } else if (section == 2)
        return @"That's the same as...";
    else if (hasDesc && section == 3)
            return @"Track Description";
    else if ((!hasDesc && section == 3) || section == 4)
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
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"dataDisplayCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        switch (indexPath.row) {
            case 0: {
                cell.textLabel.text = @"Emissions";
                cell.detailTextLabel.attributedText = [Utils attributedStringFromNumber:emissions baseFontSize:18.0f dataSuffix:kDataSuffixCO2 unitText:massUnitText];
                break;
            } case 1: {
                cell.textLabel.text = @"Fuel Used";
                cell.detailTextLabel.attributedText = [Utils attributedStringFromNumber:emissions baseFontSize:18.0f dataSuffix:kDataSuffixGas unitText:volumeUnitText];
                break;
            } case 2: {
                cell.textLabel.text = @"Calories";
                cell.detailTextLabel.attributedText = [Utils attributedStringFromNumber:gpx.metadata.extensions.caloriesBurned baseFontSize:18.0f dataSuffix:kDataSuffixCalories unitText:kUnitTextCalorie];
            }
        }
        return cell;
    } else if (indexPath.section == 1) {
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
                                                           NSForegroundColorAttributeName: numberColor}];
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
                                                           NSForegroundColorAttributeName: numberColor}];
                NSAttributedString *suffix = [[NSAttributedString alloc]
                                              initWithString:@" days"
                                              attributes:@{NSFontAttributeName: suffixFont}];
                [text appendAttributedString:number];
                [text appendAttributedString:suffix];
                cell.textLabel.attributedText = text;
                return cell;
            }
        }
    } else if (hasDesc && indexPath.section == 2) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = gpx.metadata.desc;
        cell.textLabel.font = descFont;
        return cell;
    } else if ((!hasDesc && indexPath.section == 2) || indexPath.section == 3) {
        static NSString *cellIdentifier = @"detailsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
        switch (indexPath.row) {
            case 0: {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f %@", [Utils distanceFromMeters:gpx.metadata.extensions.totalDistance units:distanceUnitText], distanceUnitText];
                cell.textLabel.text = @"Total Distance";
                return cell;
            } case 1: {
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.totalTime];
                cell.textLabel.text = @"Total Time";
                return cell;
            } case 2: {
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeMoving];
                cell.textLabel.text = @"Time Moving";
                return cell;
            } case 3: {
                cell.detailTextLabel.text = [Utils timeStringFromSeconds:gpx.metadata.extensions.timeStopped];
                cell.textLabel.text = @"Time Stopped";
                return cell;
            } case 4: {
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f %@", [Utils speedFromMetersSec:gpx.metadata.extensions.averageSpeed units:speedUnitText], speedUnitText];
                cell.textLabel.text = @"Average Speed";
                return cell;
            }
        }
    } return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat defaultHeight = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (indexPath.section == 0 && indexPath.row == 0) {
        return MAX(defaultHeight, [gpx.metadata.name sizeWithFont:nameFont constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 120, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    } else if (indexPath.section == 3) {
        return MAX(defaultHeight, [gpx.metadata.desc sizeWithFont:descFont constrainedToSize:CGSizeMake(self.tableView.frame.size.width - 120, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping].height);
    } else return defaultHeight;
}

@end
