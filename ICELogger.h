//
//  ICELogger.h
//  GoodPace
//
//  Created by Steiner, Ron on 1/5/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ICELogLevel){ICELoggerLevelVerbose=0L, ICELoggerLevelInfo, ICELoggerLevelDebug, ICELoggerLevelWarning, ICELoggerLevelError};


@interface ICELoggerLogEntry : NSObject

+(id)logEntryWithLevel:(ICELogLevel)level tag:(const NSString*) aTag line:(const NSString*) aLine;
@property (strong, readonly, nonatomic) NSString* tag;
@property (strong, readonly, nonatomic) NSString* line;
@property (readonly, nonatomic)         ICELogLevel level;
@property (readonly, nonatomic)         NSDate* time;

@end

@interface ICELogger : NSObject

+(void)verbose:(const NSString *)tag  line:(NSString *)log;
+(void)info:(const NSString *)tag  line:(NSString *)log;
+(void)debug:(const NSString *)tag  line:(NSString *)log;
+(void)warning:(const NSString *)tag  line:(NSString *)log;
+(void)error:(const NSString *)tag  line:(NSString *)log;

+(NSInteger) numberOfEntries;

+(ICELoggerLogEntry*) entryAtIndex:(NSInteger)index;

@end
