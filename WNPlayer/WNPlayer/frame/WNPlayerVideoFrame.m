//
//  WNPlayerVideoFrame.m
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 wenming. All rights reserved.
//

#import "WNPlayerVideoFrame.h"

@implementation WNPlayerVideoFrame

- (instancetype)init{
    self = [super init];
    if (self) {
        self.type = kWNPlayerFrameTypeVideo;
    }
    return self;
}
- (BOOL)prepareRender:(GLuint)program {
    return NO;
}
@end
