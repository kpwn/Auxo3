#import "UminoIconHighlightView.h"
#import "Headers.h"

@implementation UminoIconHighlightView {
    UIView *_backgroundView;
    UILabel *_titleView;
	UILabel *_hintLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 7;
        self.layer.masksToBounds = YES;
        _backgroundView = [[_UIBackdropView alloc]initWithStyle:0x7e4];
        _titleView = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleView.font = [UIFont systemFontOfSize:12];
        _titleView.textColor = [UIColor whiteColor];
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.adjustsFontSizeToFitWidth = YES;
        _titleView.minimumScaleFactor = 0.6;
        _titleView.layer.masksToBounds = NO;
        _titleView.layer.shadowOpacity = 0.6;
        _titleView.layer.shadowRadius = 3.0;
        _titleView.layer.shadowOffset = CGSizeZero;
        _titleView.layer.shadowColor = [UIColor blackColor].CGColor;
        _hintLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_hintLabel.text = @"←→\nslide\nhere";
        _hintLabel.font = [UIFont systemFontOfSize:14];
        _hintLabel.textColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
        _hintLabel.textAlignment = NSTextAlignmentCenter;
		_hintLabel.numberOfLines = 3;
		_hintLabel.layer.compositingFilter = @"plusD";
		_hintLabel.alpha = 0;
        [self addSubview:_backgroundView];
        [self addSubview:_titleView];
        [self addSubview:_hintLabel];
        self.layer.allowsGroupBlending = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    _backgroundView.frame = frame;
    frame.size.height = 22;
    frame.size.width -= 2;
    frame.origin.x += 1;
    _titleView.frame = frame;
	[_hintLabel sizeToFit];
	_hintLabel.center = CGPointMake(frame.size.width / 2.0, 153);
}

- (void)setTitle:(NSString *)title
{
    if (![_titleView.text isEqualToString:title]) {
        // [UIView transitionWithView:_titleView duration:0.2 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionOverrideInheritedDuration animations:^{
            _titleView.text = title;
        // } completion:NULL];
    }
}

- (void)setHintShowing:(BOOL)showing
{
	if (showing) {
		if (_hintLabel.alpha != 1.0) {
			[UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration animations:^(){
				_hintLabel.alpha = 1.0;
			} completion:NULL];
		}
		// if ([_hintLabel.layer animationForKey:@"hint"] == nil) {
		// 	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
		// 	animation.values = @[@0, @1, @1, @0];
		// 	animation.keyTimes = @[@0.0, @0.3, @0.7, @1.0];
		// 	animation.calculationMode = kCAAnimationPaced;
		// 	animation.duration = 1.5;
		// 	animation.repeatCount = HUGE_VALF;
		// 	[_hintLabel.layer addAnimation:animation forKey:@"hint"];
		// }
	} else {
		if (_hintLabel.alpha != 0.0) {
			[UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionOverrideInheritedDuration animations:^(){
				_hintLabel.alpha = 0.0;
			} completion:NULL];
		}
		// [_hintLabel.layer removeAnimationForKey:@"hint"];
	}
}

@end
