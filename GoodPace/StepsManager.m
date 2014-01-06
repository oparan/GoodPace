//
//  StepsManager.m
//  GoodPace
//
//  Created by Paran, Omer on 12/29/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "StepsManager.h"

#import "IPhone5SStepsCounter.h"
#import "Globals.h"
#import "LogObj.h"
#import "ICEMotionMonitor.h"
#import "BackgroundMode.h"

@implementation StepsManager

- (id) init {
    
    self = [super init];
    
    if (self) {
        hardwareCounting = !CMStepCounter.isStepCountingAvailable;
    }
    
    return self;
}

- (void) setHandler:(id<StepsHandler>) _stepsHandler messaureBy:(enum EMessaureBy) _messaureBy {
    stepsHandler = _stepsHandler;
    messaureBy = _messaureBy;
}

- (void) start {
    if (messaureBy == eDevice) {
        
        if (!hardwareCounting) {
            [backgroundMode start];
        }
        
        ICEMotionMonitor* monitor = [ICEMotionMonitor sharedMonitor];
        [monitor startStepsCountingWithHandler:^(NSInteger numberOfCountedSteps) {
            if(numberOfCountedSteps && (stepsHandler!=nil)){
                if (totalCount != numberOfCountedSteps) {
                    totalCount = (int) numberOfCountedSteps;
                    [stepsHandler update:numberOfCountedSteps];
                }
            }
        } updateEvery:1];

    }
    else if (messaureBy == eFitBit) {
    }
}

- (void) stop {
    if (messaureBy == eDevice) {
    }
    else if (messaureBy == eFitBit) {
    }
}

- (void) resume {

    if (!hardwareCounting) {
        [backgroundMode suspend];
    }
    
    if (messaureBy == eDevice) {
        
    }
    else if (messaureBy == eFitBit) {
    }
}

- (void) suspend {
    if (!hardwareCounting) {
        [backgroundMode resume];
    }
    
    if (messaureBy == eDevice) {
        
    }
    else if (messaureBy == eFitBit) {
    }
}

- (void) wakeUp {
    [logObj addLog:@"Woken Up"];
}

- (void) update:(NSInteger) numSteps {
    [logObj addLog:[NSString stringWithFormat:@"Num Steps: %d", (int) numSteps]];
    [stepsHandler update:numSteps];
}


@end
