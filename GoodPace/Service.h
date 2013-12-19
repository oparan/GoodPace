//
//  Service.h
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Service <NSObject>

- (void) start;
- (void) stop;
- (void) resume;
- (void) suspend;


@end
