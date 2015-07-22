#import "UminoControlCenterBottomView.h"
#import "Headers.h"

@class UminoPlayerButton;

__attribute__((visibility("hidden")))
@interface UminoPlayerButtonLayer : CALayer
@property(assign, nonatomic) UminoPlayerButton *button;
@end

__attribute__((visibility("hidden")))
@interface UminoPlayerButton : UIButton
@property(assign, nonatomic) UminoPlayerButtonType type;
@end

@implementation UminoPlayerButton {
    UminoPlayerButtonLayer *_imageLayer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageLayer = [UminoPlayerButtonLayer layer];
        _imageLayer.contentsScale = [UIScreen mainScreen].scale;
        _imageLayer.button = self;
        [self.layer addSublayer:_imageLayer];
        self.highlighted = NO;
        self.layer.allowsGroupBlending = NO;
    }
    return self;
}

- (void)setType:(UminoPlayerButtonType)type
{
	_type = type;
	[_imageLayer setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled
{
	[super setEnabled:enabled];
	self.alpha = enabled ? 1.0 : 0.2;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    _imageLayer.compositingFilter = highlighted ? nil : @"plusD";
    [_imageLayer setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imageLayer.frame = self.bounds;
    [_imageLayer setNeedsDisplay];
}

@end

@implementation UminoPlayerButtonLayer

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    if (CGRectEqualToRect(rect, CGRectZero)) {
        return;
    }
    switch (_button.type) {
    	case UminoPlayerButtonTypeMain: {
    		static CGFloat const width = 50.0;
		    static CGFloat const height = 50.0;
		    CGContextTranslateCTM(context, (rect.size.width - width) / 2.0, (rect.size.height - height) / 2.0);
		    CGContextSetLineWidth(context, 1.5);
		    CGContextSetStrokeColorWithColor(context, (_button.highlighted ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		    CGContextStrokeEllipseInRect(context, CGRectInset(CGRectMake(0.0, 0.0, width, height), 0.75, 0.75));
		    if (_button.selected) {
		        CGContextSetFillColorWithColor(context, (_button.highlighted ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		        CGContextFillRect(context, CGRectMake(width * 0.36, height * 0.32, width * 0.10, height * 0.36));
		        CGContextFillRect(context, CGRectMake(width * 0.54, height * 0.32, width * 0.10, height * 0.36));
		    } else {
		        CGContextBeginPath(context);
		        CGContextMoveToPoint(context, width * (0.36 + 0.28 / 6.0), height * 0.32);
		        CGContextAddLineToPoint(context, width * (0.64 + 0.28 / 6.0), height * 0.50);
		        CGContextAddLineToPoint(context, width * (0.36 + 0.28 / 6.0), height * 0.68);
		        CGContextAddLineToPoint(context, width * (0.36 + 0.28 / 6.0), height * 0.32);
		        CGContextClosePath(context);
		        CGContextSetFillColorWithColor(context, (_button.highlighted ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		        CGContextFillPath(context);
		    }
    		break;
    	}
    	case UminoPlayerButtonTypeRewind: {
    		static CGFloat const width = 23.0;
		    static CGFloat const height = 14.0;
		    CGContextTranslateCTM(context, (rect.size.width - width) / 2.0, (rect.size.height - height) / 2.0);
		    CGContextBeginPath(context);
		    CGContextMoveToPoint(context, 0.0, height * 0.5);
		    CGContextAddLineToPoint(context, width * 0.5, 0.0);
		    CGContextAddLineToPoint(context, width * 0.5, height * 0.5);
		    CGContextAddLineToPoint(context, width, 0.0);
		    CGContextAddLineToPoint(context, width, height);
		    CGContextAddLineToPoint(context, width * 0.5, height * 0.5);
		    CGContextAddLineToPoint(context, width * 0.5, height);
		    CGContextAddLineToPoint(context, 0.0, height * 0.5);
		    CGContextClosePath(context);
		    CGContextSetFillColorWithColor(context, (_button.highlighted ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		    CGContextFillPath(context);
    		break;
    	}
    	case UminoPlayerButtonTypeFastForward: {
    		static CGFloat const width = 23.0;
		    static CGFloat const height = 14.0;
		    CGContextTranslateCTM(context, (rect.size.width - width) / 2.0, (rect.size.height - height) / 2.0);
		    CGContextBeginPath(context);
		    CGContextMoveToPoint(context, 0.0, 0.0);
		    CGContextAddLineToPoint(context, width * 0.5, height * 0.5);
		    CGContextAddLineToPoint(context, width * 0.5, 0.0);
		    CGContextAddLineToPoint(context, width, height * 0.5);
		    CGContextAddLineToPoint(context, width * 0.5, height);
		    CGContextAddLineToPoint(context, width * 0.5, height * 0.5);
		    CGContextAddLineToPoint(context, 0.0, height);
		    CGContextAddLineToPoint(context, 0.0, 0.0);
		    CGContextClosePath(context);
		    CGContextSetFillColorWithColor(context, (_button.highlighted ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		    CGContextFillPath(context);
    		break;
    	}
    	case UminoPlayerButtonTypeRewindFifteenSeconds: {
    		static UIImage *image;
            if (image == nil) {
                UIImage *icon = [UIImage imageNamed:@"SystemMediaControl-RewindInterval" inBundle:[NSBundle bundleWithIdentifier:@"com.apple.MediaPlayerUI"]];
				NSString *string = @"15";
				NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:10]};
				CGSize textSize = [string sizeWithAttributes:attributes];
				UIGraphicsBeginImageContextWithOptions(icon.size, NO, [UIScreen mainScreen].scale);
				[icon drawAtPoint:CGPointZero];
				[string drawAtPoint:CGPointMake((icon.size.width - textSize.width) / 2.0, (icon.size.height - textSize.height) / 2.0) withAttributes:attributes];
				image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
                image = [image _imageScaledToProportion:0.85 interpolationQuality:kCGInterpolationDefault];
            }
		    CGRect imageRect = CGRectInset(rect, (rect.size.width - image.size.width) / 2.0, (rect.size.height - image.size.height) / 2.0);
		    CGContextTranslateCTM(context, 0.0, rect.size.height);
		    CGContextScaleCTM(context, 1.0, -1.0);
		    CGContextSetFillColorWithColor(context, (_button.highlighted ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		    CGContextSetBlendMode(context, kCGBlendModeNormal);
		    CGContextDrawImage(context, imageRect, image.CGImage);
		    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
			CGContextFillRect(context, CGRectInset(imageRect, -1, -1));
    		break;
    	}
    	case UminoPlayerButtonTypeFastForwardFifteenSeconds: {
    		static UIImage *image;
            if (image == nil) {
                UIImage *icon = [UIImage imageNamed:@"SystemMediaControl-ForwardInterval" inBundle:[NSBundle bundleWithIdentifier:@"com.apple.MediaPlayerUI"]];
				NSString *string = @"15";
				NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:10]};
				CGSize textSize = [string sizeWithAttributes:attributes];
				UIGraphicsBeginImageContextWithOptions(icon.size, NO, [UIScreen mainScreen].scale);
				[icon drawAtPoint:CGPointZero];
				[string drawAtPoint:CGPointMake((icon.size.width - textSize.width) / 2.0, (icon.size.height - textSize.height) / 2.0) withAttributes:attributes];
				image = UIGraphicsGetImageFromCurrentImageContext();
				UIGraphicsEndImageContext();
                image = [image _imageScaledToProportion:0.85 interpolationQuality:kCGInterpolationDefault];
            }
		    CGRect imageRect = CGRectInset(rect, (rect.size.width - image.size.width) / 2.0, (rect.size.height - image.size.height) / 2.0);
		    CGContextTranslateCTM(context, 0.0, rect.size.height);
		    CGContextScaleCTM(context, 1.0, -1.0);
		    CGContextSetFillColorWithColor(context, (_button.highlighted ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		    CGContextSetBlendMode(context, kCGBlendModeNormal);
		    CGContextDrawImage(context, imageRect, image.CGImage);
		    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
			CGContextFillRect(context, CGRectInset(imageRect, -1, -1));
    		break;
    	}
    	case UminoPlayerButtonTypeFavorite: {
    		static UIImage *image;
            if (image == nil) {
                image = [UIImage imageNamed:@"SystemMediaControl-LikeBan" inBundle:[NSBundle bundleWithIdentifier:@"com.apple.MediaPlayerUI"]];
                image = [image _imageScaledToProportion:0.85 interpolationQuality:kCGInterpolationDefault];
            }
		    CGRect imageRect = CGRectInset(rect, (rect.size.width - image.size.width) / 2.0, (rect.size.height - image.size.height) / 2.0);
		    CGContextTranslateCTM(context, 0.0, rect.size.height);
		    CGContextScaleCTM(context, 1.0, -1.0);
		    CGContextSetFillColorWithColor(context, (_button.highlighted ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		    CGContextSetBlendMode(context, kCGBlendModeNormal);
		    CGContextDrawImage(context, imageRect, image.CGImage);
		    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
			CGContextFillRect(context, CGRectInset(imageRect, -1, -1));
    		break;
    	}
    }
}

@end

@class UminoSlider;

__attribute__((visibility("hidden")))
@interface UminoSliderBackgroundLayer : CALayer
@property(assign, nonatomic) UminoSlider *slider;
@end

__attribute__((visibility("hidden")))
@interface UminoSliderForegroundLayer : CALayer
@property(assign, nonatomic) UminoSlider *slider;
@end

__attribute__((visibility("hidden")))
@interface UminoSliderKnotLayer : CALayer
@property(assign, nonatomic) UminoSlider *slider;
@end

__attribute__((visibility("hidden")))
@interface UminoSliderIconLayer : CALayer
@property(assign, nonatomic) UminoSlider *slider;
@end

__attribute__((visibility("hidden")))
@interface UminoSlider : UIControl
@property(assign, nonatomic) NSUInteger type;
@property(retain, nonatomic) NSArray *icons;
@property(assign, nonatomic) float value;
@property(assign, nonatomic) BOOL panning;
@property(assign, nonatomic) BOOL sliding;
@property(copy, nonatomic) void (^actionHandler)(UminoSlider *);
@end

@implementation UminoSlider {
    UminoSliderBackgroundLayer *_backgroundLayer;
    UminoSliderForegroundLayer *_foregroundLayer;
    UminoSliderKnotLayer *_knotLayer;
    UminoSliderIconLayer *_iconLayer;
	UIVisualEffectView *_effectView;
}

CHInline static CGFloat circleRadius()
{
    return 28.5;
}
CHInline static CGFloat lineLength()
{
    return widescreen ? 168.0 : 124.0;
}
CHInline static CGFloat sliderRadius(BOOL grabbed)
{
	return UminoIsPortrait(NO) ? (grabbed ? 11.0 : 8.0) : 14.0;
}
CHInline static CGFloat theta()
{
    return atan(15.0 / 55.0);
}
CHInline static CGFloat startAngle()
{
    return M_PI_2 + theta();
}
CHInline static CGFloat endAngle()
{
    return M_PI_2 * 5.0 - theta();
}

CHInline static CGFloat valueAngle(float value)
{
    return startAngle() + (endAngle() - startAngle()) * value;
}

CHInline static CGPoint circleSliderPosition(CGPoint center, float value)
{
    CGFloat angle = valueAngle(value);
    return CGPointMake(center.x + circleRadius() * cos(angle), center.y + circleRadius() * sin(angle));
}

CHInline static CGRect circleSliderFrame(CGPoint center, float value, BOOL grabbed)
{
    CGPoint position = circleSliderPosition(center, value);
    return CGRectInset(CGRectMake(position.x, position.y, 0, 0), - sliderRadius(grabbed), - sliderRadius(grabbed));
}

CHInline static CGPoint lineSliderPosition(CGPoint center, float value)
{
    return CGPointMake(center.x + lineLength() * (value - 0.5), center.y);
}

CHInline static CGRect lineSliderFrame(CGPoint center, float value, BOOL grabbed)
{
    CGPoint position = lineSliderPosition(center, value);
    return CGRectInset(CGRectMake(position.x, position.y, 0, 0), - sliderRadius(grabbed), - sliderRadius(grabbed));
}

CHInline static float angleValue(CGFloat angle)
{
    return (angle - startAngle()) / (endAngle() - startAngle());
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _backgroundLayer = [UminoSliderBackgroundLayer layer];
        _backgroundLayer.contentsScale = [UIScreen mainScreen].scale;
        _backgroundLayer.slider = self;
        _backgroundLayer.compositingFilter = @"plusD";
        _foregroundLayer = [UminoSliderForegroundLayer layer];
        _foregroundLayer.contentsScale = [UIScreen mainScreen].scale;
        _foregroundLayer.slider = self;
        _knotLayer = [UminoSliderKnotLayer layer];
        _knotLayer.contentsScale = [UIScreen mainScreen].scale;
        _knotLayer.slider = self;
        _iconLayer = [UminoSliderIconLayer layer];
        _iconLayer.contentsScale = [UIScreen mainScreen].scale;
        _iconLayer.slider = self;
        _iconLayer.compositingFilter = @"plusD";
		_effectView = [[UIVisualEffectView alloc]initWithEffect:[SBUIControlCenterVisualEffect effectWithStyle:(UIBlurEffectStyle)1]];
		_effectView.userInteractionEnabled = NO;
        [_effectView.contentView.layer addSublayer:_foregroundLayer];
        self.layer.allowsGroupBlending = NO;
        [self.layer addSublayer:_backgroundLayer];
        [self.layer addSublayer:_iconLayer];
		[self addSubview:_effectView];
        [self.layer addSublayer:_knotLayer];
    }
    return self;
}

- (void)setType:(NSUInteger)type
{
    _type = type % _icons.count;
    [_backgroundLayer setNeedsDisplay];
    [_foregroundLayer setNeedsDisplay];
    [_knotLayer setNeedsDisplay];
    [_iconLayer setNeedsDisplay];
}

- (void)triggerAction
{
	_actionHandler(self);
    [_backgroundLayer setNeedsDisplay];
    [_foregroundLayer setNeedsDisplay];
    [_knotLayer setNeedsDisplay];
    [_iconLayer setNeedsDisplay];
}

- (void)setValue:(float)value
{
    _value = MIN(MAX(value, 0.0), 1.0);
    [_backgroundLayer setNeedsDisplay];
    [_foregroundLayer setNeedsDisplay];
    [_knotLayer setNeedsDisplay];
    [_iconLayer setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _backgroundLayer.frame = self.bounds;
    _foregroundLayer.frame = self.bounds;
    _knotLayer.frame = self.bounds;
    _iconLayer.frame = self.bounds;
    _effectView.frame = self.bounds;
    [_backgroundLayer setNeedsDisplay];
    [_foregroundLayer setNeedsDisplay];
    [_knotLayer setNeedsDisplay];
    [_iconLayer setNeedsDisplay];
}

- (void)panningRecognized
{
	_panning = YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
    CGRect bounds = self.bounds;
    CGPoint location = [touches.anyObject locationInView:self];
	_panning = NO;
	[self performSelector:@selector(panningRecognized) withObject:nil afterDelay:0.4];
    _sliding = CGRectContainsPoint(CGRectInset(UminoIsPortrait(NO) ? circleSliderFrame(CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0), _value, NO) : lineSliderFrame(CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0), _value, NO), - sliderRadius(NO) * 2, - sliderRadius(NO) * 2), location);
	if (_sliding) {
		_iconLayer.compositingFilter = nil;
		[_iconLayer setNeedsDisplay];
		[_knotLayer setNeedsDisplay];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(panningRecognized) object:nil];
	_panning = YES;
    if (_sliding) {
        CGRect bounds = self.bounds;
        CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
        CGPoint location = [touches.anyObject locationInView:self];
        if (UminoIsPortrait(NO)) {
            CGFloat angle = 0;
            if (location.x - center.x > 0) {
                angle = atan((location.y - center.y) / (location.x - center.x)) + M_PI * 2.0;
            } else if (location.x - center.x < 0) {
                angle = atan((location.y - center.y) / (location.x - center.x)) + M_PI;
            } else {
                angle = location.y - center.y <= 0 ? M_PI_2 * 3.0 : M_PI_2;
            }
            if (ABS(_value - angleValue(angle)) < 0.5) {
                self.value = angleValue(angle);
            }
        } else {
            self.value = (location.x - (center.x - lineLength() * 0.5)) / lineLength();
        }
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(panningRecognized) object:nil];
	if (_panning) {
		if (_sliding) {
			CGRect bounds = self.bounds;
			CGPoint center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
			CGPoint location = [touches.anyObject locationInView:self];
			if (UminoIsPortrait(NO)) {
				CGFloat angle = 0;
				if (location.x - center.x > 0) {
					angle = atan((location.y - center.y) / (location.x - center.x)) + M_PI * 2.0;
				} else if (location.x - center.x < 0) {
					angle = atan((location.y - center.y) / (location.x - center.x)) + M_PI;
				} else {
					angle = location.y - center.y <= 0 ? M_PI_2 * 3.0 : M_PI_2;
				}
				if (ABS(_value - angleValue(angle)) < 0.5) {
					self.value = angleValue(angle);
				}
			} else {
				self.value = (location.x - (center.x - lineLength() * 0.5)) / lineLength();
			}
			[self sendActionsForControlEvents:UIControlEventValueChanged];
		}
	} else {
		[self triggerAction];
	}
	_panning = NO;
	_sliding = NO;
	_iconLayer.compositingFilter = @"plusD";
	[_iconLayer setNeedsDisplay];
	[_knotLayer setNeedsDisplay];
}

@end

@implementation UminoSliderBackgroundLayer

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    if (CGRectEqualToRect(rect, CGRectZero)) {
        return;
    }
    CGPoint center = CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0);
    float value = _slider.value;
    if (UminoIsPortrait(NO)) {
        CGContextBeginPath(context);
        CGContextAddArc(context, center.x, center.y, circleRadius(), valueAngle(value), endAngle(), 0);
        CGContextSetLineWidth(context, 3);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(context, [[UIColor blackColor]colorWithAlphaComponent:0.4].CGColor);
        CGContextStrokePath(context);
    } else {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, lineSliderPosition(center, value).x, center.y);
        CGContextAddLineToPoint(context, center.x + lineLength() * 0.5, center.y);
        CGContextSetLineWidth(context, 3);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(context, [[UIColor blackColor]colorWithAlphaComponent:0.4].CGColor);
        CGContextStrokePath(context);
    }
}

- (id<CAAction>)actionForKey:(NSString *)event { return nil; }

@end

@implementation UminoSliderForegroundLayer

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    if (CGRectEqualToRect(rect, CGRectZero)) {
        return;
    }
    CGPoint center = CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0);
    float value = _slider.value;
    if (UminoIsPortrait(NO)) {
        CGContextBeginPath(context);
        CGContextAddArc(context, center.x, center.y, circleRadius(), startAngle(), valueAngle(value), 0);
        CGContextSetLineWidth(context, 3);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextStrokePath(context);
    } else {
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, center.x - lineLength() * 0.5, center.y);
        CGContextAddLineToPoint(context, lineSliderPosition(center, value).x, center.y);
        CGContextSetLineWidth(context, 3);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextStrokePath(context);
    }
}

- (id<CAAction>)actionForKey:(NSString *)event { return nil; }

@end

@implementation UminoSliderKnotLayer

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    if (CGRectEqualToRect(rect, CGRectZero)) {
        return;
    }
    CGPoint center = CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0);
    float value = _slider.value;
	int step = value == 0 ? 0 : ceil(value * 3);
    if (UminoIsPortrait(NO)) {
		CGContextBeginPath(context);
        CGContextAddEllipseInRect(context, circleSliderFrame(center, value, _slider.sliding));
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 3.0, [UIColor colorWithWhite:0.0 alpha:0.8].CGColor);
        CGContextFillPath(context);
    } else {
        CGContextBeginPath(context);
        CGContextAddEllipseInRect(context, lineSliderFrame(center, value, _slider.sliding));
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, CGSizeMake(0.0, 1.0), 3.0, [UIColor colorWithWhite:0.0 alpha:0.8].CGColor);
        CGContextFillPath(context);
		CGContextRestoreGState(context);
        CGRect imageRect = CGRectInset(CGRectMake(lineSliderPosition(center, value).x, center.y, 0.0, 0.0), -9.0, -9.0);
		CGContextSetBlendMode(context, kCGBlendModePlusDarker);
		CGContextDrawImage(context, imageRect, imageResource([NSString stringWithFormat:@"%@%i", _slider.icons[_slider.type], step]).CGImage);
    }
}

- (id<CAAction>)actionForKey:(NSString *)event { return nil; }

@end

@implementation UminoSliderIconLayer

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    if (CGRectEqualToRect(rect, CGRectZero)) {
        return;
    }
    CGPoint center = CGPointMake(rect.size.width / 2.0, rect.size.height / 2.0);
    float value = _slider.value;
	int step = value == 0 ? 0 : ceil(value * 3);
    if (UminoIsPortrait(NO)) {
        CGRect imageRect = CGRectInset(CGRectMake(center.x, center.y, 0.0, 0.0), -14.5, -14.5);
		CGContextSetFillColorWithColor(context, (_slider.sliding ? [UIColor whiteColor] : [[UIColor blackColor]colorWithAlphaComponent:0.4]).CGColor);
		CGContextDrawImage(context, imageRect, imageResource([NSString stringWithFormat:@"%@%i", _slider.icons[_slider.type], step]).CGImage);
        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
        CGContextFillRect(context, CGRectInset(imageRect, -1, -1));
    } else {
		CGContextClearRect(context, rect);
    }
}

@end

__attribute__((visibility("hidden")))
@interface UminoTrackInfoView : UIControl
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *artist;
@property (retain, nonatomic) NSString *album;
@end

@implementation UminoTrackInfoView {
    UILabel *_songLabel;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _songLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _songLabel.font = [UIFont systemFontOfSize:14.0];
        _songLabel.textAlignment = NSTextAlignmentCenter;
        _songLabel.textColor = [UIColor whiteColor];
        [_songLabel setMarqueeEnabled:YES];
        self.layer.allowsGroupBlending = NO;
        [self addSubview:_songLabel];
        [_songLabel setMarqueeRunning:YES];
    }
    return self;
}

CHInline NSMutableAttributedString *textFromSongInfo(NSString *title, NSString *artist, NSString *album)
{
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
    [text appendAttributedString:[[NSAttributedString alloc]initWithString:artist ? [NSString stringWithFormat:@"%@  ", artist] : @"" attributes:@{NSForegroundColorAttributeName: [[UIColor blackColor]colorWithAlphaComponent:0.8]}]];
    [text appendAttributedString:[[NSAttributedString alloc]initWithString:title ? : @"" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}]];
    [text appendAttributedString:[[NSAttributedString alloc]initWithString:album ? [NSString stringWithFormat:@"  %@", album] : @"" attributes:@{NSForegroundColorAttributeName: [[UIColor blackColor]colorWithAlphaComponent:0.8]}]];
    return text;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _songLabel.attributedText = textFromSongInfo(_title, _artist, _album);
}

- (void)setArtist:(NSString *)artist
{
    _artist = artist;
    _songLabel.attributedText = textFromSongInfo(_title, _artist, _album);
}

- (void)setAlbum:(NSString *)album
{
    _album = album;
    _songLabel.attributedText = textFromSongInfo(_title, _artist, _album);
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.5 : 1.0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    CGFloat songLabelWidth = (bounds.size.width - 16.0 * 2 - 8.0 * 2) / 3.0;
    _songLabel.frame = CGRectMake(16.0, 2.5, songLabelWidth * 3.0 + 8.0 * 2.0, 18.0);
}

@end

@interface UminoControlCenterBottomScrollView : UIScrollView
@end

@implementation UminoControlCenterBottomScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldReceiveTouch:(UITouch *)touch
{
	if (self.panGestureRecognizer == recognizer) {
		UIView *view = [self hitTest:[touch locationInView:self] withEvent:nil];
		if ([view isKindOfClass:UminoPlayerButton.class] || [view isKindOfClass:UminoSlider.class]) {
			return NO;
		}
	}
	return [super gestureRecognizer:recognizer shouldReceiveTouch:touch];
}

@end

@interface UminoControlCenterBottomView () <MPUNowPlayingDelegate, MPUChronologicalProgressViewDelegate, SBControlCenterSectionViewControllerDelegate, UIModalItemDelegate, RUTrackActionsDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>
@end

@implementation UminoControlCenterBottomView {
    UIVisualEffectView *_backgroundView;
	UIVisualEffect *_backgroundEffect;
	UIView *_tintView;
    UIView *_contentView;
	UIVisualEffectView *_effectView;
	UIView *_darkenView;
    UminoControlCenterBottomScrollView *_scrollView;
    UminoPlayerButton *_centerButton;
    UminoPlayerButton *_leftButton;
    UminoPlayerButton *_rightButton;
    UminoSlider *_brightnessSlider;
    UminoSlider *_volumeSlider;
    UminoTrackInfoView *_trackInfoView;
    MPUChronologicalProgressView *_trackProgressView;
    BKSDisplayBrightnessTransactionRef _brightnessTransaction;
	SBMediaController *_mediaController;
	AVSystemController *_avController;
    MPUNowPlayingController *_nowPlayingController;
    SBCCQuickLaunchSectionController *_quickLaunchController;
    RUTrackActionsModalItem *_trackActionsModalItem;
    NSDictionary *_nowPlayingInfoForPresentedTrackActions;
    BOOL _playerButtonTapped;
    BOOL _playerButtonLongPressed;
    BOOL _isPreviousTrack;
	NSInteger _brightnessSliderAction;
	NSInteger _volumeSliderAction;
	BOOL _showingHUD;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
		/*
        _backgroundView = [[_UIBackdropView alloc]initWithStyle:0x80c];
        _backgroundView.appliesOutputSettingsAnimationDuration = 1.0;
        _backgroundView.groupName = @"Auxo";
		_backgroundView = [[NSClassFromString(@"UminoBackgroundView") alloc]initWithFrame:CGRectZero];
		*/
		_backgroundView = [[UIVisualEffectView alloc]initWithFrame:CGRectZero];
		_backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		_tintView = [[UIView alloc]initWithFrame:CGRectZero];
		_tintView.backgroundColor = [UIColor whiteColor];
		_tintView.alpha = 0.17;
        _contentView = [[UIView alloc]initWithFrame:CGRectZero];
        _contentView.layer.allowsGroupBlending = NO;
        [self addSubview:_backgroundView];
		[self addSubview:_tintView];
        [self addSubview:_contentView];
		_effectView = [[UIVisualEffectView alloc]initWithEffect:[SBUIControlCenterVisualEffect effectWithStyle:(UIBlurEffectStyle)0]];
		_effectView.userInteractionEnabled = NO;
		_darkenView = [[UIView alloc]initWithFrame:_effectView.contentView.bounds];
		_darkenView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_darkenView.backgroundColor = [UIColor whiteColor];
		[_effectView.contentView addSubview:_darkenView];
        _scrollView = [[UminoControlCenterBottomScrollView alloc]initWithFrame:CGRectZero];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.alwaysBounceHorizontal = NO;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.clipsToBounds = YES;
        _scrollView.delegate = self;
        _centerButton = [[UminoPlayerButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        _centerButton.type = UminoPlayerButtonTypeMain;
        _leftButton = [[UminoPlayerButton alloc]initWithFrame:CGRectMake(0, 0, 40, 50)];
        _leftButton.type = UminoPlayerButtonTypeRewind;
        _rightButton = [[UminoPlayerButton alloc]initWithFrame:CGRectMake(0, 0, 40, 50)];
        _rightButton.type = UminoPlayerButtonTypeFastForward;
        _brightnessSlider = [[UminoSlider alloc]initWithFrame:CGRectMake(0, 0, 78, 78)];
        _brightnessSlider.icons = @[@"Brightness", @"BrightnessAutoOff"];
        _volumeSlider = [[UminoSlider alloc]initWithFrame:CGRectMake(0, 0, 78, 78)];
        _volumeSlider.icons = @[@"Volume", @"Ringer"];
		CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _trackInfoView = [[UminoTrackInfoView alloc]initWithFrame:CGRectMake(0, 0, width, 30)];
        _trackProgressView = [[MPUChronologicalProgressView alloc]initWithStyle:1];
        _trackProgressView.bounds = CGRectMake(0, 0, width - 32, 34);
        _trackProgressView.delegate = self;
		_mediaController = (SBMediaController *)[NSClassFromString(@"SBMediaController") sharedInstance];
		_avController = [AVSystemController sharedAVSystemController];
        _nowPlayingController = [[MPUNowPlayingController alloc]init];
        _nowPlayingController.delegate = self;
        _quickLaunchController = [[NSClassFromString(@"UminoCCQuickLaunchSectionController") alloc]init];
        _quickLaunchController.delegate = self;
		((SBControlCenterSectionView *)_quickLaunchController.view).edgePadding = (iphone6 || iphone6plus) ? 26.0 : 16.0;
        [_contentView addSubview:_scrollView];
        [_centerButton addTarget:self action:@selector(playerButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_leftButton addTarget:self action:@selector(playerButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_rightButton addTarget:self action:@selector(playerButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_centerButton addTarget:self action:@selector(playerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_leftButton addTarget:self action:@selector(playerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_rightButton addTarget:self action:@selector(playerButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_centerButton addTarget:self action:@selector(playerButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_leftButton addTarget:self action:@selector(playerButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_rightButton addTarget:self action:@selector(playerButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        [_brightnessSlider addTarget:self action:@selector(brightnessSliderDidChange:) forControlEvents:UIControlEventValueChanged];
        [_volumeSlider addTarget:self action:@selector(volumeSliderDidChange:) forControlEvents:UIControlEventValueChanged];
        [_brightnessSlider addTarget:self action:@selector(sliderDidStopTracking:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        [_volumeSlider addTarget:self action:@selector(sliderDidStopTracking:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
		__typeof(self) __block blockSelf = self;
		_brightnessSlider.actionHandler = ^(UminoSlider *slider) {
			static float previousValue = 0;
			switch (blockSelf->_brightnessSliderAction) {
				case 0: {
							if (slider.value != 0) {
								previousValue = slider.value;
								slider.value = 0;
								[blockSelf brightnessSliderDidChange:slider];
							} else {
								slider.value = previousValue;	
								[blockSelf brightnessSliderDidChange:slider];
							}
							break;
						}
				case 1: {
							if (slider.value != 1) {
								previousValue = slider.value;
								slider.value = 1;
								[blockSelf brightnessSliderDidChange:slider];
							} else {
								slider.value = previousValue;	
								[blockSelf brightnessSliderDidChange:slider];
							}
							break;
						}
				case 2: {
							slider.type = slider.type + 1;
							BOOL enabled = slider.type == 0;
							BKSDisplayBrightnessSetAutoBrightnessEnabled(enabled);
							if (blockSelf->_showingHUD && UminoIsPortrait(NO)) {
								SBHUDController *hudController = [NSClassFromString(@"SBHUDController") sharedHUDController];
								SBHUDView *hudView = hudController.visibleHUDView;
								if (![hudView isKindOfClass:NSClassFromString(@"UminoBrightnessHUDView")]) {
									hudView = [[NSClassFromString(@"UminoBrightnessHUDView") alloc]init];
								}
								hudView.title = @"Auto-Brightness";
								hudView.subtitle = enabled ? @"On" : @"Off";
								hudView.showsProgress = NO;
								[hudController presentHUDView:hudView autoDismissWithDelay:1.5];
							}
							break;
						}
			}
			};
		_volumeSlider.actionHandler = ^(UminoSlider *slider) {
			static float previousValue = 0;
			switch (blockSelf->_volumeSliderAction) {
				case 0: {
							if (slider.value != 0) {
								previousValue = slider.value;
								slider.value = 0;
								[blockSelf volumeSliderDidChange:slider];
							} else {
								slider.value = previousValue;	
								[blockSelf volumeSliderDidChange:slider];
							}
							break;
						}
				case 1: {
							if (slider.value != 1) {
								previousValue = slider.value;
								slider.value = 1;
								[blockSelf volumeSliderDidChange:slider];
							} else {
								slider.value = previousValue;	
								[blockSelf volumeSliderDidChange:slider];
							}
							break;
						}
				case 2: {
							slider.type = slider.type + 1;
							float volume = 0;
							switch (slider.type) {
								case 0:
									[blockSelf->_avController getVolume:&volume forCategory:@"Audio/Video"];
									break;
								case 1:
									if (blockSelf->_mediaController.ringerMuted) {
										volume = 0.0;
									} else {
										[blockSelf->_avController getVolume:&volume forCategory:@"Ringtone"];
									}
									break;
							}
							slider.value = volume;
							break;
						}
			}
			};
    	[_trackInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(trackInfoViewActionGesture:)]];
        [_trackInfoView addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(trackInfoViewActionGesture:)]];
	    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecognized:)];
	    gestureRecognizer.delegate = self;
	    [gestureRecognizer _setCanPanHorizontally:NO];
	    [gestureRecognizer _setCanPanVertically:YES];
        [self addGestureRecognizer:gestureRecognizer];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    _backgroundView.frame = bounds;
    _tintView.frame = bounds;
    bounds.size.height /= 2.0;
	if (UminoIsMinimalStyle(NO) && reachabilityMode) {
		bounds.size.height += 73;
	}
    _contentView.frame = bounds;
    if (UminoIsPortrait(NO)) {
		if (reachabilityMode) {
			[_contentView addSubview:_centerButton];
			[_contentView addSubview:_leftButton];
			[_contentView addSubview:_rightButton];
			[_contentView addSubview:_brightnessSlider];
			[_contentView addSubview:_volumeSlider];
			[_scrollView addSubview:_trackInfoView];
			[_scrollView addSubview:_trackProgressView];
			[_scrollView addSubview:_quickLaunchController.view];
			[_contentView bringSubviewToFront:_brightnessSlider];
			[_contentView bringSubviewToFront:_volumeSlider];
			CGFloat centerX = bounds.size.width / 2.0;
			CGFloat scrollViewHeight = bounds.size.height - 73.0 - 86.0;
			_effectView.frame = CGRectMake(0.0, 73.0, bounds.size.width, 86.0);
			_scrollView.frame = CGRectMake(0.0, 73.0 + 86.0, bounds.size.width, scrollViewHeight);
			_scrollView.contentSize = CGSizeMake(bounds.size.width, scrollViewHeight * 2.0);
			_scrollView.hidden = NO;
			_centerButton.layer.position = CGPointMake(centerX, 43.0 + 73.0);
			_leftButton.layer.position = CGPointMake(centerX - ((iphone6 || iphone6plus) ? 62.5 : 53.5), 43.0 + 73.0);
			_rightButton.layer.position = CGPointMake(centerX + ((iphone6 || iphone6plus) ? 62.5 : 53.5), 43.0 + 73.0);
			_brightnessSlider.layer.bounds = CGRectMake(0.0, 0.0, 88.0, 90.0);
			_brightnessSlider.layer.position = CGPointMake(centerX - ((iphone6 || iphone6plus) ? 138.0 : 116.0), 43.0 + 73.0);
			_volumeSlider.layer.bounds = CGRectMake(0.0, 0.0, 88.0, 90.0);
			_volumeSlider.layer.position = CGPointMake(centerX + ((iphone6 || iphone6plus) ? 138.0 : 116.0), 43.0 + 73.0);
			_trackInfoView.layer.position = CGPointMake(centerX, 27.0);
			_trackProgressView.layer.position = CGPointMake(centerX, 53.0);
			_quickLaunchController.view.bounds = CGRectMake(0.0, 0.0, bounds.size.width, 45.0);
			_quickLaunchController.view.center = CGPointMake(centerX, scrollViewHeight + 24.5 + 2.5 + 11.0);
			UIScrollView *topScrollView = CHIvar(controlCenterTopView, _scrollView, UIScrollView * const);
			[_contentView addSubview:_effectView];
			[_contentView addSubview:topScrollView];
			[_contentView sendSubviewToBack:topScrollView];
			[_contentView sendSubviewToBack:_effectView];
		} else {
			if (UminoIsMinimalStyle(NO)) {
				[_effectView removeFromSuperview];
				[_scrollView addSubview:_centerButton];
				[_scrollView addSubview:_leftButton];
				[_scrollView addSubview:_rightButton];
				[_scrollView addSubview:_brightnessSlider];
				[_scrollView addSubview:_volumeSlider];
				[_scrollView addSubview:_trackInfoView];
				[_scrollView addSubview:_trackProgressView];
				[_scrollView addSubview:_quickLaunchController.view];
				[_scrollView bringSubviewToFront:_brightnessSlider];
				[_scrollView bringSubviewToFront:_volumeSlider];
				CGFloat centerX = bounds.size.width / 2.0;
				CGFloat scrollViewHeight = bounds.size.height - 4.0;
				CGFloat buttonY = _nowPlayingController.currentNowPlayingInfo.count > 0 ? 38.0 : 46.0;
				_scrollView.frame = CGRectMake(0.0, 4.0, bounds.size.width, scrollViewHeight);
				_scrollView.contentSize = CGSizeMake(bounds.size.width, scrollViewHeight * 2.0);
				_scrollView.hidden = NO;
				_centerButton.layer.position = CGPointMake(centerX, buttonY);
				_leftButton.layer.position = CGPointMake(centerX - ((iphone6 || iphone6plus) ? 62.5 : 53.5), buttonY);
				_rightButton.layer.position = CGPointMake(centerX + ((iphone6 || iphone6plus) ? 62.5 : 53.5), buttonY);
				_brightnessSlider.layer.bounds = CGRectMake(0.0, 0.0, 88.0, 90.0);
				_brightnessSlider.layer.position = CGPointMake(centerX - ((iphone6 || iphone6plus) ? 138.0 : 116.0), buttonY);
				_volumeSlider.layer.bounds = CGRectMake(0.0, 0.0, 88.0, 90.0);
				_volumeSlider.layer.position = CGPointMake(centerX + ((iphone6 || iphone6plus) ? 138.0 : 116.0), buttonY);
				_trackInfoView.layer.position = CGPointMake(centerX, 89.0);
				_trackProgressView.layer.position = CGPointMake(centerX, scrollViewHeight + 19.0);
				_quickLaunchController.view.bounds = CGRectMake(0.0, 0.0, bounds.size.width, 45.0);
				_quickLaunchController.view.center = CGPointMake(centerX, scrollViewHeight + 61.5 + 2.5 + 11.0);
			} else {
				[_effectView removeFromSuperview];
				[_contentView addSubview:_centerButton];
				[_contentView addSubview:_leftButton];
				[_contentView addSubview:_rightButton];
				[_contentView addSubview:_brightnessSlider];
				[_contentView addSubview:_volumeSlider];
				[_scrollView addSubview:_trackInfoView];
				[_scrollView addSubview:_trackProgressView];
				[_scrollView addSubview:_quickLaunchController.view];
				[_contentView bringSubviewToFront:_brightnessSlider];
				[_contentView bringSubviewToFront:_volumeSlider];
				CGFloat centerX = bounds.size.width / 2.0;
				CGFloat scrollViewHeight = bounds.size.height - 81.0;
				_scrollView.frame = CGRectMake(0.0, 81.0, bounds.size.width, scrollViewHeight);
				_scrollView.contentSize = CGSizeMake(bounds.size.width, scrollViewHeight * 2.0);
				_scrollView.hidden = NO;
				_centerButton.layer.position = CGPointMake(centerX, 43.0);
				_leftButton.layer.position = CGPointMake(centerX - ((iphone6 || iphone6plus) ? 62.5 : 53.5), 43.0);
				_rightButton.layer.position = CGPointMake(centerX + ((iphone6 || iphone6plus) ? 62.5 : 53.5), 43.0);
				_brightnessSlider.layer.bounds = CGRectMake(0.0, 0.0, 88.0, 90.0);
				_brightnessSlider.layer.position = CGPointMake(centerX - ((iphone6 || iphone6plus) ? 138.0 : 116.0), 43.0);
				_volumeSlider.layer.bounds = CGRectMake(0.0, 0.0, 88.0, 90.0);
				_volumeSlider.layer.position = CGPointMake(centerX + ((iphone6 || iphone6plus) ? 138.0 : 116.0), 43.0);
				_trackInfoView.layer.position = CGPointMake(centerX, 15.0);
				_trackProgressView.layer.position = CGPointMake(centerX, 41.0);
				_quickLaunchController.view.bounds = CGRectMake(0.0, 0.0, bounds.size.width, 45.0);
				_quickLaunchController.view.center = CGPointMake(centerX, scrollViewHeight + 20.0 + 2.5 + 11.0);
			}
    	}
    } else {
    	[_contentView addSubview:_centerButton];
        [_contentView addSubview:_leftButton];
        [_contentView addSubview:_rightButton];
        [_contentView addSubview:_brightnessSlider];
        [_contentView addSubview:_volumeSlider];
        CGFloat centerX = bounds.size.width / 2.0;
        _scrollView.hidden = YES;
        _centerButton.layer.position = CGPointMake(centerX, 33.5);
        _leftButton.layer.position = CGPointMake(centerX - ((iphone6 || iphone6plus) ? 62.5 : 53.5), 33.5);
        _rightButton.layer.position = CGPointMake(centerX + ((iphone6 || iphone6plus) ? 62.5 : 53.5), 33.5);
        CGFloat sliderWidth = (bounds.size.width - 168.0) / 2.0;
        _brightnessSlider.layer.bounds = CGRectMake(0.0, 0.0, sliderWidth, 40.0);
        _brightnessSlider.layer.position = CGPointMake(centerX - (82.0 + sliderWidth / 2.0), 33.5);
        _volumeSlider.layer.bounds = CGRectMake(0.0, 0.0, sliderWidth, 40.0);
        _volumeSlider.layer.position = CGPointMake(centerX + (82.0 + sliderWidth / 2.0), 33.5);
    }
}

- (void)setHidden:(BOOL)hidden
{
	[_backgroundView setEffect:hidden ? nil : _backgroundEffect];
    if (self.hidden == hidden) {
        [super setHidden:hidden];    
    } else {
        [super setHidden:hidden];
        if (hidden) {
        	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setQuickLauncherShowing:) object:@NO];
            [[NSNotificationCenter defaultCenter]removeObserver:self];
            [_nowPlayingController stopUpdating];
            if (_brightnessTransaction != NULL) {
		        CFRelease(_brightnessTransaction);
		        _brightnessTransaction = NULL;
		    }
            if (!_showingHUD || !UminoIsPortrait(NO)) {
                [[NSClassFromString(@"VolumeControl") sharedVolumeControl]removeAlwaysHiddenCategory:@"Audio/Video"];
                [[NSClassFromString(@"VolumeControl") sharedVolumeControl]removeAlwaysHiddenCategory:@"Ringtone"];
            }
            [_quickLaunchController controlCenterDidDismiss];
            [_quickLaunchController controlCenterWillBeginTransition];
            [_quickLaunchController controlCenterDidFinishTransition];
            _scrollView.contentOffset = CGPointZero;
			[self scrollViewDidScroll:_scrollView];
        } else {
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(brightnessDidChange:) name:UIScreenBrightnessDidChangeNotification object:[UIScreen mainScreen]];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeDidChange:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(volumeDidChange:) name:@"SBRingerChangedNotification" object:nil];
            [_nowPlayingController startUpdating];
			_brightnessSlider.type = CFPreferencesGetAppBooleanValue(CFSTR("BKEnableALS"), CFSTR("com.apple.backboardd"), NULL) ? 0 : 1;
            [self brightnessDidChange:nil];
            [self volumeDidChange:nil];
            [_nowPlayingController update];
            if (!_showingHUD || !UminoIsPortrait(NO)) {
                [[NSClassFromString(@"VolumeControl") sharedVolumeControl]addAlwaysHiddenCategory:@"Audio/Video"];
                [[NSClassFromString(@"VolumeControl") sharedVolumeControl]addAlwaysHiddenCategory:@"Ringtone"];
            }
            [_quickLaunchController controlCenterWillBeginTransition];
            [_quickLaunchController controlCenterDidFinishTransition];
            [_quickLaunchController controlCenterWillPresent];
        }
    }   
}

- (void)playerButtonTouchDown:(UminoPlayerButton *)sender
{
    if (_playerButtonTapped) {
        if (!_playerButtonLongPressed) {
            _playerButtonLongPressed = YES;
            switch (sender.type) {
                case UminoPlayerButtonTypeMain:
                    break;
                case UminoPlayerButtonTypeRewind:
                    MRMediaRemoteSendCommand(kMRStartBackwardSeek, nil);
                    break;
                case UminoPlayerButtonTypeFastForward:
                    MRMediaRemoteSendCommand(kMRStartForwardSeek, nil);
                    break;
                case UminoPlayerButtonTypeRewindFifteenSeconds:
		    		break;
		    	case UminoPlayerButtonTypeFastForwardFifteenSeconds:
		    		break;
		    	case UminoPlayerButtonTypeFavorite:
		    		break;
            }   
        }
    } else {
        _playerButtonTapped = YES;
        [self performSelector:@selector(playerButtonTouchDown:) withObject:sender afterDelay:0.5];
    }
}

- (void)playerButtonTouchUpInside:(UminoPlayerButton *)sender
{
    if (_playerButtonTapped) {
        _playerButtonTapped = NO;
        if (_playerButtonLongPressed) {
            _playerButtonLongPressed = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleArtwork:) object:@((1 << 0) + 1)];    
            switch (sender.type) {
                case UminoPlayerButtonTypeMain:
                    if (!_nowPlayingController.isPlaying) {
                        [self performSelector:@selector(handleArtwork:) withObject:@((1 << 0) + 1) afterDelay:0.1];
                    }
                    MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
                    break;
                case UminoPlayerButtonTypeRewind:
                    MRMediaRemoteSendCommand(kMREndBackwardSeek, nil);
                    break;
                case UminoPlayerButtonTypeFastForward:
                    MRMediaRemoteSendCommand(kMREndForwardSeek, nil);
                    break;
                case UminoPlayerButtonTypeRewindFifteenSeconds:
					MRMediaRemoteSendCommand(kMRGoBackFifteenSeconds, @{(__bridge id)kMRMediaRemoteOptionSkipInterval: @(15.0)});
		    		break;
		    	case UminoPlayerButtonTypeFastForwardFifteenSeconds:
		    		MRMediaRemoteSendCommand(kMRSkipFifteenSeconds, @{(__bridge id)kMRMediaRemoteOptionSkipInterval: @(15.0)});
		    		break;
		    	case UminoPlayerButtonTypeFavorite: {
					MRMediaRemoteCopySupportedCommands(dispatch_get_main_queue(), ^(NSArray *commands){
						BOOL like = NO, ban = NO, bookmark = NO;
						BOOL liked = NO, banned = NO, bookmarked = NO;
						for (id command in commands) {
							if (MRMediaRemoteCommandInfoGetCommand(command) == kMRLikeTrack) {
								like = MRMediaRemoteCommandInfoGetEnabled(command);
								liked = CFBooleanGetValue(MRMediaRemoteCommandInfoCopyValueForKey(command, kMRMediaRemoteCommandInfoIsActiveKey));
							}
							if (MRMediaRemoteCommandInfoGetCommand(command) == kMRBanTrack) {
								ban = MRMediaRemoteCommandInfoGetEnabled(command);
								banned = CFBooleanGetValue(MRMediaRemoteCommandInfoCopyValueForKey(command, kMRMediaRemoteCommandInfoIsActiveKey));
							}
							if (MRMediaRemoteCommandInfoGetCommand(command) == kMRBookmarkTrack) {
								bookmark = MRMediaRemoteCommandInfoGetEnabled(command);
								bookmarked = CFBooleanGetValue(MRMediaRemoteCommandInfoCopyValueForKey(command, kMRMediaRemoteCommandInfoIsActiveKey));
							}
						}
						_trackActionsModalItem = [RUTrackActionsModalItem modalItemWithType:1 title:nil message:nil buttonTitles:nil completion:NULL];
						_nowPlayingInfoForPresentedTrackActions = _nowPlayingController.currentNowPlayingInfo;
						_trackActionsModalItem.trackActionsDelegate = self;
						_trackActionsModalItem.songText = _nowPlayingInfoForPresentedTrackActions[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
						_trackActionsModalItem.artistText = _nowPlayingInfoForPresentedTrackActions[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
						_trackActionsModalItem.artworkImage = _nowPlayingController.currentNowPlayingArtwork;
						NSInteger enabledActions = 0;
						if (like) enabledActions |= 1;
						if (ban) enabledActions |= 2;
						if (bookmark) enabledActions |= 4;
						_trackActionsModalItem.enabledActions = enabledActions;
						NSInteger onActions = 0;
						if (liked) onActions |= 1;
						if (banned) onActions |= 2;
						if (bookmarked) onActions |= 4;
						_trackActionsModalItem.onActions = onActions;
						_trackActionsModalItem.delegate = self;
						[CHIvar([NSClassFromString(@"SBUIController") sharedInstance], _switcherController, SBAppSwitcherController * const) presentModalItem:_trackActionsModalItem animated:YES];
					});
		    		break;
		    	}
            }
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerButtonTouchDown:) object:sender];    
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleArtwork:) object:@((1 << 0) + 1)];    
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleArtwork:) object:@((1 << 1) + 1)];    
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleArtwork:) object:@((1 << 2) + 1)];    
            switch (sender.type) {
                case UminoPlayerButtonTypeMain:
                    if (!_nowPlayingController.isPlaying) {
                        [self performSelector:@selector(handleArtwork:) withObject:@((1 << 0) + 1) afterDelay:0.1];
                    }
                    MRMediaRemoteSendCommand(kMRTogglePlayPause, nil);
                    break;
                case UminoPlayerButtonTypeRewind:
                	_isPreviousTrack = YES;
                    MRMediaRemoteSendCommand(kMRPreviousTrack, nil);
                    [self performSelector:@selector(handleArtwork:) withObject:@((1 << 2) + 1) afterDelay:1.6];
                    break;
                case UminoPlayerButtonTypeFastForward:
                	_isPreviousTrack = NO;
                    MRMediaRemoteSendCommand(kMRNextTrack, nil);
                    [self performSelector:@selector(handleArtwork:) withObject:@((1 << 1) + 1) afterDelay:1.6];
                    break;
                case UminoPlayerButtonTypeRewindFifteenSeconds:
                	MRMediaRemoteSendCommand(kMRGoBackFifteenSeconds, @{(__bridge id)kMRMediaRemoteOptionSkipInterval: @(15.0)});
		    		break;
		    	case UminoPlayerButtonTypeFastForwardFifteenSeconds:
		    		MRMediaRemoteSendCommand(kMRSkipFifteenSeconds, @{(__bridge id)kMRMediaRemoteOptionSkipInterval: @(15.0)});
		    		break;
		    	case UminoPlayerButtonTypeFavorite: {
					MRMediaRemoteCopySupportedCommands(dispatch_get_main_queue(), ^(NSArray *commands){
						BOOL like = NO, ban = NO, bookmark = NO;
						BOOL liked = NO, banned = NO, bookmarked = NO;
						for (id command in commands) {
							if (MRMediaRemoteCommandInfoGetCommand(command) == kMRLikeTrack) {
								like = MRMediaRemoteCommandInfoGetEnabled(command);
								liked = CFBooleanGetValue(MRMediaRemoteCommandInfoCopyValueForKey(command, kMRMediaRemoteCommandInfoIsActiveKey));
							}
							if (MRMediaRemoteCommandInfoGetCommand(command) == kMRBanTrack) {
								ban = MRMediaRemoteCommandInfoGetEnabled(command);
								banned = CFBooleanGetValue(MRMediaRemoteCommandInfoCopyValueForKey(command, kMRMediaRemoteCommandInfoIsActiveKey));
							}
							if (MRMediaRemoteCommandInfoGetCommand(command) == kMRBookmarkTrack) {
								bookmark = MRMediaRemoteCommandInfoGetEnabled(command);
								bookmarked = CFBooleanGetValue(MRMediaRemoteCommandInfoCopyValueForKey(command, kMRMediaRemoteCommandInfoIsActiveKey));
							}
						}
						_trackActionsModalItem = [RUTrackActionsModalItem modalItemWithType:1 title:nil message:nil buttonTitles:nil completion:NULL];
						_nowPlayingInfoForPresentedTrackActions = _nowPlayingController.currentNowPlayingInfo;
						_trackActionsModalItem.trackActionsDelegate = self;
						_trackActionsModalItem.songText = _nowPlayingInfoForPresentedTrackActions[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
						_trackActionsModalItem.artistText = _nowPlayingInfoForPresentedTrackActions[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
						_trackActionsModalItem.artworkImage = _nowPlayingController.currentNowPlayingArtwork;
						NSInteger enabledActions = 0;
						if (like) enabledActions |= 1;
						if (ban) enabledActions |= 2;
						if (bookmark) enabledActions |= 4;
						_trackActionsModalItem.enabledActions = enabledActions;
						NSInteger onActions = 0;
						if (liked) onActions |= 1;
						if (banned) onActions |= 2;
						if (bookmarked) onActions |= 4;
						_trackActionsModalItem.onActions = onActions;
						_trackActionsModalItem.delegate = self;
						[CHIvar([NSClassFromString(@"SBUIController") sharedInstance], _switcherController, SBAppSwitcherController * const) presentModalItem:_trackActionsModalItem animated:YES];
					});
		    	}
            }
        }
    }
}

- (void)playerButtonTouchUpOutside:(UminoPlayerButton *)sender
{
    if (_playerButtonTapped) {
        _playerButtonTapped = NO;
        if (_playerButtonLongPressed) {
            _playerButtonLongPressed = NO;
            switch (sender.type) {
                case UminoPlayerButtonTypeMain:
                    break;
                case UminoPlayerButtonTypeRewind:
                    MRMediaRemoteSendCommand(kMREndBackwardSeek, nil);
                    break;
                case UminoPlayerButtonTypeFastForward:
                    MRMediaRemoteSendCommand(kMREndForwardSeek, nil);
                    break;
                case UminoPlayerButtonTypeRewindFifteenSeconds:
		    		break;
		    	case UminoPlayerButtonTypeFastForwardFifteenSeconds:
		    		break;
		    	case UminoPlayerButtonTypeFavorite:
		    		break;
            }
        } else {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playerButtonTouchDown:) object:sender];    
        }
    }
}

- (void)brightnessSliderDidChange:(UminoSlider *)sender
{
	if (_brightnessTransaction == NULL) {
		_brightnessTransaction = BKSDisplayBrightnessTransactionCreate(kCFAllocatorDefault);
	}
    BKSDisplayBrightnessSet(_brightnessSlider.value, 1);
    if (!_brightnessSlider.sliding && _brightnessTransaction != NULL) {
        CFRelease(_brightnessTransaction);
        _brightnessTransaction = NULL;
    }
    if (_showingHUD && UminoIsPortrait(NO)) {
        SBHUDController *hudController = [NSClassFromString(@"SBHUDController") sharedHUDController];
        SBHUDView *hudView = hudController.visibleHUDView;
        if (![hudView isKindOfClass:NSClassFromString(@"UminoBrightnessHUDView")]) {
            hudView = [[NSClassFromString(@"UminoBrightnessHUDView") alloc]init];
        }
		hudView.title = localizedString(@"BRIGHTNESS");
        hudView.progress = _brightnessSlider.value;
        [hudController presentHUDView:hudView autoDismissWithDelay:1.5];
    }
}

- (void)volumeSliderDidChange:(UminoSlider *)sender
{
	switch (sender.type) {
		case 0:
			[_avController setVolumeTo:sender.value forCategory:@"Audio/Video"];
			break;
		case 1:
			if (sender.value == 0) {
				if (_mediaController.ringerMuted != YES) {
					_mediaController.ringerMuted = YES;
					if (UminoIsPortrait(NO)) {
						[NSClassFromString(@"SBRingerHUDController") activate:0];
					}
				}
			} else {
				if (_mediaController.ringerMuted != NO) {
					_mediaController.ringerMuted = NO;
					if (UminoIsPortrait(NO)) {
						[NSClassFromString(@"SBRingerHUDController") activate:1];
					}
				}
				[_avController setVolumeTo:sender.value forCategory:@"Ringtone"];
			}
			break;
	}
}

- (void)sliderDidStopTracking:(UminoSlider *)sender
{
	if (sender.panning) {
		SBHUDController *hudController = [NSClassFromString(@"SBHUDController") sharedHUDController];
		[hudController performSelector:@selector(hideHUDView) withObject:nil afterDelay:0.1];
	}
}

- (void)trackInfoViewActionGesture:(UIGestureRecognizer *)recognizer
{
	if ([recognizer isKindOfClass:UITapGestureRecognizer.class]) {
		if (recognizer.state == UIGestureRecognizerStateRecognized) {
			if (_nowPlayingController.currentNowPlayingInfo.count > 0) {
				[self handleArtwork:@(0)];
			}
		}
	} else if ([recognizer isKindOfClass:UILongPressGestureRecognizer.class]) {
		if (recognizer.state == UIGestureRecognizerStateBegan) {
			NSString *application = _nowPlayingController.nowPlayingAppDisplayID;
			if (application.length > 0) {
				[[UIApplication sharedApplication]launchApplicationWithIdentifier:application suspended:NO];
			}
		}
	}
}

- (void)gestureRecognized:(UIPanGestureRecognizer *)recognizer
{
	if (reachabilityMode) {
		if (recognizer.state == UIGestureRecognizerStateBegan) {
			MRMediaRemoteSendCommand(kMREndBackwardSeek, nil);
			MRMediaRemoteSendCommand(kMREndForwardSeek, nil);
		}
		_transitionHandler(recognizer);
	} else {
		_gestureHandler(recognizer);
	}
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	CGPoint location = [touch locationInView:self];
	if (reachabilityMode) {
		if (UminoIsPortrait(NO)) {
			UIView *testView = [self hitTest:location withEvent:nil];
			return testView == _contentView || [testView isKindOfClass:UminoPlayerButton.class];
		} else {
			return NO;
		}
	} else {
		if (UminoIsPortrait(NO) && UminoIsMinimalStyle(NO)) {
			return location.y <= 20;
		}
		if (location.x >= 98.0 && location.x <= (self.bounds.size.width - 98.0)) {
			return location.y <= 20;
		} else {
			return location.y <= 5;
		}
	}
}

- (void)handleArtwork:(NSNumber *)action
{
	_artworkHandler(_nowPlayingController.currentNowPlayingArtwork, action.integerValue);
	_isPreviousTrack = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (UminoIsPortrait(NO)) {
		CGFloat height = scrollView.bounds.size.height;
		CGFloat offset = scrollView.contentOffset.y;
		CGFloat progress = MIN(MAX(offset / height, 0.0), 1.0);
		CGFloat scale = 1.0 - 0.1 * progress;
		CGFloat translation = offset / scale;
		CGFloat alpha = MAX((1.0 - 2.0 * progress), 0.0);
		NSArray *views = UminoIsMinimalStyle(NO) && !reachabilityMode ? @[_centerButton, _leftButton, _rightButton, _brightnessSlider, _volumeSlider, _trackInfoView, _centerButton, _leftButton, _rightButton, _brightnessSlider, _volumeSlider] : @[_trackInfoView, _trackProgressView];
		for (UIView *view in views) {
			view.transform =  CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), 0.0, translation);
			view.alpha = alpha;
		}
	}
}

- (void)brightnessDidChange:(NSNotification *)notification
{
    if (!_brightnessSlider.isTracking) {
        _brightnessSlider.value = BKSDisplayBrightnessGetCurrent();    
    }
}

- (void)volumeDidChange:(NSNotification *)notification
{
	//notification.userInfo
	//AVSystemController_AudioCategoryNotificationParameter
	//AVSystemController_AudioVolumeNotificationParameter
	if (!_volumeSlider.isTracking) {
		float volume = 0;
		switch (_volumeSlider.type) {
			case 0:
				[_avController getVolume:&volume forCategory:@"Audio/Video"];
				break;
			case 1:
				if (_mediaController.ringerMuted) {
					volume = 0.0;
				} else {
					[_avController getVolume:&volume forCategory:@"Ringtone"];
				}
				break;
		}
		_volumeSlider.value = volume;
	}
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingInfoDidChange:(NSDictionary *)info
{
	MRMediaRemoteCopySupportedCommands(dispatch_get_main_queue(), ^(NSArray *commands){
		NSString *newTitle = info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle];
		BOOL seekBack = NO, seekForward = NO, skipBack = NO, skipForward = NO, nextTrack = NO;
		for (id command in commands) {
			if (MRMediaRemoteCommandInfoGetCommand(command) == kMRStartBackwardSeek) seekBack = MRMediaRemoteCommandInfoGetEnabled(command);
			if (MRMediaRemoteCommandInfoGetCommand(command) == kMRStartForwardSeek) seekForward = MRMediaRemoteCommandInfoGetEnabled(command);
			if (MRMediaRemoteCommandInfoGetCommand(command) == kMRGoBackFifteenSeconds) skipBack = MRMediaRemoteCommandInfoGetEnabled(command);
			if (MRMediaRemoteCommandInfoGetCommand(command) == kMRSkipFifteenSeconds) skipForward = MRMediaRemoteCommandInfoGetEnabled(command);
			if (MRMediaRemoteCommandInfoGetCommand(command) == kMRNextTrack) nextTrack = MRMediaRemoteCommandInfoGetEnabled(command);
		}
		if (!skipBack && !skipForward && ![_trackInfoView.title isEqualToString:newTitle]) {
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleArtwork:) object:@(+1)];
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleArtwork:) object:@(-1)];
			[self performSelector:@selector(handleArtwork:) withObject:@(_isPreviousTrack ? -1 : +1) afterDelay:1.0];
		}
		_trackInfoView.title = newTitle;
		_trackInfoView.artist = info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoArtist];
		_trackInfoView.album = info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoAlbum];
		_trackProgressView.currentTime = [info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime]doubleValue];
		_trackProgressView.totalDuration = [info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDuration]doubleValue];
		_trackProgressView.scrubbingEnabled = seekBack && seekForward;
		_leftButton.type = skipBack ? UminoPlayerButtonTypeRewindFifteenSeconds : UminoPlayerButtonTypeRewind;
		_rightButton.type = skipForward ? UminoPlayerButtonTypeFastForwardFifteenSeconds : UminoPlayerButtonTypeFastForward;
		_leftButton.enabled = YES;
		_rightButton.enabled = YES;
		NSNumber *radioStationIdentifier = info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRadioStationIdentifier];
		if (radioStationIdentifier != nil) {
			_leftButton.type = UminoPlayerButtonTypeFavorite;
			_rightButton.enabled = nextTrack;
		}
		[UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:1.0 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			[self layoutSubviews];
		} completion:NULL];
	});
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller playbackStateDidChange:(BOOL)playing
{
    _centerButton.selected = playing;
	_transitionHandler(@(playing));
}

- (void)nowPlayingController:(MPUNowPlayingController *)controller elapsedTimeDidChange:(NSTimeInterval)elapsed
{
    _trackProgressView.currentTime = elapsed;
}

- (void)progressView:(MPUChronologicalProgressView *)progressView didScrubToCurrentTime:(NSTimeInterval)time
{
    MRMediaRemoteSetElapsedTime(time);
}

- (void)noteSectionEnabledStateDidChange:(SBControlCenterSectionViewController *)section
{
    [self setNeedsLayout];
}

- (void)sectionWantsControlCenterDismissal:(SBControlCenterSectionViewController *)section
{
    [(SBUIController *)[NSClassFromString(@"SBUIController") sharedInstance]dismissSwitcherAnimated:YES];
}

- (void)section:(SBControlCenterSectionViewController *)section updateStatusText:(NSString *)text reason:(NSString *)reason
{
}

- (void)section:(SBControlCenterSectionViewController *)section publishStatusUpdate:(SBControlCenterStatusUpdate *)update
{
}

- (void)trackActioningObject:(id<RUTrackActioning>)trackActioningObject didSelectAction:(NSInteger)action atIndex:(NSInteger)index
{
	NSDictionary *trackActioningInfo = @{(__bridge NSString *)kMRMediaRemoteOptionTrackID: _nowPlayingInfoForPresentedTrackActions[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoUniqueIdentifier] ? : @(0),
										 (__bridge NSString *)kMRMediaRemoteOptionStationID: _nowPlayingInfoForPresentedTrackActions[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRadioStationIdentifier] ? : @(0),
										 (__bridge NSString *)kMRMediaRemoteOptionStationHash: _nowPlayingInfoForPresentedTrackActions[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoRadioStationHash] ? : [NSNull null],
										 (__bridge NSString *)kMRMediaRemoteOptionIsNegative: @((_trackActionsModalItem.onActions & action) != 0)
										};
	switch (action) {
		case 1:
			MRMediaRemoteSendCommand(kMRLikeTrack, trackActioningInfo);
			break;
		case 2:
			MRMediaRemoteSendCommand(kMRBanTrack, trackActioningInfo);
			break;
		case 4:
			MRMediaRemoteSendCommand(kMRBookmarkTrack, trackActioningInfo);	
			break;
	}
}

- (void)modalItem:(_UIModalItem *)modalItem didDismissWithButtonIndex:(NSInteger)index
{
	_trackActionsModalItem = nil;
	_nowPlayingInfoForPresentedTrackActions = nil;
}

- (void)tapPlayerButton:(UminoPlayerButtonType)buttonType
{
	UminoPlayerButton *button = nil;
	if (_centerButton.type == buttonType) {
		button = _centerButton;
	} else if (_leftButton.type == buttonType) {
		button = _leftButton;
	} else if (_rightButton.type == buttonType) {
		button = _rightButton;
	}
	if (button != nil) {
		[button sendActionsForControlEvents:UIControlEventTouchDown];
		[button sendActionsForControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)setQuickLauncherShowing:(NSNumber *)showing
{
	if (UminoIsPortrait(NO)) {
		if (showing.boolValue) {
			[_scrollView setContentOffset:CGPointMake(0.0, _scrollView.bounds.size.height) animated:NO];
		} else {
			[_scrollView setContentOffset:CGPointZero animated:YES];
		}
	}
}

- (void)updateSliderActions:(NSInteger)brightness :(NSInteger)volume
{
	_brightnessSliderAction = brightness;
	_volumeSliderAction = volume;
	if (volume != 2) {
		_volumeSlider.type = 0;
	}
}

- (void)setShowingHUD:(BOOL)hud
{
	_showingHUD = hud;
}

- (void)dismissQuickLauncherAfterDelay:(NSTimeInterval)delay
{
	if (UminoIsPortrait(NO)) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setQuickLauncherShowing:) object:@NO];    
		[self performSelector:@selector(setQuickLauncherShowing:) withObject:@NO afterDelay:delay];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	if (UminoIsPortrait(NO)) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setQuickLauncherShowing:) object:@NO];
	}
}

@end
