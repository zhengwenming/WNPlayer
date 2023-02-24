//
//  WNPlayerFrame.h
//  PlayerDemo
//
//  Created by zhengwenming on 2018/10/15.
//  Copyright © 2018年 wenming. All rights reserved.
//

#import "WNPlayerManager.h"
#import "WNPlayerDecoder.h"
#import "WNPlayerDef.h"
#import "WNAudioManager.h"
#import "WNPlayerFrame.h"
#import "WNPlayerVideoFrame.h"
#import "WNPlayerAudioFrame.h"

@interface WNPlayerManager (){
    
}
@property (nonatomic, strong) WNPlayerDecoder *decoder;
@property (nonatomic, strong) WNAudioManager *audioManager;
@property (nonatomic, strong) NSMutableArray *vframes;
@property (nonatomic, strong) NSMutableArray *aframes;
@property (nonatomic, strong) WNPlayerAudioFrame *playingAudioFrame;
@property (nonatomic) NSUInteger playingAudioFrameDataPosition;
@property (nonatomic) double bufferedDuration;
@property (nonatomic) double mediaPosition;
@property (nonatomic) double mediaSyncTime;
@property (nonatomic) double mediaSyncPosition;

@property (nonatomic, strong) NSThread *frameReaderThread;
@property (nonatomic) BOOL notifiedBufferStart;
@property (nonatomic) BOOL requestSeek;
@property (nonatomic) double requestSeekPosition;
@property (nonatomic) BOOL opening;

@property (nonatomic, strong) dispatch_semaphore_t vFramesLock;
@property (nonatomic, strong) dispatch_semaphore_t aFramesLock;

@end

@implementation WNPlayerManager
- (instancetype)init{
    self = [super init];
    if (self) {
        [self initVars];
        self.audioManager = [[WNAudioManager alloc] init];
        self.decoder = [[WNPlayerDecoder alloc] init];
        self.displayView = [[WNDisplayView alloc] init];
    }
    return self;
}
- (void)initVars {
    self.minBufferDuration = WNPlayerMinBufferDuration;
    self.maxBufferDuration = WNPlayerMaxBufferDuration;
    self.bufferedDuration = 0;
    self.mediaPosition = 0;
    self.mediaSyncTime = 0;
    self.vframes = [NSMutableArray arrayWithCapacity:128];
    self.aframes = [NSMutableArray arrayWithCapacity:128];
    self.playingAudioFrame = nil;
    self.playingAudioFrameDataPosition = 0;
    self.opening = NO;
    self.buffering = NO;
    self.playing = NO;
    self.opened = NO;
    self.requestSeek = NO;
    self.requestSeekPosition = 0;
    self.frameReaderThread = nil;
    self.aFramesLock = dispatch_semaphore_create(1);
    self.vFramesLock = dispatch_semaphore_create(1);
}
- (void)clearVars {
    [self.vframes removeAllObjects];
    [self.aframes removeAllObjects];
    self.playingAudioFrame = nil;
    self.playingAudioFrameDataPosition = 0;
    self.opening = NO;
    self.buffering = NO;
    self.playing = NO;
    self.opened = NO;
    self.bufferedDuration = 0;
    self.mediaPosition = 0;
    self.mediaSyncTime = 0;
    [self.displayView clear];
}

- (void)open:(NSString *)url usesTCP:(BOOL)usesTCP optionDic:(NSDictionary *)optionDic{
    self.decoder.usesTCP = usesTCP;
    self.decoder.optionDic = optionDic;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        self.opening = YES;
        if ([self.audioManager open:&error]) {
            self.decoder.audioChannels = [self.audioManager channels];
            self.decoder.audioSampleRate = [self.audioManager sampleRate];
        } else {
            [self handleError:error];
        }
        
        if (![self.decoder open:url error:&error]) {
            self.opening = NO;
            [self handleError:error];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.displayView.isYUV = [self.decoder isYUV];
            self.displayView.keepLastFrame = [self.decoder hasPicture] && ![self.decoder hasVideo];
            self.displayView.rotation = self.decoder.rotation;
            self.displayView.contentSize = CGSizeMake([self.decoder videoWidth], [self.decoder videoHeight]);
            self.displayView.contentMode = UIViewContentModeScaleAspectFit;
            self.duration = self.decoder.duration;
            self.metadata = self.decoder.metadata;
            self.opening = NO;
            self.buffering = NO;
            self.playing = NO;
            self.bufferedDuration = 0;
            self.mediaPosition = 0;
            self.mediaSyncTime = 0;
            __weak typeof(self)weakSelf = self;
            self.audioManager.frameReaderBlock = ^(float *data, UInt32 frames, UInt32 channels) {
                [weakSelf readAudioFrame:data frames:frames channels:channels];
            };
            self.opened = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationOpened object:self];
        });
    });
}

- (void)close {
    if (!self.opened && !self.opening) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationClosed object:self];
        return;
    }
    
    [self pause];
    [self.decoder prepareClose];
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
    
    dispatch_source_set_event_handler(timer, ^{
        if (self.opening || self.buffering) return;
        [self.decoder close];
        
        NSArray<NSError *> *errors = nil;
        if ([self.audioManager close:&errors]) {
            [self clearVars];
            [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationClosed object:self];
        } else {
            for (NSError *error in errors) {
                [self handleError:error];
            }
        }
        dispatch_cancel(timer);
    });
    dispatch_resume(timer);
}
- (void)play {
    if (!self.opened || self.playing) return;
    self.playing = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1)), dispatch_get_main_queue(), ^{
        [self startFrameReaderThread];
        [self renderFrames];
    });
    
    NSError *error = nil;
    if (![self.audioManager play:&error]) {
        [self handleError:error];
    }
}

- (void)pause {
    self.playing = NO;
    NSError *error = nil;
    if (![self.audioManager pause:&error]) {
        [self handleError:error];
    }
}
- (BOOL)muteVoice {
    NSError *error = nil;
    BOOL ret = [self.audioManager mute:!_mute error:&error];
    if (!ret) {
        [self handleError:error];
    }else{
        _mute = !_mute;
    }
    return _mute;
}
- (void)startFrameReaderThread {
    if (self.frameReaderThread == nil) {
        self.frameReaderThread = [[NSThread alloc] initWithTarget:self selector:@selector(runFrameReader) object:nil];
        [self.frameReaderThread start];
    }
}

- (void)runFrameReader {
    @autoreleasepool {
        while (self.playing) {
            [self readUncompressFrames];
            if (self.requestSeek) {
                [self seekPositionInFrameReader];
            } else {
                [NSThread sleepForTimeInterval:1.5];
            }
        }
        self.frameReaderThread = nil;
    }
}
- (void)readUncompressFrames {
    self.buffering = YES;
    
    NSMutableArray *tempVFrames = [NSMutableArray array];
    NSMutableArray *tempAFrames = [NSMutableArray array];
    NSInteger tempFrame = 0;
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC);
    
    while (1) {
        if (self.playing
            &&
            self.decoder.isEOF == NO
            &&
            self.requestSeek == NO
            &&
            (self.bufferedDuration + tempFrame) < self.maxBufferDuration) {
            
            @autoreleasepool {
                NSArray *fremes = [self.decoder readFrames];
                if (fremes == nil) {
                    break;
                }
                if (fremes.count == 0) {
                    continue;
                }
                {
                    for (WNPlayerFrame *frame in fremes) {
                        if (frame.type == kWNPlayerFrameTypeVideo) {
                            [tempVFrames addObject:frame];
                            tempFrame += 1;
                        }
                    }
                    
                    long timeout = dispatch_semaphore_wait(self.vFramesLock, t);
                    if (timeout == 0) {
                        if (tempVFrames.count > 0) {
                            self.bufferedDuration += tempFrame;
                            tempFrame = 0;
                            [self.vframes addObjectsFromArray:tempVFrames];
                            [tempVFrames removeAllObjects];
                        }
                        dispatch_semaphore_signal(self.vFramesLock);
                    }
                }
                {
                    for (WNPlayerFrame *frame in fremes) {
                        if (frame.type == kWNPlayerFrameTypeAudio) {
                            [tempAFrames addObject:frame];
                            if (!self.decoder.hasVideo) {
                                tempFrame += 1;
                            }
                        }
                    }
                    
                    long timeout = dispatch_semaphore_wait(self.aFramesLock, t);
                    if (timeout == 0) {
                        if (tempAFrames.count > 0) {
                            if (!self.decoder.hasVideo) {
                                self.bufferedDuration += tempFrame;
                                tempFrame = 0;
                            }
                            [self.aframes addObjectsFromArray:tempAFrames];
                            [tempAFrames removeAllObjects];
                        }
                        dispatch_semaphore_signal(self.aFramesLock);
                    }
                }
            }
        }
        else{
            
        }
    }
    
    {
        // add the rest video frames
        while (tempVFrames.count > 0 || tempAFrames.count > 0) {
            if (tempVFrames.count > 0) {
                long timeout = dispatch_semaphore_wait(self.vFramesLock, t);
                if (timeout == 0) {
                    self.bufferedDuration += tempFrame;
                    tempFrame = 0;
                    [self.vframes addObjectsFromArray:tempVFrames];
                    [tempVFrames removeAllObjects];
                    dispatch_semaphore_signal(self.vFramesLock);
                }
            }
            if (tempAFrames.count > 0) {
                long timeout = dispatch_semaphore_wait(self.aFramesLock, t);
                if (timeout == 0) {
                    if (!self.decoder.hasVideo) {
                        self.bufferedDuration += tempFrame;
                        tempFrame = 0;
                    }
                    [self.aframes addObjectsFromArray:tempAFrames];
                    [tempAFrames removeAllObjects];
                    dispatch_semaphore_signal(self.aFramesLock);
                }
            }
        }
        
    }
    self.buffering = NO;
}
- (void)seek:(double)position{
    
}
- (void)readFrame {
    self.buffering = YES;
    
    NSMutableArray *tempVFrames = [NSMutableArray arrayWithCapacity:8];
    NSMutableArray *tempAFrames = [NSMutableArray arrayWithCapacity:8];
    double tempDuration = 0;
    dispatch_time_t t = dispatch_time(DISPATCH_TIME_NOW, 0.02 * NSEC_PER_SEC);
    
    while (self.playing &&  !self.requestSeek
           && (self.bufferedDuration + tempDuration) < self.maxBufferDuration) {
        @autoreleasepool {
            NSArray *fs = [self.decoder readFrames];
            if (fs == nil) { break; }
            if (fs.count == 0) { continue; }
            {
                for (WNPlayerFrame *f in fs) {
                    if (f.type == kWNPlayerFrameTypeVideo) {
                        [tempVFrames addObject:f];
                        tempDuration += f.duration;
                    }
                }
                
                long timeout = dispatch_semaphore_wait(self.vFramesLock, t);
                if (timeout == 0) {
                    if (tempVFrames.count > 0) {
                        self.bufferedDuration += tempDuration;
                        tempDuration = 0;
                        [self.vframes addObjectsFromArray:tempVFrames];
                        [tempVFrames removeAllObjects];
                    }
                    dispatch_semaphore_signal(self.vFramesLock);
                }
            }
            {
                for (WNPlayerFrame *f in fs) {
                    if (f.type == kWNPlayerFrameTypeAudio) {
                        [tempAFrames addObject:f];
                        if (!self.decoder.hasVideo) tempDuration += f.duration;
                    }
                }
                
                long timeout = dispatch_semaphore_wait(self.aFramesLock, t);
                if (timeout == 0) {
                    if (tempAFrames.count > 0) {
                        if (!self.decoder.hasVideo) {
                            self.bufferedDuration += tempDuration;
                            tempDuration = 0;
                        }
                        [self.aframes addObjectsFromArray:tempAFrames];
                        [tempAFrames removeAllObjects];
                    }
                    dispatch_semaphore_signal(self.aFramesLock);
                }
            }
        }
    }
    
    {
        // add the rest video frames
        while (tempVFrames.count > 0 || tempAFrames.count > 0) {
            if (tempVFrames.count > 0) {
                long timeout = dispatch_semaphore_wait(self.vFramesLock, t);
                if (timeout == 0) {
                    self.bufferedDuration += tempDuration;
                    tempDuration = 0;
                    [self.vframes addObjectsFromArray:tempVFrames];
                    [tempVFrames removeAllObjects];
                    dispatch_semaphore_signal(self.vFramesLock);
                }
            }
            if (tempAFrames.count > 0) {
                long timeout = dispatch_semaphore_wait(self.aFramesLock, t);
                if (timeout == 0) {
                    if (!self.decoder.hasVideo) {
                        self.bufferedDuration += tempDuration;
                        tempDuration = 0;
                    }
                    [self.aframes addObjectsFromArray:tempAFrames];
                    [tempAFrames removeAllObjects];
                    dispatch_semaphore_signal(self.aFramesLock);
                }
            }
        }
    }
    self.buffering = NO;
}

- (void)seekPositionInFrameReader {
    [self.decoder seek:self.requestSeekPosition];
    {
        dispatch_semaphore_wait(self.vFramesLock, DISPATCH_TIME_FOREVER);
        [self.vframes removeAllObjects];
        dispatch_semaphore_signal(self.vFramesLock);
    }
    {
        dispatch_semaphore_wait(self.aFramesLock, DISPATCH_TIME_FOREVER);
        [self.aframes removeAllObjects];
        dispatch_semaphore_signal(self.aFramesLock);
    }
    
    self.bufferedDuration = 0;
    self.requestSeek = NO;
    self.mediaSyncTime = 0;
    self.mediaPosition = self.requestSeekPosition;
}

- (void)renderFrames {
    if (!self.playing) return;
    
    BOOL eof = self.decoder.isEOF;

    BOOL noframes = ((self.decoder.hasVideo && self.vframes.count <= 0) ||
                     (self.decoder.hasAudio && self.aframes.count <= 0));
    
    // Check if reach the end and play all frames.
    if (noframes && eof) {
        [self pause];
        [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationEOF object:self];
        return;
    }
    
    if (noframes && !self.notifiedBufferStart) {
        self.notifiedBufferStart = YES;
        NSDictionary *userInfo = @{ WNPlayerNotificationBufferStateKey : @(self.notifiedBufferStart) };
        [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationBufferStateChanged object:self userInfo:userInfo];
    } else if (!noframes && self.notifiedBufferStart && self.bufferedDuration >= self.minBufferDuration) {
        self.notifiedBufferStart = NO;
        NSDictionary *userInfo = @{ WNPlayerNotificationBufferStateKey : @(self.notifiedBufferStart) };
        [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationBufferStateChanged object:self userInfo:userInfo];
    }
    
    // Render if has picture
    if (self.decoder.hasPicture && self.vframes.count > 0) {
        WNPlayerVideoFrame *frame = self.vframes[0];
        self.displayView.contentSize = CGSizeMake(frame.width, frame.height);
        [self.vframes removeObjectAtIndex:0];
        [self.displayView render:frame];
    }
    
    // Check whether render is neccessary
    if (self.vframes.count <= 0 || !self.decoder.hasVideo || self.notifiedBufferStart) {
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf renderFrames];
        });
        return;
    }
    
    // Render video
    WNPlayerVideoFrame *frame = nil;
    {
        long timeout = dispatch_semaphore_wait(self.vFramesLock, DISPATCH_TIME_NOW);
        if (timeout == 0) {
            frame = self.vframes[0];
            self.mediaPosition = frame.position;
            self.bufferedDuration -= frame.duration;
            [self.vframes removeObjectAtIndex:0];
            dispatch_semaphore_signal(self.vFramesLock);
        }
    }
    [self.displayView render:frame];
    
    // Sync audio with video
    double syncTime = [self syncTime];
    NSTimeInterval t = MAX(frame.duration + syncTime, 0.01);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(t * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self renderFrames];
    });
}

- (double)syncTime {
    const double now = [NSDate timeIntervalSinceReferenceDate];
    if (self.mediaSyncTime == 0) {
        self.mediaSyncTime = now;
        self.mediaSyncPosition = self.mediaPosition;
        return 0;
    }
    
    double dp = self.mediaPosition - self.mediaSyncPosition;
    double dt = now - self.mediaSyncTime;
    double sync = dp - dt;
    if (sync > 1 || sync < -1) {
        sync = 0;
        self.mediaSyncTime = 0;
    }
    return sync;
}

/*
 * For audioUnitRenderCallback, (WNPlayerAudioManagerFrameReaderBlock)readFrameBlock
 */
- (void)readAudioFrame:(float *)data frames:(UInt32)frames channels:(UInt32)channels {
    if (!self.playing) return;
    
    while(frames > 0) {
        @autoreleasepool {
            if (self.playingAudioFrame == nil) {
                {
                    if (self.aframes.count <= 0) {
                        memset(data, 0, frames * channels * sizeof(float));
                        return;
                    }
                    
                    long timeout = dispatch_semaphore_wait(self.aFramesLock, DISPATCH_TIME_NOW);
                    if (timeout == 0) {
                        WNPlayerAudioFrame *frame = self.aframes[0];
                        if (self.decoder.hasVideo) {
                            const double dt = self.mediaPosition - frame.position;
                            if (dt < -0.1) { // audio is faster than video, silence
                                memset(data, 0, frames * channels * sizeof(float));
                                dispatch_semaphore_signal(self.aFramesLock);
                                break;
                            } else if (dt > 0.1) { // audio is slower than video, skip
                                [self.aframes removeObjectAtIndex:0];
                                dispatch_semaphore_signal(self.aFramesLock);
                                continue;
                            } else {
                                self.playingAudioFrameDataPosition = 0;
                                self.playingAudioFrame = frame;
                                [self.aframes removeObjectAtIndex:0];
                            }
                        } else {
                            self.playingAudioFrameDataPosition = 0;
                            self.playingAudioFrame = frame;
                            [self.aframes removeObjectAtIndex:0];
                            self.mediaPosition = frame.position;
                            self.bufferedDuration -= frame.duration;
                        }
                        dispatch_semaphore_signal(self.aFramesLock);
                    } else return;
                }
            }
            
            NSData *frameData = self.playingAudioFrame.data;
            NSUInteger pos = self.playingAudioFrameDataPosition;
            if (frameData == nil) {
                memset(data, 0, frames * channels * sizeof(float));
                return;
            }
            
            const void *bytes = (Byte *)frameData.bytes + pos;
            const NSUInteger remainingBytes = frameData.length - pos;
            const NSUInteger channelSize = channels * sizeof(float);
            const NSUInteger bytesToCopy = MIN(frames * channelSize, remainingBytes);
            const NSUInteger framesToCopy = bytesToCopy / channelSize;
            
            memcpy(data, bytes, bytesToCopy);
            frames -= framesToCopy;
            data += framesToCopy * channels;
            
            if (bytesToCopy < remainingBytes) {
                self.playingAudioFrameDataPosition += bytesToCopy;
            } else {
                self.playingAudioFrame = nil;
            }
        }
    }
}

- (void)setPosition:(double)position {
    self.requestSeekPosition = position;
    self.requestSeek = YES;
}

- (double)position {
    return self.mediaPosition;
}

#pragma mark - Handle Error
- (void)handleError:(NSError *)error {
    if (error == nil) return;
    NSDictionary *userInfo = @{ WNPlayerNotificationErrorKey : error };
    [[NSNotificationCenter defaultCenter] postNotificationName:WNPlayerNotificationError object:self userInfo:userInfo];
}
- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
}
@end
