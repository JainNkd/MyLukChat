//
//  VideoCell.m
//  VideoShare
//
//  Created by PLANETMEDIA on 4/26/14.
//  Copyright (c) 2014 Channel Data House. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

@synthesize balloonView,imgViewMoviePlayer;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
       
        balloonView = (UIImageView *)[[self.contentView viewWithTag:0] viewWithTag:1];
        imgViewMoviePlayer = (UIImageView *)[[self.contentView viewWithTag:0] viewWithTag:3];
        
        
        if (!balloonView || !imgViewMoviePlayer) {
            balloonView = nil;
            imgViewMoviePlayer = nil;
            
            balloonView = [[UIImageView alloc] initWithFrame:CGRectZero];
            balloonView.tag = 1;
            
            UIView *message = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
            message.tag = 0;
            [message addSubview:balloonView];
            
            if (!imgViewMoviePlayer) {
                imgViewMoviePlayer = [[UIImageView alloc] initWithFrame:CGRectZero];
                imgViewMoviePlayer.backgroundColor = [UIColor clearColor];
                imgViewMoviePlayer.tag = 3;
                [message addSubview:imgViewMoviePlayer];
            }
            
            [self.contentView addSubview:message];

        }
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
