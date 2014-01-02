//
//  ICEMotionData.h
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/23/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICE3DVector.h"


@interface ICEMotionData : NSObject

@property (readonly) ICE3DVector * vector;
@property (readonly) double timeStamp;

-(id) initWithVector:(ICE3DVector*) aVector atTime:(double) on;

@end
