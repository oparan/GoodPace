//
//  StepsManager.h
//  GoodPace
//
//  Created by Paran, Omer on 12/29/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "Service.h"

@class IPhone5SStepsCounter;

enum EMessaureBy { eNone, eDevice, eFitBit };

@protocol StepsHandler <NSObject>

- (void) update:(NSInteger) steps;

@end

@interface StepsManager : NSObject <Service> {

    @private
    id<StepsHandler> stepsHandler;
    
    @private
    enum EMessaureBy messaureBy;
    
    @private
    IPhone5SStepsCounter* iPhone5SStepsCounter;
    
    @private
    BOOL hardwareCounting;
    
    @private
    int totalCount;
}

- (void) setHandler:(id<StepsHandler>) stepsHandler messaureBy:(enum EMessaureBy) messaureBy;
- (void) update:(NSInteger) numSteps;
- (void) wakeUp;

@end
