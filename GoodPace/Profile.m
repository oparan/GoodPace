//
//  Profile.m
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "Profile.h"
#import "Charities.h"

@implementation Profile

@synthesize charities;

- (id) init {
    self = [super init];
    
    if (self) {
        charitiesObj = [[Charities alloc] init];
    }
    
    return self;
}

- (void) load {

    [charitiesObj load];
}

- (NSArray*) getCharities {
    return charitiesObj.getCharities;
}

@end
