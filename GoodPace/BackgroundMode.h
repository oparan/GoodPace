//
//  BackgroundMode.h
//  GoodPace
//
//  Created by Paran, Omer on 1/5/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import "Service.h"

@interface BackgroundMode : NSObject <Service, CLLocationManagerDelegate> {

    @private
    CLLocationManager* locManger;
}

@end
