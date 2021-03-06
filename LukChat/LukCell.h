//
//  LukCell.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 7/31/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCZProgressView.h"


@interface LukCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic,strong) UCZProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *loadingWheelView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end
