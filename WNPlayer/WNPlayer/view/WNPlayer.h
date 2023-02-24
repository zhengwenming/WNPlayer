//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 wenming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WNPlayerManager.h"
#import "WNControlView.h"
#import "WNControlViewProtocol.h"

typedef enum : NSUInteger {
    WNPlayerStatusNone,
    WNPlayerStatusOpening,
    WNPlayerStatusOpened,
    WNPlayerStatusPlaying,
    WNPlayerStatusBuffering,
    WNPlayerStatusPaused,
    WNPlayerStatusEOF,
    WNPlayerStatusClosing,
    WNPlayerStatusClosed,
} WNPlayerStatus;




@class WNPlayer;
@protocol WNPlayerDelegate <NSObject>
@optional
/**
 * 点击播放暂停按钮代理方法
 */
- (void)player:(WNPlayer *_Nullable)player clickedPlayOrPauseButton:(UIButton *_Nullable)playOrPauseBtn;
/**
 * 点击关闭按钮代理方法
 */
- (void)player:(WNPlayer *_Nullable)player clickedCloseButton:(UIButton *_Nonnull)backBtn;
/**
 * 点击全屏按钮代理方法
 */
- (void)player:(WNPlayer *_Nonnull)player clickedFullScreenButton:(UIButton *_Nonnull)fullScreenBtn;
/**
 * 单击WMPlayer的代理方法
 */
- (void)player:(WNPlayer *_Nullable)player singleTaped:(UITapGestureRecognizer *_Nullable)singleTap;
/**
 * 双击WMPlayer的代理方法
 */
- (void)player:(WNPlayer *_Nullable)player doubleTaped:(UITapGestureRecognizer *_Nullable)doubleTaped;
/**
 * 播放失败的代理方法
 */
- (void)playerFailedPlay:(WNPlayer *_Nullable)player error:(NSError *_Nullable)error;
/**
 * 播放器已经拿到视频的尺寸大小
 */
- (void)playerReadyToPlay:(WNPlayer *_Nullable)player videoSize:(CGSize )presentationSize;
/**
 * 播放完毕的代理方法
 */
- (void)playerFinishedPlay:(WNPlayer *_Nullable)player;
@end



NS_ASSUME_NONNULL_BEGIN

@interface WNPlayer : UIView
/**
 * 播放链接
 */
@property (nonatomic,copy) NSString *urlString;
/**
 * WNPlayerDelegate委托代理
 */
@property (nonatomic, weak)id <WNPlayerDelegate> delegate;
/**
 * 控制层
 * 设置控制层，如果不设置这个controlView，则没有控制层，只有视频画面
 * 开发者可自定义一个UIView
 * 遵守WNControlViewProtocol
 * 添加自己的子控件
 * 控件的事件连接WNControlViewProtocol的事件
 */
@property (nonatomic, strong) UIView <WNControlViewProtocol> *controlView;
/**
 * 播放器管理器
 */
@property (nonatomic, strong) WNPlayerManager *playerManager;
/**
 * 是否自动播放
 */
@property (nonatomic,assign) BOOL autoplay;
/**
 * 是否全屏
 */
@property (nonatomic,assign) BOOL isFullScreen;
/**
 * 是否重复播放
 */
@property (nonatomic,assign) BOOL repeat;
/**
 * 是否锁屏
 */
@property (nonatomic,assign) BOOL preventFromScreenLock;
/**
 * app进入前台后继续播放
 */
@property (nonatomic,assign) BOOL restorePlayAfterAppEnterForeground;
/**
 * 是否静音
 */
@property (nonatomic,assign) BOOL isMute;
/**
 * 播放器状态
 */
@property (nonatomic,readonly) WNPlayerStatus status;

/**
 * 获取当前视频播放帧的截图UIImage
 */
- (UIImage*)snapshot:(CGSize)viewSize;
/**
 * 默认是UDP，如有需要用TCP，请传YES,optionDic里面可以设置key-value，比如headers-cookie：xxxx
 */
- (void)openWithTCP:(BOOL)usesTCP optionDic:(NSDictionary *)optionDic;
/**
 * 关闭播放器
 */
- (void)close;
/**
 * 开始播放
 */
- (void)play;
/**
 * 暂停
 */
- (void)pause;
/**
* 判断是否为刘海屏系列手机
*/
+(BOOL)IsiPhoneX;
@end

NS_ASSUME_NONNULL_END
