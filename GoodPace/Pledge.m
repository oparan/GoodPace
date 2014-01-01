//
//  Pledge.m
//  GoodPace
//
//  Created by Paran, Omer on 12/25/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "Pledge.h"

@implementation Pledge

- (id)init {
    self = [super init];
    
    if (self) {
        // initialize instance variables here
    }
    
    return self;
}

- (id)initWithValues:(NSString *) name  neededSteps:(NSString*) neededSteps moneyGiven:(NSString *)moneyGiven iconPath:(NSString *)iconPath {

    self = [super init];
    
    if (self) {
        self.name = name;
        self.icon = [UIImage imageNamed:iconPath];
        self.moneyGiven = moneyGiven;
        self.neededSteps = neededSteps;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.icon forKey:@"icon"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.moneyGiven forKey:@"moneyGiven"];
    [coder encodeObject:self.neededSteps forKey:@"neededSteps"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.icon = [coder decodeObjectForKey:@"icon"];
        self.moneyGiven = [coder decodeObjectForKey:@"moneyGiven"];
        self.neededSteps = [coder decodeObjectForKey:@"neededSteps"];
    }
    
    return self;
}


@end
