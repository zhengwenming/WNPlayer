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
//点击播放暂停按钮代理方法
-(void)player:(WNPlayer *_Nullable)player clickedPlayOrPauseButton:(UIButton *_Nullable)playOrPauseBtn;
//点击关闭按钮代理方法
-(void)player:(WNPlayer *_Nullable)player clickedCloseButton:(UIButton *_Nonnull)backBtn;
//点击全屏按钮代理方法
-(void)player:(WNPlayer *_Nonnull)player clickedFullScreenButton:(UIButton *_Nonnull)fullScreenBtn;
//单击WMPlayer的代理方法
-(void)player:(WNPlayer *_Nullable)player singleTaped:(UITapGestureRecognizer *_Nullable)singleTap;
//双击WMPlayer的代理方法
-(void)player:(WNPlayer *_Nullable)player doubleTaped:(UITapGestureRecognizer *_Nullable)doubleTaped;
//播放失败的代理方法
-(void)playerFailedPlay:(WNPlayer *_Nullable)player error:(NSError *_Nullable)error;
//播放器已经拿到视频的尺寸大小
-(void)playerReadyToPlay:(WNPlayer *_Nullable)player videoSize:(CGSize )presentationSize;
//播放完毕的代理方法
-(void)playerFinishedPlay:(WNPlayer *_Nullable)player;
@end



NS_ASSUME_NONNULL_BEGIN

@interface WNPlayer : UIView
@property (nonatomic,copy) NSString *urlString;
@property (nonatomic, weak)id <WNPlayerDelegate> delegate;
@property (nonatomic,strong) UIView <WNControlViewProtocol> *controlView;
@property (nonatomic, strong) WNPlayerManager *playerManager;
//控制层，开发者可自定义(自定义一个UIView，遵守WNControlViewProtocol，添加自己的子控件，控件的事件连接WNControlViewProtocol的事件)
@property (nonatomic,assign) BOOL autoplay;
@property (nonatomic,assign) BOOL isFullScreen;
@property (nonatomic,assign) BOOL repeat;
@property (nonatomic,assign) BOOL preventFromScreenLock;
@property (nonatomic,assign) BOOL restorePlayAfterAppEnterForeground;
@property (nonatomic,readonly) WNPlayerStatus status;
//获取当前视频播放帧的截图UIImage
- (UIImage*)snapshot:(CGSize)viewSize;
///默认是UDP，如有需要用TCP，请传YES,optionDic里面可以设置key-value，比如headers-cookie：xxxx
- (void)openWithTCP:(BOOL)usesTCP optionDic:(NSDictionary *)optionDic;
- (void)close;
- (void)play;
- (void)pause;
//判断是否为iPhone X系列
+(BOOL)IsiPhoneX;
@end

NS_ASSUME_NONNULL_END
