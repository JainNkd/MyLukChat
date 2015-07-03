#import "JCNotificationBannerView.h"
#import "Constants.h"

const CGFloat kJCNotificationBannerViewOutlineWidth = 2.0;
const CGFloat kJCNotificationBannerViewMarginX = 15.0;
const CGFloat kJCNotificationBannerViewMarginY = 5.0;

@interface JCNotificationBannerView () {
  BOOL isPresented;
  NSObject* isPresentedMutex;
}

- (void) handleSingleTap:(UIGestureRecognizer*)gestureRecognizer;

@end

@implementation JCNotificationBannerView

@synthesize notificationBanner;
@synthesize iconImageView;
@synthesize titleLabel;
@synthesize messageLabel;

- (id) initWithNotification:(JCNotificationBanner*)notification {
  self = [super init];
  if (self) {
    isPresentedMutex = [NSObject new];

    self.backgroundColor = [UIColor clearColor];
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    self.titleLabel.textColor = [UIColor lightTextColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];
    self.messageLabel = [UILabel new];
    self.messageLabel.font = [UIFont systemFontOfSize:14];
    self.messageLabel.textColor = [UIColor lightTextColor];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    self.messageLabel.numberOfLines = 0;
    [self addSubview:self.messageLabel];
    self.iconImageView = [UIImageView new];
    [self.iconImageView setImage:[UIImage imageNamed:@"luk-app-icon-80.png"]];
    self.iconImageView.layer.cornerRadius = 5;
    [self.iconImageView.layer setMasksToBounds:YES];
    [self addSubview:self.iconImageView];

    UITapGestureRecognizer* tapRecognizer;
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                            action:@selector(handleSingleTap:)];
    [self addGestureRecognizer:tapRecognizer];

    self.notificationBanner = notification;
  }
  return self;
}

- (void) drawRect:(CGRect)rect {
  CGRect bounds = self.bounds;

  CGFloat lineWidth = kJCNotificationBannerViewOutlineWidth;
  CGFloat radius = 10;
  CGFloat height = bounds.size.height;
  CGFloat width = bounds.size.width;

  CGContextRef context = UIGraphicsGetCurrentContext();

  CGContextSetAllowsAntialiasing(context, true);
  CGContextSetShouldAntialias(context, true);

  CGMutablePathRef outlinePath = CGPathCreateMutable();

  CGPathMoveToPoint(outlinePath, NULL, lineWidth, 0);
  CGPathAddLineToPoint(outlinePath, NULL, lineWidth, height - radius - lineWidth);
  CGPathAddArc(outlinePath, NULL, radius + lineWidth, height - radius - lineWidth, radius, -M_PI, M_PI_2, 1);
  CGPathAddLineToPoint(outlinePath, NULL, width - radius - lineWidth, height - lineWidth);
  CGPathAddArc(outlinePath, NULL, width - radius - lineWidth, height - radius - lineWidth, radius, M_PI_2, 0, 1);
  CGPathAddLineToPoint(outlinePath, NULL, width - lineWidth, 0);

  CGContextSetRGBFillColor(context, 0, 0, 0, 0.9);
  CGContextAddPath(context, outlinePath);
  CGContextFillPath(context);

  CGContextAddPath(context, outlinePath);
  CGContextSetRGBFillColor(context, 0, 0, 0, 1);
  CGContextSetLineWidth(context, lineWidth);
  CGContextDrawPath(context, kCGPathStroke);

  CGPathRelease(outlinePath);
}

- (void) layoutSubviews {
  if (!(self.frame.size.width > 0)) { return; }

    CGRect viewframe = self.frame;
    viewframe.origin.x = 0;
    viewframe.origin.y = 0;
    if(IS_IPHONE_4_OR_LESS && IS_IPHONE_5)
        viewframe.size.width = 320;
    else if (IS_IPHONE_6)
        viewframe.size.width = 375;
    else if (IS_IPHONE_6P)
        viewframe.size.width = 414;
    
    self.frame = viewframe;
  BOOL hasTitle = notificationBanner ? (notificationBanner.title.length > 0) : NO;

  CGFloat borderY = kJCNotificationBannerViewOutlineWidth + kJCNotificationBannerViewMarginY;
  CGFloat borderX = kJCNotificationBannerViewOutlineWidth + kJCNotificationBannerViewMarginX + 20;
  CGFloat currentX = borderX;
  CGFloat currentY = borderY;
  CGFloat contentWidth = self.frame.size.width - (borderX * 2.0)+30;
   NSLog(@"bounds ..%f...%f....%f...%f....%f",self.frame.origin.x ,self.frame.origin.y ,self.frame.size.width ,self.frame.size.height,contentWidth);
    
  [self.iconImageView setFrame:CGRectMake(8,8,22,22)];
  currentY += 2.0;
  if (hasTitle) {
    self.titleLabel.frame = CGRectMake(currentX, currentY, contentWidth, 22.0);
    currentY += 22.0;
  }
  self.messageLabel.frame = CGRectMake(currentX, currentY, contentWidth, (self.frame.size.height - borderY) - currentY);
  [self.messageLabel sizeToFit];
  CGRect messageFrame = self.messageLabel.frame;
//    self.messageLabel.backgroundColor = [UIColor grayColor];
  CGFloat spillY = (currentY + messageFrame.size.height + kJCNotificationBannerViewMarginY) - self.frame.size.height;
  if (spillY > 0.0) {
    messageFrame.size.height -= spillY;
    self.messageLabel.frame = messageFrame;
  }
    
 NSLog(@"bounds .....%f...%f....%f",self.messageLabel.frame.size.width ,self.messageLabel.frame.size.height,contentWidth);
}

- (void) setNotificationBanner:(JCNotificationBanner*)notification {
  notificationBanner = notification;

  self.titleLabel.text = notification.title;
  self.messageLabel.text = notification.message;
}

- (void) handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
  if (notificationBanner && notificationBanner.tapHandler) {
    notificationBanner.tapHandler();
  }
}

- (BOOL) getCurrentPresentingStateAndAtomicallySetPresentingState:(BOOL)state {
  @synchronized(isPresentedMutex) {
    BOOL originalState = isPresented;
    isPresented = state;
    return originalState;
  }
}

@end
