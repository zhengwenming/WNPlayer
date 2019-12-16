//
//  AppDelegate.m
//  WNPlayer
//
//  Created by wenming on 2019/10/9.
//  Copyright © 2019 apple. All rights reserved.
//

#import "AppDelegate.h"
#import "RootTabBarController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window  = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[RootTabBarController alloc]init];
    [self.window makeKeyAndVisible];

    return YES;
}

@end
