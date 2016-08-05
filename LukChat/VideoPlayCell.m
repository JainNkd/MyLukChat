//
//  VideoPlayCell.m
//  LukChat
//
//  Created by Naveen Dungarwal on 31/07/16.
//  Copyright © 2016 Markus Haass Mac Mini. All rights reserved.
//

#import "VideoPlayCell.h"

@implementation VideoPlayCell
@synthesize progressViewObj;

-(void)awakeFromNib
{
    self.thumbnail.image = [UIImage imageNamed:@"pic-bgwith-monkey-icon.png"];
    
    progressViewObj = [[UCZProgressView alloc]initWithFrame:CGRectMake(0,0,39,39)];
//    progressViewObj.tag = indexPath.row;
    progressViewObj.indeterminate = YES;
    progressViewObj.showsText = YES;
    progressViewObj.tintColor = [UIColor whiteColor];
    progressViewObj.radius = 10;
    
    [self addSubview:progressViewObj];
    
}

-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if(selected)
    {
        
        self.layer.borderWidth = 2.0f;
        UIColor *selectedColor = [UIColor colorWithRed:247.0/255 green:19.0/255 blue:101.0/255 alpha:1];
        self.layer.borderColor = selectedColor.CGColor;
        self.layer.masksToBounds = YES;
        
    }
    else
    {
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.masksToBounds = YES;
    }
}

@end
