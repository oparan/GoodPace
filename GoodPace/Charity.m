//
//  Donor.m
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "Charity.h"

@implementation Charity

- (id)init {
    self = [super init];
    
    if (self) {
        // initialize instance variables here
    }
    
    return self;
}

- (id)initWithValues:(NSString *) name steps:(NSString *)steps moneyRaised:(NSString *)moneyRaised
         iconPath:(NSString *)iconPath
{
    self = [super init];
    
    if (self) {
        self.name = name;
        self.iconPath = iconPath;
        self.steps = steps;
        self.moneyRaised = moneyRaised;
    }
    
    return self;
}

@end
