//
//  ICEMotionMonitor.h
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/26/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICEMotionRecords.h"


typedef void (^ICEStepsCountHandler)(NSInteger numberOfCountedSteps);

@interface ICEMotionMonitor : NSObject

//these are temporary - for Ron
@property (strong, nonatomic) ICEMotionRecords *accelerationRecords;
@property (strong, nonatomic) ICEMotionRecords *gyroRecords;


+(ICEMotionMonitor*) sharedMonitor;

-(void) startStepsCounting;
-(void) startStepsCountingWithHandler:(ICEStepsCountHandler)stepsCountHandler updateEvery:(NSInteger)steps;
-(void) stopStepsCounting;

// set the update interval for sampling acceleration and motion data from device
-(double) updateIntervalSeconds;
-(void) setUpdateIntervalSeconds: (double) interval;

// the noise cutoff for data fitting/smooting filters
-(double) filterCutoff;
-(void) setFilterCutoff: (double) cutoff;

// set the filter type (0 - none, 1 - low pass-high pass, 2- high pass-low pass
-(void) setDataFilterType: (NSInteger) type;

// the counted steps
-(unsigned long) stepsCountAccelerometer;
-(unsigned long) stepsCountAccelerometerHighs;
-(unsigned long) stepsCountAccelerometerLows;
-(unsigned long) stepsCountStepsCounter;

@end
