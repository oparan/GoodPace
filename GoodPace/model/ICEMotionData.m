//
//  ICEMotionData.m
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/23/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "ICEMotionData.h"

@implementation ICEMotionData
-(id) initWithVector:(ICE3DVector*) aVector atTime:(double) on
{
    if(!(self = [super init])){
        return nil;
    }
    self->_vector = aVector;
    self->_timeStamp = on;
    return self;
}
@end
