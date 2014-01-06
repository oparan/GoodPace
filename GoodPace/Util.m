//
//  Util.m
//  GoodPace
//
//  Created by Paran, Omer on 1/5/14.
//  Copyright (c) 2014 eBay. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString*) getDocPath:(NSString*) fileName {
    
    NSArray*    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*   documentsDirectoryPath = [paths objectAtIndex:0];
    NSString*   filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}

@end
