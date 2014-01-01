//
//  UI.h
//  GoodPace
//
//  Created by Paran, Omer on 12/24/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

@interface UI : NSObject

+ (void) addRightButton:(UIViewController*) viewCtrl title:(NSString*) title action:(SEL) action;
+ (void) showOKMsg:(NSString*) msg title:(NSString*) title;

@end
