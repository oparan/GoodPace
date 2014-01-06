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

+ (UILabel*) createTextLabel:(CGRect) frame text:(NSString*) text color:(UIColor *) color font:(UIFont*) font {

    UILabel* textLabel = [[UILabel alloc] initWithFrame:frame];
    textLabel.text = NSLocalizedString(text, nil);
    
    if (color) {
        textLabel.textColor = color;
    }
    
    if (font) {
        textLabel.font = font;
    }
    
    return textLabel;
}

@end
