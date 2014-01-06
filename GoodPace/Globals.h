//
//  Globals.h
//  GoodPace
//
//  Created by Paran, Omer on 12/18/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#ifndef GoodPace_Globals_h
#define GoodPace_Globals_h

@class ServerObj;
@class Services;
@class Profile;
@class Charity;
@class StepsManager;
@class LogObj;
@class LogViewController;
@class BackgroundMode;

extern Services* services;
extern ServerObj* serverObj;
extern BackgroundMode* backgroundMode;
extern StepsManager* stepsManager;

extern Profile* profile;
extern Charity* activeDonor;
extern LogObj* logObj;
extern LogViewController* logView;

#define UNUSED(x) (void)(x)

#endif
