//
//  Services.m
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "Services.h"

#import "Globals.h"
#import "ServerObj.h"
#import "StepsManager.h"
#import "BackgroundMode.h"

@implementation Services

- (id) init {
    self = [super init];
    
    if (self) {
        // initialize instance variables here
    }
    
    return self;
}

- (void) start {
    
    [self createServices];
    
    [serverObj start];
}

- (void) stop {
    
    [serverObj stop];
    [stepsManager stop];
    [backgroundMode stop];
}

- (void) suspend {
    
    [serverObj suspend];
    
}

- (void) resume {
    
    [serverObj resume];
    
}

- (void) createServices {
    
    if (serverObj == nil) {
        serverObj = [[ServerObj alloc] init];
    }
    
    if (stepsManager == nil) {
        stepsManager = [[StepsManager alloc] init];
    }
    
    if (backgroundMode == nil) {
        backgroundMode = [[BackgroundMode alloc] init];
    }
}

@end
