//
//  TrackAnnotation.h
//  onTrac
//
//  Created by Stan Zhang on 10/26/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface TrackAnnotation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *filePath;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithFilePath:(NSString *)path title:(NSString *)t subtitle:(NSString *)s coordinate:(CLLocationCoordinate2D) coord;

@end
