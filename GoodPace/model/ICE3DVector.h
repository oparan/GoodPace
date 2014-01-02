//
//  ICE3DVector.h
//  GoodPaceLogic
//
//  Created by Steiner, Ron on 12/23/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICE3DVector : NSObject

@property double x;
@property double y;
@property double z;

@property (readonly) double size;

-(id) initWithX: (double)aX y:(double)aY z:(double)aZ;


@end
