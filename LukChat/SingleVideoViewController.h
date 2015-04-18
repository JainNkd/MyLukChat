//
//  SingleVideoViewController.h
//  LukChat
//
//  Created by Naveen Kumar Dungarwal on 4/15/15.
//  Copyright (c) 2015 Markus Haass Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SingleVideoViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
    NSInteger singleVideoIndex;
    NSString *title;
    NSMutableArray*singleVideosData;
}
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

@property (weak, nonatomic) IBOutlet UILabel *wordLBL;
@property (weak, nonatomic) IBOutlet UICollectionView *singleVideoCollectionView;

- (IBAction)selectButtonPressed:(UIButton *)sender;

- (IBAction)backButtonPressed:(UIButton *)sender;
@end
