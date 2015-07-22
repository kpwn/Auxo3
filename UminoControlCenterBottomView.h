#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UminoPlayerButtonType) {
	UminoPlayerButtonTypeMain,
	UminoPlayerButtonTypeRewind,
	UminoPlayerButtonTypeFastForward,
	UminoPlayerButtonTypeRewindFifteenSeconds,
	UminoPlayerButtonTypeFastForwardFifteenSeconds,
	UminoPlayerButtonTypeFavorite
};

__attribute__((visibility("hidden")))
@interface UminoControlCenterBottomView : UIView

@property (copy) void (^gestureHandler)(UIPanGestureRecognizer *);
@property (copy) void (^transitionHandler)(id);
@property (copy) void (^artworkHandler)(UIImage *, NSInteger);

- (void)tapPlayerButton:(UminoPlayerButtonType)buttonType;
- (void)setQuickLauncherShowing:(NSNumber *)showing;
- (void)dismissQuickLauncherAfterDelay:(NSTimeInterval)delay;
- (void)updateSliderActions:(NSInteger)brightness :(NSInteger)volume;
- (void)setShowingHUD:(BOOL)hud;

@end
