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
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.icon forKey:@"icon"];
    [coder encodeObject:self.joined forKey:@"joined"];
    [coder encodeObject:self.moneyRaised forKey:@"moneyRaised"];
    [coder encodeObject:self.description forKey:@"description"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.stepsPerDollar forKey:@"stepsPerDollar"];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.name = [coder decodeObjectForKey:@"name"];
        self.icon = [coder decodeObjectForKey:@"icon"];
        self.joined = [coder decodeObjectForKey:@"joined"];
        self.moneyRaised = [coder decodeObjectForKey:@"moneyRaised"];
        self.description = [coder decodeObjectForKey:@"description"];
        self.url = [coder decodeObjectForKey:@"url"];
        self.stepsPerDollar = [coder decodeObjectForKey:@"stepsPerDollar"];
        
        if (self.stepsPerDollar == 0) {
            self.stepsPerDollar = @"100";
        }
    }
    
    return self;
}


- (id)initWithValues:(NSString *) name description:(NSString*) description joined:(NSString *)joined moneyRaised:(NSString *)moneyRaised
            iconPath:(NSString *)iconPath url:(NSString*)url
{
    self = [super init];
    
    if (self) {
        self.name = name;
        self.icon = [UIImage imageNamed:iconPath];
        self.joined = joined;
        self.moneyRaised = moneyRaised;
        self.description = description;
        self.stepsPerDollar = @"100";
        self.url = url;
    }
    
    return self;
}

@end
