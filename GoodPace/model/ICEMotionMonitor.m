//
//  ICEMotionMonitor.m
//  GoodPaceLogic
//
//  count steps using accelerometer data. acceleration is pronounced using a 3D-vector (x,y,z)
//  and the count is based on a "peak counting" method (zero-crossing) over teh accumulated data
//  the data is smothed using a High Pass filter and then by a Low Pass filter and then analysis
//  every 10-seconds a segment of collected data is sent to analysis.
//  analisis tries to establish the frequency of steps and the "right-foot-left-foot" (high-low) threshold.
//  these two factors assist in eliminating acceleration noises (i.e. values that are NOT steps)
//
//  Created by Steiner, Ron on 12/26/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "ICEMotionMonitor.h"
#import <CoreMotion/CMMotionManager.h>
#import <CoreMotion/CMStepCounter.h>
#import <CoreMotion/CMDeviceMotion.h>

#import "AccelerometerFilter.h"
#include <math.h>
#define MIN_STEPS_FREQUENCY (0.2)
#define MAX_STEPS_FREQUENCY (1.8)
#define MIN_STEPS_THREASHOLD (1.5)
#define MAX_STEPS_THREASHOLD (12.0)

typedef NS_ENUM(NSInteger, ICEMotionAnalysisCertainty) {ICEMotionAnalysisCertaintyNone = -1L, ICEMotionAnalysisCertaintyLow, ICEMotionAnalysisCertaintyMid, ICEMotionAnalysisCertaintyHigh};



/**
 
 ICEStepMotionValidator
 
 a utility to validate that a motion record represent a valid step.
 the validation is based on expected step intervale/frequency and a threshold diff,
 and is performed in comparison to the last validated record that represents a step.
 
 */


@interface ICEStepMotionValidator : NSObject

    // accumulative data for analysis
    @property double stepFrequency;     // the frequency of going from "high" to "low" aceleration norms
    @property double stepMinFrequency;  // the min frequency of going from "high" to "low" aceleration norms
    @property double stepMaxFrequency;  // the max frequency of going from "high" to "low" aceleration norms
    
    @property double stepDiffThreshold; // the threashold bewteen "high" and "low" peaks
    @property double stepMinThreshold;  // the min threashold for "low" peaks
    @property double stepMaxThreshold;  // the max threashold for "high" peaks

+(id) validateAs:(ICEStepMotionValidator*)other;

-(BOOL) isValidAccelerationOfStep: (ICEMotionData*)acceleration lastValid:(ICEMotionData*) lastStep;

@end

@implementation ICEStepMotionValidator

-(id) init
{
    self=[super init];
    self.stepFrequency=(MIN_STEPS_FREQUENCY+MAX_STEPS_FREQUENCY)/2.0;
    self.stepMinFrequency = MIN_STEPS_FREQUENCY;
    self.stepMaxFrequency = MAX_STEPS_FREQUENCY;
    
    self.stepDiffThreshold=(MIN_STEPS_THREASHOLD+MAX_STEPS_THREASHOLD)/2.0;
    self.stepMinThreshold = MIN_STEPS_THREASHOLD;
    self.stepMaxThreshold = MAX_STEPS_THREASHOLD;
    return self;
}

+(id) validateAs:(ICEStepMotionValidator*)other
{
    ICEStepMotionValidator *result = [[ICEStepMotionValidator alloc] init];
    if(other!=nil){
        result.stepFrequency    = other.stepFrequency;;
        result.stepMinFrequency = other.stepMinFrequency;
        result.stepMaxFrequency = other.stepMaxFrequency;
        
        result.stepDiffThreshold= other.stepDiffThreshold;
        result.stepMinThreshold = other.stepMinThreshold;
        result.stepMaxThreshold = other.stepMaxThreshold;
    }
    return result;
}

-(BOOL) isValidAccelerationOfStep: (ICEMotionData*)acceleration lastValid:(ICEMotionData*) lastStep{
    
    BOOL isValidStep = lastStep==nil;
    if(!isValidStep){
        double dt = acceleration.timeStamp-lastStep.timeStamp;
        double dv = fabsl(acceleration.vector.size-lastStep.vector.size);
        isValidStep = (dt>self.stepMinFrequency && dt<self.stepMaxFrequency && dv>self.stepMinThreshold && dv<self.stepMaxThreshold);
    }
    return isValidStep;
}

@end








/**
 
 ICEMotionSegmentAnalysisResult 
 
 an analysis result of a motion segment. the result expreses the certainity of hte analysis and the steps cunted in the segment.
 
 */

@interface ICEMotionSegmentAnalysisResult : NSObject

@property (strong, readonly, nonatomic) ICEMotionSegmentRecords *analyzedSegment;
@property (readonly) ICEMotionAnalysisCertainty resultCertainty;
@property (readonly) NSInteger countedSteps;
@property (readonly) BOOL endingAcceleration;
+(id)resultWithSegment:(ICEMotionSegmentRecords*)segment certainty:(ICEMotionAnalysisCertainty) certain steps:(NSInteger)numberOfSteps accelerationOnEnd:(BOOL)acceleration;

@end

@implementation ICEMotionSegmentAnalysisResult
{
    ICEMotionSegmentRecords *theSegment;
    ICEMotionAnalysisCertainty analysisCertainty;
    NSInteger steps;
    BOOL accelerationOnEnd;
}
+(id)resultWithSegment:(ICEMotionSegmentRecords*)segment certainty:(ICEMotionAnalysisCertainty) certain steps:(NSInteger)numberOfSteps accelerationOnEnd:(BOOL)acceleration{
    ICEMotionSegmentAnalysisResult *result = [[super alloc ]init];
    result->theSegment=segment;
    result->analysisCertainty = certain;
    result->steps=numberOfSteps;
    result->accelerationOnEnd=acceleration;
    return result;
}

-(ICEMotionSegmentRecords *)analyzedSegment
{
    return theSegment;
}
-(ICEMotionAnalysisCertainty)resultCertainty
{
    return analysisCertainty;
}
-(NSInteger) countedSteps
{
    return steps;
}
-(BOOL)endingAcceleration
{
    return accelerationOnEnd;
}
@end







/**
 ICEMotionSegmentAnalyzer
 
 analyze a motion segment (count steps)
 
 */

@interface ICEMotionSegmentAnalyzer :NSObject

@property (strong, readonly) ICEStepMotionValidator* stepValidator;

@property (readonly) double performanceRate;

-(ICEMotionSegmentAnalysisResult*) analyzeSegment:(ICEMotionSegmentRecords*) segment currentlyAccelerating:(BOOL) isAccelerating expectedStepsMin:(NSInteger) minSteps expectedMax:(NSInteger) maxSteps;

-(void) updateResultsToSegment: (ICEMotionSegmentRecords*) segment;

-(void) addResultCertaintyToPerformanceRate: (ICEMotionAnalysisCertainty) analysisCertainty;

-(ICEStepMotionValidator*) generateImprovedValidator;

@end



@implementation ICEMotionSegmentAnalyzer
{
    ICEStepMotionValidator * validator;
    NSMutableArray *lows, *highs;
    NSInteger numberOfAnalysis;
    NSInteger accumulatedCertainties;
    BOOL accelerating;
}

+(id)analizerWithValidator:(ICEStepMotionValidator*) aValidator
{
    ICEMotionSegmentAnalyzer* analyzer = [[ICEMotionSegmentAnalyzer alloc] init];
    analyzer->validator = [ICEStepMotionValidator validateAs:aValidator];
    return analyzer;
}

-(id)init
{
    self= [super init];
    lows = [[NSMutableArray alloc] init];
    highs = [[NSMutableArray alloc] init];
    validator = [[ICEStepMotionValidator alloc] init];
    accumulatedCertainties=0;
    numberOfAnalysis=0;
    return self;
}

-(ICEStepMotionValidator*) stepValidator
{
    return validator;
}

-(ICEMotionSegmentAnalysisResult*) analyzeSegment:(ICEMotionSegmentRecords*) segment currentlyAccelerating:(BOOL) isAccelerating expectedStepsMin:(NSInteger) minSteps expectedMax:(NSInteger) maxSteps
{
    accelerating = isAccelerating;
    [self computeAccelerationHighsLowsforSegment:segment];
    ICEMotionAnalysisCertainty certainty = (lows.count>=minSteps && lows.count<=maxSteps) ? ICEMotionAnalysisCertaintyHigh : ICEMotionAnalysisCertaintyLow;
    certainty = (highs.count>=minSteps && highs.count<=maxSteps) ? certainty : certainty--;
    
    ICEMotionSegmentAnalysisResult * result = [ICEMotionSegmentAnalysisResult resultWithSegment: segment certainty:certainty steps: MAX(highs.count,lows.count) accelerationOnEnd:accelerating];
    return result;
}

-(void) addResultCertaintyToPerformanceRate: (ICEMotionAnalysisCertainty) analysisCertainty
{
    numberOfAnalysis++;
    accumulatedCertainties+=analysisCertainty;
    
}

-(double) performanceRate
{
    return (numberOfAnalysis!=0) ? accumulatedCertainties/numberOfAnalysis : 0.0;
}

-(void) computeAccelerationHighsLowsforSegment:(ICEMotionSegmentRecords*) segment
{
    ICEMotionData *lastAccelerationData=nil;
    ICEMotionData* lastHigh=nil;
    ICEMotionData* lastLow=nil;
    
    [lows removeAllObjects];
    [highs removeAllObjects];
    
    double dataSize;
    double lastDataSize ;

    for(ICEMotionData* data in segment.motionValues){
        
        if(lastAccelerationData!=nil){
            
            lastHigh = [highs lastObject];
            lastLow  = [lows  lastObject];
            dataSize = data.vector.size;
            lastDataSize = lastAccelerationData.vector.size;
            
            // consider lastAccelerationData as a valid "low" peak (minima)
            if( dataSize < lastDataSize && accelerating && [validator isValidAccelerationOfStep:lastAccelerationData lastValid:lastHigh]){
                
                [lows addObject:lastAccelerationData];
                
//                NSLog(@"\n\nAdding LOW:\t(t)%f\t(n)%f\t(freq)%f\t(th)%f\n\n", lastAccelerationData.timeStamp,lastAccelerationData.vector.size, validator.stepFrequency, validator.stepDiffThreshold);
                
                accelerating=NO;
            }
            // else consider lastAccelerationData as a valid "high" peak (maxima)
            else if(dataSize > lastDataSize && !accelerating && [validator isValidAccelerationOfStep:lastAccelerationData lastValid:lastLow]){
                
                [highs addObject:lastAccelerationData ];
                
                
//                 NSLog(@"\n\nAdding HIGH:\t(t)%f\t(n)%f\t(freq)%f\t(th)%f\n\n", lastAccelerationData.timeStamp,lastAccelerationData.vector.size, validator.stepFrequency, validator.stepDiffThreshold);
                
                accelerating=YES;
            }
        }
        lastAccelerationData = data;
        
    }
    
}

-(void) updateResultsToSegment: (ICEMotionSegmentRecords*) segment
{
    if(segment!=nil){
        segment.highs = [NSArray arrayWithArray:highs];
        segment.lows =  [NSArray arrayWithArray:lows];
    }
    
}


-(ICEStepMotionValidator*) generateImprovedValidator
{
    
    if(lows.count<2 || highs.count<2){
        return nil; // i.e. cannot improve self
    }
    ICEStepMotionValidator* improved = [[ICEStepMotionValidator alloc] init];
    double avgHigh=0.0;
    double avgLow=0.0;
    double frequency=0.0;
    double threashold=0.0;
    
    NSArray* sorted = [highs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = NSOrderedSame;
        ICEMotionData* item1 = obj1;
        ICEMotionData* item2 = obj2;
        if(item1.vector.size>item2.vector.size){
            result = NSOrderedDescending;
        }
        else if(item1.vector.size<item2.vector.size){
            result = NSOrderedAscending;
        }
        return result;
    }];
    
    for(int i=1 ; i<(sorted.count-2); i++){
        ICEMotionData* data = [sorted objectAtIndex:i];
        avgHigh+=data.vector.size;
        
    }
    avgHigh=avgHigh/(sorted.count-2);
    
    sorted = [lows sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = NSOrderedSame;
        ICEMotionData* item1 = obj1;
        ICEMotionData* item2 = obj2;
        if(item1.vector.size>item2.vector.size){
            result = NSOrderedDescending;
        }
        else if(item1.vector.size<item2.vector.size){
            result = NSOrderedAscending;
        }
        return result;
    }];
    
    for(int i=1 ; i<(sorted.count-2); i++){
        ICEMotionData* data = [sorted objectAtIndex:i];
        avgLow+=data.vector.size;
    }
    avgLow=avgLow/(sorted.count-2);
    
    threashold = fabsl(avgHigh-avgLow);
    
    ICEMotionData *item, *jtem;
    NSArray* currentLows = lows;
    NSArray* currentHighs = highs;
    
    item = [currentLows firstObject];
    jtem = [currentHighs firstObject];
    double start = MIN(item.timeStamp,jtem.timeStamp);
    item = [currentLows lastObject];
    jtem = [currentHighs lastObject];
    double end = MAX(item.timeStamp, jtem.timeStamp);
    
    frequency = (end-start)/(currentHighs.count+currentLows.count-1);
    
    improved.stepDiffThreshold = self.performanceRate==0.0 ? threashold : (validator.stepDiffThreshold*3+threashold*7)/10.0;
    improved.stepMinThreshold = (improved.stepMinThreshold+MIN(avgLow,avgHigh))/2.0;
    improved.stepMaxThreshold = (improved.stepMaxThreshold+MAX(avgLow,avgHigh))/2.0;
    
    improved.stepFrequency = self.performanceRate==0.0 ? frequency : (validator.stepFrequency*3+frequency*7)/10.0;
    improved.stepMinFrequency = (improved.stepFrequency*0.5);
    improved.stepMaxFrequency = (improved.stepFrequency*2.0);
    
    NSLog(@"\nImproved step frequency: %f (%f,%f), threshold: %f (%f,%f)", improved.stepFrequency, improved.stepMinFrequency, improved.stepMaxFrequency, improved.stepDiffThreshold, improved.stepMinThreshold, improved.stepMaxThreshold);
    
    return improved;
}

@end





/**
 
 ICEStepsCountUpdateHandler

 internal class to reference a step countering handler
 
 */

@interface ICEStepsCountUpdateHandler : NSObject

@property (readonly) ICEStepsCountHandler handler;
@property (readonly) NSInteger updateEveryXSteps;
+(ICEStepsCountUpdateHandler*) updateHandlerWith:(ICEStepsCountHandler)blockhandler steps:(NSInteger)steps;

@end


@implementation ICEStepsCountUpdateHandler
{
    ICEStepsCountHandler blockhandler;
    NSInteger updateStepsRate;
}
+(ICEStepsCountUpdateHandler*) updateHandlerWith:(ICEStepsCountHandler)blockhandler steps:(NSInteger)steps
{
    ICEStepsCountUpdateHandler* handler = [[ICEStepsCountUpdateHandler alloc] init];
    handler->blockhandler = blockhandler;
    handler->updateStepsRate = steps;
    return handler;
}
-(ICEStepsCountHandler) handler
{
    return blockhandler;
}
-(NSInteger)updateEveryXSteps
{
    return updateStepsRate;
}
@end



/**
 ICEMotionMonitor
 
 the actual motion monitor and step counting class, implemented as singleton.
 it can cout steps in 2 ways:
    1. using CMStepCounter API if available (M7 chip on iphone 5s)
    2. collect accelerometer data and analyze segments of it.
 
 both methods support reporting to a handler (ICEStepsCountHandler) at every X steps
 
 */


static ICEMotionMonitor* instance;


@interface ICEMotionMonitor()
{
    
    
    CMMotionManager *motionManager;
    CMDeviceMotion * deviceMotion;
    CMStepCounter *stepsCounter;
    NSTimeInterval updateEveryXSec;
    
    // data (curve) smoothing filters
    NSInteger filterType;
    AccelerometerFilter *dataFilter;
    LowpassFilter * lowPassFilter;
    HighpassFilter* highPassFilter;
    NSNumber *filterCutoff;
    
    // collection of segment analyzer (step counters):
    NSMutableArray * segmentAnalyzers;
    
    BOOL accelerating;
    // the number of counted steps since a 'start' was called.
    NSInteger countedSteps;

}
@end



@implementation ICEMotionMonitor
{
    ICEStepsCountUpdateHandler *countedStepsHandler;
    NSTimer *countedStepsHandlerTimer;
}

// the singleton
+(ICEMotionMonitor*) sharedMonitor
{
    static dispatch_once_t onceToken=0;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
    });
    
    return instance;
}


-(id)init
{
    self= [super init];
    updateEveryXSec = 0.025;
    filterType=2;
    countedSteps=0;
    
    motionManager = [[CMMotionManager alloc] init];
    deviceMotion = [[CMDeviceMotion alloc] init];
    stepsCounter = [[CMStepCounter alloc] init];
    
    segmentAnalyzers = [[NSMutableArray alloc] init];
    [segmentAnalyzers addObject:[[ICEMotionSegmentAnalyzer alloc] init]];
    
    return self;
}

-(void) startStepsCounting
{
    NSLog((@"starting step-counting at %f interval"), updateEveryXSec);
    countedSteps=0;
    if(CMStepCounter.isStepCountingAvailable){
        [self countStepsUsingStepCounter];
    }
    else{
        [self countStepsUsingAccelerometer];
    }
    
}

-(void) startStepsCountingWithHandler:(ICEStepsCountHandler)stepsCountHandler updateEvery:(NSInteger)steps
{
    // this is raw and very temporary:
    countedStepsHandler = [ICEStepsCountUpdateHandler updateHandlerWith:stepsCountHandler steps:steps];
    if(countedStepsHandlerTimer!=nil){
        [countedStepsHandlerTimer invalidate];
        countedStepsHandlerTimer=nil;
    }
    countedStepsHandlerTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(reportCurrentCountToHandler) userInfo:nil repeats:YES];
    
    [self startStepsCounting];
    
}
                       
-(void)reportCurrentCountToHandler
{
    if(countedStepsHandler==nil){
        return;
    }
    if(!CMStepCounter.isStepCountingAvailable){
    
        BOOL isAccelerating = accelerating;
        ICEMotionSegmentAnalyzer* analyzer = [[ICEMotionSegmentAnalyzer alloc] init];
        
        ICEMotionSegmentAnalysisResult *result = [analyzer analyzeSegment:[self.accelerationRecords.motionSegments lastObject] currentlyAccelerating:isAccelerating expectedStepsMin:3 expectedMax:20];
        countedSteps = self.stepsCountAccelerometer+result.countedSteps;
        
    }
  countedStepsHandler.handler(countedSteps);
    
    
}
                        

-(void)countStepsUsingStepCounter
{
    [stepsCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
        countedSteps=numberOfSteps;
    } ];
}


-(void)countStepsUsingAccelerometer
{
    // reset previous data
    if(self.accelerationRecords!=nil){
        [self.accelerationRecords clear];
    }
    if(self.gyroRecords!=nil){
        [self.gyroRecords clear];
    }
    self.accelerationRecords = [[ICEMotionRecords alloc] initWithSegmentReadyHandler:^(ICEMotionSegmentRecords *segment) {
        [self analyzeAccelerationDataWithSegment:segment];
    }];
    self.gyroRecords = [[ICEMotionRecords alloc] init];
    
    self.gyroRecords.name = @"GYRO"; // just for debug
    self.accelerationRecords.name=@"ACCL";// just for debug
    
    accelerating=NO;
    
    
    // recreate the filters
    
    lowPassFilter = [[LowpassFilter alloc] initWithSampleRate:1.0/updateEveryXSec cutoffFrequency:[self filterCutoff]];
    highPassFilter =[[HighpassFilter alloc] initWithSampleRate:1.0/updateEveryXSec cutoffFrequency:[self filterCutoff]];
    if(filterType==0){
        dataFilter = nil;
        
    }
    else if (filterType==1){
        dataFilter = lowPassFilter;
    }
    else if (filterType==2){
        dataFilter = highPassFilter;
    }
    
    [motionManager setDeviceMotionUpdateInterval:updateEveryXSec];
    [motionManager setGyroUpdateInterval:updateEveryXSec];
    
    [motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        
        [self addDataTo:self.accelerationRecords atTime:motion.timestamp x:motion.userAcceleration.x y:motion.userAcceleration.y z:motion.userAcceleration.z];
        
    }];
    
    [motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
        
        [self addDataTo:self.gyroRecords atTime:gyroData.timestamp x:gyroData.rotationRate.x y:gyroData.rotationRate.y z:gyroData.rotationRate.z];
        
    }];

}

-(void) stopStepsCounting
{
    if(countedStepsHandlerTimer!=nil){
        [countedStepsHandlerTimer invalidate];
        countedStepsHandlerTimer=nil;
    }
    if(CMStepCounter.isStepCountingAvailable){
        [stepsCounter stopStepCountingUpdates];
    }
    else{
        [motionManager stopGyroUpdates];
        [motionManager stopDeviceMotionUpdates];
        [self analyzeAccelerationDataWithSegment:[self.accelerationRecords.motionSegments lastObject]];
    
    }
}


-(ICEMotionSegmentAnalyzer*) bestAnalyzer
{
    // the best analyzer is the one at the end of hte collection.
    // hte collection is sorted according to the performace rates of the analyzers.
    ICEMotionSegmentAnalyzer *analyzer = [segmentAnalyzers lastObject];
    return analyzer;
}

-(void) analyzeAccelerationDataWithSegment: (ICEMotionSegmentRecords*) segment
{
    BOOL isAccelerating = accelerating;
    ICEMotionSegmentAnalyzer* analyzer = [self bestAnalyzer];
    
    ICEMotionSegmentAnalysisResult *result = [analyzer analyzeSegment:segment currentlyAccelerating:isAccelerating expectedStepsMin:3 expectedMax:30];
    // first update the performance of this analyzer with the certainty achieved in this analysis
    [analyzer  addResultCertaintyToPerformanceRate:result.resultCertainty];
    
    if(result.resultCertainty>=ICEMotionAnalysisCertaintyMid){
        
        // update teh analysis results to the segment and update teh "accelerating" value according to the analysis result.
        
        [analyzer updateResultsToSegment: segment];
        accelerating = result.endingAcceleration; // i.e. the analysis ended with this "accelerating" value;
        
        countedSteps = self.stepsCountAccelerometer+result.countedSteps;
        
        // try to improve - create a tighter analyzer for next segment
        
        analyzer = [ICEMotionSegmentAnalyzer analizerWithValidator:[analyzer generateImprovedValidator]];
        
        // test it on the current segment:
        result = [analyzer analyzeSegment:segment currentlyAccelerating:isAccelerating expectedStepsMin:result.countedSteps-1 expectedMax:result.countedSteps+1];
        if(result.resultCertainty>=ICEMotionAnalysisCertaintyMid){
            // i.e. - is is at least as good as the one it was generated from - add it to the end of the list
            NSLog(@"Adding an improved analyzer");
            [segmentAnalyzers addObject:analyzer];
            [analyzer  addResultCertaintyToPerformanceRate:result.resultCertainty];
        }
        
        
    }
    else if(result.resultCertainty<=ICEMotionAnalysisCertaintyLow && segmentAnalyzers.count>=2){
        // try to analyze using a previous analyzer
        ICEMotionSegmentAnalyzer *previous;
        for(unsigned long i=segmentAnalyzers.count-1 ;i>0;i--){
            previous = segmentAnalyzers[i-1];
            ICEMotionSegmentAnalysisResult *prevResult = [previous analyzeSegment:segment currentlyAccelerating:isAccelerating expectedStepsMin:3 expectedMax:30];
            if(prevResult.resultCertainty>result.resultCertainty){
                NSLog(@"A previous analyzer did better in analyzing");
                
                [previous updateResultsToSegment: segment];
                [previous  addResultCertaintyToPerformanceRate:result.resultCertainty];
                countedSteps = self.stepsCountAccelerometer+result.countedSteps;
            }
            if(prevResult.resultCertainty>=ICEMotionAnalysisCertaintyMid){
                //that's good enough
                break;
            }
        }
        
        // re-sort the collection of analyzers
        [segmentAnalyzers sortUsingComparator:^NSComparisonResult(ICEMotionSegmentAnalyzer * a1, ICEMotionSegmentAnalyzer * a2) {
            
            NSComparisonResult res = NSOrderedSame;
            if(a1.performanceRate>a2.performanceRate){
                res = NSOrderedDescending;
            }
            else if(a1.performanceRate<a2.performanceRate){
                res = NSOrderedAscending;
            }
            return res;
        }];
        
        // just for debug:
        ICEMotionSegmentAnalyzer* a ;
        
        for(int i=0; i<segmentAnalyzers.count; i++){
            a=segmentAnalyzers[i];
            NSLog(@"analyzer %d performance rate: %f",i, a.performanceRate);
            i++;
        }
    }
    
}



-(unsigned long) stepsCountAccelerometerHighs
{
    unsigned long count=0;
    for (ICEMotionSegmentRecords* segment in self.accelerationRecords.motionSegments) {
        count+=segment.highs.count;
    }
    return count;
}
-(unsigned long) stepsCountAccelerometerLows
{
    unsigned long count=0;
    for (ICEMotionSegmentRecords* segment in self.accelerationRecords.motionSegments) {
        count+=segment.lows.count;
    }
    return count;
}

-(unsigned long) stepsCountAccelerometer
{
    return MAX(self.stepsCountAccelerometerLows, self.stepsCountAccelerometerHighs);
}

-(unsigned long) stepsCountStepsCounter
{
    return countedSteps;
}


-(double) updateIntervalSeconds
{
    return updateEveryXSec;
}

-(void) setUpdateIntervalSeconds: (double) interval
{
    updateEveryXSec = interval;
}

-(double) filterCutoff
{
    if(filterCutoff!=nil){
        return [filterCutoff doubleValue];
    }
    return 3.0;
}

-(void) setFilterCutoff: (double) cutoff
{
    filterCutoff = [[NSNumber alloc] initWithDouble:cutoff];
}

-(void) setDataFilterType: (NSInteger) type
{
    filterType = type;

}


-(ICEMotionData*) addDataTo:(ICEMotionRecords*) motionData atTime:(double)timestamp x:(double)withX y:(double)withY z:(double)withZ
{
    ICEMotionData *data ;
    if(dataFilter!=nil){
        [dataFilter addAccelerationX:withX y:withY z:withZ];
        AccelerometerFilter *otherFilter = (dataFilter==lowPassFilter?highPassFilter:lowPassFilter);
        
        [otherFilter addAccelerationX:dataFilter.x y:dataFilter.y z:dataFilter.z];
        
        data = [[ICEMotionData alloc] initWithVector:[[ICE3DVector alloc] initWithX:otherFilter.x y:otherFilter.y z:otherFilter.z] atTime:timestamp];
        
    }
    else{
        data = [[ICEMotionData alloc] initWithVector:[[ICE3DVector alloc] initWithX:withX y:withY z:withZ] atTime:timestamp];
        
    }
    @synchronized(self)
    {
//        if(motionData==self.accelerationRecords){
//            NSLog(@"(n)%f\t(t)%f\t",  data.vector.size,data.timeStamp);
//
//        }
        [motionData addRecord:data];
    }
    return data;
    
}


@end
