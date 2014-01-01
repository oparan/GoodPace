//
//  LogObj.h
//  GoodPace
//
//  Created by Paran, Omer on 12/30/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@interface LogObj : NSObject {
    @private
    NSMutableString* logString;
}

@property (readonly, getter = getLogs) NSString* logs;

- (void) addLog:(NSString*) logLine;

@end
