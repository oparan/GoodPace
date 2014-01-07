//
//  ICENumericRange.h
//  GoodPace
//
//  Created by Steiner, Ron on 1/7/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICENumericRange : NSObject

@property double lowEnd;
@property double highEnd;

+(id)rangeFrom:(double)low to:(double)high;
-(BOOL) isInRange:(double) value;

@end
