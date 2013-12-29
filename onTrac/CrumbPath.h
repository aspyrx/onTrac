//
//  CrumbPath.h
//  onTrac
//
//  Created by Stan Zhang on 6/13/13.
//  Copyright (c) 2013 caekboard. All rights reserved.

/*
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
*/

#import <MapKit/MapKit.h>
#import <pthread.h>

@interface CrumbPath : NSObject <MKOverlay> {
    MKMapPoint *points;
    
    NSUInteger pointCount;
    NSUInteger pointSpace;
    
    MKMapRect boundingMapRect;
    
    pthread_rwlock_t rwLock;
}

// Initialize the CrumbPath with the starting coordinate.
// The CrumbPath's boundingMapRect will be set to a sufficiently large square
// centered on the starting coordinate.

- (id)initWithCenterCoordinate:(CLLocationCoordinate2D)coord;

// Add a location observation. A MKMapRect containing the newly added point
// and the previously added point is returned so that the view can be updated
// in that rectangle.  If the added coordinate has not moved far enough from
// the previously added coordinate it will not be added to the list and
// MKMapRectNull will be returned.

- (MKMapRect)addCoordinate:(CLLocationCoordinate2D)coord;

- (void)lockForReading;

// The following properties must only be accessed when holding the read lock
// via lockForReading.  Once you're done accessing the points, release the
// read lock with unlockForReading.

@property (readonly) MKMapPoint *points;
@property (readonly) NSUInteger pointCount;

- (void)unlockForReading;

@end
