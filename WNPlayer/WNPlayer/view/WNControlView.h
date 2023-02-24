//
//  WNControlView.h
//  WNPlayer
//
//  Created by apple on 2019/11/15.
//  Copyright © 2019 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WNControlViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface WNControlView : UIView<WNControlViewProtocol>
/**
 * 播放器标题title
 */
@property (nonatomic,copy) NSString *title;
/**
 * 播放器默认背景
 */
@property (nonatomic,strong) UIImageView *coverImageView;
/**
 * 播放器着色
 */
@property (nonatomic,strong) UIColor *tintColor;

-(void)syncScrubber:(NSNumber *_Nonnull)position;
-(void)playerReadyToPlay:(WNPlayer *_Nonnull)player;
-(void)playerBufferStateChanged:(NSNumber *_Nonnull)info;
-(void)playerError:(NSError *_Nonnull)error;
-(void)playerEOF:(WNPlayer *_Nonnull)player;;
-(void)playerIsFullScreen:(NSNumber *_Nonnull)isFullScreen;

@end

NS_ASSUME_NONNULL_END
