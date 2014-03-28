//
//  TrackAnnotation.m
//  onTrac
//
//  Created by Stan Zhang on 10/26/13.
//  Copyright (c) 2014 aspyrx. All rights reserved.
//

#import "TrackAnnotation.h"

@implementation TrackAnnotation

@synthesize filePath;
@synthesize title;
@synthesize subtitle;
@synthesize coordinate;

- (id)initWithFilePath:(NSString *)path title:(NSString *)t subtitle:(NSString *)s coordinate:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (self) {
        filePath = path;
        title = t;
        subtitle = s;
        coordinate = coord;
    }
    return self;
}

@end
