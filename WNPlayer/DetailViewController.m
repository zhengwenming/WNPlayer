//
//  DetailViewController.m
//  WNPlayer
//
//  Created by apple on 2019/10/10.
//  Copyright © 2019 apple. All rights reserved.
//

#import "DetailViewController.h"
#import "WNPlayer.h"
@interface DetailViewController ()<WNPlayerDelegate>
@property(nonatomic,strong)WNPlayer *wnPlayer;
@property(nonatomic,assign)CGRect originalRect;
@property(nonatomic,strong)WNControlView *customerControlView;
@end

@implementation DetailViewController

-(BOOL)shouldAutorotate{
    return YES;
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(BOOL)prefersStatusBarHidden{
    return NO;
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
//点击关闭按钮代理方法
-(void)player:(WNPlayer *)player clickedCloseButton:(UIButton *)backBtn{
    if (self.wnPlayer.isFullScreen) {//全屏
        //强制翻转屏幕，Home键在下边。
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
//点击全屏按钮代理方法
-(void)player:(WNPlayer *)player clickedFullScreenButton:(UIButton *)fullScreenBtn{
    if (self.wnPlayer.isFullScreen) {//全屏
        //强制翻转屏幕，Home键在下边。
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];
    }else{//非全屏
        [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationLandscapeRight) forKey:@"orientation"];
    }
    //刷新
    [UIViewController attemptRotationToDeviceOrientation];
}
/**
 *  旋转屏幕通知
 */
- (void)onDeviceOrientationChange:(NSNotification *)notification{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    UIInterfaceOrientation interfaceOrientation = (UIInterfaceOrientation)orientation;
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortraitUpsideDown:{
            NSLog(@"第3个旋转方向---电池栏在下");
        }
            break;
        case UIInterfaceOrientationPortrait:{
            NSLog(@"第0个旋转方向---电池栏在上");
            [self toOrientation:UIInterfaceOrientationPortrait];
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:{
            NSLog(@"第2个旋转方向---电池栏在左");
            [self toOrientation:UIInterfaceOrientationLandscapeLeft];
        }
            break;
        case UIInterfaceOrientationLandscapeRight:{
            NSLog(@"第1个旋转方向---电池栏在右");
            [self toOrientation:UIInterfaceOrientationLandscapeRight];
        }
            break;
        default:
            break;
    }
}

//点击进入,退出全屏,或者监测到屏幕旋转去调用的方法
-(void)toOrientation:(UIInterfaceOrientation)orientation{
    if (orientation ==UIInterfaceOrientationPortrait) {
        self.wnPlayer.frame = self.originalRect;
        self.wnPlayer.isFullScreen = NO;
    }else{
        self.wnPlayer.frame = self.view.bounds;
        self.wnPlayer.isFullScreen = YES;
    }
    if (@available(iOS 11.0, *)) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
-(void)viewWillDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
       //旋转屏幕通知
       [[NSNotificationCenter defaultCenter] addObserver:self
                                                selector:@selector(onDeviceOrientationChange:)
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil
        ];
    self.view.backgroundColor = UIColor.blackColor;
    self.originalRect = CGRectMake(0, [WNPlayer IsiPhoneX]?44:0, self.view.frame.size.width, self.view.frame.size.width*(9.0/16));
    self.wnPlayer = [[WNPlayer alloc] initWithFrame:self.originalRect];
    self.wnPlayer.autoplay = YES;
    self.wnPlayer.delegate = self;
    self.wnPlayer.repeat = YES;
    self.wnPlayer.restorePlayAfterAppEnterForeground = YES;
    //连接设置控制层
    WNControlView *contrlView = [[WNControlView alloc] initWithFrame:self.wnPlayer.bounds];
    contrlView.title = @"测试播放wmv";
    contrlView.coverImageView.image = [UIImage imageNamed:@"cover"];
    self.wnPlayer.controlView = contrlView;
//        self.wnPlayer.urlString = @"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov";
//    self.wnPlayer.urlString = @"http://mov.bn.netease.com/mobilev/open/nos/mp4/2015/12/09/SB9F77DEA_sd.mp4";
//    self.wnPlayer.urlString = @"https://review.v.news.cn/review/basics/live4958/20200605/0955521822_mp4/095552_1822_5000k.mp4?ut=5ed9af72&us=73284591&sign=e1ad1a1d2d652bc64c7b1e6f594daa11";

    
    self.wnPlayer.urlString = @"https://b.pan.wo.cn:8443/file?fid=Mjq6NZGVy5L6X6YFcBRW5jeVXoiKbhlrYp/z4FHMdD8=&filename=2021-12-18_151939_000096223.mov&auth=b0d2QWJBaTA5NjQ6wem9aeVplUnE5dUNzd2J6OThEZ2ZYMjVIdEdIZkwvTXA3MElUeWorTEVvST0sMTM5MDMwMTU1NzA=&sign=48a4b520023e28e2k74c46f29b4957416&timestamp=1641798942";

//    self.wnPlayer.urlString = @"http://bian-oss.oss-cn-beijing.aliyuncs.com/Video/20201214/1607929647318294.flv";

//    self.wnPlayer.urlString = @"https://becpan245129201909202114533965970.eos-guangzhou-1.cmecloud.cn/53e60ce31cab4823b0576cfdd2e8023a?response-content-disposition=attachment%3Bfilename%3D%22001---%E5%BA%94%E7%94%A8%E9%87%8D%E7%AD%BE%E5%90%8D.wmv%22&AWSAccessKeyId=9RM1KC629RXWWWGZ5XG6&Expires=1585202559&Signature=%2BpEaExUcDfT0eLwhRbRDustSVQk%3D";

    
    
    
//        self.wnPlayer.urlString = @"https://paasalihlsgw.lechange.cn:443/LCO/4F069C3PAZB2065/15/1/20190919162804/dev_20190919162804_kcfx18ca340dnrdg.m3u8?proto=https";

        
//        NSURL *URL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"flv"]];
//        self.wnPlayer.urlString = URL.absoluteString;
    
        [self.view addSubview:self.wnPlayer];
//        [self.wnPlayer openWithTCP:YES optionDic:@{@"headers":@"Cookie:FTN5K=f44da28b"}];
        [self.wnPlayer play];
    
    
//    e测试header cookie的连接，配合openWithTCP：YES使用
    //    self.wnPlayer.urlString = @"http://updatedown.heikeyun.net/WMV%E6%96%87%E4%BB%B6%E8%A7%86%E9%A2%91%E6%B5%8B%E8%AF%95.wmv";

}

- (void)dealloc{
    [_wnPlayer close];
    NSLog(@"%s",__FUNCTION__);
}
@end
