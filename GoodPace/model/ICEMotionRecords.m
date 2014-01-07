//
//  ICEMotionRecords.m
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/24/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//
#define DEFAULT_SEGMENT_SIZE (200)

#import "ICEMotionRecords.h"
@implementation ICEMotionSegmentRecords

-(id) init
{
    if(!(self=[super init])){
        return nil;
    }
    self.motionValues = [[NSMutableArray alloc] init];
    self.analyzedStepsPeaks = [[NSArray alloc] init];
    
    self.startTime=MAXFLOAT;
    self.endTime=0.0;
    
    return self;
}
-(NSInteger) size
{
    return self.motionValues.count;
}
@end

@implementation ICEMotionRecords
{
    ICEMotionSegmentReadyHandler segmentReadyHandler;
}

-(id) initWithSegmentReadyHandler:(ICEMotionSegmentReadyHandler)segmentHandler
{
    self = [self init];
    segmentReadyHandler = segmentHandler;
    return self;
}

-(id)init
{
    if(!(self=[super init])){
        return nil;
    }
    self.motionSegments = [[NSMutableArray alloc] init];
    [self.motionSegments addObject:[[ICEMotionSegmentRecords alloc] init]];
    
    self.minValue=MAXFLOAT;
    self.maxValue=0.0;
    
    self.segmentSize = DEFAULT_SEGMENT_SIZE;
    segmentReadyHandler = nil;
    return self;
}

-(void) clear
{
    [self.motionSegments removeAllObjects];
    self.minValue=MAXFLOAT;
    self.maxValue=0.0;
    
}

-(NSInteger) size
{
    NSInteger count=0;
    for (ICEMotionSegmentRecords* segment in self.motionSegments) {
        count+=[segment size];
    }
    return count;
}

-(void) addRecord: (ICEMotionData*) record{
    if(record==nil){
        return;
    }
    
    
    if(record.vector.size > self.maxValue) {
        self.maxValue = record.vector.size;
    }
    if(record.vector.x < self.minValue) {
        self.minValue = record.vector.x;
    }
    if(record.vector.y < self.minValue) {
        self.minValue = record.vector.y;
    }
    if(record.vector.z < self.minValue) {
        self.minValue = record.vector.z;
    }
    ICEMotionSegmentRecords* segment = [self.motionSegments lastObject];
    if([segment size]>=self.segmentSize){
        
        NSLog(@"\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
//        NSLog(@"%@ segment full. Start: %f, end:%f",self.name, segment.startTime, segment.endTime);

        if(segmentReadyHandler!=nil){
            segmentReadyHandler(segment);
        }
        segment = [[ICEMotionSegmentRecords alloc] init];
        [self.motionSegments addObject:segment];
    }
    
    
    if(record.timeStamp > segment.endTime) {
        segment.endTime = record.timeStamp;
    }
    if(record.timeStamp < segment.startTime) {
        segment.startTime = record.timeStamp;
    }
    
    [segment.motionValues addObject:record];
    
}
@end
