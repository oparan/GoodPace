//
//  AppDelegate.m
//  GoodPace
//
//  Created by Paran, Omer on 12/17/13.
//  Copyright (c) 2013 eBay. All rights reserved.
//

#import "AppDelegate.h"
#import "Services.h"
#import "Globals.h"
#import "ServerObj.h"
#import "StepsManager.h"
#import "BackgroundMode.h"
#import "LogObj.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UNUSED(application);
    UNUSED(launchOptions);
    
    // Load services
    logObj = [[LogObj alloc] init];
    services = [[Services alloc] init];

    [services start];
    
    // Load FB classes - otherwise they are not known
    [FBLoginView class];
    [FBProfilePictureView class];
    
    return YES;
}
							
// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
- (void)applicationWillResignActive:(UIApplication *)application {
    UNUSED(application);
    
    [serverObj suspend];
    [backgroundMode resume];
}

// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
- (void)applicationDidEnterBackground:(UIApplication *)application {
    UNUSED(application);
    
    //[serverObj suspend];
}

// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
- (void)applicationWillEnterForeground:(UIApplication *)application {
    UNUSED(application);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UNUSED(application);

    [serverObj resume];
    [backgroundMode suspend];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    UNUSED(application);
    
    [services stop];
}

// For facebook callback URL

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    UNUSED(application);
    UNUSED(annotation);
    
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      UNUSED(call);
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Here goes the code to handle the links
                                      // Use the links to show a relevant view of your app to the user
                                  }];
    
    return urlWasHandled;
}

@end
