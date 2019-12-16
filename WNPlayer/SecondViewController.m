//
//  SecondViewController.m
//  WNPlayer
//
//  Created by apple on 2019/10/10.
//  Copyright © 2019 apple. All rights reserved.
//

#import "SecondViewController.h"
#import "WNPlayer.h"
#import "CustomerControlView_test.h"

@interface SecondViewController ()<WNPlayerDelegate>
@property(nonatomic,assign)CGRect originalRect;
@end

@implementation SecondViewController
-(void)player:(WNPlayer *)player clickedPlayOrPauseButton:(UIButton *)playOrPauseBtn{
    NSLog(@"playOrPauseBtn");
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.originalRect = CGRectMake(0, [WNPlayer IsiPhoneX]?44:0, self.view.frame.size.width, self.view.frame.size.width*(9.0/16));
    WNPlayer *wnPlayer = [[WNPlayer alloc] initWithFrame:self.originalRect];
    wnPlayer.autoplay = YES;
    wnPlayer.delegate = self;
    wnPlayer.repeat = YES;
    wnPlayer.restorePlayAfterAppEnterForeground = YES;
    //连接设置控制层
    CustomerControlView_test *contrlView = [[CustomerControlView_test alloc] initWithFrame:wnPlayer.bounds];
//        contrlView.title = @"测试播放wmv";
    contrlView.coverImageView.image = [UIImage imageNamed:@"cover"];
    wnPlayer.controlView = contrlView;

//        self.wnPlayer.urlString = @"rtsp://184.72.239.149/vod/mp4://BigBuckBunny_175k.mov";
    wnPlayer.urlString = @"http://mov.bn.netease.com/mobilev/open/nos/mp4/2015/12/09/SB9F77DEA_sd.mp4";
    [self.view addSubview:wnPlayer];
    [wnPlayer play];
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
@end
