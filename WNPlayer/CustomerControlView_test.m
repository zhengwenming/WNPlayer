//
//  CustomerControlView_test.m
//  WNPlayer
//
//  Created by apple on 2019/11/19.
//  Copyright © 2019 apple. All rights reserved.
//

#import "CustomerControlView_test.h"
#import "WNPlayer.h"

@interface CustomerControlView_test ()
@property(nonatomic,strong)UIView *container;
@property(nonatomic,strong)UIButton *centerPlayerBtn;
@end

@implementation CustomerControlView_test
@synthesize player = _player;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        //        self.coverImageView.userInteractionEnabled =  YES;
                [self addSubview:self.coverImageView];
        self.container = [[UIView alloc] initWithFrame:frame];
        [self addSubview:self.container];
        
        self.centerPlayerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.centerPlayerBtn.showsTouchWhenHighlighted = YES;
        [self.centerPlayerBtn setImage:[UIImage imageNamed:@"player_pause"] forState:UIControlStateNormal];
        [self.centerPlayerBtn setImage:[UIImage imageNamed:@"player_play"] forState:UIControlStateSelected];
        self.centerPlayerBtn.selected = YES;
        [self.centerPlayerBtn addTarget:self action:@selector(playOrPause:) forControlEvents:UIControlEventTouchUpInside];
        [self.container addSubview:self.centerPlayerBtn];
        [self.centerPlayerBtn sizeToFit];
        self.centerPlayerBtn.center = self.container.center;
    }
    return self;
}
-(void)playOrPause:(UIButton *)sender{
     if (self.player.playerManager.playing) {
           [self.player.playerManager pause];
           self.centerPlayerBtn.selected = YES;
       } else {
           [self.player.playerManager play];
           self.centerPlayerBtn.selected = NO;
       }
       if (self.player.delegate&&[self.player.delegate respondsToSelector:@selector(player:clickedPlayOrPauseButton:)]) {
           [self.player.delegate player:self.player clickedPlayOrPauseButton:sender];
       }
}
-(void)playerReadyToPlay:(WNPlayer *)player{
    if (self.player.delegate&&[self.player.delegate respondsToSelector:@selector(playerReadyToPlay:videoSize:)]) {
        [self.player.delegate playerReadyToPlay:self.player videoSize:self.player.playerManager.displayView.contentSize];
    }
    double duration = player.playerManager.duration;
    int seconds = ceil(duration);
    
    self.coverImageView.hidden = YES;
}
@end
