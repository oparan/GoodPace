//
//  ICEMotionRecords.h
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/24/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICEMotionData.h"



@interface ICEMotionSegmentRecords : NSObject

@property (strong, nonatomic) NSMutableArray *motionValues;
@property (strong, nonatomic) NSArray *highPeaks, *lowPeaks, *analyzedStepsPeaks;
@property (nonatomic) double startTime;
@property (nonatomic) double endTime;


-(NSInteger) size;

@end


typedef void (^ICEMotionSegmentReadyHandler)(ICEMotionSegmentRecords* segment);


@interface ICEMotionRecords : NSObject

@property (strong, nonatomic) NSString *name; // for debug purposes
@property (strong, nonatomic) NSMutableArray *motionSegments; // the colection of motion segments
@property (nonatomic) double minValue; // the lowest value (vector size) among the collected records
@property (nonatomic) double maxValue; // the highest value (vector size) among the collected records
@property (nonatomic) unsigned int segmentSize; // how may records define a segment

-(id) initWithSegmentReadyHandler:(ICEMotionSegmentReadyHandler)segmentHandler;
-(void) clear;
-(NSInteger) size;
-(void) addRecord: (ICEMotionData*) record;

@end
