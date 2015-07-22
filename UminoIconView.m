#import "UminoIconView.h"
#import "UminoIconListView.h"
#import "Headers.h"

@implementation UminoIconView {
	//UIImageView *_alternativeImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.contentMode = UIViewContentModeScaleAspectFit;
		/*
		_alternativeImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    	_alternativeImageView.contentMode = UIViewContentModeScaleAspectFit;
    	_alternativeImageView.alpha = 0;
    	_alternativeImageView.layer.masksToBounds = NO;
    	_alternativeImageView.layer.shadowOpacity = 0.2;
		_alternativeImageView.layer.shadowRadius = 6.0;
		_alternativeImageView.layer.shadowOffset = CGSizeZero;
        _alternativeImageView.layer.shadowColor = [UIColor blackColor].CGColor;
        _alternativeImageView.layer.shouldRasterize = YES;
        _alternativeImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    	[self addSubview:_alternativeImageView];
		*/
    }
    return self;
}

/*
- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	_alternativeImageView.frame = self.bounds;
	CGFloat width = frame.size.width;
	if (width >= kIconMaxSize) {
		_alternativeImageView.alpha = 0;
	} else if (width <= kIconMinSize) {
		_alternativeImageView.alpha = 1;
	} else {
		_alternativeImageView.alpha = (kIconMaxSize - width) / (kIconMaxSize - kIconMinSize);
	}
}
*/

- (void)loadIcon:(NSString *)identifier
{
	if (self.image != nil) {
		return;
	}
	UIImage * __block largeImage/*, *smallImage*/;
	if ([identifier isEqualToString:@"com.apple.mobilecal"] || [identifier isEqualToString:@"com.apple.mobiletimer"]) {
		void (^block)() = ^{
			SBIcon *icon = [((SBIconController *)[NSClassFromString(@"SBIconController")sharedInstance]).model applicationIconForBundleIdentifier:identifier];
			SBIconView *view = [[NSClassFromString(@"SBIconView")alloc]initWithDefaultSize];
			view.icon = icon;
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(kIconMaxSize, kIconMaxSize), NO, [UIScreen mainScreen].scale);
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGContextTranslateCTM(context, 1, 1);
			[view.layer renderInContext:context];
			largeImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
		};
		//smallImage = [UIImage _applicationIconImageForBundleIdentifier:identifier format:phone ? 0 : 1 scale:[UIScreen mainScreen].scale];
		if ([NSThread isMainThread]) {
			block();
		} else {
			dispatch_semaphore_t sema = dispatch_semaphore_create(0);
			dispatch_async(dispatch_get_main_queue(), ^{
				block();
				dispatch_semaphore_signal(sema);
				});
			dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
		}
	} else if ([identifier isEqualToString:@"com.apple.springboard"]) {
		largeImage = imageResource(@"Home");
		//smallImage = imageResource(@"HomeSmall");
	} else {
		static NSCache *cache;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			cache = [[NSCache alloc]init];
			cache.countLimit = 32;
		});
		largeImage = [cache objectForKey:identifier];
		if (largeImage == nil) {
			largeImage = [UIImage _applicationIconImageForBundleIdentifier:identifier format:2 scale:[UIScreen mainScreen].scale];
			[cache setObject:largeImage forKey:identifier];
		}
        //smallImage = [UIImage _applicationIconImageForBundleIdentifier:identifier format:phone ? 0 : 1 scale:[UIScreen mainScreen].scale];
	}
	[self performSelectorOnMainThread:@selector(setImage:) withObject:largeImage waitUntilDone:NO];
	//[_alternativeImageView performSelectorOnMainThread:@selector(setImage:) withObject:smallImage waitUntilDone:NO];
}
@end
