//
//  ServerObj.m
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "ServerObj.h"
#import "Profile.h"
#import "Globals.h"

@implementation ServerObj

- (id) init {
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void) start {
    
    if (!profile) {
        profile = [[Profile alloc] init];
        [profile load];
    }
    
}

- (void) stop {
    
}

- (void) resume {
    
}

- (void) suspend {
    
}

@end
