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
#import <CoreMotion/CMDeviceMotion.h>

#import "ICELogger.h"
#import "ICENumericRange.h"

#import "AccelerometerFilter.h"
#include <math.h>


#define MIN_STEPS_FREQUENCY (0.1)
#define MAX_STEPS_FREQUENCY (1.8)
#define MIN_STEPS_THREASHOLD (1.0)
#define MAX_STEPS_THREASHOLD (40.0)

static const NSString* TAG = @"MotionMonitor";

typedef NS_ENUM(NSInteger, ICEMotionAnalysisCertainty) {ICEMotionAnalysisCertaintyNone = -1L, ICEMotionAnalysisCertaintyLow, ICEMotionAnalysisCertaintyMid, ICEMotionAnalysisCertaintyHigh};



/**
 
 ICEStepMotionValidator
 
 a utility to validate that a motion record represent a valid step.
 the validation is based on expected step intervale/frequency and a threshold diff,
 and is performed in comparison to the last validated record that represents a step.
 
 */


@interface ICEStepMotionValidator : NSObject

    // accumulative data for analysis
    @property ICENumericRange* stepFrequencyRange;     // the range of frequency of going from "high" to "low" aceleration norms

    @property ICENumericRange* stepDiffThresholdRange; // the threashold range of a steps' change in acceleration
    @property ICENumericRange* stepLowThresholdRange;  // the threashold range for "low" peaks
    @property ICENumericRange* stepHighThresholdRange; // the threashold range for "high" peaks

+(id) validateAs:(ICEStepMotionValidator*)other;

-(BOOL) isValidAccelerationOfStep: (ICEMotionData*)acceleration lastValid:(ICEMotionData*) lastStep;

@end

@implementation ICEStepMotionValidator

-(id) init
{
    self=[super init];
    self.stepFrequencyRange=[ICENumericRange rangeFrom:MIN_STEPS_FREQUENCY to:MAX_STEPS_FREQUENCY];
    double f= (MIN_STEPS_THREASHOLD+MAX_STEPS_THREASHOLD)/2.0;
    self.stepDiffThresholdRange= [ICENumericRange rangeFrom:MIN_STEPS_THREASHOLD to:MAX_STEPS_THREASHOLD];
    self.stepLowThresholdRange = [ICENumericRange rangeFrom:MIN_STEPS_THREASHOLD to:f];
    self.stepHighThresholdRange = [ICENumericRange rangeFrom:f to:MAX_STEPS_THREASHOLD];
    return self;
}

+(id) validateAs:(ICEStepMotionValidator*)other
{
    ICEStepMotionValidator *result = [[[other class] alloc] init];
    if(other!=nil){
        result.stepFrequencyRange    = other.stepFrequencyRange;;
        
        result.stepDiffThresholdRange= other.stepDiffThresholdRange;
        result.stepLowThresholdRange = other.stepLowThresholdRange;
        result.stepHighThresholdRange = other.stepHighThresholdRange;
    }
    return result;
}

-(BOOL) isValidAccelerationOfStep: (ICEMotionData*)acceleration lastValid:(ICEMotionData*) lastStep{
    
//    BOOL isValidStep = lastStep==nil;
//    if(!isValidStep){
//        double dt = acceleration.timeStamp-lastStep.timeStamp;
//        double dv = fabsl(acceleration.vector.size-lastStep.vector.size);
//        isValidStep = (dt>self.stepMinFrequency && dt<self.stepMaxFrequency && dv>self.stepMinThreshold && dv<self.stepMaxThreshold);
//    }
//    return isValidStep;
    return NO;
}

@end




@interface ICEImprovedStepMotionValidator : ICEStepMotionValidator
@end

@implementation ICEImprovedStepMotionValidator

-(BOOL) isValidAccelerationOfStep: (ICEMotionData*)acceleration lastValid:(ICEMotionData*) lastStep{
    
    BOOL isValidStep = (lastStep==nil);
    if(!isValidStep){
        double dt = acceleration.timeStamp-lastStep.timeStamp;
        double dv = fabsl(acceleration.vector.size-lastStep.vector.size);
        double acceleration = lastStep.vector.size;
        isValidStep = [self.stepFrequencyRange isInRange:dt] && [self.stepDiffThresholdRange isInRange:dv] && ([self.stepHighThresholdRange isInRange:acceleration] || [self.stepLowThresholdRange isInRange:acceleration]);
        
        [ICELogger debug:@"ImprovedStepMotionValidator" line:[NSString stringWithFormat:@"validating with dt=%f, dv=%f %@",dt,dv, (isValidStep?@"PASSED":@"FAILED")]];
        

    }
    return isValidStep;
}

@end



/**
 
 ICEMotionSegmentAnalysisResult 
 
 an analysis result of a motion segment. the result expreses the certainity of the analysis and the steps cunted in the segment.
 
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

@property (strong, readonly) NSString* analyzerId;
@property (strong, readonly) ICEStepMotionValidator* stepValidator;

@property (readonly) double performanceRate;

-(ICEMotionSegmentAnalysisResult*) analyzeSegment:(ICEMotionSegmentRecords*) segment currentlyAccelerating:(BOOL) isAccelerating expectedStepsMin:(NSInteger) minSteps expectedMax:(NSInteger) maxSteps;

-(void) updateResultsToSegment;

-(void) addResultCertaintyToPerformanceRate: (ICEMotionAnalysisCertainty) analysisCertainty;

-(ICEStepMotionValidator*) generateImprovedValidator;

@end



@implementation ICEMotionSegmentAnalyzer
{
    ICEStepMotionValidator * validator;
    ICEMotionSegmentRecords* analyzedSegment;
    NSMutableArray *lowPeaks, *highPeaks, *peaksAsStepsSequence;
    
    ICENumericRange *highPeaksRange;
    ICENumericRange *lowPeaksRange;
    ICENumericRange *stepFrequencyRange;
    ICENumericRange *stepThresholdRange;
    
    NSInteger numberOfAnalysis;
    NSInteger accumulatedCertainties;
    BOOL accelerating;
}
@synthesize analyzerId;

+(id)analyzerWithId: (NSString*) anId validator:(ICEStepMotionValidator*) aValidator
{
    ICEMotionSegmentAnalyzer* analyzer = [[ICEMotionSegmentAnalyzer alloc] init];
    analyzer->analyzerId = anId;
    analyzer->validator = [[aValidator class] validateAs:aValidator];
    return analyzer;
}

-(id)init
{
    self= [super init];
    lowPeaks = [[NSMutableArray alloc] init];
    highPeaks = [[NSMutableArray alloc] init];
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
    analyzedSegment = segment;
    
    [self computeAccelerationPeaksOfRecords];
    [self composeStepsSequence];
    
    ICEMotionAnalysisCertainty certainty = (peaksAsStepsSequence.count>=minSteps && peaksAsStepsSequence.count<=maxSteps) ? ICEMotionAnalysisCertaintyHigh : ICEMotionAnalysisCertaintyLow;
    certainty = (highPeaks.count>=minSteps && highPeaks.count<=maxSteps) ? certainty : certainty--;
    
    ICEMotionSegmentAnalysisResult * result = [ICEMotionSegmentAnalysisResult resultWithSegment: segment certainty:certainty steps: peaksAsStepsSequence.count accelerationOnEnd:accelerating];
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


-(void) composeStepsSequence
{
    peaksAsStepsSequence = [[NSMutableArray alloc] init];
    
    ICEMotionData *low=[lowPeaks firstObject], *high=[highPeaks firstObject];
    if(low==nil || high==nil){
        return;
    }
//    [ICELogger debug:TAG line:[NSString stringWithFormat:@"composeStepsSequence: lows:%lu, highs:%lu", (unsigned long)lowPeaks.count, (unsigned long)highPeaks.count]];
  
    [peaksAsStepsSequence addObject:(low.timeStamp<high.timeStamp?low:high)];
    
    @try {
        for(int iLows=0, iHighs=0; iLows<lowPeaks.count && iHighs<highPeaks.count; ){
            low = lowPeaks[iLows];
            high = highPeaks[iHighs];
            /*[ICELogger verbose:TAG line:[NSString stringWithFormat:@"\tiLows: %d, iHighs:%d", iLows, iHighs]];
            [ICELogger verbose:TAG line:[NSString stringWithFormat:@"\tLOW: t=%f, n=%f", low.timeStamp, low.vector.size]];
            [ICELogger verbose:TAG line:[NSString stringWithFormat:@"\tHIGH: t=%f, n=%f", high.timeStamp, high.vector.size]];
             */
            if(low.timeStamp<high.timeStamp){
                if([validator isValidAccelerationOfStep:high lastValid:low]){
                    [peaksAsStepsSequence addObject:high];
                    [ICELogger info:analyzerId line:[NSString stringWithFormat:@"Add HIGH: t=%f, n=%f", high.timeStamp, high.vector.size]];
                }
                iLows++;
            }
            else {
                if([validator isValidAccelerationOfStep:low lastValid:high]){
                    [peaksAsStepsSequence addObject:high];
                    [ICELogger info:analyzerId line:[NSString stringWithFormat:@"Add LOW: t=%f, n=%f", low.timeStamp, low.vector.size]];
                }
                iHighs++;
            }
        }
        
    }
    @catch (NSException *exception) {
        [ICELogger error:TAG line:@"Error creating the step sequence series"];
    }
    
    
}
-(void) computeAccelerationPeaksOfRecords
{
    
    lowPeaks  = [[NSMutableArray alloc] init];
    highPeaks = [[NSMutableArray alloc] init];
    
    if(analyzedSegment==nil){
        return;
    }
    
    
    NSArray * motionRecords = analyzedSegment.motionValues;
    ICEMotionData *lastAccelerationData=nil;
    
    
    double newDataSize;
    double lastDataSize ;
    
    for(ICEMotionData* newData in motionRecords){
        
        if(lastAccelerationData!=nil){
            
            
            newDataSize = newData.vector.size;
            lastDataSize = lastAccelerationData.vector.size;
            
            // consider lastAccelerationData as a valid "low" peak (minima)
            if( newDataSize < lastDataSize && accelerating ){
                
                [highPeaks addObject:lastAccelerationData];
                
                accelerating=NO;
            }
            // else consider lastAccelerationData as a valid "high" peak (maxima)
            else if(newDataSize > lastDataSize && !accelerating){
                
                [lowPeaks addObject:lastAccelerationData ];
                
                accelerating=YES;
            }
           
        }
        lastAccelerationData = newData;
    }
    [ICELogger info:analyzerId line:[NSString stringWithFormat:@"computeAccelerationPeaksOfRecords: lows:%lu, highs:%lu", (unsigned long)lowPeaks.count, (unsigned long)highPeaks.count]];
}

-(void) computeValidationRanges
{
    double min, max;
    ICEMotionData* data;
    
    NSArray* sorted = [highPeaks sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
    

    data = [sorted firstObject];
    min = data.vector.size;
    data = [sorted lastObject];
    max = data.vector.size;
        
   
    highPeaksRange=[ICENumericRange rangeFrom:min to:max];
    
    sorted = [lowPeaks sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
    
    data = [sorted firstObject];
    min = data.vector.size;
    data = [sorted lastObject];
    max = data.vector.size;
    
    lowPeaksRange=[ICENumericRange rangeFrom:min to:max];
    
    min = highPeaksRange.lowEnd-lowPeaksRange.highEnd;
    max = highPeaksRange.highEnd-lowPeaksRange.lowEnd;
    
    stepThresholdRange = [ICENumericRange rangeFrom:min to:max];
    
    ICEMotionData *item, *jtem;
    double start, end;
    
    item = [lowPeaks firstObject];
    jtem = [highPeaks firstObject];
    start = MIN(item.timeStamp,jtem.timeStamp);
    item = [lowPeaks lastObject];
    jtem = [highPeaks lastObject];
    end = MAX(item.timeStamp, jtem.timeStamp);
    
    max = (end-start)/(lowPeaks.count-1+highPeaks.count-1);
    
    item = [lowPeaks firstObject];
    jtem = [highPeaks firstObject];
    start = MAX(item.timeStamp,jtem.timeStamp);
    item = [lowPeaks lastObject];
    jtem = [highPeaks lastObject];
    end = MIN(item.timeStamp, jtem.timeStamp);
    
    min = (end-start)/(lowPeaks.count+highPeaks.count);
    
    stepFrequencyRange = [ICENumericRange rangeFrom:min to:max];

}


-(void) updateResultsToSegment
{
    if(analyzedSegment!=nil){
        analyzedSegment.analyzedStepsPeaks = peaksAsStepsSequence;
        analyzedSegment.highPeaks = highPeaks;
        analyzedSegment.lowPeaks = lowPeaks;
    }
    
}


-(ICEStepMotionValidator*) generateImprovedValidator
{
    
    if(lowPeaks.count<2 || highPeaks.count<2){
        return nil; // i.e. cannot improve self
    }
    
    [self computeValidationRanges];
    
    ICEStepMotionValidator* improved = [[ICEImprovedStepMotionValidator alloc] init];
    
    improved.stepDiffThresholdRange = stepThresholdRange;
    improved.stepLowThresholdRange = lowPeaksRange;
    improved.stepHighThresholdRange = highPeaksRange;
    
    improved.stepFrequencyRange = stepFrequencyRange;
    
    [ICELogger debug:TAG line:[NSString stringWithFormat:@"Improved step frequency: %@, threshold: low %@ high %@ diff %@", improved.stepFrequencyRange, improved.stepLowThresholdRange, improved.stepHighThresholdRange, improved.stepDiffThresholdRange]];
    
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
    /*CMStepCounter *stepsCounter;*/
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
    /*stepsCounter = [[CMStepCounter alloc] init];*/
    
    segmentAnalyzers = [[NSMutableArray alloc] init];
    [segmentAnalyzers addObject:[ICEMotionSegmentAnalyzer analyzerWithId:@"DEFAULT" validator:nil]];
    
    return self;
}

-(void) startStepsCounting
{
    [ICELogger verbose:TAG line:[NSString stringWithFormat:(@"starting step-counting at %f interval"), updateEveryXSec]];
    countedSteps=0;
    /*if(CMStepCounter.isStepCountingAvailable){
        [ICELogger info:TAG line:@"counting using M7 chip"];
        
        [self countStepsUsingStepCounter];
    }
    else{*/
        [ICELogger info:TAG line:@"counting uisng acceloeromter"];
        
        [self countStepsUsingAccelerometer];
    /*}*/
    
}

-(void) startStepsCountingWithHandler:(ICEStepsCountHandler)stepsCountHandler updateEvery:(NSInteger)steps
{
    // this is raw and very temporary:
    countedStepsHandler = [ICEStepsCountUpdateHandler updateHandlerWith:stepsCountHandler steps:steps];
    if(countedStepsHandlerTimer!=nil){
        [countedStepsHandlerTimer invalidate];
        countedStepsHandlerTimer=nil;
    }
   // countedStepsHandlerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(reportCurrentCountToHandler) userInfo:nil repeats:YES];
    
    [self startStepsCounting];
    
}
                       
-(void)reportCurrentCountToHandler
{
    if(countedStepsHandler==nil){
        return;
    }
    /*if(!CMStepCounter.isStepCountingAvailable){
    */
        BOOL isAccelerating = accelerating;
    ICEMotionSegmentAnalyzer* analyzer = [ICEMotionSegmentAnalyzer analyzerWithId:@"TEMP" validator:[self bestAnalyzer].stepValidator];
        
        ICEMotionSegmentAnalysisResult *result = [analyzer analyzeSegment:[self.accelerationRecords.motionSegments lastObject] currentlyAccelerating:isAccelerating expectedStepsMin:3 expectedMax:20];
        countedSteps = self.stepsCountAccelerometer+result.countedSteps;
        
    /*}*/
    [ICELogger debug:TAG line:[NSString stringWithFormat:@"reportCurrentCountToHandler - %ld steps.", (long)countedSteps]];
    countedStepsHandler.handler(countedSteps);
    
    
}
                        
/*
-(void)countStepsUsingStepCounter
{
    [stepsCounter startStepCountingUpdatesToQueue:[NSOperationQueue mainQueue] updateOn:1 withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
        countedSteps=numberOfSteps;
        [ICELogger info:TAG line:[NSString stringWithFormat:@"countStepsUsingStepCounter - %ld steps.", (long)countedSteps]];
    } ];
}
*/

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
    
    lowPassFilter = [[LowpassFilter  alloc] initWithSampleRate:1.0/updateEveryXSec cutoffFrequency:[self filterCutoff]];
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
    [ICELogger warning:TAG line:@"stopping...."];
    if(countedStepsHandlerTimer!=nil){
        [countedStepsHandlerTimer invalidate];
        countedStepsHandlerTimer=nil;
    }
    /*if(CMStepCounter.isStepCountingAvailable){
        [stepsCounter stopStepCountingUpdates];
    }
    else{*/
        [motionManager stopGyroUpdates];
        [motionManager stopDeviceMotionUpdates];
        [self analyzeAccelerationDataWithSegment:[self.accelerationRecords.motionSegments lastObject]];
    
    /*}*/
}


-(ICEMotionSegmentAnalyzer*) bestAnalyzer
{
    // the best analyzer is the one at the end of the collection.
    // the collection is sorted according to the performace rates of the analyzers.
    ICEMotionSegmentAnalyzer *analyzer = [segmentAnalyzers lastObject];
    return analyzer;
}


static int analyzerIds=0;

-(void) analyzeAccelerationDataWithSegment: (ICEMotionSegmentRecords*) segment
{
    if(segment==nil){
        return;
    }
        
    BOOL isAccelerating = accelerating;
    ICEMotionSegmentAnalyzer* analyzer = [self bestAnalyzer];
    
    ICEMotionSegmentAnalysisResult *result = [analyzer analyzeSegment:segment currentlyAccelerating:isAccelerating expectedStepsMin:3 expectedMax:30];
    
    // first update the performance of this analyzer with the certainty achieved in this analysis
    [analyzer  addResultCertaintyToPerformanceRate:result.resultCertainty];
    
    if(result.resultCertainty>=ICEMotionAnalysisCertaintyMid){
        
        // update the analysis results to the segment and update the "accelerating" value according to the analysis result.
        
        [analyzer updateResultsToSegment];
        accelerating = result.endingAcceleration; // i.e. the analysis ended with this "accelerating" value;
        
        countedSteps = self.stepsCountAccelerometer+result.countedSteps;
        
    }
    else if(result.resultCertainty<=ICEMotionAnalysisCertaintyLow && segmentAnalyzers.count>=2){
        // try to analyze using a previous analyzer
        ICEMotionSegmentAnalyzer *previous;
        for(unsigned long i=segmentAnalyzers.count-1 ;i>0;i--){
            previous = segmentAnalyzers[i-1];
            ICEMotionSegmentAnalysisResult *prevResult = [previous analyzeSegment:segment currentlyAccelerating:isAccelerating expectedStepsMin:2 expectedMax:30];
            if(prevResult.resultCertainty>result.resultCertainty){
                [ICELogger info:TAG line:@"A previous analyzer performed better"];
                
                [previous updateResultsToSegment];
                [previous  addResultCertaintyToPerformanceRate:result.resultCertainty];
                countedSteps = self.stepsCountAccelerometer+result.countedSteps;
            }
            if(prevResult.resultCertainty>=ICEMotionAnalysisCertaintyMid){
                //that's good enough
                break;
            }
        }
        
    }
    // try to improve - create a tigther analyzer for next segment
    BOOL previousWasImprovement = [analyzer isKindOfClass: [ICEImprovedStepMotionValidator class]];
    
    analyzer = [ICEMotionSegmentAnalyzer analyzerWithId: [NSString stringWithFormat:@"A%d",analyzerIds++]validator:[analyzer generateImprovedValidator]];
    
    // test it on the current segment:
    if(previousWasImprovement){
        result = [analyzer analyzeSegment:segment currentlyAccelerating:isAccelerating expectedStepsMin:result.countedSteps-1 expectedMax:result.countedSteps+1];
    }
    else{
        result = [analyzer analyzeSegment:segment currentlyAccelerating:isAccelerating expectedStepsMin:2 expectedMax:30];
    }
    
    
    if(result.resultCertainty>=ICEMotionAnalysisCertaintyMid){
        // i.e. - is is at least as good as the one it was generated from - add it to the end of the list
        [ICELogger info:TAG line:@"Adding an improved analyzer" ];
        [segmentAnalyzers addObject:analyzer];
        [analyzer  addResultCertaintyToPerformanceRate:result.resultCertainty];
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
        [ICELogger debug:TAG line:[NSString stringWithFormat:@"analyzer %d %@ perf rate: %f",i, a.analyzerId, a.performanceRate]];
    }

    
}



-(unsigned long) stepsCountAccelerometerHighs
{
    unsigned long count=0;
    for (ICEMotionSegmentRecords* segment in self.accelerationRecords.motionSegments) {
        count+=segment.analyzedStepsPeaks.count;
    }
    return count;
}
-(unsigned long) stepsCountAccelerometerLows
{
    unsigned long count=0;
    for (ICEMotionSegmentRecords* segment in self.accelerationRecords.motionSegments) {
        count+=segment.analyzedStepsPeaks.count;
    }
    return count;
}

-(unsigned long) stepsCountAccelerometer
{
    return MIN(self.stepsCountAccelerometerLows, self.stepsCountAccelerometerHighs);
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
//            [ICELogger debug:TAG line:[NSString stringWithFormat:@"(n)%f\t(t)%f\t",  data.vector.size,data.timeStamp);
//
//        }
        [motionData addRecord:data];
    }
    return data;
    
}


@end
