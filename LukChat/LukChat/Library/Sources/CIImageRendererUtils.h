//
//  CIImageRendererUtils.h
//  SCRecorder
//
//  Created by Simon CORSIN on 13/09/14.
//  Copyright (c) 2014 rFlex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SCSampleBufferHolder.h"
#import "CIImageRenderer.h"

@interface CIImageRendererUtils : NSObject

+ (CGRect)processRect:(CGRect)rect withImageSize:(CGSize)imageSize contentScale:(CGFloat)contentScale contentMode:(UIViewContentMode)mode;

+ (CIImage *)generateImageFromSampleBufferHolder:(SCSampleBufferHolder *)sampleBufferHolder;

+ (CGAffineTransform)preferredCIImageTransformFromUIImage:(UIImage *)image;

+ (void)putUIImage:(UIImage *)image toRenderer:(id<CIImageRenderer>)renderer;

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
