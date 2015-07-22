#import <CaptainHook.h>
#import "UminoIconListView.h"
#import "UminoIconView.h"
#import "UminoIconHighlightView.h"

// CHInline static CGPoint positionOfRect(CGRect rect)
// {
//     return CGPointMake(rect.origin.x + rect.size.width * 0.5, rect.origin.y + rect.size.height * 0.5);
// }

// CHInline static CGRect boundsOfRect(CGRect rect)
// {
//     return CGRectMake(0, 0, rect.size.width, rect.size.height);
// }

// CHInline static void animateViewFrame(UIView *view, CGRect frame, CGFloat positionDuration, CGFloat boundsDuration)
// {
//     if (CGRectEqualToRect(view.frame, frame)) {
//         return;
//     }
//     CALayer *layer = view.layer;
//     CGPoint position = positionOfRect(frame);
//     CGRect bounds = boundsOfRect(frame);
//     CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
//     positionAnimation.duration = positionDuration;
//     positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//     positionAnimation.fromValue = [NSValue valueWithCGPoint:((CALayer *)layer.presentationLayer).position];
//     positionAnimation.toValue = [NSValue valueWithCGPoint:position];
//     CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
//     boundsAnimation.duration = boundsDuration;
//     boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//     boundsAnimation.fromValue = [NSValue valueWithCGRect:((CALayer *)layer.presentationLayer).bounds];
//     boundsAnimation.toValue = [NSValue valueWithCGRect:bounds];
//     CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
//     animationGroup.duration = MAX(positionDuration, boundsDuration);
//     animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//     animationGroup.animations = @[positionAnimation, boundsAnimation];
//     [layer addAnimation:animationGroup forKey:kUmino];
//     layer.position = position;
//     layer.bounds = bounds;
// }

CHInline static NSString *displayNameForIdentifier(NSString *identifier)
{
    NSString *displayName = nil;
    if ([identifier isEqualToString:@"com.apple.springboard"]) {
        displayName = @"";
    } else {
        displayName = [(SBApplicationController *)[NSClassFromString(@"SBApplicationController")sharedInstance]applicationWithBundleIdentifier:identifier].displayName;
    }
    return displayName ? : @"";
}

CHInline static CGFloat iconPositionXForIndex(NSInteger index)
{
    return (kViewMargin + kIconSpacing * 0.5) + (kIconMinSize + kIconSpacing) * (index + 0.5);
}

CHInline static CGFloat widthForIconCount(NSInteger count)
{
    return kViewMargin * 2 + kIconSpacing + (kIconMinSize + kIconSpacing) * count;
}

CHInline static CGFloat yOffset(CGFloat y)
{
	static CGFloat const base = 120.0, phase1 = 120.0, phase2 = 240.0, rubber = 40.0;
	y = base - y;
	CGFloat yo = 0;
	if (y < 0) {
		yo = 0;
	} else if (y < phase1) {
		yo = y;
	} else {
		yo = phase1 + rubber * sin(MIN((y - phase1) / (phase2 - phase1), 1.0) * M_PI_2);
	}
	return -yo;
}

CHInline static CGRect iconFrameForIndex(NSInteger index, CGPoint touchLocation)
{
	CGFloat x = iconPositionXForIndex(index);
    CGFloat distance = x - touchLocation.x;
    CGFloat size = kIconMinSize;
	CGFloat minY = kIconMinY + yOffset(touchLocation.y);
    if (ABS(distance) < kIconSizingArgument) {
        size = kIconMinSize + (kIconMaxSize - kIconMinSize) * (cos(ABS(distance) / kIconSizingArgument * M_PI) + 1.0) * 0.5;
    }
    CGFloat deltaX = 0;
    if (distance < -kIconXPositioningArgument) {
        deltaX = -kIconSpacingOffset;
    } else if (distance > kIconXPositioningArgument) {
        deltaX = kIconSpacingOffset;
    } else {
        deltaX = kIconSpacingOffset * (sin(distance / kIconXPositioningArgument * M_PI_2));
    }
    x += deltaX;
    //CGFloat y = kIconMaxY - (kIconMaxY - minY) * exp(-ABS(distance) / (kIconYPositioningArgument - yOffset(touchLocation.y) / 5.0)) - size;
    CGFloat y = kIconMaxY - (kIconMaxY - minY) * exp(-pow(distance / (kIconYPositioningArgument - yOffset(touchLocation.y) * 0.5), 2)) - size;
    return CGRectMake(x - size * 0.5, y, size, size);
}

CHInline static NSInteger highlightIndexForTouchLocationX(CGFloat x)
{
    return floor(MAX(x - (kViewMargin + kIconSpacing * 0.5), 0.0) / (kIconMinSize + kIconSpacing));
}

CHInline static CGFloat correctedOffset(CGFloat offset)
{
    CGFloat stepWidth = kIconMinSize + kIconSpacing;
    NSInteger step = floor(offset / stepWidth);
    CGFloat surplus = offset - stepWidth * (step + 0.5);
    CGFloat correctedSurplus = stepWidth * pow(2.0, 2.0) * pow((surplus / stepWidth), 3.0);
    CGFloat correctedOffset = offset - surplus + correctedSurplus;
    return correctedOffset;
}

CHInline static CGFloat correctedX(CGFloat x, NSInteger count)
{
    CGFloat realX = x - (kViewMargin + kIconSpacing * 0.5);
    CGFloat minRealX = (kIconMinSize + kIconSpacing) * 0.5;
    CGFloat maxRealX = (kIconMinSize + kIconSpacing) * (count - 0.5);
    CGFloat offset = realX;
    if (realX < minRealX) {
        offset = correctedOffset(minRealX);
    } else if (realX > maxRealX) {
        offset = correctedOffset(maxRealX);
    } else {
        offset = correctedOffset(realX);
    }
    return offset + (kViewMargin + kIconSpacing * 0.5);
}

CHInline static CGRect highlightFrameForTouchLocation(CGPoint touchLocation)
{
    return CGRectMake(touchLocation.x - kHighlightWidth * 0.5, yOffset(touchLocation.y), kHighlightWidth, kHighlightHeight);
}

@implementation UminoIconListView {
    NSArray *_icons;
    NSMutableDictionary *_iconTitles;
    NSMutableDictionary *_iconViews;
    UminoIconHighlightView *_iconHighlightView;
    NSOperationQueue *_iconLoadingQueue;
    BOOL _unlimitedIconCount;
	BOOL _openToLast;
    BOOL _atHomeScreen;
    CGPoint _touchLocation;
    BOOL _hasHomeScreen;
    NSTimer *_timer;
	NSInteger _transitFlag;
	BOOL _leftAccessed;
	BOOL _rightAccessed;
    void (^_handler)(CGFloat, NSInteger, NSTimeInterval);
}

- (id)initWithFrame:(CGRect)frame handler:(void (^)(CGFloat, NSInteger, NSTimeInterval))handler
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceHorizontal = NO;
        self.alwaysBounceVertical = NO;
        self.scrollEnabled = NO;
        self.clipsToBounds = NO;
        _iconHighlightView = [[UminoIconHighlightView alloc]initWithFrame:CGRectZero];
        _iconLoadingQueue = [[NSOperationQueue alloc]init];
        _iconLoadingQueue.maxConcurrentOperationCount = 1;
        [self addSubview:_iconHighlightView];
        _handler = [handler copy];
    }
    return self;
}

- (NSString *)iconAtIndex:(NSInteger)index
{
    return (index >= 0 && index < _icons.count) ? _icons[index] : nil;
}

- (void)setIcons:(NSArray *)icons
{
	if (icons == nil) {
		icons = @[];
	}
    [_iconLoadingQueue cancelAllOperations];
    [_iconViews.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _hasHomeScreen = [icons.firstObject isEqualToString:@"com.apple.springboard"];
    _icons = icons;
    _iconTitles = [NSMutableDictionary dictionary];
    _iconViews = [NSMutableDictionary dictionary];
	_leftAccessed = NO;
	_rightAccessed = NO;
    if (_icons.count > 0) {
		NSUInteger hiddenCount = (!_atHomeScreen && _hasHomeScreen) + (_openToLast && icons.count > (_hasHomeScreen + 1));
		NSUInteger loadingCount = recommendedIconCount() + hiddenCount;
    	[_icons enumerateObjectsUsingBlock:^(NSString *icon, NSUInteger index, BOOL *stop) {
    		_iconTitles[icon] = displayNameForIdentifier(icon);
	        UminoIconView *iconView = [[UminoIconView alloc]initWithFrame:CGRectZero];
            if (index < loadingCount) {
                [iconView loadIcon:icon];    
            }
	        _iconViews[icon] = iconView;
	        [self addSubview:iconView];
    	}];
	    _touchLocation = CGPointMake(iconPositionXForIndex(0), 0);
	    [self layout];
		self.contentOffset = CGPointMake((kIconMinSize + kIconSpacing) * hiddenCount, 0);
    }
}

- (void)loadIconsAsynchronously:(NSInteger)highlightIndex
{
    if (_icons.count < 3) {
        return;
    }
    [[_icons subarrayWithRange:NSMakeRange(MIN(MAX(highlightIndex, 1), _icons.count - 2) - 1, 3)] enumerateObjectsUsingBlock:^(NSString *icon, NSUInteger index, BOOL *stop) {
        UminoIconView *iconView = _iconViews[icon];
        if (iconView.image == nil) {
            NSInvocationOperation *operation = [[NSInvocationOperation alloc]initWithTarget:iconView selector:@selector(loadIcon:) object:icon];
            operation.queuePriority = NSOperationQueuePriorityLow;
            [_iconLoadingQueue addOperation:operation];
        }
    }];
}

- (void)layout
{
    self.contentSize = CGSizeMake(widthForIconCount(_unlimitedIconCount ? _icons.count : MIN(_icons.count, recommendedIconCount() + _hasHomeScreen)), self.bounds.size.height);
    [_icons enumerateObjectsUsingBlock:^(NSString *icon, NSUInteger index, BOOL *stop) {
        UminoIconView *iconView = _iconViews[icon];
        iconView.frame = iconFrameForIndex(index, _touchLocation);
    }];
    _iconHighlightView.frame = highlightFrameForTouchLocation(_touchLocation);
	if (_icons.count > 0) {
		[_iconHighlightView setTitle:_iconTitles[_icons[MIN(highlightIndexForTouchLocationX(_touchLocation.x), _icons.count - 1)]]];
	}
	[_iconHighlightView setHintShowing:_touchLocation.y < -100];
}

- (void)alternateLayout:(SBAppSwitcherIconController *)iconController
{
    UIView *iconContainer = CHIvar(iconController, _iconContainer, UIView * const);
    [_icons enumerateObjectsUsingBlock:^(NSString *icon, NSUInteger index, BOOL *stop) {
        UminoIconView *iconView = _iconViews[icon];
        if (_hasHomeScreen) {
        	if (index == 0) {
        		iconView.center = CGPointMake(iconView.center.x, self.bounds.size.height + iconView.bounds.size.height);
        	} else {
        		CGRect frame = [self convertRect:[iconController _iconFaultRectForIndex:index] fromView:iconContainer];
            	iconView.frame = frame;
        	}
        } else {
            CGRect frame = [self convertRect:[iconController _iconFaultRectForIndex:index + 1] fromView:iconContainer];
            iconView.frame = frame;
        }        
    }];
    CGRect frame = _iconHighlightView.frame;
    frame.origin.y = self.bounds.size.height;
    _iconHighlightView.frame = frame;
    [_iconHighlightView setTitle:nil];
}

- (void)abortAnimation
{
	NSMutableArray *views = [NSMutableArray arrayWithArray:_iconViews.allValues];
	[views addObject:_iconHighlightView];
	for (UIView *view in views) {
		CALayer *layer = view.layer;
		layer.position = ((CALayer *)layer.presentationLayer).position;
		layer.bounds = ((CALayer *)layer.presentationLayer).bounds;
		[layer removeAnimationForKey:@"position"];
		[layer removeAnimationForKey:@"bounds"];
	}
}

- (void)setUnlimitedIconCount:(BOOL)unlimited
{
	_unlimitedIconCount = unlimited;
}

- (void)setOpenToLast:(BOOL)last
{
	_openToLast = last;
}

- (void)setAtHomeScreen:(BOOL)homeScreen
{
	_atHomeScreen = homeScreen;
}

- (void)setTouchLocation:(CGPoint)location
{
	BOOL smooth = iphone6 || iphone6plus;
    location.x = correctedX(location.x, _unlimitedIconCount ? _icons.count : MIN(_icons.count, recommendedIconCount() + _hasHomeScreen));
    _touchLocation = location;
    CGFloat touchLocationX = location.x;
	switch (_transitFlag) {
		case 0: {
					if (smooth) {
						[UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
							[self layout];
						} completion:NULL];
					} else {
						[self layout];
					}
			break;
				}
		case 1: {
			break;
				}
		case 2: {
			_transitFlag = 0;
			[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				[self layout];
			} completion:NULL];
			break;
				}
	}
    CGFloat radius = kIconMinSize + kIconSpacing + kIconSpacingOffset;
    CGFloat distance = touchLocationX - self.contentOffset.x;
    if (distance < radius) {
        if ((!_timer.isValid || [_timer.userInfo integerValue] != -1) && _leftAccessed) {
            [_timer invalidate];
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:@(-1) repeats:YES];
            _timer.tolerance = 0.1;
        }
    } else if (self.bounds.size.width - distance < radius) {
        if ((!_timer.isValid || [_timer.userInfo integerValue] != +1) && _rightAccessed) {
            [_timer invalidate];
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerFired:) userInfo:@(+1) repeats:YES];
            _timer.tolerance = 0.1;
        }
    } else {
        [_timer invalidate];
        _timer = nil;
		_leftAccessed = YES;
		_rightAccessed = YES;
    }
    [self loadIconsAsynchronously:highlightIndexForTouchLocationX(touchLocationX)];
    if (_handler) {
        CGFloat offset = 0.0;
        NSInteger index = 0;
        if (_hasHomeScreen) {
            offset = (touchLocationX - (kViewMargin + kIconSpacing * 0.5) - (kIconMinSize + kIconSpacing) * 0.5) / ((kIconMinSize + kIconSpacing) * (_icons.count - 1));    
            index = MIN(highlightIndexForTouchLocationX(touchLocationX), _icons.count - 1);
        } else {
            offset = (touchLocationX - (kViewMargin + kIconSpacing * 0.5) + (kIconMinSize + kIconSpacing) * 0.5) / ((kIconMinSize + kIconSpacing) * _icons.count);   
            index = MIN(highlightIndexForTouchLocationX(touchLocationX), _icons.count - 1) + 1;
        }
        if (offset < 0.0 || offset > 1.0 || isnan(offset)) {
            offset = 0.0;
        }
        _handler(offset, index, 0.1 * smooth);
    }
}

- (void)normalizeTouchLocation
{
	_touchLocation.y = self.bounds.size.height;
	[self layout];
}

- (void)cancelTouch
{
    [_timer invalidate];
    _timer = nil;
}

- (void)setHighlightIndex:(NSInteger)index
{
    if (!_hasHomeScreen) {
        index--;
    }
    if (index >= 0 && index < _icons.count) {
        _touchLocation = CGPointMake(iconPositionXForIndex(index), 0);
        [self layout];
    }
}

- (void)timerFired:(NSTimer *)timer
{
    if (timer != _timer) {
        return;
    }
    NSInteger scrollDirection = [_timer.userInfo integerValue];
    CGFloat minOffsetX = 0;
    CGFloat maxOffsetX = MAX(self.contentSize.width - self.bounds.size.width, minOffsetX);
    CGFloat offsetX = self.contentOffset.x;
    offsetX += ((kIconMinSize + kIconSpacing) * scrollDirection);
    if (offsetX < minOffsetX) {
        [_timer invalidate];
        _timer = nil;
        [UIView animateWithDuration:kScrollingAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setContentOffset:CGPointMake(minOffsetX, 0) animated:NO];
        } completion:NULL];
    } else if (offsetX > maxOffsetX) {
        [_timer invalidate];
        _timer = nil;
        [UIView animateWithDuration:kScrollingAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self setContentOffset:CGPointMake(maxOffsetX, 0) animated:NO];
        } completion:NULL];
    } else {
        _touchLocation.x += ((kIconMinSize + kIconSpacing) * scrollDirection);
        _touchLocation.x = correctedX(_touchLocation.x, _unlimitedIconCount ? _icons.count : MIN(_icons.count, recommendedIconCount() + _hasHomeScreen));
        CGFloat touchLocationX = _touchLocation.x;
        [self loadIconsAsynchronously:highlightIndexForTouchLocationX(touchLocationX)];
        if (_handler) {
            if (_hasHomeScreen) {
                _handler((touchLocationX - (kViewMargin + kIconSpacing * 0.5) - (kIconMinSize + kIconSpacing) * 0.5) / ((kIconMinSize + kIconSpacing) * (_icons.count - 1)), MIN(highlightIndexForTouchLocationX(touchLocationX), _icons.count - 1), kScrollingAnimationDuration);
            } else {
                _handler((touchLocationX - (kViewMargin + kIconSpacing * 0.5) + (kIconMinSize + kIconSpacing) * 0.5) / ((kIconMinSize + kIconSpacing) * _icons.count), MIN(highlightIndexForTouchLocationX(touchLocationX), _icons.count - 1) + 1, kScrollingAnimationDuration);
            }
        }
		[self abortAnimation];
        [UIView animateWithDuration:kScrollingAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self layout];
            [self setContentOffset:CGPointMake(offsetX, 0) animated:NO];
        } completion:NULL];
    }
}

- (void)setHidden:(BOOL)hidden
{
    if (self.hidden == hidden) {
        [super setHidden:hidden];    
    } else {
        [super setHidden:hidden];
        if (hidden) {
            [self setIcons:nil];
        }
    }
}

- (void)transitIn:(SBAppSwitcherIconController *)iconController animated:(BOOL)animated
{
    if (self.alpha == 1) {
        return;
    }
    if (animated) {
		[self abortAnimation];
        [self alternateLayout:iconController];
        self.alpha = 0;
        iconController.view.alpha = 1;
		_transitFlag = 1;
        [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState | UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.1 animations:^{
                self.alpha = 1;
                iconController.view.alpha = 0;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.1 relativeDuration:0.4 animations:^{
                [self layout];
            }];
        } completion:^(BOOL finished) {
			_transitFlag = 2;
			[self setTouchLocation:_touchLocation];
			}];
    } else {
        self.alpha = 1;
        iconController.view.alpha = 0;
        [self layout];
    }
}

- (void)transitOut:(SBAppSwitcherIconController *)iconController animated:(BOOL)animated
{
    [_timer invalidate];
    _timer = nil;
    if (self.alpha == 0) {
        return;
    }
    if (animated) {
		[self abortAnimation];
        [self layout];
        self.alpha = 1;
        iconController.view.alpha = 0;
        [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState | UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.4 animations:^{
                [self alternateLayout:iconController];
            }];
            [UIView addKeyframeWithRelativeStartTime:0.4 relativeDuration:0.1 animations:^{
                self.alpha = 0;
                iconController.view.alpha = 1;
            }];
        } completion:NULL];    
    } else {
        [self alternateLayout:iconController];
        self.alpha = 0;
        iconController.view.alpha = 1;
    }
}

@end
