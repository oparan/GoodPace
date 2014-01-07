//
//  ICENumericRange.m
//  GoodPace
//
//  Created by Steiner, Ron on 1/7/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import "ICENumericRange.h"

@implementation ICENumericRange
+(id)rangeFrom:(double)low to:(double)high
{
    ICENumericRange *range = [[ICENumericRange alloc] init];
    range.lowEnd = low;
    range.highEnd = high;
    return range;
}

-(BOOL) isInRange:(double) value
{
    return (value>=self.lowEnd && value<=self.highEnd);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%f, %f]",self.lowEnd, self.highEnd];
}
@end
