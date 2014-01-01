//
//  MasterViewController.h
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@class DetailViewController;

@interface MasterViewController : UITableViewController {
    @private
    UIImage* walkManImg;
    
    @private
    BOOL fromWalkScreen;
    
    @private
    DetailViewController* detailViewController;
    
    @private
    NSArray* charities;
}

@property (weak, nonatomic) IBOutlet UINavigationItem* navItem;

- (void) setFromWalkScreen:(DetailViewController*) detailViewController;

@end
