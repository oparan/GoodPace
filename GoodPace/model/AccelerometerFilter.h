//
//  AccelerometerFilter.h
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/24/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICE3DVector.h"

#import <UIKit/UIKit.h>

// Basic filter object.
@interface AccelerometerFilter : NSObject
{
	BOOL adaptive;
	double x, y, z;
}

// Add a UIAcceleration to the filter.
- (void)addAccelerationX:(double)anX y:(double)aY z:(double)aZ;

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;
@property (nonatomic, readonly) double z;

@property (nonatomic, getter=isAdaptive) BOOL adaptive;
@property (unsafe_unretained, nonatomic, readonly) NSString *name;

@end

#pragma mark -

// A filter class to represent a lowpass filter
@interface LowpassFilter : AccelerometerFilter
{
	double filterConstant;
	ICE3DVector *lastAccelerationVector;
}

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

@end

#pragma mark -

// A filter class to represent a highpass filter.
@interface HighpassFilter : AccelerometerFilter
{
	double filterConstant;
	ICE3DVector *lastAccelerationVector;
}

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

@end
