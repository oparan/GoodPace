//
//  IPhone5SStepsCounter.h
//  GoodPace
//
//  Created by Paran, Omer on 12/29/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@interface IPhone5SStepsCounter : NSObject {
    @private
    CMStepCounter* stepsCounter;
}

- (void) start;

@end
