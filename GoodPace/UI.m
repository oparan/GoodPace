//
//  UI.m
//  GoodPace
//
//  Created by Paran, Omer on 12/24/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "UI.h"

@implementation UI

+ (void) addRightButton:(UIViewController*) viewCtrl title:(NSString*) title action:(SEL) action {

    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:viewCtrl action:action];
    viewCtrl.navigationItem.rightBarButtonItem = button;
}

+ (void) showOKMsg:(NSString*) msg title:(NSString*) title {
    [[[UIAlertView alloc] initWithTitle:title
                                message:msg
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];

}


@end
