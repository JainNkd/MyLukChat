//
//  MixedVideoViewController.h
//  LukChat
//
//  Created by Naveen Dungarwal on 28/07/16.
//  Copyright © 2016 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MixedVideoViewController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource>
{
        NSMutableArray *randomVideosData;
        NSMutableArray *selectedIndexPaths ,*selectedWords;
        NSMutableString *videoTitle;
}
@property (weak, nonatomic) IBOutlet UIButton *twoMonkeyButton;

@property (weak, nonatomic) IBOutlet UILabel *videoTitleLbl;

- (IBAction)twoMonkeyButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
