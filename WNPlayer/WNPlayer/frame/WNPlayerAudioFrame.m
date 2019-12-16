//
//  WNPlayerAudioFrame.m
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 wenming. All rights reserved.
//

#import "WNPlayerAudioFrame.h"

@implementation WNPlayerAudioFrame
- (instancetype)init{
    self = [super init];
    if (self) {
        self.type = kWNPlayerFrameTypeAudio;
    }
    return self;
}
@end
