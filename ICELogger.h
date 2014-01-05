//
//  ICELogger.h
//  GoodPace
//
//  Created by Steiner, Ron on 1/5/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICELogger : NSObject

+(void)verbose:(NSString *)tag  line:(NSString *)log;
+(void)info:(NSString *)tag  line:(NSString *)log;
+(void)debug:(NSString *)tag  line:(NSString *)log;
+(void)warning:(NSString *)tag  line:(NSString *)log;
+(void)error:(NSString *)tag  line:(NSString *)log;


@end
