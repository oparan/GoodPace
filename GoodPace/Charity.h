//
//  Donor.h
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Charity : NSObject  <NSCoding>

    @property UIImage* icon;
    @property NSString* name;
    @property NSString* joined;
    @property NSString* moneyRaised;
    @property NSString* description;
    @property NSString* url;
    @property NSString* stepsPerDollar;

- (id)initWithValues:(NSString *) name  description:(NSString*) description joined:(NSString *)joined moneyRaised:(NSString *)moneyRaised
            iconPath:(NSString *)icon url:(NSString*)url;

@end
