//
//  Charities.h
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Charities : NSObject {
    @private
    NSMutableArray* charitiesInt;
}

@property (readonly, getter = getCharities) NSArray* charities;

- (void) load;

@end
