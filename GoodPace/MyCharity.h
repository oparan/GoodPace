//
//  MyCharity.h
//  GoodPace
//
//  Created by Paran, Omer on 12/26/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@class Pledges;
@class Pledge;

@interface MyCharity : NSObject <NSCoding> {
    @private
    int addedStepsInt;
}

    @property NSMutableString* addedSteps;
    @property NSMutableString* steps;
    @property NSString* name;
    @property NSMutableString* momeyRaised;
    @property NSString* stepsPerDollar;

    @property NSMutableArray* pledges;

- (id) initWithName:(NSString*) name;
- (void) addPledge:(Pledge*) pledge;
- (void) addSteps:(int) newSteps;
- (void) walkingStarts;
- (int) goalOfSteps;
- (NSArray*) getPledges;
@end
