//
//  WhereamiAppDelegate.m
//  Whereami
//
//  Created by Sivaram Adhiappan on 5/12/13.
//  Copyright (c) 2013 Sivaram Adhiappan. All rights reserved.
//

#import "WhereamiAppDelegate.h"
#import "WhereamiViewController.h"
#import "LocationsViewController.h"
#import "PaperFoldNavigationController.h"

@implementation WhereamiAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

//    UITabBarController *tabBar = [[UITabBarController alloc] init];
//    WhereamiViewController *whereamiController = [[WhereamiViewController alloc] init];
//    LocationsViewController *locationsViewController = [[LocationsViewController alloc] init];
//    tabBar.viewControllers = [NSArray arrayWithObjects:whereamiController, locationsViewController, nil];
//    
//    self.window.rootViewController = tabBar;
    [self.window makeKeyAndVisible];
    
    LocationsViewController *locationsViewController = [[LocationsViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:locationsViewController];
    PaperFoldNavigationController *paperFoldNavController = [[PaperFoldNavigationController alloc] initWithRootViewController:navController];
    [self.window setRootViewController:paperFoldNavController];
    
//    Left View to be implmented later
//    LeftViewController *leftViewController = [[LeftViewController alloc] init];
//    UINavigationController *leftNavController = [[UINavigationController alloc] initWithRootViewController:leftViewController];
//    [leftNavController setNavigationBarHidden:YES];
//    [paperFoldNavController setLeftViewController:leftNavController width:150];
    
    WhereamiViewController *whereamiController = [[WhereamiViewController alloc] init];
    UINavigationController *rightNavController = [[UINavigationController alloc] initWithRootViewController:whereamiController];
    [rightNavController setNavigationBarHidden:YES];
    [paperFoldNavController setRightViewController:rightNavController width:250.0 rightViewFoldCount:3 rightViewPullFactor:0.9];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
