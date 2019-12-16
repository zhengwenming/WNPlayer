//
//  FirstViewController.m
//  WNPlayer
//
//  Created by apple on 2019/10/10.
//  Copyright © 2019 apple. All rights reserved.
//

#import "FirstViewController.h"
#import "DetailViewController.h"

@interface FirstViewController ()
@property(nonatomic,strong)UIButton *abtn;

@end

@implementation FirstViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.abtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.abtn.frame = CGRectMake(0, 0, 150, 50);
    [self.abtn setTitle:@"万能播放器" forState:UIControlStateNormal];
    [self.abtn setTitle:@"万能播放器" forState:UIControlStateSelected];
    self.abtn.backgroundColor = UIColor.grayColor;
    [self.abtn addTarget:self action:@selector(pushDetailVC:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.abtn];
    self.abtn.center =self.view.center;
}
-(void)pushDetailVC:(UIButton *)sender{
    DetailViewController *detailVC = [DetailViewController new];
    [self.navigationController pushViewController:detailVC animated:YES];
}
-(void)viewWillLayoutSubviews{
    self.abtn.center =self.view.center;
}
@end
