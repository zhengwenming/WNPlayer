//
//  RootTabBarController.m
//  WNPlayer
//
//  Created by apple on 2019/10/10.
//  Copyright © 2019 apple. All rights reserved.
//

#import "RootTabBarController.h"
#import "BaseNavigationController.h"

@interface RootTabBarController ()

@end

@implementation RootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *viewControllersArray = [NSMutableArray array];
    
    UIViewController  *firstVC =  [[NSClassFromString(@"FirstViewController") alloc]init];
    BaseNavigationController *firstNav = [[BaseNavigationController alloc]initWithRootViewController:firstVC];
    firstVC.title =@"WNPlayer测试";
    firstNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"First" image:[[UIImage imageNamed:@"tab_live"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_live_p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [viewControllersArray addObject:firstNav];
    
    
    UIViewController  *secondVC =  [[NSClassFromString(@"SecondViewController") alloc]init];
    BaseNavigationController *secondNav = [[BaseNavigationController alloc]initWithRootViewController:secondVC];
    secondVC.title =@"second";
    secondNav.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Second" image:[[UIImage imageNamed:@"tab_me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_me_p"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [viewControllersArray addObject:secondNav];
    
    self.viewControllers = viewControllersArray;
    self.tabBar.tintColor = UIColor.darkGrayColor;
    self.tabBar.translucent = NO;
}

@end
