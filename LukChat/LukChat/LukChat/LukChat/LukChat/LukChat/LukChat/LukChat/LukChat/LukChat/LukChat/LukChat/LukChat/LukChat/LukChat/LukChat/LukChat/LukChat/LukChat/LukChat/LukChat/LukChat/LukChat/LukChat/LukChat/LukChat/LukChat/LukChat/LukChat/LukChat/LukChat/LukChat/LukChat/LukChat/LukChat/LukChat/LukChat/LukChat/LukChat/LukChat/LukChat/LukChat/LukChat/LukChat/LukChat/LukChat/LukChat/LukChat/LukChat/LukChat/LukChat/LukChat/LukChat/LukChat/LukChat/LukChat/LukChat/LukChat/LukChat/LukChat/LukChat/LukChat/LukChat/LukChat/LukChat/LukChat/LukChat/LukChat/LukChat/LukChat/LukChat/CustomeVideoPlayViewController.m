//
//  CustomeVideoPlayViewController.m
//  LukChat
//
//  Created by Naveen on 21/08/14.
//  Copyright (c) 2014 Markus Haass Mac Mini. All rights reserved.
//

#import "CustomeVideoPlayViewController.h"

@interface CustomeVideoPlayViewController ()

@end

@implementation CustomeVideoPlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSLog(@"Play. - %@", self.videoUrl);
    self.navigationController.navigationBarHidden = YES;
   
    // prepare the video asset from recorded file
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:self.videoUrl] options:nil];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
    player = [AVPlayer playerWithPlayerItem:playerItem];

    
    // prepare the layer to show the video
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = CGRectMake(10, 10, self.videoToPlayView.bounds.size.width-20, self.videoToPlayView.bounds.size.height-20);
    [self.videoToPlayView.layer addSublayer:playerLayer];
    
    // play the video
    [player play];

    
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonPressed:(UIButton *)sender {
    player.rate = 0;
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

@end
