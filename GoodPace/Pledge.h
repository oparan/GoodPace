//
//  Pledge.h
//  GoodPace
//
//  Created by Paran, Omer on 12/25/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@interface Pledge : NSObject <NSCoding>

@property NSString* name;
@property NSString* neededSteps;
@property NSString* moneyGiven;
@property UIImage* icon;

- (id)initWithValues:(NSString *) name  neededSteps:(NSString*) neededSteps moneyGiven:(NSString *)moneyGiven iconPath:(NSString *)iconPath;

@end
