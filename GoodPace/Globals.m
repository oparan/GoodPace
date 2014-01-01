//
//  Globals.c
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "ServerObj.h"
#import "Services.h"
#import "Profile.h"
#import "StepsManager.h"
#import "LogObj.h"
#import "LogViewController.h"

Services*   services    = nil;
ServerObj*  serverObj   = nil;
Profile*    profile     = nil;
Profile*    activeDonor     = nil;
StepsManager* stepsManager = nil;
LogObj* logObj = nil;
LogViewController* logView = nil;

NSString* getDocPath(NSString* fileName) {
    NSArray*    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString*   documentsDirectoryPath = [paths objectAtIndex:0];
    NSString*   filePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    
    return filePath;
}