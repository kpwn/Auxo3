#import <UIKit/UIKit.h>
#import "Headers.h"

#define kIconMinSize (phone ? 29.0 : 40.0)
#define kIconMaxSize (phone ? 62.0 : 78.0)
#define kViewMargin (13.5 + 0.5 * iphone6 + 1.0 * iphone6plus)
#define kIconSpacing (17.0 + 1.0 * iphone6 + 0.0 * iphone6plus)
#define kIconSpacingOffset 19.5
#define kIconMinY (kIconMaxSize + 20.0)
#define kIconMaxY 131.0
#define kIconXPositioningArgument 20.0
#define kIconYPositioningArgument 80.0
#define kIconSizingArgument 50.0
#define kHighlightWidth (kIconMaxSize + 12.0 + 2.0 * (iphone6 || iphone6plus))
#define kHighlightHeight 400.0
#define kScrollingAnimationDuration 0.2

CHInline static NSUInteger recommendedIconCount()
{
    NSUInteger count = ceil((screenWidth() - (kViewMargin * 2 + kIconSpacing)) / (kIconMinSize + kIconSpacing));
    return count;
}

@class SBAppSwitcherIconController;

__attribute__((visibility("hidden")))
@interface UminoIconListView : UIScrollView

- (id)initWithFrame:(CGRect)frame handler:(void (^)(CGFloat, NSInteger, NSTimeInterval))handler;
- (NSString *)iconAtIndex:(NSInteger)index;
- (void)setIcons:(NSArray *)icons;
- (void)layout;
- (void)alternateLayout:(SBAppSwitcherIconController *)iconController;
- (void)setUnlimitedIconCount:(BOOL)unlimited;
- (void)setOpenToLast:(BOOL)last;
- (void)setAtHomeScreen:(BOOL)homeScreen;
- (void)setTouchLocation:(CGPoint)location;
- (void)normalizeTouchLocation;
- (void)cancelTouch;
- (void)setHighlightIndex:(NSInteger)index;
- (void)transitIn:(SBAppSwitcherIconController *)iconController animated:(BOOL)animated;
- (void)transitOut:(SBAppSwitcherIconController *)iconController animated:(BOOL)animated;

@end
