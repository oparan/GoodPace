//
//  ICELogger.m
//  GoodPace
//
//  Created by Steiner, Ron on 1/5/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import "ICELogger.h"



@implementation ICELoggerLogEntry

@synthesize tag, line, level, time;

+(id)logEntryWithLevel:(ICELogLevel)level tag:(NSString*) aTag line:(NSString*) aLine
{
    ICELoggerLogEntry *entry = [[ICELoggerLogEntry alloc] init];
    entry->level=level;
    entry->line = aLine;
    entry->tag = aTag;
    entry->time = [NSDate date];
    return entry;
}

@end



static NSMutableArray* logs;

@implementation ICELogger

+(void)log: (ICELogLevel) level tag:(const NSString*) aTag line:(NSString*) aLine
{
#ifdef DEBUG
    @synchronized (self)
    {
        if(logs==nil){
            logs = [[NSMutableArray alloc] init];
        }
        [logs addObject: [ICELoggerLogEntry logEntryWithLevel:level tag:aTag line:aLine]];
        NSLog(@"%@:\t%@",aTag, aLine);
    }
#endif
}

+(void)verbose:(const NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelVerbose tag:tag line:log];
}
+(void)info:(const NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelInfo tag:tag line:log];
}
+(void)debug:(const NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelDebug tag:tag line:log];
}
+(void)warning:(const NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelWarning tag:tag line:log];
}
+(void)error:(const NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelError tag:tag line:log];
}

+(NSInteger) numberOfEntries
{
    @synchronized (self)
    {
        return logs!=nil ? logs.count:0;
    }
}


+(ICELoggerLogEntry*) entryAtIndex:(NSInteger)index;
{
    @synchronized (self)
    {
        if(logs!=nil && index>=0 && index<logs.count){
            return [logs objectAtIndex:index];
        }
        return nil;
    }
}

@end
