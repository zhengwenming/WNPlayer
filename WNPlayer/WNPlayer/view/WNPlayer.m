//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 wenming. All rights reserved.
//

#import "WNPlayer.h"
#import "WNPlayerUtils.h"


typedef enum : NSUInteger {
    WNPlayerOperationNone,
    WNPlayerOperationOpen,
    WNPlayerOperationPlay,
    WNPlayerOperationPause,
    WNPlayerOperationClose,
} WNPlayerOperation;

@interface WNPlayer ()
@property (nonatomic) dispatch_source_t dispath_timer;
@property (nonatomic,assign) BOOL usesTCP;
@property (nonatomic,assign) BOOL restorePlay;
@property (nonatomic,strong) NSDictionary *optionDic;
@property (nonatomic,readwrite) WNPlayerStatus status;
@property (nonatomic) WNPlayerOperation nextOperation;
@property (nonatomic, strong) UIView  *viewStatusBar;
@end

@implementation WNPlayer

- (UIImage*)snapshot:(CGSize)viewSize{
    return [WNDisplayView glToUIImage:self.playerManager.displayView.frame.size];
}
- (instancetype)init{
    self = [super init];
    if (self) {
        [self initSubViews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame controlView:(WNControlView *)controlView{
    self = [super initWithFrame:frame];
    if (self) {
        if (controlView) {
            _controlView = controlView;
            [self addSubview:_controlView];
        }
        [self initSubViews];
    }
    return self;
}
//设置控制层，如果不设置这个controlView，则没有控制层，只有视频画面
-(void)setControlView:(UIView<WNControlViewProtocol> *)controlView{
    _controlView = controlView;
    if (!controlView) {
        return;
    }
    controlView.player = self;
    [self addSubview:controlView];
}
-(void)initSubViews{
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor blackColor];
    self.playerManager = [[WNPlayerManager alloc] init];
    [self addSubview:self.playerManager.displayView];//画面渲染到dispalyView上，然后add画面到self（WNPlayer）上
    self.status = WNPlayerStatusNone;
    self.nextOperation = WNPlayerOperationNone;    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:)
               name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:)
               name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerOpened:) name:WNPlayerNotificationOpened object:self.playerManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerClosed:) name:WNPlayerNotificationClosed object:self.playerManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerEOF:) name:WNPlayerNotificationEOF object:self.playerManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerBufferStateChanged:) name:WNPlayerNotificationBufferStateChanged object:self.playerManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerError:) name:WNPlayerNotificationError object:self.playerManager];
}
- (UIView *)viewStatusBar{
    if (!_viewStatusBar) {
        if (@available(iOS 13.0, *)) {
            _viewStatusBar = [[UIApplication sharedApplication].keyWindow.windowScene.statusBarManager performSelector:NSSelectorFromString(@"createLocalStatusBar")];
            _viewStatusBar.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            _viewStatusBar.backgroundColor = [UIColor clearColor];
            _viewStatusBar.hidden = YES;
            _viewStatusBar.tag = 321;
            //手动设置状态栏字体颜色为白色
            [[[_viewStatusBar valueForKey:@"_statusBar"]valueForKey:@"_statusBar"] performSelector:@selector(setForegroundColor:) withObject:[UIColor whiteColor]];
        } else {
            // Fallback on earlier versions
        }
        
    }
    return _viewStatusBar;
}
#pragma mark layoutSubviews
-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerManager.displayView.frame = self.bounds;
    if (self.isFullScreen) {
        self.controlView.frame = CGRectMake(60, 0, self.frame.size.width-2*60, self.frame.size.height);
    }else{
        self.controlView.frame = self.bounds;
    }
}

-(void)syncScrubber{
       if (!self.playerManager.playing) return;
       double position = self.playerManager.position;
        if (self.controlView&&[self.controlView respondsToSelector:@selector(syncScrubber:)]) {
            [self.controlView performSelector:@selector(syncScrubber:) withObject:@(position)];
        }
}
- (void)openWithTCP:(BOOL)usesTCP optionDic:(NSDictionary *)optionDic{
    self.usesTCP = usesTCP;
    self.optionDic = optionDic;
    if (self.status == WNPlayerStatusClosing) {
        self.nextOperation = WNPlayerOperationOpen;
        return;
    }
    if (self.status != WNPlayerStatusNone &&
        self.status != WNPlayerStatusClosed) {
        return;
    }
    self.status = WNPlayerStatusOpening;
    [self.playerManager open:self.urlString usesTCP:self.usesTCP optionDic:optionDic];
}

- (void)close {
    if (self.status == WNPlayerStatusOpening) {
        self.nextOperation = WNPlayerOperationClose;
        return;
    }
    self.status = WNPlayerStatusClosing;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.playerManager close];
}
- (void)releaseWNPlayer{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.playerManager releaseManager];
}
- (void)play {
    if (self.status == WNPlayerStatusNone ||
        self.status == WNPlayerStatusClosed) {
        [self openWithTCP:self.usesTCP optionDic:self.optionDic];
        self.nextOperation = WNPlayerOperationPlay;
    }
    if (self.status != WNPlayerStatusOpened &&
        self.status != WNPlayerStatusPaused &&
        self.status != WNPlayerStatusEOF) {
        return;
    }
    self.status = WNPlayerStatusPlaying;
    [UIApplication sharedApplication].idleTimerDisabled = self.preventFromScreenLock;
    [self.playerManager play];
}

- (void)replay {
    self.playerManager.position = 0;
    [self play];
}

- (void)pause {
    if (self.status != WNPlayerStatusOpened &&
        self.status != WNPlayerStatusPlaying &&
        self.status != WNPlayerStatusEOF) {
        return;
    }
    self.status = WNPlayerStatusPaused;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self.playerManager pause];
}

- (BOOL)doNextOperation {
    if (self.nextOperation == WNPlayerOperationNone) return NO;
    switch (self.nextOperation) {
        case WNPlayerOperationOpen:
            [self openWithTCP:self.usesTCP optionDic:self.optionDic];
            break;
        case WNPlayerOperationPlay:
            [self play];
            break;
        case WNPlayerOperationPause:
            [self pause];
            break;
        case WNPlayerOperationClose:
            [self close];
            break;
        default:
            break;
    }
    self.nextOperation = WNPlayerOperationNone;
    return YES;
}

#pragma mark - Notifications 进入后台
- (void)appDidEnterBackground:(NSNotification *)notif {
    if (self.playerManager.playing) {
        [self pause];
        if (self.restorePlayAfterAppEnterForeground) {
           self.restorePlay = YES;
        }
    }
}

- (void)appWillEnterForeground:(NSNotification *)notif {
    if (self.restorePlay) {
        self.restorePlay = NO;
        [self play];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[self.viewStatusBar valueForKey:@"_statusBar"]valueForKey:@"_statusBar"] performSelector:@selector(setForegroundColor:) withObject:[UIColor whiteColor]];
    });
}
#pragma mark 是否全屏的设置
-(void)setIsFullScreen:(BOOL)isFullScreen{
    _isFullScreen = isFullScreen;
    if (isFullScreen) {
        //状态栏处理
        if ([WNPlayer IsiPhoneX]) {
            if(![self.controlView viewWithTag:321]){
                self.viewStatusBar.hidden = NO;
                [self.controlView addSubview:self.viewStatusBar];
                self.viewStatusBar.frame = CGRectMake(0, -5, 2*self.controlView.frame.size.width-40, self.viewStatusBar.frame.size.height);
            }
        }else{
            
        }
    }else{
        if ([WNPlayer IsiPhoneX]) {
            self.viewStatusBar.hidden = YES;
            if ([self.controlView viewWithTag:321]) {
                [self.viewStatusBar removeFromSuperview];
            }
        }else{
            
        }
    }
    if (self.controlView&&[self.controlView respondsToSelector:@selector(playerIsFullScreen:)]) {
        [self.controlView performSelector:@selector(playerIsFullScreen:) withObject:@(isFullScreen)];
    }
}
- (void)playerEOF:(NSNotification *)notif {
    self.status = WNPlayerStatusEOF;
    if (self.controlView&&[self.controlView respondsToSelector:@selector(playerEOF:)]) {
        [self.controlView performSelector:@selector(playerEOF:) withObject:self];
    }
    if (self.repeat){
      [self replay];
    }else{
        [self close];
    }
}

- (void)playerClosed:(NSNotification *)notif {
    self.status = WNPlayerStatusClosed;
    [self destroyTimer];
    [self doNextOperation];
}

- (void)playerOpened:(NSNotification *)notif {
        self.status = WNPlayerStatusOpened;
        if (self.controlView&&[self.controlView respondsToSelector:@selector(playerReadyToPlay:)]) {
            [self.controlView performSelector:@selector(playerReadyToPlay:) withObject:self];
        }
        [self createTimer];
        if (![self doNextOperation]) {
            if (self.autoplay){
                [self play];
            }
        }
}

- (void)playerBufferStateChanged:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    if (self.controlView&&[self.controlView respondsToSelector:@selector(playerBufferStateChanged:)]) {
        [self.controlView performSelector:@selector(playerBufferStateChanged:) withObject:userInfo[WNPlayerNotificationBufferStateKey]];
    }
}

- (void)playerError:(NSNotification *)notif {
    NSDictionary *userInfo = notif.userInfo;
    NSError *error = userInfo[WNPlayerNotificationErrorKey];
    if ([error.domain isEqualToString:WNPlayerErrorDomainDecoder]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.status = WNPlayerStatusNone;
            self.nextOperation = WNPlayerOperationNone;
        });
        NSLog(@"Player decoder error: %@", error);
    } else if ([error.domain isEqualToString:WNPlayerErrorDomainAudioManager]) {
        NSLog(@"Player audio error: %@", error);
        // I am not sure what will cause the audio error,
        // if it happens, please issue to me
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationError object:self userInfo:userInfo];
  
    if (self.controlView&&[self.controlView respondsToSelector:@selector(playerError:)]) {
        [self.controlView performSelector:@selector(playerError:) withObject:error];
    }

}

- (void)createTimer {
    if (self.dispath_timer) return;
    self.dispath_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.dispath_timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 1 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.dispath_timer, ^{
        [self syncScrubber];
    });
    dispatch_resume(self.dispath_timer);
}
- (void)destroyTimer {
    if (self.dispath_timer == nil) return;
    dispatch_cancel(self.dispath_timer);
    self.dispath_timer = nil;
}
+(BOOL)IsiPhoneX{
    BOOL iPhoneXSeries = NO;
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        return iPhoneXSeries;
    }
    if (@available(iOS 11.0, *)) {//x系列的系统从iOS11开始
        if(UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom > 0.0) {
            iPhoneXSeries = YES;
        }
    }
    return iPhoneXSeries;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__FUNCTION__);
}

@end
