//
//  WNControlViewProtocol.h
//  WNPlayer
//
//  Created by apple on 2019/11/15.
//  Copyright © 2019 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WNPlayerManager.h"

NS_ASSUME_NONNULL_BEGIN
@class WNPlayer;

@protocol WNControlViewProtocol <NSObject>

@required
/**
 * 播放器
 */
@property (nonatomic,weak) WNPlayer *player;
/**
 * 播放
 */
- (void)play;
/**
 * 暂停
 */
- (void)pause;
/**
 * 单击
 */
- (void)singleTaped;
/**
 * 双击
 */
- (void)doubleTaped;
@end

NS_ASSUME_NONNULL_END
