//
//  SCFilterSwitcherView.m
//  SCRecorderExamples
//
//  Created by Simon CORSIN on 29/05/14.
//
//

#import "SCSwipeableFilterView.h"
#import "CIImageRendererUtils.h"
#import "SCSampleBufferHolder.h"
#import "SCFilterSelectorViewInternal.h"

@interface SCSwipeableFilterView() {
    CGFloat _filterGroupIndexRatio;
}

@end

@implementation SCSwipeableFilterView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (void)dealloc {
}

- (void)commonInit {
    [super commonInit];
    
    _refreshAutomaticallyWhenScrolling = YES;
    _selectFilterScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _selectFilterScrollView.delegate = self;
    _selectFilterScrollView.pagingEnabled = YES;
    _selectFilterScrollView.showsHorizontalScrollIndicator = NO;
    _selectFilterScrollView.showsVerticalScrollIndicator = NO;
    _selectFilterScrollView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_selectFilterScrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _selectFilterScrollView.frame = self.bounds;

    [self updateScrollViewContentSize];
}

- (void)updateScrollViewContentSize {
    _selectFilterScrollView.contentSize = CGSizeMake(self.filterGroups.count * self.frame.size.width * 2, self.frame.size.height);
}

static CGRect CGRectTranslate(CGRect rect, CGFloat width, CGFloat maxWidth) {
    rect.origin.x += width;

    return rect;
}

- (void)updateCurrentSelected {
    NSUInteger filterGroupsCount = self.filterGroups.count;
    NSInteger selectedIndex = (NSInteger)((_selectFilterScrollView.contentOffset.x + _selectFilterScrollView.frame.size.width / 2) / _selectFilterScrollView.frame.size.width) % filterGroupsCount;
    id newFilterGroup = nil;
    
    if (selectedIndex >= 0 && selectedIndex < filterGroupsCount) {
        newFilterGroup = [self.filterGroups objectAtIndex:selectedIndex];
    } else {
        NSLog(@"Invalid contentOffset of scrollView in SCFilterSwitcherView (%f/%f with %d)", _selectFilterScrollView.contentOffset.x, _selectFilterScrollView.contentOffset.y, (int)self.filterGroups.count);
    }
    
    [self setSelectedFilterGroup:newFilterGroup];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self updateCurrentSelected];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updateCurrentSelected];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentSelected];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat width = scrollView.frame.size.width;
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    CGFloat contentSizeWidth = scrollView.contentSize.width;
    CGFloat normalWidth = self.filterGroups.count * width;
    
    if (contentOffsetX < 0) {
        scrollView.contentOffset = CGPointMake(contentOffsetX + normalWidth, scrollView.contentOffset.y);
    } else if (contentOffsetX + width > contentSizeWidth) {
        scrollView.contentOffset = CGPointMake(contentOffsetX - normalWidth, scrollView.contentOffset.y);
    }
    
    CGFloat ratio = scrollView.contentOffset.x / width;
    
    _filterGroupIndexRatio = ratio;
    
    if (_refreshAutomaticallyWhenScrolling) {
        [self refresh];
    }
}

- (void)render:(CIImage *)image toContext:(CIContext *)context inRect:(CGRect)rect {
    CGRect extent = [image extent];
    
    CGFloat ratio = _filterGroupIndexRatio;
    
    NSInteger index = (NSInteger)ratio;
    NSInteger upIndex = (NSInteger)ceilf(ratio);
    CGFloat remainingRatio = ratio - ((CGFloat)index);
    
    NSArray *filterGroups = self.filterGroups;
    
    CGFloat xOutputRect = rect.size.width * -remainingRatio;
    CGFloat xImage = extent.size.width * -remainingRatio;
    
    while (index <= upIndex) {
        NSInteger currentIndex = index % filterGroups.count;
        id obj = [filterGroups objectAtIndex:currentIndex];
        CIImage *imageToUse = image;
        
        if ([obj isKindOfClass:[SCFilterGroup class]]) {
            imageToUse = [((SCFilterGroup *)obj) imageByProcessingImage:imageToUse];
        }
        
        CGRect outputRect = CGRectTranslate(rect, xOutputRect, rect.size.width);
        CGRect fromRect = CGRectTranslate(extent, xImage, extent.size.width);
        
        [context drawImage:imageToUse inRect:outputRect fromRect:fromRect];
        
        xOutputRect += rect.size.width;
        xImage += extent.size.width;
        index++;
    }
}

- (void)setFilterGroups:(NSArray *)filterGroups {
    [super setFilterGroups:filterGroups];
    
    [self updateScrollViewContentSize];
}

@end

// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net 
