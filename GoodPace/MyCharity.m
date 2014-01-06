//
//  MyCharity.m
//  GoodPace
//
//  Created by Paran, Omer on 12/26/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "MyCharity.h"

#import "Pledge.h"

@implementation MyCharity

- (id) initWithName:(NSString*) name {
    self = [super init];
    
    if (self) {
        self.name = name;
        
        self.steps = [[NSMutableString alloc] init];
        self.addedSteps = [[NSMutableString alloc] init];
        self.momeyRaised = [[NSMutableString alloc] init];
        
        self.pledges = [[NSMutableArray alloc] initWithCapacity:10];
        [self addDefPledges];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    if (addedStepsInt != 0) {
        long stepsPerDollar = [self.stepsPerDollar intValue];
        
        int moneyRaised = (int) ([self.steps intValue] + addedStepsInt) / stepsPerDollar;
        
        [self.addedSteps setString:[NSString stringWithFormat:@"%d", addedStepsInt]];
        
        [self.momeyRaised setString:[NSString stringWithFormat:@"%d", moneyRaised]];
    }

    [coder encodeObject:self.addedSteps forKey:@"addedSteps"];
    [coder encodeObject:self.steps forKey:@"steps"];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.momeyRaised forKey:@"momeyRaised"];
    [coder encodeObject:self.stepsPerDollar forKey:@"stepsPerDollar"];
    
    if (self.pledges) {
        [coder encodeObject:self.pledges forKey:@"pledges"];
    }
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.stepsPerDollar = [coder decodeObjectForKey:@"stepsPerDollar"];
        
        self.addedSteps = [[NSMutableString alloc] initWithString:[coder decodeObjectForKey:@"addedSteps"]];
        addedStepsInt = [self.addedSteps intValue];
        
        self.steps = [[NSMutableString alloc] initWithString:[coder decodeObjectForKey:@"steps"]];
        self.momeyRaised = [[NSMutableString alloc] initWithString:[coder decodeObjectForKey:@"momeyRaised"]];
        
        self.pledges = [coder decodeObjectForKey:@"pledges"];
        
        if (!self.pledges) {
            self.pledges = [[NSMutableArray alloc] initWithCapacity:10];
            [self addDefPledges];
        }
        
        // Reset left overs from the past walk
        [self walkingStarts];
    }
    
    return self;
}

- (void) walkingStarts {

    if (addedStepsInt != 0) {
        [self.steps setString:[NSString stringWithFormat:@"%d", [self.steps intValue] + addedStepsInt]];
        [self.addedSteps setString:@""];
        addedStepsInt = 0;
    }
}

- (void) addDefPledges {
    struct Pledge {
        char* name;
        char* neededSteps;
        char* moneyGiven;
        char* iconPath;
    };
    
    struct Pledge pledges[] = { { "Vincent Giseppi", "25000","100", "ron.png"},
                                { "Omer Paran", "7500","300", "omer.png"},
                                { "Ron Steiner", "150000","500", "dina.png"},
    };
    
    int size  = sizeof(pledges) / sizeof(pledges[0]);
    
    for(int i= 0; i < size; i++) {
        
        int neededSteps = arc4random() % 10000;
        
        Pledge* pledge = [[Pledge alloc] initWithValues:[NSString stringWithUTF8String:pledges[i].name]
                                            neededSteps:[NSString stringWithFormat:@"%d", neededSteps]
                                             moneyGiven:[NSString stringWithFormat:@"%d", neededSteps / 100]
                                               iconPath:[NSString stringWithUTF8String:pledges[i].iconPath]];
        [self.pledges addObject:pledge];
    }


}

- (NSArray*) getPledges {
    return self.pledges;
}

- (void) addPledge:(Pledge*) pledge {
    [self.pledges addObject:pledge];
}

- (void) addSteps:(int) newSteps {
    addedStepsInt = newSteps;
}

- (int) goalOfSteps {
    int retGoal = 0;
    for (Pledge* pledge in self.pledges) {
        retGoal += [pledge.neededSteps intValue];
    }
    
    return retGoal;
}

@end
