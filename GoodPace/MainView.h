//
//  MainView.h
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainView : UIView <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView  *donorsTable;
}

@end