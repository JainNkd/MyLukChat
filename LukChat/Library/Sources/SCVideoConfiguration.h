//
//  SCVideoConfiguration.h
//  SCRecorder
//
//  Created by Simon CORSIN on 21/11/14.
//  Copyright (c) 2014 rFlex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCMediaTypeConfiguration.h"
#import "SCFilterGroup.h"

#define kSCVideoConfigurationDefaultCodec AVVideoCodecH264
#define kSCVideoConfigurationDefaultScalingMode AVVideoScalingModeResizeAspectFill
#define kSCVideoConfigurationDefaultBitrate 2000000

@interface SCVideoConfiguration : SCMediaTypeConfiguration

/**
 Change the size of the video
 If options has been changed, this property will be ignored
 If this value is CGSizeZero, the input video size received
 from the camera will be used
 Default is CGSizeZero
 */
@property (assign, nonatomic) CGSize size;

/**
 Change the affine transform for the video
 If options has been changed, this property will be ignored
 */
@property (assign, nonatomic) CGAffineTransform affineTransform;

/**
 Set the codec used for the video
 Default is AVVideoCodecH264
 */
@property (copy, nonatomic) NSString *codec;

/**
 Set the video scaling mode
 */
@property (copy, nonatomic) NSString *scalingMode;

/**
 The maximum framerate that this SCRecordSession should handle
 If the camera appends too much frames, they will be dropped.
 If this property's value is 0, it will use the current video
 framerate from the camera.
 */
@property (assign, nonatomic) CMTimeScale maxFrameRate;

/**
 The time scale of the video
 A value more than 1 will make the buffers last longer, it creates
 a slow motion effect. A value less than 1 will make the buffers be
 shorter, it creates a timelapse effect.
 
 Only used in SCRecorder.
 */
@property (assign, nonatomic) CGFloat timeScale;

/**
 If true and videoSize is CGSizeZero, the videoSize
 used will equal to the minimum width or height found,
 thus making the video square.
 */
@property (assign, nonatomic) BOOL sizeAsSquare;

/**
 If true, each frame will be encoded as a keyframe
 This is needed if you want to merge the recordSegments using
 the passthrough preset. This will seriously impact the video
 size. You can set this to NO and change the recordSegmentsMergePreset if you want
 a better quality/size ratio, but the merge will be slower.
 Default is NO
 */
@property (assign, nonatomic) BOOL shouldKeepOnlyKeyFrames;

/**
 If not nil, each appended frame will be processed by this SCFilterGroup.
 While it seems convenient, this removes the possibility to change the
 filter after the segment has been added.
 Setting a new filterGroup will cause the SCRecordSession to stop the
 current record segment if the previous filterGroup was NIL and the
 new filterGroup is NOT NIL or vice versa. If you want to have a smooth
 transition between filters in the same record segment, make sure to set
 an empty SCFilterGroup instead of setting this property to nil.
 */
@property (strong, nonatomic) SCFilterGroup *filterGroup;

/**
 If YES, the affineTransform will be ignored and the output affineTransform
 will be the same as the input asset.
 
 Only used in SCAssetExportSession.
 */
@property (assign, nonatomic) BOOL keepInputAffineTransform;


- (NSDictionary *)createAssetWriterOptionsWithVideoSize:(CGSize)videoSize;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
