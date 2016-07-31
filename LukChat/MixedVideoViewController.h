//
//  MixedVideoViewController.h
//  LukChat
//
//  Created by Naveen Dungarwal on 28/07/16.
//  Copyright © 2016 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UCZProgressView.h"


@interface MixedVideoViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>
{
        NSMutableArray *randomVideosData;
        NSMutableArray *selectedIndexPaths ,*selectedWords;
        NSMutableString *videoTitle;
}
@property (weak, nonatomic) IBOutlet UIButton *twoMonkeyButton;

@property (weak, nonatomic) IBOutlet UILabel *videoTitleLbl;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *VideoCollectionVIew;

- (IBAction)twoMonkeyButtonPressed:(UIButton *)sender;

@end
