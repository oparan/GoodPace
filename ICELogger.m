//
//  ICELogger.m
//  GoodPace
//
//  Created by Steiner, Ron on 1/5/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import "ICELogger.h"
typedef NS_ENUM(NSInteger, ICELogLevel){ICELoggerLevelVerbose=0L, ICELoggerLevelInfo, ICELoggerLevelDebug, ICELoggerLevelWarning, ICELoggerLevelError};


@interface ICELoggerLogEntry : NSObject

+(id)logEntryWithLevel:(ICELogLevel)level tag:(NSString*) aTag line:(NSString*) aLine;
@property (strong, readonly, nonatomic) NSString* tag;
@property (strong, readonly, nonatomic) NSString* line;
@property (readonly, nonatomic)         ICELogLevel level;
@property (readonly, nonatomic)         NSDate* time;

@end

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

+(void)log: (ICELogLevel) level tag:(NSString*) aTag line:(NSString*) aLine
{
    @synchronized (self)
    {
        if(logs==nil){
            logs = [[NSMutableArray alloc] init];
        }
        [logs addObject: [ICELoggerLogEntry logEntryWithLevel:level tag:aTag line:aLine]];
    }
    
}

+(void)verbose:(NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelVerbose tag:tag line:log];
}
+(void)info:(NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelInfo tag:tag line:log];
}
+(void)debug:(NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelDebug tag:tag line:log];
}
+(void)warning:(NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelWarning tag:tag line:log];
}
+(void)error:(NSString *)tag  line:(NSString *)log
{
    [ICELogger log:ICELoggerLevelError tag:tag line:log];
}

@end
