//
//  Profile.h
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@class Pledges;
@class Charities;
@class MyCharity;

@interface Profile : NSObject <NSCoding> {
    @private
    NSMutableDictionary* charities;
    
    @private
    NSMutableDictionary* myCharities;
}

@property (readonly, getter = getCharities) NSDictionary* charities;

@property  id<FBGraphUser> fbUser;
@property  (nonatomic) UIImage* userImg;

+ (id) loadFromArchive;

- (void) save;
- (void) addMyCharity:(NSString*) name;
- (MyCharity*) myCharityByName:(NSString*) charityName;


@end
