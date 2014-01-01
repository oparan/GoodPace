//
//  WalkInfoViewController.h
//  GoodPace
//
//  Created by Paran, Omer on 12/25/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@class Charity;
@class MyCharity;

#import "StepsManager.h"

@interface WalkInfoViewController : UITableViewController <UIActionSheetDelegate, StepsHandler> {
    @private
    MyCharity* myCharity;
    
    @private
    enum EMessaureBy messaureBy;
    
    @private
    UILabel* stepsLabel;
}

@end
