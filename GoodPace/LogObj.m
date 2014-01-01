//
//  LogObj.m
//  GoodPace
//
//  Created by Paran, Omer on 12/30/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "LogObj.h"
#import "Globals.h"
#import "LogViewController.h"

static const int maxLength = 10000;

@implementation LogObj

- (id) init {
    self = [super init];
    
    if (self) {
        logString = [[NSMutableString alloc] initWithCapacity:maxLength];
    }
    
    return self;
}

- (NSString*) getLogs {
    return logString;
}

- (void) addLog:(NSString*) logLine {
    
    if ([logString length] > maxLength){
        [logString setString:@""];
    }
    else {
        [logString appendString:@"\n"];
    }
    
    [logString appendString:logLine];
    
    [logView upodateLog];
}

@end
