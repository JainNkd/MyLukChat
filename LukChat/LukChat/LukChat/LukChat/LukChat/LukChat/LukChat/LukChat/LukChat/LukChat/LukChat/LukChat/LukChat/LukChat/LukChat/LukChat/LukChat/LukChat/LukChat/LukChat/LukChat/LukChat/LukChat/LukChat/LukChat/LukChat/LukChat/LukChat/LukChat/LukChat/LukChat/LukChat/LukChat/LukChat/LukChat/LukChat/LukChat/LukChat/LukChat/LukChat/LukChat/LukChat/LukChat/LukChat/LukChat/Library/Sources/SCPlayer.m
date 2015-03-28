//
//  SCVideoPlayer.m
//  SCAudioVideoRecorder
//
//  Created by Simon CORSIN on 8/30/13.
//  Copyright (c) 2013 rFlex. All rights reserved.
//

#import "SCPlayer.h"

////////////////////////////////////////////////////////////
// PRIVATE DEFINITION
/////////////////////

@interface SCPlayer() <AVPlayerItemOutputPullDelegate, AVPlayerItemOutputPushDelegate> {
    CADisplayLink *_displayLink;
    AVPlayerItemVideoOutput *_videoOutput;
    AVPlayerItem *_oldItem;
    Float64 _itemsLoopLength;
    id _timeObserver;
}

@end


////////////////////////////////////////////////////////////
// IMPLEMENTATION
/////////////////////

@implementation SCPlayer

- (id)init {
	self = [super init];
	
	if (self) {

		[self addObserver:self forKeyPath:@"currentItem" options:NSKeyValueObservingOptionNew context:nil];
	}
	
	return self;
}

- (void)dealloc {
    [self endSendingPlayMessages];

    [self unsetupVideoOutputToItem:self.currentItem];
    [self removeObserver:self forKeyPath:@"currentItem"];
    [self removeOldObservers];
    [self endSendingPlayMessages];
}

- (void)beginSendingPlayMessages {
    if (!self.isSendingPlayMessages) {
        __weak SCPlayer *myWeakSelf = self;
        
        _timeObserver = [self addPeriodicTimeObserverForInterval:CMTimeMake(1, 24) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            SCPlayer *mySelf = myWeakSelf;
            id<SCPlayerDelegate> delegate = mySelf.delegate;
            if ([delegate respondsToSelector:@selector(player:didPlay:loopsCount:)]) {
                int itemsLoopLength = 1;
                
                if (mySelf != nil) {
                    itemsLoopLength = mySelf->_itemsLoopLength;
                }
                Float64 ratio = 1.0 / itemsLoopLength;
                CMTime currentTime = CMTimeMultiplyByFloat64(time, ratio);
                
                NSInteger loopCount = CMTimeGetSeconds(time) / (CMTimeGetSeconds(mySelf.currentItem.duration) / (Float64)itemsLoopLength);
                
                [delegate player:mySelf didPlay:currentTime loopsCount:loopCount];
            }
        }];
    }
}

- (void)endSendingPlayMessages {
    if (_timeObserver != nil) {
        [self removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

- (void)playReachedEnd:(NSNotification*)notification {
	if (notification.object == self.currentItem) {
		if (_loopEnabled) {
			[self seekToTime:kCMTimeZero];
			if ([self isPlaying]) {
				[self play];
			}
		}
        id<SCPlayerDelegate> delegate = self.delegate;
        if ([delegate respondsToSelector:@selector(player:didReachEndForItem:)]) {
            [delegate player:self didReachEndForItem:self.currentItem];
        }
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"currentItem"]) {
		[self initObserver];
	} else {
		
	}
}

- (void)removeOldObservers {
    if (_oldItem != nil) {
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_oldItem];
        
        [self unsetupVideoOutputToItem:_oldItem];
        
        _oldItem = nil;
	}
}

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender {
	_displayLink.paused = NO;
}

- (void)renderVideo:(CFTimeInterval)hostFrameTime {
    CMTime outputItemTime = [_videoOutput itemTimeForHostTime:hostFrameTime];
    
	if ([_videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        CMTime time;
		CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:&time];
        
        if (pixelBuffer != nil) {
            CIImage *inputImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            
            self.CIImageRenderer.CIImage = inputImage;
            
            CFRelease(pixelBuffer);
        }
    }
}

- (void)replaceCurrentItemWithPlayerItem:(AVPlayerItem *)item {
    _itemsLoopLength = 1;

    [super replaceCurrentItemWithPlayerItem:item];
    [self suspendDisplay];
}

- (void)willRenderFrame:(CADisplayLink *)sender {
	CFTimeInterval nextFrameTime = sender.timestamp + sender.duration;
    
    [self renderVideo:nextFrameTime];
}

- (void)suspendDisplay {
    _displayLink.paused = YES;
    [_videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.1];
}

- (void)setupDisplayLink {
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(willRenderFrame:)];
        _displayLink.frameInterval = 1;
        
        [self setupVideoOutputToItem:self.currentItem];

        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        [self suspendDisplay];
    }
}

- (void)unsetupDisplayLink {
    if (_displayLink != nil) {
        [_displayLink invalidate];
        _displayLink = nil;

        [self unsetupVideoOutputToItem:self.currentItem];
        
        _videoOutput = nil;
    }
}

- (void)setupVideoOutputToItem:(AVPlayerItem *)item {
    if (_displayLink != nil && item != nil && _videoOutput == nil) {
        NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
        [_videoOutput setDelegate:self queue:dispatch_get_main_queue()];
        _videoOutput.suppressesPlayerRendering = YES;
        
        [item addOutput:_videoOutput];
        
        _displayLink.paused = NO;
        
        id<CIImageRenderer> renderer = self.CIImageRenderer;
        
        if ([renderer respondsToSelector:@selector(frame)] && [renderer respondsToSelector:@selector(setPreferredCIImageTransform:)]) {
            NSArray *videoTracks = [item.asset tracksWithMediaType:AVMediaTypeVideo];
            
            if (videoTracks.count > 0) {
                AVAssetTrack *track = videoTracks.firstObject;
                
                CGAffineTransform transform = track.preferredTransform;
                
//                NSLog(@"Transform: %@ / Size: %@ (transformed frame: %@)", NSStringFromCGAffineTransform(transform), NSStringFromCGSize(track.naturalSize), NSStringFromCGRect( CGRectApplyAffineTransform(CGRectMake(0, 0, track.naturalSize.width, track.naturalSize.height), transform)));
                
                // Return the video if it is upside down
                if (transform.b == 1 && transform.c == -1) {
                    transform = CGAffineTransformRotate(transform, M_PI);
                }
                
                if (self.autoRotate) {
                    CGSize videoSize = track.naturalSize;
                    CGSize viewSize =  [renderer frame].size;
                    CGRect outRect = CGRectApplyAffineTransform(CGRectMake(0, 0, videoSize.width, videoSize.height), transform);
                    
                    BOOL viewIsWide = viewSize.width / viewSize.height > 1;
                    BOOL videoIsWide = outRect.size.width / outRect.size.height > 1;
                    
                    if (viewIsWide != videoIsWide) {
                        transform = CGAffineTransformRotate(transform, M_PI_2);
                    }
                }
                
                
                [renderer setPreferredCIImageTransform:transform];
            }
        }
    }
}

- (void)unsetupVideoOutputToItem:(AVPlayerItem *)item {
    if (_videoOutput != nil && item != nil) {
        if ([item.outputs containsObject:_videoOutput]) {
            [item removeOutput:_videoOutput];
        }
        _videoOutput = nil;
    }
}

- (void)initObserver {
	[self removeOldObservers];
	
	if (self.currentItem != nil) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playReachedEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentItem];
        _oldItem = self.currentItem;

        [self setupVideoOutputToItem:self.currentItem];
	}
    

    id<SCPlayerDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(player:didChangeItem:)]) {
		[delegate player:self didChangeItem:self.currentItem];
	}
}

- (CMTime)playableDuration {
	AVPlayerItem * item = self.currentItem;
	CMTime playableDuration = kCMTimeZero;
	
	if (item.status != AVPlayerItemStatusFailed) {
        for (NSValue *value in item.loadedTimeRanges) {
            CMTimeRange timeRange = [value CMTimeRangeValue];
            
            playableDuration = CMTimeAdd(playableDuration, timeRange.duration);
        }
	}
	
	return playableDuration;
}

- (void)setItemByStringPath:(NSString *)stringPath {
	[self setItemByUrl:[NSURL URLWithString:stringPath]];
}

- (void)setItemByUrl:(NSURL *)url {
	[self setItemByAsset:[AVURLAsset URLAssetWithURL:url options:nil]];
}

- (void)setItemByAsset:(AVAsset *)asset {
	[self setItem:[AVPlayerItem playerItemWithAsset:asset]];
}

- (void)setItem:(AVPlayerItem *)item {
	[self replaceCurrentItemWithPlayerItem:item];
}

- (void)setSmoothLoopItemByStringPath:(NSString *)stringPath smoothLoopCount:(NSUInteger)loopCount {
	[self setSmoothLoopItemByUrl:[NSURL URLWithString:stringPath] smoothLoopCount:loopCount];
}

- (void)setSmoothLoopItemByUrl:(NSURL *)url smoothLoopCount:(NSUInteger)loopCount {
	[self setSmoothLoopItemByAsset:[AVURLAsset URLAssetWithURL:url options:nil] smoothLoopCount:loopCount];
}

- (void)setSmoothLoopItemByAsset:(AVAsset *)asset smoothLoopCount:(NSUInteger)loopCount {
	AVMutableComposition * composition = [AVMutableComposition composition];
	
	CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
	
	for (NSUInteger i = 0; i < loopCount; i++) {
		[composition insertTimeRange:timeRange ofAsset:asset atTime:composition.duration error:nil];
	}
	
	[self setItemByAsset:composition];
	
	_itemsLoopLength = loopCount;
}

- (BOOL)isPlaying {
    return self.rate > 0;
}

- (void)setLoopEnabled:(BOOL)loopEnabled {
    _loopEnabled = loopEnabled;
    
    self.actionAtItemEnd = loopEnabled ? AVPlayerActionAtItemEndNone : AVPlayerActionAtItemEndPause;
}

- (void)setCIImageRenderer:(id<CIImageRenderer>)CIImageRenderer {
    _CIImageRenderer = CIImageRenderer;
    
    if (CIImageRenderer == nil) {
        [self unsetupDisplayLink];
    } else {
        [self setupDisplayLink];
    }
}

- (CMTime)itemDuration {
    Float64 ratio = 1.0 / _itemsLoopLength;

    return CMTimeMultiply(self.currentItem.duration, ratio);
}

- (BOOL)isSendingPlayMessages {
    return _timeObserver != nil;
}

- (void)setAutoRotate:(BOOL)autoRotate {
    _autoRotate = autoRotate;
}

+ (SCPlayer*)player {
    return [SCPlayer new];
}

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
