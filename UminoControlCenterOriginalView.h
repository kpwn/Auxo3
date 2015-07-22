#import <UIKit/UIKit.h>

@class _MPUSystemMediaControlsView;

__attribute__((visibility("hidden")))
@interface UminoControlCenterOriginalView : UIView

@property (copy) void (^gestureHandler)(UIPanGestureRecognizer *);

- (_MPUSystemMediaControlsView *)mediaControlsView;

@end
