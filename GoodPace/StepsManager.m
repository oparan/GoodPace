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

@implementation StepsManager

- (void) setHandler:(id<StepsHandler>) _stepsHandler messaureBy:(enum EMessaureBy) _messaureBy {
    stepsHandler = _stepsHandler;
    messaureBy = _messaureBy;
}

- (void) start {
    if (messaureBy == eDevice) {
/*        [NSTimer scheduledTimerWithTimeInterval:1
                                                     target:self
                                                   selector:@selector(timerFireMethod:)
                                                   userInfo:nil
                                                    repeats:YES];*/

        if ([CMStepCounter isStepCountingAvailable]) {
            if (!iPhone5SStepsCounter) {
                iPhone5SStepsCounter = [[IPhone5SStepsCounter alloc] init];
            }
            
            [iPhone5SStepsCounter start];
        }
    }
    else if (messaureBy == eFitBit) {
    }
}

/*- (void)timerFireMethod:(NSTimer *)timer {
    [stepsHandler update:100];
}*/


- (void) stop {
    if (messaureBy == eDevice) {
        
    }
    else if (messaureBy == eFitBit) {
    }
}

- (void) resume {
    if (messaureBy == eDevice) {
        
    }
    else if (messaureBy == eFitBit) {
    }
}

- (void) suspend {
    if (messaureBy == eDevice) {
        
    }
    else if (messaureBy == eFitBit) {
    }
}

- (void) update:(NSInteger) numSteps {
    [logObj addLog:[NSString stringWithFormat:@"Num Steps: %d", (int) numSteps]];
    [stepsHandler update:numSteps];
}


@end
