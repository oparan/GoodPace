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

static NSString* profileFile = @"user_profile";
static const int SAVE_TIMER_INT = 1;

@implementation ServerObj

- (id) init {
    
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

- (void) start {

    // Load Profile
    if (!profile) {
        profile = [Profile loadFromArchive];
       
       if (!profile) {
           profile = [[Profile alloc] init];
       }
    }
    
    [self startTimer];
}

- (void) stop {
    [saveTimer invalidate];
    [profile save];
}

- (void) resume {
    [self startTimer];
}

- (void) suspend {
    [saveTimer invalidate];
    [profile save];
}

- (void) startTimer {
    if (!saveTimer) {
        saveTimer = [NSTimer scheduledTimerWithTimeInterval:SAVE_TIMER_INT
                                                     target:self
                                                   selector:@selector(timerFireMethod:)
                                                   userInfo:nil
                                                    repeats:YES];
    }
}

- (void)timerFireMethod:(NSTimer *)timer {
    
    (void)(timer);
    
    [profile save];
}

@end
