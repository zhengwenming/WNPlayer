//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 wenming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WNPlayerDef.h"
#import "WNDisplayView.h"
typedef void (^onPauseComplete)(void);


NS_ASSUME_NONNULL_BEGIN

@interface WNPlayerManager : NSObject
@property (nonatomic, strong) WNDisplayView *displayView;
@property (nonatomic) double minBufferDuration;
@property (nonatomic) double maxBufferDuration;
@property (nonatomic) double position;
@property (nonatomic) double duration;
@property (nonatomic) BOOL opened;
@property (nonatomic) BOOL playing;
@property (nonatomic) BOOL buffering;
@property (nonatomic, assign) BOOL mute;//静音
@property (nonatomic, strong) NSDictionary *metadata;//视频元数据

- (void)open:(NSString *)url usesTCP:(BOOL)usesTCP optionDic:(NSDictionary *)optionDic;
/**
 *  跳转到特定时间点播放
 */
- (void)seek:(double)position;
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
 * 静音 OR 外放出声音
 */
- (BOOL)muteVoice;
@end

NS_ASSUME_NONNULL_END
