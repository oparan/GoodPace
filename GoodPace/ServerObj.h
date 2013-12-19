//
//  ServerObj.h
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Service.h"

@interface ServerObj : NSObject <Service>

- (void) start;
- (void) stop;
- (void) resume;
- (void) suspend;

@end
