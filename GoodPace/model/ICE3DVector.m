//
//  ICE3DVector.m
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/23/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "ICE3DVector.h"

@implementation ICE3DVector

-(id) initWithX:(double)aX y:(double)aY z:(double)aZ
{
    if(! (self = [super init]) ){
        return nil;
    }
    self.x = aX;
    self.y = aY;
    self.z = aZ;
    
    return self;
}

-(double) size
{
    double s =  self.x*self.x+self.y*self.y+self.z*self.z;
    return sqrt(s);
}

@end
