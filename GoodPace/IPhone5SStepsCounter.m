//
//  IPhone5SStepsCounter.m
//  GoodPace
//
//  Created by Paran, Omer on 12/29/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "IPhone5SStepsCounter.h"
#import "Globals.h"
#import "StepsManager.h"

@implementation IPhone5SStepsCounter

- (id) init {
    
    self = [super init];
    
    if (self) {
        static dispatch_once_t onceToken=0;
        
        dispatch_once(&onceToken, ^{
            
            stepsCounter = [[CMStepCounter alloc] init];
        });
    }
    
    return self;
}

- (void) start {
    [stepsCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
        [stepsManager update:numberOfSteps];
    } ];
}

@end
