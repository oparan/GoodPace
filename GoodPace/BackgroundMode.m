//
//  BackgroundMode.m
//  GoodPace
//
//  Created by Paran, Omer on 1/5/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import "BackgroundMode.h"

#import "Globals.h"
#import "StepsManager.h"
#import "LogObj.h"

@implementation BackgroundMode

- (id) init {
    self = [super init];
    
    if (self) {
        locManger = [[CLLocationManager alloc] init];
        locManger.delegate = self;
        locManger.desiredAccuracy = kCLLocationAccuracyBest;
        locManger.activityType = CLActivityTypeFitness;
        locManger.distanceFilter = kCLDistanceFilterNone; // meters
    }
    
    return self;
}

- (void) start {
    if (![CLLocationManager locationServicesEnabled]) {
        // Report this error
    }
}

- (void) stop {
    [locManger stopUpdatingLocation];
}

- (void) resume {
    [logObj addLog:@"Startin location updates"];
    [locManger startUpdatingLocation];
}

- (void) suspend {
    [locManger stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    UNUSED(manager);
    UNUSED(locations);
    
    // If it's a relatively recent event, turn off updates to save power.
    /*CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              location.coordinate.latitude,
              location.coordinate.longitude);
    }*/
    
    [stepsManager wakeUp];
}


@end
