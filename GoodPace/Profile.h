//
//  Profile.h
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Charities.h"

@interface Profile : NSObject {
    @private
    Charities* charitiesObj;
    
}

@property (readonly, getter = getCharities) NSArray* charities;

- (void) load;

@end
