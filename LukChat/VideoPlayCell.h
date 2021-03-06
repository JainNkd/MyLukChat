//
//  VideoPlayCell.h
//  LukChat
//
//  Created by Naveen Dungarwal on 31/07/16.
//  Copyright © 2016 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCZProgressView.h"

@interface VideoPlayCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (strong, nonatomic) UCZProgressView *progressViewObj;
@end
