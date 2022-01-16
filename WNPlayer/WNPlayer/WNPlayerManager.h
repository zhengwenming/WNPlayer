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
@property (nonatomic, strong) NSDictionary *metadata;

- (void)open:(NSString *)url usesTCP:(BOOL)usesTCP optionDic:(NSDictionary *)optionDic;
- (void)seek:(double)position;
- (void)close;

- (void)play;
- (void)pause;
@end

NS_ASSUME_NONNULL_END
