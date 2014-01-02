//
//  AccelerometerFilter.m
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/24/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "AccelerometerFilter.h"

@implementation AccelerometerFilter

@synthesize x, y, z, adaptive;


- (void)addAccelerationX:(double)anX y:(double)aY z:(double)aZ
{
	x = anX;
    y = aY;
    z = aZ;
}

- (NSString *)name
{
	return @"You should not see this";
}

@end


#pragma mark -

#define kAccelerometerMinStep				0.02
#define kAccelerometerNoiseAttenuation		3.0

double Norm(double x, double y, double z)
{
	return sqrt(x * x + y * y + z * z);
}

double Clamp(double v, double min, double max)
{
	if(v > max)
		return max;
	else if(v < min)
		return min;
	else
		return v;
}


#pragma mark -

// See http://en.wikipedia.org/wiki/Low-pass_filter for details low pass filtering
@implementation LowpassFilter

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	self = [super init];
	if(self != nil)
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = dt / (dt + RC);
	}
	return self;
}

- (void)addAccelerationX:(double)anX y:(double)aY z:(double)aZ
{
	double alpha = filterConstant;
	
	if(adaptive)
	{
		double d = Clamp(fabs(Norm(x, y, z) - Norm(anX, aY, aZ)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = (1.0 - d) * filterConstant / kAccelerometerNoiseAttenuation + d * filterConstant;
	}
	
	x = anX * alpha + x * (1.0 - alpha);
	y = aY * alpha + y * (1.0 - alpha);
	z = aZ * alpha + z * (1.0 - alpha);
}

- (NSString *)name
{
	return adaptive ? @"Adaptive Lowpass Filter" : @"Lowpass Filter";
}

@end


#pragma mark -

// See http://en.wikipedia.org/wiki/High-pass_filter for details on high pass filtering
@implementation HighpassFilter

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	self = [super init];
	if (self != nil)
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = RC / (dt + RC);
	}
	return self;
}

- (void)addAccelerationX:(double)anX y:(double)aY z:(double)aZ
{
	double alpha = filterConstant;
	
	if (adaptive)
	{
		double d = Clamp(fabs(Norm(x, y, z) - Norm(anX, aY, aZ)) / kAccelerometerMinStep - 1.0, 0.0, 1.0);
		alpha = d * filterConstant / kAccelerometerNoiseAttenuation + (1.0 - d) * filterConstant;
	}
	
	x = alpha * (x + anX - lastAccelerationVector.x);
	y = alpha * (y + aY - lastAccelerationVector.y);
	z = alpha * (z + aZ - lastAccelerationVector.z);
	
	lastAccelerationVector.x = anX;
	lastAccelerationVector.y = aY;
	lastAccelerationVector.z = aZ;
}

- (NSString *)name
{
	return adaptive ? @"Adaptive Highpass Filter" : @"Highpass Filter";
}

@end
