//
//  VideoPlayCell.m
//  LukChat
//
//  Created by Naveen Dungarwal on 31/07/16.
//  Copyright © 2016 Markus Haass Mac Mini. All rights reserved.
//

#import "VideoPlayCell.h"

@implementation VideoPlayCell

-(void)awakeFromNib
{
    self.thumbnail.image = [UIImage imageNamed:@"pic-bgwith-monkey-icon.png"];
}

@end
