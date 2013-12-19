//
//  Donor.h
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Charity : NSObject

    @property NSString* iconPath;
    @property NSString* name;
    @property NSString* steps;
    @property NSString* moneyRaised;

- (id)initWithValues:(NSString *) name steps:(NSString *)steps moneyRaised:(NSString *)moneyRaised
            iconPath:(NSString *)iconPath;


@end
