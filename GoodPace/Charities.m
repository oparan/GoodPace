//
//  Charities.m
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "Charities.h"
#import "Charity.h"
#import "Globals.h"

struct Provider {
    char* name;
    char* steps;
    char* money;
    char* icon;
};

struct Provider providers[] = { {"American Heart Association Heart Walk",   "12346" ,"64791", "heart.png"},
                                {"Habitat for humanity",                    "11093" ,"72889", "habitat.png"},
                                {"SPCA of San Francisco Cat & Dog Walk",    "11002" ,"52363", "Spca.png"},
                                {"American Red Cross Walkathon",            "9768" ,"42405", "redCross.png"}
                    };

@implementation Charities

- (id) init {
    self =[super init];
    
    if (self) {
        charitiesInt = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

- (NSArray*) getCharities {
    return charitiesInt;
}

- (void) load {
 
    int size  = sizeof(providers) / sizeof(providers[0]);
                       
    for(int i= 0; i < size; i++) {
        Charity* charity = [[Charity alloc] initWithValues:[NSString stringWithUTF8String:providers[i].name]
                                                     steps:[NSString stringWithUTF8String:providers[i].steps]
                                               moneyRaised:[NSString stringWithUTF8String:providers[i].money]
                                                  iconPath:[NSString stringWithUTF8String:providers[i].icon]];
        [charitiesInt addObject:charity];
    }
}

@end
