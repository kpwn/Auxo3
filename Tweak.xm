#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CaptainHook.h>
#import <substrate.h>
#import "Headers.h"
#import "UminoIconListView.h"
#import "UminoIconHighlightView.h"
#import "UminoIconView.h"
#import "License.h"

typedef NS_ENUM(NSInteger, CornerBehavior) {
    ControlCenter = 0,
                  QuickSwitcher = 1,
                  AppSwitcher = 2,
                  Auxo = 3,
                  HomeScreen = 4,
				  LockScreen = 5
};

typedef NS_ENUM(NSInteger, LicenseStatus) {
    Undetermined = 0,
                 Valid = 1,
                 Invalid = 2
};

__attribute__((visibility("hidden"))) BOOL phone;
__attribute__((visibility("hidden"))) BOOL widescreen;
__attribute__((visibility("hidden"))) BOOL iphone6;
__attribute__((visibility("hidden"))) BOOL iphone6plus;
__attribute__((visibility("hidden"))) BOOL reachabilityMode;
__attribute__((visibility("hidden"))) UminoControlCenterTopView *controlCenterTopView;
__attribute__((visibility("hidden"))) UminoControlCenterBottomView *controlCenterBottomView;
__attribute__((visibility("hidden"))) UminoControlCenterOriginalView *controlCenterOriginalView;

static SBWorkspace *workspace;
static SBUIController *uiController;
static SBAppSwitcherController *switcherController;
static SBAppSwitcherPageViewController *pageController;
static SBAppSwitcherIconController *iconController;
static SBFAnimationFactory *animationFactory;
static UIView *contentView;
static UIView *pageView;
static UIView *iconView;
static UIView *peopleView;
static SBNotificationCenterController *notificationCenterController;
static SBControlCenterController *controlCenterController;
static SBBacklightController *backlightController;
static SBLockScreenManager *lockscreenManager;
static SBOffscreenSwipeGestureRecognizer *activeGestureRecognizer;
static UminoIconListView *iconListView;
static UminoAppSwitcherIconView *homeScreenIconView;
static UIView *dimView;
static UIWindow *dimWindow;
static UIImageView *artworkView;
static UIImageView *zoomedArtworkView;
static UminoCloseAllAppsGestureView *closeAllAppsGestureView;
static UIView *homeScreenGestureView;

static CornerBehavior umino;
static BOOL noScale;
static BOOL noPageScroll;
static BOOL noIconScroll;
static BOOL ignoreGesture;
static BOOL needDismissal;
static BOOL xTranslationFix;
static BOOL hangingFix;
static BOOL slidingDismiss;
static BOOL continuePresentation;
static BOOL forceAnimation;
static BOOL suppressAnimation;
static BOOL noXTranslation;
static BOOL keepAllItems;
static BOOL noSendBackOnce;
static NSInteger noSendBack;
static CGPoint touchLocation;
static CGSize pageExpectedSize;
static CGPoint iconExpectedPosition;
static NSInteger currentIndex;
static NSInteger startingIndex;
static BOOL reachabilityTransition;
static BOOL quickLaunchAutoDismissed;
static BOOL quickLaunchWorkaround;
static BOOL flipcontrolcenterWorkaround;
static BOOL gridSwitcherWorkaround;

static CornerBehavior leftBehavior;
static CornerBehavior rightBehavior;
static CornerBehavior centerBehavior;
static BOOL minimalStyleEnabled;
static NSInteger minimalStyleCondition;
static BOOL openToLastApp;
static BOOL openToLastAppWithQS;
static NSInteger quickLaunchOptionWithoutMediaPlaying;
static NSInteger quickLaunchOptionWithMediaPlaying;
static NSTimeInterval quickLaunchAutoDismissDelay;
static NSInteger sliderActionsBrightness;
static NSInteger sliderActionsVolume;
static BOOL sliderActionsDisableHUD;
static NSInteger albumArtworkAutoDisplay;
static NSTimeInterval albumArtworkAutoDismissDelay;
static BOOL closeAllAppsNoConfirmation;
static BOOL closeAllAppsBackToHomeScreen;
static BOOL closeAllAppsExcludeNowPlaying;
static NSDictionary *closeAllAppsExceptions;
static BOOL unlimitedQuickSwitcher;
static BOOL accessHomeScreen;
static BOOL accessAppSwitcher;
static BOOL invertHotCorners;
static BOOL peopleInTodayHeader;
static BOOL disableHomeDoubleClick;
static NSInteger sensitivity;
static BOOL disableWithKeyboard;
static NSDictionary *exceptions;

static LicenseStatus licenseStatus = Undetermined;
static NSUInteger usageCount = 0;

static void * const kAssociatedObjectKey = (void *)&kAssociatedObjectKey;

__attribute__((visibility("hidden"))) BOOL UminoIsPortrait(BOOL update)
{
    static UIInterfaceOrientation orientation;
    if (update) {
        orientation = ((SpringBoard *)[UIApplication sharedApplication])._frontMostAppOrientation;
    }
    return UIInterfaceOrientationIsPortrait(orientation);
}

__attribute__((visibility("hidden"))) BOOL UminoIsMinimalStyle(BOOL update)
{
    static BOOL minimal;
    if (update) {
        if (minimalStyleCondition == -1) {
            minimal = NO;
        } else if (minimalStyleCondition == 0) {
            minimal = YES;
        } else {
            minimal = YES;
            if (minimalStyleCondition & (1 << 0)) {
                minimal &= (((SBMediaController *)[NSClassFromString(@"SBMediaController") sharedInstance]).isPlaying == NO);
            }
            if (minimalStyleCondition & (1 << 1)) {
                minimal &= (![MPAudioVideoRoutingViewController hasWirelessDisplayRoutes]);
            }
            if (minimalStyleCondition & (1 << 2) && widescreen) {
                minimal &= (CHIvar(CHIvar(CHIvar(controlCenterTopView, _airStuffController, SBCCAirStuffSectionController * const), _airDropDiscoveryController, SFAirDropDiscoveryController * const), _discoverableMode, SFAirDropDiscoverableMode) == SFAirDropDiscoverableModeOff);
            }
        }
		reachabilityTransition = !minimal;
    }
	if (minimalStyleEnabled && reachabilityMode) {
		return !reachabilityTransition;
	} else {
		return minimal;
	}
}

CHInline static SBApplication *frontMostApplication()
{
    return ((SpringBoard *)[UIApplication sharedApplication])._accessibilityFrontMostApplication;
}

CHInline static BOOL isAtHomeScreen()
{
    SBApplication *app = frontMostApplication();
    return (app == nil);
}

CHInline static BOOL isAppSwitcherShowing()
{
    return [uiController isAppSwitcherShowing];
}

CHInline static BOOL isMediaPlaying()
{
    return ((SBMediaController *)[NSClassFromString(@"SBMediaController") sharedInstance]).isPlaying;
}

CHInline static BOOL isPeopleViewDisabled()
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return ([defaults boolForKey:@"SBAppSwitcherContactsFavoritesDisabled"] && [defaults boolForKey:@"SBAppSwitcherContactsRecentsDisabled"]);
}

CHInline static BOOL disabledInCurrentApp()
{
    if (disableWithKeyboard && [UIKeyboard isOnScreen]) {
        return YES;
    }
    SBApplication *app = frontMostApplication();
    if (app) {
        NSString *identifier = app.bundleIdentifier;
        return [exceptions[identifier]boolValue];
    } else {
        return NO;
    }
}

CHInline static CGFloat cornerWidth()
{
	return (iphone6 || iphone6plus) ? 100.0 : 80.0;
}

CHInline static CGFloat minScale()
{
    return 1.0;
}

CHInline static CGFloat maxScale()
{
    return switcherController._scaleForFullscreenPageView;
}

CHInline static CGFloat preferedScale()
{
    return maxScale() * 0.815;
}

CHInline static CGFloat transitionScale()
{
    return maxScale() * (phone ? (widescreen ? 0.6 : 0.5) : 0.7);
}

CHInline static CGFloat currentScale(BOOL bounded = YES)
{
    CGFloat y = touchLocation.y;
    CGFloat minY = switcherController._nominalPageViewFrame.origin.y + switcherController._nominalPageViewFrame.size.height;
    CGFloat deltaY = screenHeight() - minY;
    CGFloat minS = minScale();
    CGFloat maxS = maxScale();
    CGFloat deltaScale = maxS - minS;
    CGFloat currentScale = (y - minY) / deltaY * deltaScale + minS;
	if (bounded) {
		currentScale = MIN(MAX(currentScale, minS), maxS);
	}
    return currentScale;
}

CHInline static CGFloat pageOffset()
{
    if (iphone6) return UminoIsPortrait(NO) ? 62.0 : 35.0;
    if (iphone6plus) return UminoIsPortrait(NO) ? 68.0 : 38.0;
    return phone ? (UminoIsPortrait(NO) ? (widescreen ? 53.0 : 45.0) : 18.0) : (UminoIsPortrait(NO) ? 95.0 : 71.0);
}

CHInline static CGFloat itemOffset()
{
    CGFloat y = touchLocation.y;
    CGFloat minY = switcherController._nominalPageViewFrame.origin.y + switcherController._nominalPageViewFrame.size.height;
    CGFloat itemOffset = MAX(minY - y, 0.0);
    return itemOffset;
}

CHInline static NSArray *displayLayouts(BOOL includingContinuity)
{
    NSMutableArray *layouts = CHIvar(pageController, _displayLayouts, NSMutableArray * const).mutableCopy;
	if (!includingContinuity) {
		[layouts filterUsingPredicate:[NSPredicate predicateWithBlock:^(SBDisplayLayout *layout, NSDictionary *bindings){
			SBDisplayItem *item = layout.displayItems.firstObject;
			return [item.type isEqualToString:@"ContinuityApp"] ? NO : YES;
		}]];
	}
	return layouts;
}

CHInline static NSArray *applicationList()
{
    NSArray *layouts = displayLayouts(NO);
    NSMutableArray *list = [NSMutableArray array];
    for (SBDisplayLayout *layout in layouts) {
        SBDisplayItem *item = layout.displayItems.firstObject;
        [list addObject:item.displayIdentifier];
    }
    return list;
}

CHInline static NSArray *sliderItems(BOOL includingContinuity)
{
    NSArray *layouts = displayLayouts(includingContinuity);
    NSDictionary *items = CHIvar(pageController, _items, NSMutableDictionary * const);
    NSMutableArray *realItems = [NSMutableArray array];
    for (SBDisplayLayout *layout in layouts) {
        [realItems addObject:items[layout]];
    }
    return realItems;
}

CHInline static SBAppSwitcherItemScrollView *sliderItem(NSInteger index, BOOL includingContinuity)
{
    NSArray *layouts = displayLayouts(includingContinuity);
    NSDictionary *items = CHIvar(pageController, _items, NSMutableDictionary * const);
    return (index >= 0 && index < items.count) ? items[layouts[index]] : nil;
}

CHInline static NSUInteger sliderContinuityCount()
{
	return [displayLayouts(YES) filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(SBDisplayLayout *layout, NSDictionary *bindings){
        SBDisplayItem *item = layout.displayItems.firstObject;
		return [item.type isEqualToString:@"ContinuityApp"];
	}]].count;
}

CHInline static SBWallpaperEffectView *sliderItemWallpaperEffectView()
{
    UIView<SBAppSwitcherPageContentView> *itemView = sliderItem(0, NO).item.view;
    SBWallpaperEffectView *view = [itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherHomePageCellView")] ? CHIvar(itemView, _wallpaperView, SBWallpaperEffectView * const) : nil;
    return view;
}

CHInline static CGFloat iconListHeight()
{
    return 142.0;
}

#define auxoReachabilityHeightMin 159.0
#define auxoReachabilityHeightMax 232.0
#define _auxoReachabilityPageOffsetMin1 133.8
#define _auxoReachabilityPageOffsetMin2 133.8
#define _auxoReachabilityPageOffsetMin3 133.8
#define _auxoReachabilityPageOffsetMax1 179.8
#define _auxoReachabilityPageOffsetMax2 179.8
#define _auxoReachabilityPageOffsetMax3 139.8
#define _auxoReachabilityIconOffsetMin1 172.0
#define _auxoReachabilityIconOffsetMin2 172.0
#define _auxoReachabilityIconOffsetMin3 132.0
#define _auxoReachabilityIconOffsetMax1 213.5
#define _auxoReachabilityIconOffsetMax2 213.5
#define _auxoReachabilityIconOffsetMax3 193.5
#define auxoReachabilityPageOffsetMin (iphone6 ? _auxoReachabilityPageOffsetMin1 : iphone6plus ? _auxoReachabilityPageOffsetMin2 : _auxoReachabilityPageOffsetMin3)
#define auxoReachabilityPageOffsetMax (iphone6 ? _auxoReachabilityPageOffsetMax1 : iphone6plus ? _auxoReachabilityPageOffsetMax2 : _auxoReachabilityPageOffsetMax3)
#define auxoReachabilityIconOffsetMin (iphone6 ? _auxoReachabilityIconOffsetMin1 : iphone6plus ? _auxoReachabilityIconOffsetMin2 : _auxoReachabilityIconOffsetMin3)
#define auxoReachabilityIconOffsetMax (iphone6 ? _auxoReachabilityIconOffsetMax1 : iphone6plus ? _auxoReachabilityIconOffsetMax2 : _auxoReachabilityIconOffsetMax3)

CHInline static CGFloat auxoTopHeight()
{
	if (UminoIsPortrait(NO) && reachabilityMode) return 0.0;
    return phone ? (UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? 71.0 : 106.0) : 67.0) : 0.0;
}

CHInline static CGFloat auxoBottomHeight()
{
	if (UminoIsPortrait(NO) && reachabilityMode) return UminoIsMinimalStyle(NO) ? auxoReachabilityHeightMin : auxoReachabilityHeightMax;
    return phone ? (UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? 106.5 : 142.0) : 67.0) : 184.0;
}

CHInline static CGFloat auxoPageScale()
{
	if (gridSwitcherWorkaround) return 1.0;
    if (iphone6) return UminoIsPortrait(NO) ? ((UminoIsMinimalStyle(NO) || reachabilityMode) ? 342.0 / 374.0 : 300.0 / 374.0) : 109.0 / 152.0;
    if (iphone6plus) return UminoIsPortrait(NO) ? ((UminoIsMinimalStyle(NO) || reachabilityMode) ? 590.0 / 620.0 : 550.0 / 620.0) : 109.0 / 152.0;
	if (widescreen && reachabilityMode && UminoIsPortrait(NO)) return 1.0;
    return phone ? (UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? (widescreen ? 1.0 : 182.0 / 228.0) : 199.0 / 270.0) : 109.0 / 152.0) : 1.0;
}

CHInline static CGFloat auxoPageOffset()
{
	if (iphone6) return UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? (reachabilityMode ? _auxoReachabilityPageOffsetMin1 : 64.0) : (reachabilityMode ? _auxoReachabilityPageOffsetMax1 : 94.0)) : 45.0;
	if (iphone6plus) return UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? (reachabilityMode ? _auxoReachabilityPageOffsetMin2 : 64.0) : (reachabilityMode ? _auxoReachabilityPageOffsetMax2 : 84.0)) : 65.0;
	if (widescreen && reachabilityMode && UminoIsPortrait(NO)) return UminoIsMinimalStyle(NO) ? _auxoReachabilityPageOffsetMin3 : _auxoReachabilityPageOffsetMax3;
    CGFloat offset = phone ? (UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? (widescreen ? 64.0 : 76.5) : 86.4) : 40.0) : (UminoIsPortrait(NO) ? 156.0 : 158.0);
	if (!phone && !isPeopleViewDisabled()) {
		offset -= (UminoIsPortrait(NO) ? 65 : 90);
	}
	return offset;
}

CHInline static CGFloat auxoIconOffset()
{
	if (iphone6) return UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? (reachabilityMode ? _auxoReachabilityIconOffsetMin1 : 96.0) : (reachabilityMode ? _auxoReachabilityIconOffsetMax1 : 133.0)) : 78.0;
	if (iphone6plus) return UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? (reachabilityMode ? _auxoReachabilityIconOffsetMin2 : 96.0) : (reachabilityMode ? _auxoReachabilityIconOffsetMax2 : 133.0)) : 78.0;
	if (widescreen && reachabilityMode && UminoIsPortrait(NO)) return UminoIsMinimalStyle(NO) ? _auxoReachabilityIconOffsetMin3 : _auxoReachabilityIconOffsetMax3;
    CGFloat offset = phone ? (UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? (widescreen ? 67.0 : 91.0) : 103.0) : 74.0) : (UminoIsPortrait(NO) ? 166.0 : 167.0);
	if (!phone && !isPeopleViewDisabled()) {
		offset -= (UminoIsPortrait(NO) ? 5 : 20);
	}
	return offset;
}

CHInline static CGFloat auxoIconScrollingRate()
{
    return phone ? (UminoIsPortrait(NO) ? 0.327 : 0.540) : (UminoIsPortrait(NO) ? 0.240 : 0.308);
}

CHInline static CGFloat auxoPadArtworkSize()
{
    return UminoIsPortrait(NO) ? 552.0 : 516.0;
}

CHInline static CGFloat closeAllAppsPageOffset()
{
	return phone ? (UminoIsPortrait(NO) ? (widescreen ? 255.0 : 215.0) : 135.0) : (UminoIsPortrait(NO) ? 375.0 : 255.0);
}

CHInline static CGFloat closeAllAppsIconOffset()
{
	return phone ? (UminoIsPortrait(NO) ? (UminoIsMinimalStyle(NO) ? (widescreen ? 133.5 : 93.5) : 94.5) : 32.0) : (UminoIsPortrait(NO) ? 220.5 : 108.5);
}

CHInline static CGFloat closeAllAppsPageSpacing()
{
    return phone ? 10.0 : 40.0;
}

CHInline static double currentProgress()
{
	CGFloat maxPosition = auxoBottomHeight() * (phone ? (widescreen ? (UminoIsMinimalStyle(NO) ? (reachabilityMode ? 2.0 : 2.5) : (reachabilityMode ? 1.5 : 2.0)) : 2.0) : 2.0);
    CGFloat height = screenHeight();
    CGFloat position = height - touchLocation.y;
    double progress = 0.0;
    if (position < 0.0) {
        progress = 0.0;
    } else if (position > maxPosition) {
        progress = 1.0 + 0.1 * sin(MIN(position - maxPosition, maxPosition) / maxPosition * M_PI_2);
    } else {
        progress = (height - touchLocation.y) / maxPosition;
    }
    return progress;
}

CHInline void abortAnimation(CALayer *layer, NSString *keypath)
{
	[layer setValue:[layer.presentationLayer valueForKey:keypath]forKey:keypath];
	[layer removeAnimationForKey:keypath];
}

CHInline static void pageAlphaUpdate(CGFloat value, BOOL includeHome, BOOL animated)
{
	NSUInteger maxCount = unlimitedQuickSwitcher ? NSUIntegerMax : recommendedIconCount();
    void (^block)(void) = ^(){
		[sliderItems(NO) enumerateObjectsUsingBlock:^(SBAppSwitcherItemScrollView *item, NSUInteger index, BOOL *stop) {
			if (index == 0) {
				item.alpha = includeHome ? value : 1;
			} else {
				item.alpha = (index > maxCount) ? value : 1;
			}
		}];
    };
    if (animated) {
		abortAnimation(sliderItem(0, NO).layer, @"opacity");
        [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:NULL];
    } else {
        block();
    }
}

CHInline static void iconAlphaUpdate(CGFloat value, BOOL includeHome)
{
    value = MIN(MAX(value, 0.0), 1.0);
    NSArray *layouts = CHIvar(iconController, _appList, NSArray * const);
    NSDictionary *views = CHIvar(iconController, _iconViews, NSDictionary * const);
    [layouts enumerateObjectsUsingBlock:^(SBDisplayLayout *layout, NSUInteger index, BOOL *stop) {
        NSString *identifier = [layout.displayItems.firstObject displayIdentifier];
        SBAppSwitcherIconView *view = [identifier isEqualToString:@"com.apple.springboard"] ? (includeHome ? homeScreenIconView : nil) : views[layout];
        view.iconImageAlpha = MIN(MAX(value * (index == currentIndex ? 2.0 : (value * 2.0 - 1.0)), 0.0), 1.0);
        view.iconAccessoryAlpha = MIN(MAX(value * (index == currentIndex ? 2.0 : (value * 2.0 - 1.0)), 0.0), 1.0);
        view.iconLabelAlpha = MIN(MAX(value * 2.0 - 1.0, 0.0), 1.0);
    }];
}

CHInline static void iconShadowUpdate(BOOL animated)
{
    static void (^ const updateShadow)(CALayer *, BOOL, BOOL) = ^(CALayer *imageLayer, BOOL circular, BOOL animated) {
        if (umino == Auxo) {
            CGFloat shadowOpacity = 0.1;
			if (UminoIsPortrait(NO)) {
				if (phone && !iphone6 && !iphone6plus && reachabilityMode && !UminoIsMinimalStyle(NO)) {
					shadowOpacity = 0.4;
				}
			} else {
				if (phone || (!phone && !isPeopleViewDisabled())) {
					shadowOpacity = 0.4;
				}
			}
			if (imageLayer.shadowPath == nil) {
				CGRect bounds = imageLayer.bounds;
				imageLayer.shadowPath = (circular ? [UIBezierPath bezierPathWithOvalInRect:bounds] : [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:bounds.size.width * 0.225]).CGPath;
				imageLayer.shadowRadius = 15.0;
				imageLayer.shadowOffset = CGSizeZero;
				imageLayer.shadowColor = [UIColor blackColor].CGColor;
			}
            if (imageLayer.shadowOpacity != shadowOpacity) {
				if (animated) {
					CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
					anim.fromValue = @(((CALayer *)imageLayer.presentationLayer).shadowOpacity);
					anim.toValue = @(shadowOpacity);
					anim.duration = 0.4;
					[imageLayer addAnimation:anim forKey:@"shadowOpacity"];
				}
				imageLayer.shadowOpacity = shadowOpacity;
            }
        } else {
            imageLayer.shadowOpacity = 0.0;
        }
    };
    if (CHIvar(iconController, _iconViewCenters, NSMutableArray * const).count > 0) {
        NSArray *iconViews = CHIvar(iconController, _iconViews, NSMutableDictionary * const).allValues;
        for (SBAppSwitcherIconView *iconView in iconViews) {
            updateShadow(iconView._iconImageView.layer, NO, animated);
        }
        updateShadow(homeScreenIconView._iconImageView.layer, YES, animated);
    }
}

CHInline static void wallpaperAlphaUpdate(CGFloat blur, CGFloat dim)
{
	CALayer *wallpaperEffectLayer = sliderItemWallpaperEffectView().layer;
	CGFloat opacity = MIN(MAX(blur, 0.0), 1.0);
	if ([wallpaperEffectLayer animationForKey:@"opacity"]) {
		abortAnimation(wallpaperEffectLayer, @"opacity");
		if (ABS(wallpaperEffectLayer.opacity - opacity) < 0.1) {
			wallpaperEffectLayer.opacity = opacity;
		} else {
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
				wallpaperEffectLayer.opacity = opacity;
			} completion:NULL];
		}
	} else {
    	wallpaperEffectLayer.opacity = opacity;
	}
    if (umino == Auxo) {
        contentView.backgroundColor = [UIColor clearColor];
        dimView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:MAX(dim, 0.0) * 0.2];
        [contentView insertSubview:dimView belowSubview:pageView];
        dimView.frame = phone ? CGRectMake(0.0, auxoTopHeight() * dim, contentView.bounds.size.width, contentView.bounds.size.height - ((auxoTopHeight() + auxoBottomHeight()) * dim)) : CGRectMake(0.0, 0.0, contentView.bounds.size.width, contentView.bounds.size.height - (auxoBottomHeight() * dim));
    } else {
        contentView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:MAX(dim, 0.0) * 0.2];
        dimView.backgroundColor = [UIColor clearColor];
        [dimView removeFromSuperview];
    }
}

static void preferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    leftBehavior = ControlCenter;
    rightBehavior = ControlCenter;
    centerBehavior = ControlCenter;
    if ([getPreferences(kMultiCenterKey) boolValue]) {
        leftBehavior = Auxo;
        rightBehavior = Auxo;
        centerBehavior = Auxo;
    }
    if ([getPreferences(kHotCornersKey) boolValue]) {
		leftBehavior = AppSwitcher;
		rightBehavior = HomeScreen;
    }
    if ([getPreferences(kQuickSwitcherKey) boolValue]) {
        leftBehavior = QuickSwitcher;
    }
	invertHotCorners = [getPreferences(kInvertHotCornersKey) boolValue];
	if (invertHotCorners) {
		CornerBehavior tempBehavior = leftBehavior;
		leftBehavior = rightBehavior;
		rightBehavior = tempBehavior;
	}
	minimalStyleEnabled = [getPreferences(kMinimalControlCenterEnabledKey) boolValue];
    minimalStyleCondition = widescreen ? (minimalStyleEnabled ? [getPreferences(kMinimalControlCenterConditionKey) integerValue] : -1) : 0;
	reachabilityMode = widescreen ? [getPreferences(kReachabilityModeKey) boolValue] : NO;
    openToLastApp = [getPreferences(kOpenToLastAppKey) boolValue];
    openToLastAppWithQS = [getPreferences(kOpenToLastAppWithQSKey) boolValue];
    quickLaunchOptionWithoutMediaPlaying = [getPreferences(kQuickLauncherNotPlayingKey) integerValue];
    quickLaunchOptionWithMediaPlaying = [getPreferences(kQuickLauncherIsPlayingKey) integerValue];
    quickLaunchAutoDismissDelay = [getPreferences(kQuickLauncherAutoDismissDelayKey) integerValue];
	if (minimalStyleEnabled && reachabilityMode) {
		quickLaunchOptionWithoutMediaPlaying = 1;
		quickLaunchOptionWithMediaPlaying = 0;
	}
	sliderActionsBrightness = [getPreferences(kSliderActionsBrightnessKey) integerValue];
	sliderActionsVolume = [getPreferences(kSliderActionsVolumeKey) integerValue];
	sliderActionsDisableHUD = [getPreferences(kSliderActionsDisableHUDKey) boolValue];
    albumArtworkAutoDisplay = [getPreferences(kAlbumArtworkAutoDisplayKey) integerValue];
    albumArtworkAutoDismissDelay = [getPreferences(kAlbumArtworkAutoDismissDelayKey) integerValue];
    closeAllAppsNoConfirmation = [getPreferences(kCloseAllAppsNoConfirmationKey) boolValue];
    closeAllAppsBackToHomeScreen = [getPreferences(kCloseAllAppsBackToHomeScreenKey) boolValue];
    closeAllAppsExcludeNowPlaying = [getPreferences(kCloseAllAppsExcludeNowPlayingKey) boolValue];
    closeAllAppsExceptions = getPreferences(kCloseAllAppsExceptionsKey);
    unlimitedQuickSwitcher = phone ? [getPreferences(kUnlimitedQuickSwitcherKey) boolValue] : YES;
	accessHomeScreen = [getPreferences(kAccessHomeScreenKey) boolValue];
	accessAppSwitcher = [getPreferences(kAccessAppSwitcherKey) boolValue];
	peopleInTodayHeader = phone ? [getPreferences(kPeopleInTodayKey) boolValue] : NO;
	disableHomeDoubleClick = [getPreferences(kDisableHomeDoubleClickKey) boolValue];
    iconListView.unlimitedIconCount = unlimitedQuickSwitcher;
	iconListView.openToLast = openToLastAppWithQS;
	[controlCenterBottomView updateSliderActions:sliderActionsBrightness :sliderActionsVolume];
	[controlCenterBottomView setShowingHUD:!sliderActionsDisableHUD];
    sensitivity = 0;
    disableWithKeyboard = NO; // [getPreferences(kDisableWithKeyboardKey) boolValue];
}

static void exceptionsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    exceptions = [NSDictionary dictionaryWithContentsOfFile:kExceptionsPlist];
}

static void workaroundsChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    gridSwitcherWorkaround = [[NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/jp.tom-go.GridSwitcher.plist"][@"gridSwitcherEnabled"] boolValue];
}

@implementation UminoAppSwitcherIconRootView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (umino == Auxo && ([self convertPoint:point toView:contentView].y >= (screenHeight() - auxoBottomHeight()) || [self convertPoint:point toView:pageView].y <= pageView.bounds.size.height)) {
        return nil;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

- (void)gestureRecognized:(UIPanGestureRecognizer *)recognizer
{
	if (umino != Auxo || !phone) {
		return;
	}
	if (artworkView.alpha != 0.0) {
		[switcherController hideArtwork];
	}
	CGFloat width = screenWidth();
	CGFloat height = screenHeight();
	CGFloat max = auxoBottomHeight();
	CGFloat y = [recognizer locationInView:contentView].y - (height - max);
	double progress = 0.0;
	if (y < 0.0) {
		progress = 0.0 - 0.1 * sin(MIN(-y, max) / max * M_PI_2);
	} else if (y > max) {
		progress = 1.0 + 0.1 * sin(MIN(y - max, max) / max * M_PI_2);
	} else {
		progress = y / max;
	}
	progress = 1.0 - progress;
	void (^ block)(void) = ^(void) {
		CGFloat positionX = width / 2.0;
		CGFloat positionY = - auxoPageOffset() * pow(progress, reachabilityMode ? 2.0 : 3.0);
		CGFloat pageScale = maxScale() * (1.0 - progress) + auxoPageScale() * progress;
		CGPoint iconViewPosition = iconExpectedPosition;
		iconViewPosition.y = height;
		iconViewPosition.y -= (iconViewPosition.y - iconExpectedPosition.y) * progress;
		iconAlphaUpdate(progress, YES);
		wallpaperAlphaUpdate(progress, progress);
		pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(pageScale, pageScale, 1), 0, positionY, 0);
		iconView.layer.position = iconViewPosition;
		controlCenterTopView.layer.position = CGPointMake(positionX, auxoTopHeight() * progress);
		controlCenterBottomView.layer.position = CGPointMake(positionX, screenHeight() - auxoBottomHeight() * progress);
	};
	switch (recognizer.state) {
		case UIGestureRecognizerStateBegan:
			{
				[pageController setOffsetToIndex:pageController.currentPage animated:YES];
				[iconController setOffsetToIndex:pageController.currentPage animated:YES];
				[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:NULL];
				break;
			}
		case UIGestureRecognizerStateChanged:
			{
				block();
				break;
			}
		case UIGestureRecognizerStateEnded:
			{
				BOOL gestureCancelled = (y > 0.0 && [recognizer velocityInView:controlCenterBottomView].y > 0.0);
				if (gestureCancelled) {
					[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
					if (needDismissal) {
						needDismissal = NO;
					} else {
						[[UIApplication sharedApplication] endIgnoringInteractionEvents];
						return;
					}
				} else {
					xTranslationFix = YES;
				}
				CGFloat x = width / 2.0;
				CGFloat endScale = gestureCancelled ? maxScale() : auxoPageScale();
				CGFloat endPositionY = -(gestureCancelled ? 0.0 : auxoPageOffset());
				CGFloat endTopY = gestureCancelled ? 0.0 : auxoTopHeight();
				CGFloat endBottomY = gestureCancelled ? height : height - auxoBottomHeight();
				if (gestureCancelled) {
					iconExpectedPosition.y = height;
					UIView *itemView = sliderItem(currentIndex, YES).item.view;
					if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
						[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
					}
				}
				[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
					pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(endScale, endScale, 1.0), 0.0, endPositionY, 0.0);
					iconView.layer.position = iconExpectedPosition;
					iconAlphaUpdate(gestureCancelled ? 0.0 : 1.0, YES);
					wallpaperAlphaUpdate(gestureCancelled ? 0.0 : 1.0, gestureCancelled ? 0.0 : 1.0);
					controlCenterTopView.layer.position = CGPointMake(x, endTopY);
					controlCenterBottomView.layer.position = CGPointMake(x, endBottomY);
					if (gestureCancelled) {
						pageView.layer.position = CGPointMake(x, height / 2.0);
						[pageController setOffsetToIndex:currentIndex animated:NO];
						[iconController setOffsetToIndex:currentIndex animated:NO];
					}
				} completion:^(BOOL finished) {
					if (gestureCancelled) {
						suppressAnimation = YES;
						[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
						suppressAnimation = NO;
						[[UIApplication sharedApplication] endIgnoringInteractionEvents];
					}
				}];
				break;
			}
		default:
			{
				break;
			}
	}
}

@end

@implementation UminoCloseAllAppsGestureView {
CGRect _actionFrame;
CGPoint _touchBeganPoint;
@public
BOOL _done;
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (!hidden) {
        _done = NO;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_done) {
        return;
    }
    _actionFrame = [self convertRect:homeScreenIconView.bounds fromView:homeScreenIconView];
    _touchBeganPoint = [touches.anyObject locationInView:self];
    if (CGRectContainsPoint(_actionFrame, _touchBeganPoint)) {
        homeScreenIconView.highlighted = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_done) {
        return;
    }
    if (CGRectContainsPoint(_actionFrame, _touchBeganPoint) && CGRectContainsPoint(_actionFrame, [touches.anyObject locationInView:self])) {
        homeScreenIconView.highlighted = YES;
    } else {
        homeScreenIconView.highlighted = NO;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_done) {
        return;
    }
    homeScreenIconView.highlighted = NO;
    SBAppSwitcherItemScrollView *scrollView = sliderItem(0, NO);
    if (CGRectContainsPoint(_actionFrame, _touchBeganPoint) && CGRectContainsPoint(_actionFrame, [touches.anyObject locationInView:self])) {
        _done = YES;
        [scrollView setContentSize:CGSizeMake(pageExpectedSize.width, pageExpectedSize.height * 2)];
        [scrollView _prepareToPageWithHorizontalVelocity:0.0 verticalVelocity:100.0];
        noSendBackOnce = YES;
        [scrollView _endPanNormal:YES];
    } else {
        [scrollView setContentOffset:CGPointZero animated:YES];
        while (scrollView.contentOffset.y != 0.0) {
            [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
        }
        [scrollView.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_done) {
        return;
    }
    _done = YES;
    SBAppSwitcherItemScrollView *scrollView = sliderItem(0, NO);
    [scrollView setContentOffset:CGPointZero animated:YES];
    while (scrollView.contentOffset.y != 0.0) {
        [[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
    }
    [scrollView.delegate scrollViewDidEndDecelerating:scrollView];
}

@end

%hook SBWorkspace

- (id)init
{
    self = %orig;
    workspace = self;
    return self;
}

%end

%hook SBAppSwitcherPageViewController

%new
- (CGFloat)normalizedOffsetOfIndex:(NSUInteger)index
{
    CGFloat width = CHIvar(self, _scrollView, UIScrollView * const).contentSize.width - 2 * self._halfWidth;
	if (width == 0) return 0;
    CGFloat offset = [self _centerOfIndex:index].x - self._halfWidth;
	return offset / width;
}

- (void)setOffsetToIndex:(NSUInteger)index animated:(BOOL)animated completion:(id)completion
{
    if (noPageScroll) {
        noPageScroll = NO;
        startingIndex = index;
        index = currentIndex;
		animated = NO;
    }
    currentIndex = index;
    %orig;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    %orig;
    if (umino == Auxo) {
        iconView.userInteractionEnabled = NO;
        if ([scrollView isKindOfClass:NSClassFromString(@"SBAppSwitcherItemScrollView")]) {
			noSendBack++;
            if (phone) {
                [contentView bringSubviewToFront:controlCenterTopView];
                [contentView bringSubviewToFront:controlCenterBottomView];
            } else {
                [contentView bringSubviewToFront:controlCenterOriginalView];
            }
            SBAppSwitcherItemScrollView *homeScreenItem = sliderItem(0, NO);
            if (scrollView == homeScreenItem) {
                for (SBAppSwitcherItemScrollView *itemScrollView in sliderItems(YES)) {
                    if (itemScrollView != scrollView) {
                        itemScrollView.scrollEnabled = NO;
                        itemScrollView.contentOffset = CGPointZero;
                    }
                }
            } else {
                homeScreenItem.scrollEnabled = NO;
                homeScreenItem.contentOffset = CGPointZero;
            }
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(CGPoint *)offset
{
    %orig;
    if (umino == Auxo) {
        iconView.userInteractionEnabled = YES;
        if ([scrollView isKindOfClass:NSClassFromString(@"SBAppSwitcherItemScrollView")]) {
			if (scrollView == sliderItem(0, NO) && (*offset).y > 0) {
				[pageController setOffsetToIndex:sliderContinuityCount() animated:YES];
				[iconController setOffsetToIndex:sliderContinuityCount() animated:YES];
			}
		}
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    %orig;
    if (umino == Auxo) {
        if ([scrollView isKindOfClass:NSClassFromString(@"SBAppSwitcherItemScrollView")]) {
            if (scrollView.contentOffset.y == 0.0) {
				noSendBack--;
				if (noSendBack == 0) {
					if (noSendBackOnce) {
						noSendBackOnce = NO;
					} else {
						if (phone) {
							[contentView sendSubviewToBack:controlCenterTopView];
							[contentView sendSubviewToBack:controlCenterBottomView];
						} else {
							[contentView sendSubviewToBack:controlCenterOriginalView];
						}
					}
				}
                closeAllAppsGestureView.hidden = YES;
                [closeAllAppsGestureView removeFromSuperview];
            } else {
                if ([sliderItems(NO) indexOfObjectIdenticalTo:scrollView] == 0) {
                    closeAllAppsGestureView.frame = contentView.bounds;
                    closeAllAppsGestureView.hidden = NO;
                    [contentView addSubview:closeAllAppsGestureView];
                }
            }
            SBAppSwitcherItemScrollView *homeScreenItem = sliderItem(0, NO);
            if (scrollView == homeScreenItem) {
                for (SBAppSwitcherItemScrollView *itemScrollView in sliderItems(YES)) {
                    if (itemScrollView != scrollView) {
                        itemScrollView.scrollEnabled = YES;
                    }
                }
            } else {
                homeScreenItem.scrollEnabled = YES;
            }
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    %orig;
    if (umino == Auxo && !gridSwitcherWorkaround) {
        if ([scrollView isKindOfClass:NSClassFromString(@"SBAppSwitcherItemScrollView")]) {
            NSArray *items = sliderItems(NO);
            NSUInteger index = [items indexOfObjectIdenticalTo:scrollView];
			if (index != NSNotFound) {
				if (index > 0) {
					SBAppSwitcherIconView *view = [iconController _iconViewForIndex:index];
					view.transform = CGAffineTransformMakeTranslation(0.0, MAX(scrollView.contentOffset.y * auxoIconScrollingRate(), 0.0));
					CGFloat remain = scrollView.bounds.size.height - scrollView.contentOffset.y;
					CGFloat alpha = remain < 20.0 ? remain / 20.0 : 1.0;
					scrollView.alpha = alpha;
					view.alpha = alpha;
				} else {
					keepAllItems = YES;
					[pageController _updateVisiblePageViews];
					keepAllItems = NO;
					static double (^ const curvedValue)(double) = ^(double value){
						if (value <= 0.5) {
							return pow(value * 2.0, 2.0) / 2.0;
						} else {
							return 1.0 - pow((1 - value) * 2.0, 2.0) / 2.0;
						}
					};
					CGFloat offsetY = scrollView.contentOffset.y;
					double progress = curvedValue(MIN(MAX(offsetY / closeAllAppsPageOffset(), 0.0), 1.0));
					double alternateProgress = curvedValue(MIN(MAX(- offsetY / (scrollView.bounds.size.height * 2.0), 0.0), 1.0));
					homeScreenIconView._iconImageView.alternateIconView.alpha = offsetY >= 0 ? progress : alternateProgress;
					homeScreenIconView.transform = CGAffineTransformMakeTranslation(0.0, - closeAllAppsIconOffset() * (offsetY >= 0 ? progress : alternateProgress));
					iconAlphaUpdate(1.0 - progress, NO);
					[items enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SBAppSwitcherItemScrollView *view, NSUInteger index, BOOL *stop) {
						[view.superview bringSubviewToFront:view];
						if (index > 19) {
							view.transform = CGAffineTransformIdentity;
							view.contentOffset = CGPointMake(0.0, 0.0);
							view.alpha = 1.0;
						} else if (index > 0) {
							CGFloat scale = 1.0;
							CGFloat translationX = 0.0;
							CGFloat othersOffsetY = 0.0;
							CGFloat pageAlpha = 1.0;
							if (offsetY >= 0) {
								scale = MAX(1.0 - (0.05 * index) * progress, 0.05);
								translationX = ([pageController _centerOfIndex:0].x - [pageController _centerOfIndex:index].x) * progress / scale;
								othersOffsetY = (offsetY - (index * closeAllAppsPageSpacing()) * progress) / scale;
								pageAlpha = 1.0 - (index < 20 ? 0.5 : 1.0) * progress;
							}
							CGAffineTransform transform = CGAffineTransformIdentity;
							transform = CGAffineTransformScale(transform, scale, scale);
							transform = CGAffineTransformTranslate(transform, translationX, 0.0);
							view.transform = transform;
							view.contentOffset = CGPointMake(0.0, othersOffsetY);
							view.alpha = pageAlpha;
						} else {
							if (view.isTracking) {
								pageExpectedSize = view.bounds.size;
							}
							if (!closeAllAppsNoConfirmation && closeAllAppsGestureView.hidden) {
								view.contentSize = CGSizeMake(pageExpectedSize.width, pageExpectedSize.height + closeAllAppsPageOffset());
							}
						}
					}];
				}
			}
        }
    }
}

%end

%hook SBAppSwitcherIconController

- (UIView *)view
{
    UIView *view = %orig;
    if (![view isKindOfClass:UminoAppSwitcherIconRootView.class]) {
        object_setClass(view, UminoAppSwitcherIconRootView.class);
	    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:view action:@selector(gestureRecognized:)];
	    [gestureRecognizer _setCanPanHorizontally:NO];
	    [gestureRecognizer _setCanPanVertically:YES];
        [view addGestureRecognizer:gestureRecognizer];
    }
    return view;
}

- (void)setOffsetToIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (noIconScroll) {
        noIconScroll = NO;
        index = currentIndex;
    }
    %orig;
}

- (void)reloadInOrientation:(UIInterfaceOrientation)orientation
{
    %orig;
    if (umino == Auxo && !gridSwitcherWorkaround) {
        [CHIvar(iconController, _iconContainer, UIView * const) addSubview:homeScreenIconView];
    } else {
        [homeScreenIconView removeFromSuperview];
    }
}

- (void)_updateVisibleIconViewsWithPadding:(BOOL)padding
{
    %orig;
    if (CHIvar(self, _iconViewCenters, NSMutableArray * const).count > 0) {
        homeScreenIconView.frame = [self _iconFaultRectForIndex:sliderContinuityCount()];
        homeScreenIconView.center = [self _adjustedCenter:homeScreenIconView.center forIconView:homeScreenIconView];
    }
	iconShadowUpdate(NO);
}

- (void)iconHandleLongPress:(SBIconView *)iconView
{
    if (iconView == homeScreenIconView) {

    } else {
        %orig;
    }
}

- (void)iconTouchBegan:(SBIconView *)iconView
{
    if (iconView == homeScreenIconView) {
        iconView.highlighted = YES;
    } else {
        %orig;
    }
}

- (BOOL)iconShouldAllowTap:(SBIconView *)iconView
{
    if (iconView == homeScreenIconView) {
        return YES;
    } else {
        return %orig;
    }
}

- (void)iconTapped:(SBIconView *)iconView
{
    if (iconView == homeScreenIconView) {
        iconView.highlighted = NO;
        [switcherController switcherScroller:pageController itemTapped:displayLayouts(NO)[0]];
    } else {
        %orig;
    }
}

%end

%subclass UminoIcon : SBIcon

                      - (NSString *)displayName
{
    return @"";
}

- (UIImage *)getGenericIconImage:(NSInteger)format
{
    if (format == 2) {
        return imageResource(@"Home");
    } else {
        return imageResource(@"HomeSmall");
    }
}

- (UIImage *)generateIconImage:(NSInteger)format
{
    if (format == 2) {
        return imageResource(@"Home");
    } else {
        return imageResource(@"HomeSmall");
    }
}

%end

%subclass UminoAppSwitcherIconView : SBAppSwitcherIconView

                                     - (SBIconImageView *)_iconImageView
{
    SBIconImageView *iconImageView = %orig;
    if (![iconImageView isKindOfClass:NSClassFromString(@"UminoIconImageView")]) {
        object_setClass(iconImageView, NSClassFromString(@"UminoIconImageView"));
    }
    return iconImageView;
}

%end

%subclass UminoIconImageView : SBIconImageView

                               - (UIImage *)_currentOverlayImage
{
    static UIImage *overlayImage;
    if (overlayImage == nil) {
        static CGFloat const imageSize = 62.0;
        static CGFloat const overlaySize = 52.0;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, (imageSize - overlaySize) / 2.0, (imageSize - overlaySize) / 2.0);
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0, 0.0, overlaySize, overlaySize));
        overlayImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return overlayImage;
}

%new
- (UIView *)alternateIconView
{
    static UIImage *alternateIconImage;
    if (alternateIconImage == nil) {
        static CGFloat const imageSize = 62.0;
        static CGFloat const overlaySize = 51.0;
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(imageSize, imageSize), NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, (imageSize - overlaySize) / 2.0, (imageSize - overlaySize) / 2.0);
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(0.0, 0.0, overlaySize, overlaySize));
        CGContextMoveToPoint(context, 18.0, 18.0);
        CGContextAddLineToPoint(context, 34.0, 34.0);
        CGContextMoveToPoint(context, 18.0, 34.0);
        CGContextAddLineToPoint(context, 34.0, 18.0);
        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
        CGContextSetLineWidth(context, 2.5);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextStrokePath(context);
        alternateIconImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    UIImageView *view = objc_getAssociatedObject(self, kAssociatedObjectKey);
    if (view == nil) {
        view = [[UIImageView alloc]initWithImage:alternateIconImage];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectZero];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = localizedString(@"CLOSE_ALL_APPS");
        [view addSubview:label];
        view.alpha = 0.0;
        objc_setAssociatedObject(self, kAssociatedObjectKey, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:view];
        [self setNeedsLayout];
    }
    return view;
}

- (void)layoutSubviews
{
    %orig;
    CGRect bounds = self.bounds;
    UIView *alternateIconView = self.alternateIconView;
    UILabel *label = alternateIconView.subviews.firstObject;
    alternateIconView.frame = bounds;
    [label sizeToFit];
    label.center = CGPointMake(bounds.size.width / 2.0, self.superview.bounds.size.height - label.bounds.size.height / 2.0);
    [self bringSubviewToFront:CHIvar(self, _overlayView, UIImageView * const)];
}

%end

%hook SBAppSwitcherItemScrollView

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    CGFloat translationY = [recognizer translationInView:self].y;
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
                                                if (slidingDismiss) {
                                                    return;
                                                } else {
                                                    slidingDismiss = (umino == Auxo && (translationY > 0.0 || [recognizer velocityInView:self].y > 0.0) && self.contentOffset.y == 0.0 && !gridSwitcherWorkaround);
                                                    if (slidingDismiss) {
														NSArray *items = sliderItems(YES);
                                                        NSUInteger index = [items indexOfObjectIdenticalTo:self];
                                                        [pageController setOffsetToIndex:index animated:YES];
                                                        [iconController setOffsetToIndex:index animated:YES];
                                                        for (SBAppSwitcherItemScrollView *itemScrollView in items) {
                                                            if (itemScrollView != self) {
                                                                itemScrollView.scrollEnabled = NO;
                                                                itemScrollView.contentOffset = CGPointZero;
                                                            }
                                                        }
                                                    } else {
                                                        %orig;
                                                    }
                                                }
                                                break;
                                            }
        case UIGestureRecognizerStateChanged: {
                                                  if (slidingDismiss) {
                                                      if (currentIndex == [sliderItems(YES) indexOfObjectIdenticalTo:self]) {
                                                          double progress = 0.0;
                                                          static const CGFloat maxTranslationY = 128.0;
                                                          if (translationY < 0.0) {
                                                              progress = 0.0 - 0.1 * sin(MIN(0.0 - translationY, maxTranslationY) / maxTranslationY * M_PI_2);
                                                          } else if (translationY > maxTranslationY) {
                                                              progress = 1.0 + 0.1 * sin(MIN(translationY - maxTranslationY, maxTranslationY) / maxTranslationY * M_PI_2);
                                                          } else {
                                                              progress = translationY / maxTranslationY;
                                                          }
                                                          progress = 1.0 - progress;
                                                          CGFloat positionX = screenWidth() / 2.0;
														  CGFloat positionY = - auxoPageOffset() * pow(progress, reachabilityMode ? 2.0 : 3.0);
                                                          CGPoint iconViewPosition = iconExpectedPosition;
                                                          iconViewPosition.y = screenHeight();
                                                          iconViewPosition.y -= (iconViewPosition.y - iconExpectedPosition.y) * progress;
                                                          [switcherController _updatePageViewScale:maxScale() * (1.0 - progress) + auxoPageScale() * progress];
                                                          iconAlphaUpdate(progress, YES);
                                                          homeScreenIconView.iconImageAlpha = MIN(MAX(progress * 2.0 - 1.0, 0.0), 1.0);
                                                          homeScreenIconView.iconAccessoryAlpha = MIN(MAX(progress * 2.0 - 1.0, 0.0), 1.0);
                                                          homeScreenIconView.iconLabelAlpha = MIN(MAX(progress * 2.0 - 1.0, 0.0), 1.0);
                                                          wallpaperAlphaUpdate(progress, progress);
                                                          pageView.layer.transform = CATransform3DTranslate(pageView.layer.transform, 0, positionY, 0);
                                                          iconView.layer.position = iconViewPosition;
                                                          if (phone) {
                                                              controlCenterTopView.layer.position = CGPointMake(positionX, auxoTopHeight() * progress);
                                                              controlCenterBottomView.layer.position = CGPointMake(positionX, screenHeight() - auxoBottomHeight() * progress);
                                                          } else {
                                                              controlCenterOriginalView.layer.position = CGPointMake(positionX, screenHeight() - auxoBottomHeight() * progress);
                                                          }
                                                      } else {
                                                          return;
                                                      }
                                                  } else {
                                                      %orig;
                                                  }
                                                  break;
                                              }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
                                                    if (slidingDismiss) {
                                                        if (currentIndex == [sliderItems(YES) indexOfObjectIdenticalTo:self]) {
                                                            slidingDismiss = NO;
                                                            BOOL gestureCancelled = (translationY > 0.0 && [recognizer velocityInView:self].y > 0.0);
                                                            if (gestureCancelled) {
                                                                [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                                                                if (needDismissal) {
                                                                    needDismissal = NO;
                                                                } else {
                                                                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                                                    return;
                                                                }
                                                            } else {
                                                                xTranslationFix = YES;
                                                            }
                                                            CGFloat x = screenWidth() / 2.0;
                                                            CGFloat height = screenHeight();
                                                            CGFloat endScale = gestureCancelled ? maxScale() : auxoPageScale();
                                                            CGFloat endPositionY = -(gestureCancelled ? 0.0 : auxoPageOffset());
                                                            CGFloat endTopY = gestureCancelled ? 0.0 : auxoTopHeight();
                                                            CGFloat endBottomY = gestureCancelled ? height : height - auxoBottomHeight();
                                                            if (gestureCancelled) {
                                                                iconExpectedPosition.y = height;
																UIView *itemView = sliderItem(currentIndex, YES).item.view;
																if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
																	[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
																}																
                                                            }
                                                            [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                                                                pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(endScale, endScale, 1.0), 0.0, endPositionY, 0.0);
                                                                iconView.layer.position = iconExpectedPosition;
                                                                iconAlphaUpdate(gestureCancelled ? 0.0 : 1.0, YES);
                                                                wallpaperAlphaUpdate(gestureCancelled ? 0.0 : 1.0, gestureCancelled ? 0.0 : 1.0);
                                                                if (phone) {
                                                                    controlCenterTopView.layer.position = CGPointMake(x, endTopY);
                                                                    controlCenterBottomView.layer.position = CGPointMake(x, endBottomY);
                                                                } else {
                                                                    controlCenterOriginalView.layer.position = CGPointMake(x, endBottomY);
                                                                }
                                                                if (gestureCancelled) {
                                                                    pageView.layer.position = CGPointMake(x, height / 2.0);
                                                                    [pageController setOffsetToIndex:currentIndex animated:NO];
                                                                    [iconController setOffsetToIndex:currentIndex animated:NO];
                                                                }
                                                            } completion:^(BOOL finished) {
                                                                if (gestureCancelled) {
                                                                    suppressAnimation = YES;
                                                                    [switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
                                                                    suppressAnimation = NO;
                                                                    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                                                }
                                                                for (SBAppSwitcherItemScrollView *itemScrollView in sliderItems(YES)) {
                                                                    if (itemScrollView != self) {
                                                                        itemScrollView.scrollEnabled = YES;
                                                                    }
                                                                }
                                                            }];
                                                        } else {
                                                            return;
                                                        }
                                                    } else {
                                                        %orig;
                                                    }
                                                    break;
                                                }
        default: {
                     if (slidingDismiss) {

                     } else {
                         %orig;
                     }
                     break;
                 }
    }
}

%end

%hook SBAppSwitcherController

- (void)_updatePageViewScale:(CGFloat)scale xTranslation:(CGFloat)x
{
	if (noXTranslation) {
		x = 0;
	}
    if (continuePresentation) {
        CGFloat endScale = scale == 1.0 ? auxoPageScale() : scale;
        CGFloat endPositionX = scale == 1.0 ? 0 : x / auxoPageScale();
        CGFloat endPositionY = - auxoPageOffset() / scale;
        pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(endScale, endScale), endPositionX, endPositionY);
        return;
    }
    static BOOL flag = NO;
    if (noScale && scale == 1.0) {
        if (flag) {
            noScale = NO;
            forceAnimation = YES;
            flag = NO;
            scale = maxScale();
            iconAlphaUpdate(umino == Auxo ? 0.0 : 1.0, YES);
            wallpaperAlphaUpdate(0.0, 0.0);
        } else {
            flag = YES;
        }
    }
    if (xTranslationFix) {
        xTranslationFix = NO;
        x /= auxoPageScale();
    }
    %orig;
}

- (CGFloat)_switcherThumbnailVerticalPositionOffset
{
    return suppressAnimation ? 0.0 : %orig;
}

- (void)_bringIconViewToFront
{
    if (umino == QuickSwitcher) {
        %orig;
        [contentView bringSubviewToFront:iconListView];
    } else if (umino == AppSwitcher) {
        %orig;
    } else if (umino == Auxo) {
        if (phone) {
            [contentView bringSubviewToFront:controlCenterTopView];
            [contentView bringSubviewToFront:controlCenterBottomView];
        } else {
            [contentView bringSubviewToFront:controlCenterOriginalView];
        }
        [contentView bringSubviewToFront:pageView];
        %orig;
    } else {
        %orig;
    }
}

- (void)_cacheAppList
{
    %orig;
	NSUInteger index = [CHIvar(self, _appList_use_block_accessor, NSArray * const) indexOfObject:self.startingDisplayLayout];
	currentIndex = index == NSNotFound ? 0 : index;
}

- (void)peopleController:(id)peopleController wantsToContact:(NSURL *)url
{
	if (isAppSwitcherShowing()) {
		%orig;
	} else {
		[[UIApplication sharedApplication]openURL:url];
	}
}

- (void)_continuityAppSuggestionChanged:(NSNotification *)note
{
	if (umino != QuickSwitcher) {
		if (!closeAllAppsGestureView->_done) {
			[closeAllAppsGestureView touchesCancelled:nil withEvent:nil];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
				%orig;
			});
		} else {
			%orig;
		}
	}
}

- (void)animatePresentationFromDisplayLayout:(SBDisplayLayout *)layout withViews:(id)views withCompletion:(void (^)(BOOL))completion
{
    if (umino == Auxo && [pageView.layer animationForKey:@"transform"] != nil) {
        %orig(layout, views, NULL);
        CABasicAnimation *anim = (CABasicAnimation *)[pageView.layer animationForKey:@"transform"];
        CGPoint translation = CGPointApplyAffineTransform(CGPointZero, CATransform3DGetAffineTransform([anim.fromValue CATransform3DValue]));
        [pageView.layer removeAnimationForKey:@"transform"];
        CGFloat scale = maxScale();
        CGFloat positionX = translation.x / scale * auxoPageScale();
        CGFloat positionY = - auxoPageOffset();
        pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), positionX, 0.0);
        [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
            pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(auxoPageScale(), auxoPageScale()), 0.0, positionY);
        } completion:completion];
    } else {
        %orig;
    }
	peopleView.frame = (CGRect){CGPointZero, peopleView.frame.size};
	[contentView addSubview:peopleView];
    if (umino == QuickSwitcher) {
        needDismissal = YES;
        iconListView.hidden = NO;
        iconListView.layer.bounds = CGRectMake(0.0, 0.0, screenWidth(), iconListHeight());
		BOOL atHomeScreen = isAtHomeScreen();
		NSMutableArray *icons = [NSMutableArray arrayWithArray:applicationList()];
		if (!atHomeScreen && !accessHomeScreen) {
			[icons removeObject:@"com.apple.springboard"];
		}
		[iconListView setAtHomeScreen:atHomeScreen];
        [iconListView setIcons:icons];
        [iconListView setHighlightIndex:currentIndex];
        [iconListView layout];
        iconListView.alpha = 1.0;
        iconController.view.alpha = 0.0;
        CGFloat positionX = screenWidth() / 2.0;
        CGFloat iconStartPositionY = screenHeight(), iconEndPositionY = iconStartPositionY - iconListHeight();
        iconListView.layer.position = CGPointMake(positionX, iconStartPositionY);
        [contentView addSubview:iconListView];
        [switcherController _bringIconViewToFront];
        [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
            iconListView.layer.position = CGPointMake(positionX, iconEndPositionY);
            contentView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.2];
        } completion:NULL];
        if (!accessAppSwitcher) {
            iconExpectedPosition = iconView.layer.position;
            iconExpectedPosition.y -= auxoIconOffset();
        }
        pageAlphaUpdate(0.0, !atHomeScreen && !accessHomeScreen, NO);
		peopleView.hidden = YES;
    } else if (umino == AppSwitcher) {
        needDismissal = YES;
        iconExpectedPosition = iconView.layer.position;
        CGPoint iconViewPosition = iconExpectedPosition;
        iconViewPosition.y = screenHeight();
        [iconView.layer removeAnimationForKey:@"position"];
        iconView.layer.position = iconViewPosition;
        [switcherController _bringIconViewToFront];
        iconAlphaUpdate(0.0, NO);
        peopleView.hidden = NO;
    } else if (umino == Auxo) {
        needDismissal = YES;
        if (phone) {
            controlCenterTopView.hidden = NO;
            controlCenterBottomView.hidden = NO;
            CGFloat width = screenWidth();
            CGFloat height = screenHeight();
            controlCenterTopView.layer.bounds = CGRectMake(0.0, 0.0, width, auxoTopHeight() * 2.0);
            controlCenterBottomView.layer.bounds = CGRectMake(0.0, 0.0, width, auxoBottomHeight() * 2.0);
            controlCenterTopView.layer.position = CGPointMake(width / 2.0, 0.0);
            controlCenterBottomView.layer.position = CGPointMake(width / 2.0, height);
            [contentView addSubview:controlCenterTopView];
            [contentView addSubview:controlCenterBottomView];
            [contentView addSubview:dimView];
            iconExpectedPosition = iconView.layer.position;
            iconExpectedPosition.y -= auxoIconOffset();
            CGPoint iconViewPosition = iconExpectedPosition;
            iconViewPosition.y = screenHeight();
            [iconView.layer removeAnimationForKey:@"position"];
            iconView.layer.position = iconViewPosition;
            UIView *pageScrollView = pageView.subviews.firstObject;
            CGRect bounds = pageView.layer.bounds;
            CGPoint position = pageScrollView.layer.position;
            bounds.size.width /= auxoPageScale();
            position.x = bounds.size.width / 2.0;
            pageView.layer.bounds = bounds;
            pageScrollView.layer.position = position;
            [switcherController _bringIconViewToFront];
            [controlCenterBottomView layoutSubviews];
            peopleView.hidden = YES;
            switch (isMediaPlaying() ? quickLaunchOptionWithMediaPlaying : quickLaunchOptionWithoutMediaPlaying) {
                case 0:
                    [controlCenterBottomView setQuickLauncherShowing:@NO];
                    break;
                case 1:
                    [controlCenterBottomView setQuickLauncherShowing:@YES];
                    break;
                case 2:
                    [controlCenterBottomView setQuickLauncherShowing:@YES];
					quickLaunchAutoDismissed = NO;
                    break;
                default:
                    [controlCenterBottomView setQuickLauncherShowing:@NO];
                    break;
            }
            if (continuePresentation) {
                continuePresentation = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                    xTranslationFix = YES;
                    [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                        iconView.layer.position = iconExpectedPosition;
                        controlCenterTopView.layer.position = CGPointMake(width / 2.0, auxoTopHeight());
                        controlCenterBottomView.layer.position = CGPointMake(width / 2.0, height - auxoBottomHeight());
                        iconAlphaUpdate(1.0, YES);
                        wallpaperAlphaUpdate(1.0, 1.0);
                        } completion:^(BOOL finished) {
							[[UIApplication sharedApplication] endIgnoringInteractionEvents];
							if (!(UminoIsMinimalStyle(NO) && reachabilityMode)) {
							if ((isMediaPlaying() ? quickLaunchOptionWithMediaPlaying : quickLaunchOptionWithoutMediaPlaying) == 2) {
							[controlCenterBottomView dismissQuickLauncherAfterDelay:quickLaunchAutoDismissDelay];
							}
							} else {
								switch (isMediaPlaying() ? quickLaunchOptionWithMediaPlaying : quickLaunchOptionWithoutMediaPlaying) {
									case 0:
										[controlCenterBottomView setQuickLauncherShowing:@NO];
										break;
									case 1:
										[controlCenterBottomView setQuickLauncherShowing:@YES];
										break;
									case 2:
										[controlCenterBottomView setQuickLauncherShowing:@YES];
										quickLaunchAutoDismissed = NO;
										break;
									default:
										[controlCenterBottomView setQuickLauncherShowing:@NO];
										break;
								}
							}
                            }];
                            });
            }
        } else {
            controlCenterOriginalView.hidden = NO;
            CGFloat width = screenWidth();
            CGFloat height = screenHeight();
            controlCenterOriginalView.layer.bounds = CGRectMake(0.0, 0.0, width, auxoBottomHeight() * 2.0);
            controlCenterOriginalView.layer.position = CGPointMake(width / 2.0, height);
            [contentView addSubview:controlCenterOriginalView];
            [contentView addSubview:dimView];
            iconExpectedPosition = iconView.layer.position;
            iconExpectedPosition.y -= auxoIconOffset();
            CGPoint iconViewPosition = iconExpectedPosition;
            iconViewPosition.y = screenHeight();
            [iconView.layer removeAnimationForKey:@"position"];
            iconView.layer.position = iconViewPosition;
            UIView *pageScrollView = pageView.subviews.firstObject;
            CGRect bounds = pageView.layer.bounds;
            CGPoint position = pageScrollView.layer.position;
            bounds.size.width /= auxoPageScale();
            position.x = bounds.size.width / 2.0;
            pageView.layer.bounds = bounds;
            pageScrollView.layer.position = position;
            [switcherController _bringIconViewToFront];
            SBChevronView *chevronView = CHIvar(controlCenterOriginalView, _contentView, SBControlCenterContentView * const).grabberView.chevronView;
            [chevronView setState:0 animated:NO];
			peopleView.frame = (CGRect){CGPointMake(0.0, UminoIsPortrait(NO) ? -45 : -45), peopleView.frame.size};
            if (continuePresentation) {
                continuePresentation = NO;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
                    xTranslationFix = YES;
                    [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                        iconView.layer.position = iconExpectedPosition;
                        controlCenterOriginalView.layer.position = CGPointMake(width / 2.0, height - auxoBottomHeight());
                        iconAlphaUpdate(1.0, YES);
                        wallpaperAlphaUpdate(1.0, 1.0);
                        } completion:^(BOOL finished) {
                            [chevronView setState:1 animated:YES];
                            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                            }];
                            });
            }
        }
    }
}

- (void)animateDismissalToDisplayLayout:(SBDisplayLayout *)layout withCompletion:(void (^)(BOOL))completion
{
    %orig;
    if (umino == Auxo && [pageView.layer animationForKey:@"transform"] != nil) {
        CABasicAnimation *anim = (CABasicAnimation *)[pageView.layer animationForKey:@"transform"];
        CGPoint translation = CGPointApplyAffineTransform(CGPointZero, CATransform3DGetAffineTransform([anim.fromValue CATransform3DValue]));
        [pageView.layer removeAnimationForKey:@"transform"];
        CGFloat scale = auxoPageScale();
        CGFloat positionY = - auxoPageOffset();
        pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), 0.0, positionY);
        [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
            pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(maxScale(), maxScale()), - translation.x / scale, 0.0);
        } completion:NULL];
    }
    if (umino == QuickSwitcher) {
        if (needDismissal) {
            needDismissal = NO;
            CGFloat positionX = screenWidth() / 2.0;
            CGFloat endPositionY = screenHeight(), startPositionY = endPositionY - iconListHeight();
            iconListView.layer.position = CGPointMake(positionX, startPositionY);
            [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                iconListView.layer.position = CGPointMake(positionX, endPositionY);
				[iconListView normalizeTouchLocation];
                wallpaperAlphaUpdate(0.0, 0.0);
                pageView.alpha = 1.0;
                artworkView.alpha = 0.0;
                zoomedArtworkView.alpha = 0.0;
            } completion:NULL];
        }
        umino = ControlCenter;
    } else if (umino == AppSwitcher) {
        if (needDismissal) {
            needDismissal = NO;
            [iconView.layer removeAnimationForKey:@"position"];
            iconView.layer.position = iconExpectedPosition;
            iconExpectedPosition.y = screenHeight();
            [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                iconView.layer.position = iconExpectedPosition;
                wallpaperAlphaUpdate(0.0, 0.0);
                pageView.alpha = 1.0;
                artworkView.alpha = 0.0;
                zoomedArtworkView.alpha = 0.0;
            } completion:NULL];
        }
        umino = ControlCenter;
    } else if (umino == Auxo) {
        if (needDismissal) {
            needDismissal = NO;
            if (phone) {
                CGFloat positionX = screenWidth() / 2.0;
                CGFloat height = screenHeight();
                controlCenterTopView.layer.position = CGPointMake(positionX, auxoTopHeight());
                controlCenterBottomView.layer.position = CGPointMake(positionX, height - auxoBottomHeight());
                [iconView.layer removeAnimationForKey:@"position"];
                iconView.layer.position = iconExpectedPosition;
                iconExpectedPosition.y = height;
                void (^scrollingDoneBlock)(void) = ^(){
                    [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                        controlCenterTopView.layer.position = CGPointMake(positionX, 0.0);
                        controlCenterBottomView.layer.position = CGPointMake(positionX, height);
                        iconView.layer.position = iconExpectedPosition;
                        wallpaperAlphaUpdate(0.0, 0.0);
                        pageView.alpha = 1.0;
                        artworkView.alpha = 0.0;
                        zoomedArtworkView.alpha = 0.0;
                        sliderItem(0, NO).contentOffset = CGPointZero;
                    } completion:NULL];
                };
                void (^originalScrollingDoneBlock)(void) = CHIvar(pageController, _scrollDoneBlock, id const);
                if (originalScrollingDoneBlock) {
                    CHIvar(pageController, _scrollDoneBlock, __strong id) = ^(){
                        originalScrollingDoneBlock();
                        scrollingDoneBlock();
                    };
                } else {
                    scrollingDoneBlock();
                }
            } else {
                CGFloat positionX = screenWidth() / 2.0;
                CGFloat height = screenHeight();
                controlCenterOriginalView.layer.position = CGPointMake(positionX, height - auxoBottomHeight());
                [iconView.layer removeAnimationForKey:@"position"];
                iconView.layer.position = iconExpectedPosition;
                iconExpectedPosition.y = screenHeight();
                void (^scrollingDoneBlock)(void) = ^(){
                    [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                        controlCenterOriginalView.layer.position = CGPointMake(positionX, height);
                        iconView.layer.position = iconExpectedPosition;
                        wallpaperAlphaUpdate(0.0, 0.0);
                        pageView.alpha = 1.0;
                        artworkView.alpha = 0.0;
                        sliderItem(0, NO).contentOffset = CGPointZero;
                    } completion:NULL];
                };
                void (^originalScrollingDoneBlock)(void) = CHIvar(pageController, _scrollDoneBlock, id const);
                if (originalScrollingDoneBlock) {
                    CHIvar(pageController, _scrollDoneBlock, __strong id) = ^(){
                        originalScrollingDoneBlock();
                        scrollingDoneBlock();
                    };
                } else {
                    scrollingDoneBlock();
                }
            }
        }
        umino = ControlCenter;
    }
}

- (void)switcherWasDismissed:(BOOL)animated
{
    %orig;
    umino = ControlCenter;
    noScale = NO;
    noPageScroll = NO;
    noIconScroll = NO;
    ignoreGesture = NO;
    needDismissal = NO;
    xTranslationFix = NO;
    hangingFix = NO;
    slidingDismiss = NO;
    continuePresentation = NO;
    suppressAnimation = NO;
    keepAllItems = NO;
    [backlightController setIdleTimerDisabled:NO forReason:kUmino];
    wallpaperAlphaUpdate(0.0, 0.0);
    pageView.alpha = 1.0;
    iconListView.hidden = YES;
    [iconListView removeFromSuperview];
    peopleView.hidden = NO;
    if (phone) {
        controlCenterTopView.hidden = YES;
        [controlCenterTopView removeFromSuperview];
        controlCenterBottomView.hidden = YES;
        [controlCenterBottomView removeFromSuperview];		
    } else {
        controlCenterOriginalView.hidden = YES;
        [controlCenterOriginalView removeFromSuperview];
    }
    artworkView.alpha = 0.0;
    [artworkView removeFromSuperview];
    zoomedArtworkView.alpha = 0.0;
    [zoomedArtworkView removeFromSuperview];
    homeScreenIconView.transform = CGAffineTransformIdentity;
    homeScreenIconView._iconImageView.alternateIconView.alpha = 0.0;
    closeAllAppsGestureView.hidden = YES;
    [closeAllAppsGestureView removeFromSuperview];
}

- (BOOL)switcherScroller:(SBAppSwitcherPageViewController *)scroller displayItemWantsToBeKeptInViewHierarchy:(SBDisplayItem *)item
{
    if (keepAllItems) {
        return YES;
    }
    if (umino == Auxo && phone) {
        NSUInteger index = [displayLayouts(YES) indexOfObject:item];
        return %orig || (ABS(index - currentIndex) < 3);
    }
    return %orig;
}

- (BOOL)switcherScroller:(SBAppSwitcherPageViewController *)scroller isDisplayItemRemovable:(SBDisplayItem *)item
{
    if (umino == Auxo && !gridSwitcherWorkaround) {
        return [item.displayIdentifier isEqualToString:@"com.apple.springboard"] ? YES : %orig;
    } else {
        return %orig;
    }
}

- (void)_updateSnapshots
{
    %orig;
}

- (void)switcherScroller:(SBAppSwitcherPageViewController *)scroller displayItemWantsToBeRemoved:(SBDisplayItem *)item
{
    if (umino == Auxo && !gridSwitcherWorkaround) {
        if ([item.displayIdentifier isEqualToString:@"com.apple.springboard"]) {
            SBAppSwitcherItemScrollView *homeScreenItem = sliderItem(0, NO);
            NSString *nowPlayingApplication = ((SBMediaController *)[NSClassFromString(@"SBMediaController") sharedInstance]).nowPlayingApplication.bundleIdentifier;
            NSArray *layouts = displayLayouts(NO);
            for (NSInteger i = layouts.count - 1; i >= 0; i--) {
                SBDisplayItem *aItem = [layouts[i] displayItems].firstObject;
                NSString *application = aItem.displayIdentifier;
                if ([application isEqualToString:@"com.apple.springboard"]) {
                } else if ([application isEqualToString:nowPlayingApplication]) {
                    if (!closeAllAppsExcludeNowPlaying) {
                        %orig(scroller, aItem);
                    }
                } else {
                    if (![closeAllAppsExceptions[application] boolValue]) {
                        %orig(scroller, aItem);
                    }
                }
            }
            pageView.userInteractionEnabled = NO;
            iconView.userInteractionEnabled = NO;
            NSArray *items = sliderItems(NO);
            [items enumerateObjectsUsingBlock:^(SBAppSwitcherItemScrollView *view, NSUInteger index, BOOL *stop) {
                view.transform = CGAffineTransformIdentity;
                view.alpha = 1.0;
                view.layer.position = CGPointMake([pageController _centerOfIndex:index + sliderContinuityCount()].x, pageExpectedSize.height / 2.0);
                view.layer.bounds = CGRectMake(0, 0, pageExpectedSize.width, pageExpectedSize.height);
				view.contentSize = CGSizeMake(pageExpectedSize.width, pageExpectedSize.height * 2);
                view.contentOffset = CGPointMake(0, - pageExpectedSize.height * 2);
            }];
            iconAlphaUpdate(0.0, NO);
            [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                for (SBAppSwitcherItemScrollView *view in items) {
                    view.contentOffset = CGPointZero;
                }
                iconAlphaUpdate(1.0, NO);
            } completion:^(BOOL finished){
                if ([homeScreenItem.layer animationForKey:@"bounds"] == nil) {
                    if (phone) {
                        [contentView sendSubviewToBack:controlCenterTopView];
                        [contentView sendSubviewToBack:controlCenterBottomView];
                    } else {
                        [contentView sendSubviewToBack:controlCenterOriginalView];
                    }
                    pageView.userInteractionEnabled = YES;
                    iconView.userInteractionEnabled = YES;
                    [homeScreenItem.delegate scrollViewDidEndDecelerating:homeScreenItem];
                    if (closeAllAppsBackToHomeScreen) {
                        [switcherController switcherScroller:pageController itemTapped:displayLayouts(NO)[0]];
                    }
                }
            }];
        } else {
            %orig;
			if (noSendBack == 0) {
				if (phone) {
					[contentView sendSubviewToBack:controlCenterTopView];
					[contentView sendSubviewToBack:controlCenterBottomView];
				} else {
					[contentView sendSubviewToBack:controlCenterOriginalView];
				}
			}
        }
    } else {
        %orig;
    }
}

%new
- (void)showArtwork:(UIImage *)image action:(NSInteger)action
{
    if (image == nil) {
        image = imageResource(@"AlbumArtwork");
    }
    if (action == 0) {
        if (artworkView.alpha == 0.0) {
            if (phone) {
                artworkView.image = image;
                zoomedArtworkView.image = image;
                CGRect startFrame1 = CGRectMake(0.0, auxoTopHeight(), screenWidth(), screenHeight() - auxoTopHeight() - auxoBottomHeight()), endFrame1 = startFrame1;
                CGRect startFrame2 = contentView.bounds, endFrame2 = startFrame2;
                startFrame1.origin.y = contentView.bounds.size.height;
                startFrame2.origin.y = contentView.bounds.size.height;
                artworkView.frame = startFrame1;
                zoomedArtworkView.frame = startFrame2;
                [contentView addSubview:artworkView];
                [contentView addSubview:zoomedArtworkView];
                [contentView sendSubviewToBack:artworkView];
                [contentView sendSubviewToBack:zoomedArtworkView];
                [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    artworkView.frame = endFrame1;
                    pageView.alpha = 0.0;
                    iconView.alpha = 0.0;
                    artworkView.alpha = 1.0;
                    dimView.alpha = 0.0;
                } completion:NULL];
                [animationFactory _animateWithAdditionalDelay:0.05 options:0 actions:^{
                    zoomedArtworkView.frame = endFrame2;
                    zoomedArtworkView.alpha = 1.0;
                } completion:NULL];
            } else {
                artworkView.image = image;
                artworkView.bounds = CGRectMake(0.0, 0.0, auxoPadArtworkSize(), auxoPadArtworkSize());
                CGFloat x = screenWidth() / 2.0, height = screenHeight();
                CGPoint startCenter = CGPointMake(x, height + auxoPadArtworkSize() / 2.0);
                CGPoint endCenter = CGPointMake(x, (height - auxoBottomHeight()) / 2.0);
                artworkView.center = startCenter;
                [contentView addSubview:artworkView];
                [contentView sendSubviewToBack:artworkView];
                [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                    artworkView.center = endCenter;
                    pageView.alpha = 0.0;
                    iconView.alpha = 0.0;
                    artworkView.alpha = 1.0;
                    dimView.alpha = 0.0;
                } completion:NULL];
            }
        } else {
            [self hideArtwork];
        }
    } else if (ABS(action) == 1) {
        if (artworkView.alpha == 0.0) {
            if (phone) {
                artworkView.image = image;
                zoomedArtworkView.image = image;	
            } else {
                artworkView.image = image;
            }
        } else {
            if (phone) {
                UIImage *oldImage = artworkView.image;
                CGRect frame1 = artworkView.frame;
                CGRect frame2 = zoomedArtworkView.frame;
                UIImageView *tempArtworkView = [[UIImageView alloc]initWithFrame:frame1];
                tempArtworkView.contentMode = UIViewContentModeScaleAspectFill;
                tempArtworkView.clipsToBounds = YES;
                tempArtworkView.image = oldImage;
                UIImageView *tempZoomedArtworkView = [[UIImageView alloc]initWithFrame:frame2];
                tempZoomedArtworkView.contentMode = UIViewContentModeScaleAspectFill;
                tempZoomedArtworkView.clipsToBounds = YES;
                tempZoomedArtworkView.image = oldImage;
                [contentView insertSubview:tempArtworkView belowSubview:zoomedArtworkView];
                [contentView insertSubview:tempZoomedArtworkView belowSubview:tempArtworkView];
                artworkView.frame = CGRectMake(action > 0 ? frame1.size.width : -frame1.size.width, frame1.origin.y, frame1.size.width, frame1.size.height);
                artworkView.image = image;
                zoomedArtworkView.frame = CGRectMake(action > 0 ? frame2.size.width : -frame2.size.width, frame2.origin.y, frame2.size.width, frame2.size.height);
                zoomedArtworkView.image = image;
                [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                    artworkView.frame = frame1;
                    zoomedArtworkView.frame = frame2;
                    tempArtworkView.frame = CGRectMake(action > 0 ? -frame1.size.width : frame1.size.width, frame1.origin.y, frame1.size.width, frame1.size.height);
                    tempZoomedArtworkView.frame = CGRectMake(action > 0 ? -frame2.size.width : frame2.size.width, frame2.origin.y, frame2.size.width, frame2.size.height);
                } completion:^(BOOL finished){
                    [tempArtworkView removeFromSuperview];
                    [tempZoomedArtworkView removeFromSuperview];
                }];
            } else {
                UIImage *oldImage = artworkView.image;
                CGFloat width = screenWidth(), height = screenHeight();
                CGPoint center = CGPointMake(width / 2.0, (height - auxoBottomHeight()) / 2.0);
                UIImageView *tempArtworkView = [[UIImageView alloc]initWithFrame:artworkView.frame];
                tempArtworkView.contentMode = UIViewContentModeScaleAspectFill;
                tempArtworkView.clipsToBounds = YES;
                tempArtworkView.image = oldImage;
                [contentView insertSubview:tempArtworkView belowSubview:artworkView];
                artworkView.center = CGPointMake(center.x + width * (action > 0 ? +1 : -1), center.y);
                artworkView.image = image;
                [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                    artworkView.center = center;
                    tempArtworkView.center = CGPointMake(center.x + width * (action > 0 ? -1 : +1), center.y);
                } completion:^(BOOL finished){
                    [tempArtworkView removeFromSuperview];
                }];
            }
        }
    } else if (action > 1) {
        action--;
        if (albumArtworkAutoDisplay & action) {
            if (activeGestureRecognizer.state != UIGestureRecognizerStateBegan && activeGestureRecognizer.state != UIGestureRecognizerStateChanged && artworkView.alpha == 0.0) {
                [self showArtwork:image action:0];
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideArtwork) object:nil];
                [self performSelector:@selector(hideArtwork) withObject:nil afterDelay:albumArtworkAutoDismissDelay + 0.4];
            }
        }
    }
}

%new
- (void)hideArtwork
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideArtwork) object:nil];
    if (artworkView.alpha > 0.0) {
        if (phone) {
            CGRect startFrame1 = CGRectMake(0.0, auxoTopHeight(), screenWidth(), screenHeight() - auxoTopHeight() - auxoBottomHeight()), endFrame1 = startFrame1;
            CGRect startFrame2 = contentView.bounds, endFrame2 = startFrame2;
            endFrame1.origin.y = contentView.bounds.size.height;
            endFrame2.origin.y = contentView.bounds.size.height;
            artworkView.frame = startFrame1;
            zoomedArtworkView.frame = startFrame2;
            zoomedArtworkView.alpha = 0.0;
            [animationFactory _animateWithAdditionalDelay:0.01 options:0 actions:^{
                artworkView.frame = endFrame1;
                pageView.alpha = 1.0;
                iconView.alpha = 1.0;
                artworkView.alpha = 0.0;
                dimView.alpha = 1.0;
            } completion:NULL];
            [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                zoomedArtworkView.frame = endFrame2;
                zoomedArtworkView.alpha = 0.0;
            } completion:NULL];
        } else {
            CGFloat x = screenWidth() / 2.0, height = screenHeight();
            CGPoint startCenter = CGPointMake(x, (height - auxoBottomHeight()) / 2.0);
            CGPoint endCenter = CGPointMake(x, height + auxoPadArtworkSize() / 2.0);
            artworkView.center = startCenter;
            [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                artworkView.center = endCenter;
                pageView.alpha = 1.0;
                iconView.alpha = 1.0;
                artworkView.alpha = 0.0;
                dimView.alpha = 1.0;
            } completion:NULL];
        }
    }
}

%new
- (void)artworkTapGesture:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self hideArtwork];
    }
}

%new
- (void)artworkLongPressGesture:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (phone) {
            NSString *application = CHIvar(controlCenterBottomView, _nowPlayingController, MPUNowPlayingController * const).nowPlayingAppDisplayID;
            if (application.length > 0) {
                [[UIApplication sharedApplication]launchApplicationWithIdentifier:application suspended:NO];
            }	
        } else {
            [controlCenterOriginalView.mediaControlsView.trackInformationView _touchControlTapped:nil];
        }
    }
}

%new
- (void)artworkLeftSwipeGesture:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if (phone) {
            [controlCenterBottomView tapPlayerButton:UminoPlayerButtonTypeFastForward];	
        } else {
            MPUTransportControlsView *controlsView = controlCenterOriginalView.mediaControlsView.transportControlsView;
            UIButton *rightButton = controlsView._rightButton;
            if (rightButton.tag == 8) {
                [controlsView _transportControlTap:rightButton];
            }
        }
    }
}

%new
- (void)artworkRightSwipeGesture:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        if (phone) {
            [controlCenterBottomView tapPlayerButton:UminoPlayerButtonTypeRewind];	
        } else {
            MPUTransportControlsView *controlsView = controlCenterOriginalView.mediaControlsView.transportControlsView;
            UIButton *leftButton = controlsView._leftButton;
            if (leftButton.tag == 1) {
                [controlsView _transportControlTap:leftButton];
            }
        }
    }
}

%new
- (void)artworkDownSwipeGesture:(UIGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [self hideArtwork];
    }
}

%end

%hook SBControlCenterController

- (void)beginTransitionWithTouchLocation:(CGPoint)location
{
    umino = ControlCenter;
    if (!self.isUILocked && !self.isPresented && !disabledInCurrentApp()) {
        if (location.x < cornerWidth()) {
            umino = leftBehavior;
        } else if (location.x > screenWidth() - cornerWidth()) {
            umino = rightBehavior;
        } else {
            umino = centerBehavior;
        }
        if (umino == HomeScreen) {
            umino = centerBehavior;
        }
    }
    if (umino == QuickSwitcher || umino == AppSwitcher || umino == Auxo) {
        ignoreGesture = isAppSwitcherShowing() || ![switcherController allowShowHide] || [workspace alertManager].activeAlert != nil || ((SBIconController *)[NSClassFromString(@"SBIconController") sharedInstance]).hasAnimatingFolder || ((SBSearchGesture *)[NSClassFromString(@"SBSearchGesture") sharedInstance]).activated || workspace.currentTransaction != nil || [frontMostApplication()._stateSettings boolForStateSetting:16];
        if (ignoreGesture) {
            return;
        }
        noScale = YES;
        noPageScroll = YES;
        noIconScroll = YES;
        hangingFix = YES;
		touchLocation = location;
		noSendBack = 0;
		[uiController handleMenuDoubleTap];
		[backlightController setIdleTimerDisabled:YES forReason:kUmino];
	} else {
		%orig;
	}
}

- (void)updateTransitionWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity
{
	if (umino == QuickSwitcher) {
		if (ignoreGesture) {
			return;
		}
		if (!accessAppSwitcher) {
			touchLocation = location;
			CGFloat max = maxScale();
			CGFloat prefered = preferedScale();
			CGFloat scale = currentScale(NO);
			static const CGFloat minInput = -0.4, minDelta = 0.36, constantDelta = 0.24;
			if (scale < minInput) {
				scale = prefered - minDelta;
			} else if (scale < prefered) {
				scale = prefered - minDelta * sin((prefered - scale) / (prefered - minInput) * M_PI_2);
			}
			scale -= constantDelta;
			CGFloat translationY = pageOffset() * (max - scale) / (max - prefered);
			void (^block)() = ^{
				pageView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, -translationY, 0), scale, scale, 1);
				wallpaperAlphaUpdate((max - scale) / (max - (prefered - minDelta)), 1.0);
				[iconListView setTouchLocation:[iconListView convertPoint:location fromView:contentView]];
			};
			if (forceAnimation) {
				forceAnimation = NO;
				[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:NULL];
			} else {
				block();
			}
			pageAlphaUpdate(0.0, !accessHomeScreen && !isAtHomeScreen(), forceAnimation);
		} else {
			touchLocation = location;
			CGFloat min = minScale();
			CGFloat max = maxScale();
			CGFloat scale = currentScale();
			CGFloat prefered = preferedScale();
			CGFloat translationY = 0.0;
			if (scale > prefered) {
				translationY = pageOffset() * (max - scale) / (max - prefered);
			} else {
				translationY = pageOffset() * (scale - min) / (prefered - min);
			}
			void (^block)() = ^{
				pageView.layer.transform = CATransform3DScale(CATransform3DMakeTranslation(0, -translationY, 0), scale, scale, 1);
				wallpaperAlphaUpdate((max - scale) / (max - min), 1.0);
				SBAppSwitcherItemScrollView *currentItem = sliderItem(currentIndex, YES);
				currentItem.contentOffset = CGPointMake(0.0, [currentItem _rubberBandOffsetForOffset:itemOffset() maxOffset:currentItem.contentSize.height - currentItem.bounds.size.height minOffset:0 range:currentItem.bounds.size.height outside:NULL]);
				if (scale > transitionScale()) {
					[iconListView setTouchLocation:[iconListView convertPoint:location fromView:contentView]];
					[iconListView transitIn:iconController animated:!forceAnimation];
					pageAlphaUpdate(0.0, !accessHomeScreen && !isAtHomeScreen(), !forceAnimation);
				} else {
					[iconListView transitOut:iconController animated:!forceAnimation];
					pageAlphaUpdate(1.0, !accessHomeScreen && !isAtHomeScreen(), !forceAnimation);
				}
			};
			if (forceAnimation) {
				forceAnimation = NO;
				[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:NULL];
			} else {
				block();
			}
		}
	} else if (umino == AppSwitcher) {
		if (ignoreGesture) {
			return;
		}
		touchLocation = location;
		CGFloat min = minScale();
		CGFloat max = maxScale();
		CGFloat scale = currentScale();
		CGFloat progress = MIN((max - scale) / (max - min), 1.0);
		CGPoint iconViewPosition = iconExpectedPosition;
		iconViewPosition.y = screenHeight();
		iconViewPosition.y -= (iconViewPosition.y - iconExpectedPosition.y) * progress;
		void (^block)() = ^{
			[switcherController _updatePageViewScale:scale];
			iconAlphaUpdate(progress, YES);
			wallpaperAlphaUpdate(progress, 0.0);
			iconView.layer.position = iconViewPosition;
			NSUInteger indexToRemove = openToLastApp ? startingIndex : currentIndex;
			SBAppSwitcherItemScrollView *currentItem = sliderItem(indexToRemove, YES);
			currentItem.contentOffset = CGPointMake(0.0, [currentItem _rubberBandOffsetForOffset:itemOffset() maxOffset:currentItem.contentSize.height - currentItem.bounds.size.height minOffset:0 range:currentItem.bounds.size.height outside:NULL]);
			if (openToLastApp) {
				static double (^ const curvedValue)(double) = ^(double value){
					if (value <= 0.5) {
						return pow(value * 2.0, 3.0) / 2.0;
					} else {
						return 1.0 - pow((1 - value) * 2.0, 3.0) / 2.0;
					}
				};
				double curvedProgress = curvedValue(MIN(MAX(progress, 0.0), 1.0));
				CGFloat startOffset = [pageController normalizedOffsetOfIndex:currentIndex];
				CGFloat endOffset = [pageController normalizedOffsetOfIndex:startingIndex];
				CGFloat offset = startOffset * (1.0 - curvedProgress) + endOffset * curvedProgress;
				[pageController setNormalizedOffset:offset];
				[iconController setNormalizedOffset:offset];
			}
		};
		if (forceAnimation) {
			forceAnimation = NO;
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:NULL];
		} else {
			block();
		}
	} else if (umino == Auxo) {
		if (ignoreGesture) {
			return;
		}
		if (phone) {
			touchLocation = location;
			double progress = currentProgress();
			CGFloat scale = maxScale() * (1.0 - progress) + auxoPageScale() * progress;
			CGFloat positionX = screenWidth() / 2.0;
			CGFloat positionY = - auxoPageOffset() * pow(progress, reachabilityMode ? 2.0 : 3.0);
			CGPoint iconViewPosition = iconExpectedPosition;
			iconViewPosition.y = screenHeight();
			iconViewPosition.y -= (iconViewPosition.y - iconExpectedPosition.y) * progress;
			void (^block)() = ^{
				iconAlphaUpdate(progress, YES);
				wallpaperAlphaUpdate(progress, progress);
				pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(scale, scale, 1), 0, positionY, 0);
				iconView.layer.position = iconViewPosition;
				controlCenterTopView.layer.position = CGPointMake(positionX, auxoTopHeight() * progress);
				controlCenterBottomView.layer.position = CGPointMake(positionX, screenHeight() - auxoBottomHeight() * progress);
				if (openToLastApp) {
					static double (^ const curvedValue)(double) = ^(double value){
						if (value <= 0.5) {
							return pow(value * 2.0, 3.0) / 2.0;
						} else {
							return 1.0 - pow((1 - value) * 2.0, 3.0) / 2.0;
						}
					};
					double curvedProgress = curvedValue(MIN(MAX(progress, 0.0), 1.0));
					CGFloat startOffset = [pageController normalizedOffsetOfIndex:currentIndex];
					CGFloat endOffset = [pageController normalizedOffsetOfIndex:startingIndex];
					CGFloat offset = startOffset * (1.0 - curvedProgress) + endOffset * curvedProgress;
					[pageController setNormalizedOffset:offset];
					[iconController setNormalizedOffset:offset];
				}
			};
			if (forceAnimation) {
				forceAnimation = NO;
				[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:NULL];
			} else {
				block();
			}
		} else {
			touchLocation = location;
			double progress = currentProgress();
			CGFloat scale = maxScale() * (1.0 - progress) + auxoPageScale() * progress;
			CGFloat positionX = screenWidth() / 2.0;
			CGFloat positionY = - auxoPageOffset() * pow(progress, 2.0);
			CGPoint iconViewPosition = iconExpectedPosition;
			iconViewPosition.y = screenHeight();
			iconViewPosition.y -= (iconViewPosition.y - iconExpectedPosition.y) * progress;
			void (^block)() = ^{
				iconAlphaUpdate(progress, YES);
				wallpaperAlphaUpdate(progress, progress);
				pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(scale, scale, 1), 0, positionY, 0);
				iconView.layer.position = iconViewPosition;
				controlCenterOriginalView.layer.position = CGPointMake(positionX, screenHeight() - auxoBottomHeight() * progress);
				if (openToLastApp) {
					static double (^ const curvedValue)(double) = ^(double value){
						if (value <= 0.5) {
							return pow(value * 2.0, 3.0) / 2.0;
						} else {
							return 1.0 - pow((1 - value) * 2.0, 3.0) / 2.0;
						}
					};
					double curvedProgress = curvedValue(MIN(MAX(progress, 0.0), 1.0));
					CGFloat startOffset = [pageController normalizedOffsetOfIndex:currentIndex];
					CGFloat endOffset = [pageController normalizedOffsetOfIndex:startingIndex];
					CGFloat offset = startOffset * (1.0 - curvedProgress) + endOffset * curvedProgress;
					[pageController setNormalizedOffset:offset];
					[iconController setNormalizedOffset:offset];
				}
			};
			if (forceAnimation) {
				forceAnimation = NO;
				[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:NULL];
			} else {
				block();
			}
		}
	} else {
		%orig;
	}
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
		if (activeGestureRecognizer.state != UIGestureRecognizerStateChanged && hangingFix) {
		[uiController clickedMenuButton];
		}
		});
}

- (void)endTransitionWithVelocity:(CGPoint)velocity completion:(void(^)(void))completion
{
	if (umino == QuickSwitcher) {
		if (ignoreGesture) {
			goto CompletionTag1;
		}
		if (!accessAppSwitcher) {
			hangingFix = NO;
			[iconListView cancelTouch];
			[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
			if (needDismissal) {
				needDismissal = NO;
			} else {
				[[UIApplication sharedApplication] endIgnoringInteractionEvents];
				goto CompletionTag1;
			}
			CGFloat width = screenWidth();
			CGFloat height = screenHeight();
			CGFloat endScale = maxScale();
			CGFloat scaleBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.scale"]doubleValue];
			CGFloat positionYBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.translation.y"]doubleValue];
			BOOL animationFix = [pageView.layer animationForKey:@"transform"] != nil;
			abortAnimation(pageView.layer, @"transform");
			abortAnimation(pageView.layer, @"position");
			abortAnimation(iconListView.layer, @"position");
			if (animationFix) {
				pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(scaleBeforeAborted, scaleBeforeAborted, 1.0), 0.0, positionYBeforeAborted, 0.0);
			}
			UIView *itemView = sliderItem(currentIndex, YES).item.view;
			if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
				[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
			}
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
				pageView.layer.transform = CATransform3DMakeScale(endScale, endScale, 1);
				iconListView.layer.position = CGPointMake(width / 2.0, height);
				wallpaperAlphaUpdate(0.0, 0.0);
				[iconListView normalizeTouchLocation];
				[pageController setOffsetToIndex:currentIndex animated:NO];
				[iconController setOffsetToIndex:currentIndex animated:NO];
			} completion:^(BOOL finished) {
				suppressAnimation = YES;
				noXTranslation = YES;
				[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
				noXTranslation = NO;
				suppressAnimation = NO;
				[[UIApplication sharedApplication] endIgnoringInteractionEvents];
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
					if (isAppSwitcherShowing()) {
					[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
					}
					});
			}];
		} else {
			hangingFix = NO;
			if (itemOffset() > 0.0) {
				SBAppSwitcherItemScrollView *currentItem = sliderItem(currentIndex, YES);
				bool (^shouldCloseApp)(CGFloat, CGFloat) = ^(CGFloat offsetY, CGFloat velocityY){
					return ((CALayer *)pageView.layer.presentationLayer).transform.m11 == 1.0 && offsetY > currentItem.bounds.size.height * 0.5 && velocityY < 0.0;
				};
				if (shouldCloseApp(itemOffset(), velocity.y) && [switcherController switcherScroller:pageController isDisplayItemRemovable:[displayLayouts(YES)[currentIndex] displayItems].firstObject]) {
					[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
					[currentItem setContentOffset:CGPointMake(0.0, currentItem.bounds.size.height * 2.0) animated:YES];
					[[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
					[switcherController switcherScroller:pageController displayItemWantsToBeRemoved:[displayLayouts(YES)[currentIndex] displayItems].firstObject];
					[[UIApplication sharedApplication] endIgnoringInteractionEvents];
				} else {
					[currentItem setContentOffset:CGPointZero animated:YES];
				}
			} else {
				BOOL gestureCancelled = velocity.y > 0.0;
				if (gestureCancelled) {
					[iconListView transitIn:iconController animated:YES];
					[iconListView cancelTouch];
					[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
					if (needDismissal) {
						needDismissal = NO;
					} else {
						[[UIApplication sharedApplication] endIgnoringInteractionEvents];
						goto CompletionTag1;
					}
				} else {
					[iconListView transitOut:iconController animated:YES];
					pageAlphaUpdate(1.0, !accessHomeScreen && !isAtHomeScreen(), YES);
				}
				CGFloat width = screenWidth();
				CGFloat height = screenHeight();
				CGFloat endScale = gestureCancelled ? maxScale() : minScale();
				CGFloat endPositionY = height / 2.0 + (gestureCancelled ? 0.0 : switcherController._switcherThumbnailVerticalPositionOffset);
				CGFloat scaleBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.scale"]doubleValue];
				CGFloat positionYBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.translation.y"]doubleValue];
				BOOL animationFix = [pageView.layer animationForKey:@"transform"] != nil;
				abortAnimation(pageView.layer, @"transform");
				abortAnimation(pageView.layer, @"position");
				if (gestureCancelled) {
					abortAnimation(iconListView.layer, @"position");
					UIView *itemView = sliderItem(currentIndex, YES).item.view;
					if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
						[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
					}
				}
				if (animationFix) {
					pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(scaleBeforeAborted, scaleBeforeAborted, 1.0), 0.0, positionYBeforeAborted, 0.0);
				}
				[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
					pageView.layer.transform = CATransform3DMakeScale(endScale, endScale, 1.0);
					pageView.layer.position = CGPointMake(width / 2.0, endPositionY);
					wallpaperAlphaUpdate(gestureCancelled ? 0.0 : 1.0, gestureCancelled ? 0.0 : 1.0);
					if (gestureCancelled) {
						iconListView.layer.position = CGPointMake(width / 2.0, height);
						[iconListView normalizeTouchLocation];
						[pageController setOffsetToIndex:currentIndex animated:NO];
						[iconController setOffsetToIndex:currentIndex animated:NO];
					}
				} completion:^(BOOL finished) {
					if (gestureCancelled) {
						suppressAnimation = YES;
						noXTranslation = YES;
						[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
						noXTranslation = NO;
						suppressAnimation = NO;
						[[UIApplication sharedApplication] endIgnoringInteractionEvents];
						dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
							if (isAppSwitcherShowing()) {
							[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
							}
							});
					} else {
						if (iconListView.alpha != 0.0) {
							[iconListView transitOut:iconController animated:YES];
							pageAlphaUpdate(1.0, !accessHomeScreen && !isAtHomeScreen(), YES);
							[[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
						}
					}
				}];
			}
		}
CompletionTag1:
		if (completion) {
			completion();
		}
		[backlightController setIdleTimerDisabled:NO forReason:kUmino];
	} else if (umino == AppSwitcher) {
		if (ignoreGesture) {
			goto CompletionTag2;
		}
		hangingFix = NO;
		if (itemOffset() > 0.0) {
			NSUInteger indexToRemove = openToLastApp ? startingIndex : currentIndex;
			SBAppSwitcherItemScrollView *currentItem = sliderItem(indexToRemove, YES);
			bool (^shouldCloseApp)(CGFloat, CGFloat) = ^(CGFloat offsetY, CGFloat velocityY){
				return ((CALayer *)pageView.layer.presentationLayer).transform.m11 == 1.0 && offsetY > currentItem.bounds.size.height * 0.5 && velocityY < 0.0;
			};
			if (shouldCloseApp(itemOffset(), velocity.y) && [switcherController switcherScroller:pageController isDisplayItemRemovable:[displayLayouts(YES)[indexToRemove] displayItems].firstObject]) {
				[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
				[currentItem setContentOffset:CGPointMake(0.0, currentItem.bounds.size.height * 2.0) animated:YES];
				[[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
				[switcherController switcherScroller:pageController displayItemWantsToBeRemoved:[displayLayouts(YES)[indexToRemove] displayItems].firstObject];
				[[UIApplication sharedApplication] endIgnoringInteractionEvents];
			} else {
				[currentItem setContentOffset:CGPointZero animated:YES];
			}
		} else {
			BOOL gestureCancelled = velocity.y > 0.0;
			if (gestureCancelled) {
				[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
				if (needDismissal) {
					needDismissal = NO;
				} else {
					[[UIApplication sharedApplication] endIgnoringInteractionEvents];
					goto CompletionTag2;
				}
			}
			CGFloat height = screenHeight();
			CGFloat endScale = gestureCancelled ? maxScale() : minScale();
			CGFloat endPositionY = height / 2.0 + (gestureCancelled ? 0.0 : switcherController._switcherThumbnailVerticalPositionOffset);
			if (gestureCancelled) {
				iconExpectedPosition.y = height;
				UIView *itemView = sliderItem(currentIndex, YES).item.view;
				if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
					[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
				}
			}
			CGFloat scaleBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.scale"]doubleValue];
			CGFloat positionYBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.translation.y"]doubleValue];
			BOOL animationFix = [pageView.layer animationForKey:@"transform"] != nil;
			abortAnimation(pageView.layer, @"transform");
			abortAnimation(pageView.layer, @"position");
			abortAnimation(iconView.layer, @"position");
			if (animationFix) {
				pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(scaleBeforeAborted, scaleBeforeAborted, 1.0), 0.0, positionYBeforeAborted, 0.0);
			}
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
				pageView.layer.transform = CATransform3DMakeScale(endScale, endScale, 1.0);
				pageView.layer.position = CGPointMake(screenWidth() / 2.0, endPositionY);
				iconView.layer.position = iconExpectedPosition;
				iconAlphaUpdate(gestureCancelled ? 0.0 : 1.0, YES);
				wallpaperAlphaUpdate(gestureCancelled ? 0.0 : 1.0, 0.0);
				if (openToLastApp) {
					NSUInteger index = gestureCancelled ? currentIndex : startingIndex;
					[pageController setOffsetToIndex:index animated:NO];
					[iconController setOffsetToIndex:index animated:NO];
				}
			} completion:^(BOOL finished) {
				if (gestureCancelled) {
					suppressAnimation = YES;
					[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
					suppressAnimation = NO;
					[[UIApplication sharedApplication] endIgnoringInteractionEvents];
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
						if (isAppSwitcherShowing()) {
						[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
						}
						});
				}
			}];
		}
CompletionTag2:
		if (completion) {
			completion();
		}
		[backlightController setIdleTimerDisabled:NO forReason:kUmino];
	} else if (umino == Auxo) {
		if (ignoreGesture) {
			goto CompletionTag3;
		}
		hangingFix = NO;
		if (phone) {
			BOOL gestureCancelled = currentProgress() < 1.0 && velocity.y > 0.0;
			if (gestureCancelled) {
				[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
				[pageController setOffsetToIndex:currentIndex animated:YES];
				[iconController setOffsetToIndex:currentIndex animated:YES];
				if (needDismissal) {
					needDismissal = NO;
				} else {
					[[UIApplication sharedApplication] endIgnoringInteractionEvents];
					goto CompletionTag3;
				}
			} else {
				xTranslationFix = YES;
			}
			CGFloat x = screenWidth() / 2.0;
			CGFloat height = screenHeight();
			CGFloat endScale = gestureCancelled ? maxScale() : auxoPageScale();
			CGFloat endPositionY = -(gestureCancelled ? 0.0 : auxoPageOffset());
			CGFloat endTopY = gestureCancelled ? 0.0 : auxoTopHeight();
			CGFloat endBottomY = gestureCancelled ? height : height - auxoBottomHeight();
			if (gestureCancelled) {
				iconExpectedPosition.y = height;
				UIView *itemView = sliderItem(currentIndex, YES).item.view;
				if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
					[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
				}
			}
			CGFloat scaleBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.scale"]doubleValue];
			CGFloat positionYBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.translation.y"]doubleValue];
			BOOL animationFix = [pageView.layer animationForKey:@"transform"] != nil;
			abortAnimation(pageView.layer, @"transform");
			abortAnimation(iconView.layer, @"position");
			abortAnimation(controlCenterTopView.layer, @"position");
			abortAnimation(controlCenterBottomView.layer, @"position");
			abortAnimation(dimView.layer, @"position");
			abortAnimation(dimView.layer, @"bounds");
			abortAnimation(dimView.layer, @"backgroundColor");
			if (iconView.layer.position.x != x) {
				CGPoint p = iconView.layer.position;
				p.x = x;
				iconView.layer.position = p;
			}
			if (gestureCancelled) {
				abortAnimation(pageView.layer, @"position");
			}
			if (animationFix) {
				pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(scaleBeforeAborted, scaleBeforeAborted, 1.0), 0.0, positionYBeforeAborted, 0.0);
			}
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
				pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(endScale, endScale, 1.0), 0.0, endPositionY, 0.0);
				iconView.layer.position = iconExpectedPosition;
				iconAlphaUpdate(gestureCancelled ? 0.0 : 1.0, YES);
				wallpaperAlphaUpdate(gestureCancelled ? 0.0 : 1.0, gestureCancelled ? 0.0 : 1.0);
				controlCenterTopView.layer.position = CGPointMake(x, endTopY);
				controlCenterBottomView.layer.position = CGPointMake(x, endBottomY);
				if (gestureCancelled) {
					pageView.layer.position = CGPointMake(x, height / 2.0);
				}
				if (openToLastApp) {
					NSUInteger index = gestureCancelled ? currentIndex : startingIndex;
					[pageController setOffsetToIndex:index animated:NO];
					[iconController setOffsetToIndex:index animated:NO];
				}
			} completion:^(BOOL finished) {
				if (gestureCancelled) {
					suppressAnimation = YES;
					[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
					suppressAnimation = NO;
					[[UIApplication sharedApplication] endIgnoringInteractionEvents];
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
						if (isAppSwitcherShowing()) {
						[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
						}
						});
				} else {
					if (!(UminoIsMinimalStyle(NO) && reachabilityMode)) {
						if ((isMediaPlaying() ? quickLaunchOptionWithMediaPlaying : quickLaunchOptionWithoutMediaPlaying) == 2) {
							[controlCenterBottomView dismissQuickLauncherAfterDelay:quickLaunchAutoDismissDelay];
						}
					} else {
						switch (isMediaPlaying() ? quickLaunchOptionWithMediaPlaying : quickLaunchOptionWithoutMediaPlaying) {
							case 0:
								[controlCenterBottomView setQuickLauncherShowing:@NO];
								break;
							case 1:
								[controlCenterBottomView setQuickLauncherShowing:@YES];
								break;
							case 2:
								[controlCenterBottomView setQuickLauncherShowing:@YES];
								quickLaunchAutoDismissed = NO;
								break;
							default:
								[controlCenterBottomView setQuickLauncherShowing:@NO];
								break;
						}
					}
				}
			}];
		} else {
			BOOL gestureCancelled = currentProgress() < 1.0 && velocity.y > 0.0;
			if (gestureCancelled) {
				[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
				[pageController setOffsetToIndex:currentIndex animated:YES];
				[iconController setOffsetToIndex:currentIndex animated:YES];
				if (needDismissal) {
					needDismissal = NO;
				} else {
					[[UIApplication sharedApplication] endIgnoringInteractionEvents];
					goto CompletionTag3;
				}
			} else {
				xTranslationFix = YES;
			}
			CGFloat x = screenWidth() / 2.0;
			CGFloat height = screenHeight();
			CGFloat endScale = gestureCancelled ? maxScale() : auxoPageScale();
			CGFloat endPositionY = -(gestureCancelled ? 0.0 : auxoPageOffset());
			CGFloat endBottomY = gestureCancelled ? height : height - auxoBottomHeight();
			if (gestureCancelled) {
				iconExpectedPosition.y = height;
				UIView *itemView = sliderItem(currentIndex, YES).item.view;
				if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
					[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
				}
			}
			CGFloat scaleBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.scale"]doubleValue];
			CGFloat positionYBeforeAborted = [[pageView.layer.presentationLayer valueForKeyPath:@"transform.translation.y"]doubleValue];
			BOOL animationFix = [pageView.layer animationForKey:@"transform"] != nil;
			abortAnimation(pageView.layer, @"transform");
			abortAnimation(iconView.layer, @"position");
			abortAnimation(controlCenterOriginalView.layer, @"position");
			abortAnimation(dimView.layer, @"position");
			abortAnimation(dimView.layer, @"bounds");
			abortAnimation(dimView.layer, @"backgroundColor");
			if (iconView.layer.position.x != x) {
				CGPoint p = iconView.layer.position;
				p.x = x;
				iconView.layer.position = p;
			}
			if (gestureCancelled) {
				abortAnimation(pageView.layer, @"position");
			}
			if (animationFix) {
				pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(scaleBeforeAborted, scaleBeforeAborted, 1.0), 0.0, positionYBeforeAborted, 0.0);
			}
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
				pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(endScale, endScale, 1.0), 0.0, endPositionY, 0.0);
				iconView.layer.position = iconExpectedPosition;
				iconAlphaUpdate(gestureCancelled ? 0.0 : 1.0, YES);
				wallpaperAlphaUpdate(gestureCancelled ? 0.0 : 1.0, gestureCancelled ? 0.0 : 1.0);
				controlCenterOriginalView.layer.position = CGPointMake(x, endBottomY);
				[CHIvar(controlCenterOriginalView, _contentView, SBControlCenterContentView * const).grabberView.chevronView setState:gestureCancelled ? 0 : 1 animated:NO];
				if (gestureCancelled) {
					pageView.layer.position = CGPointMake(x, height / 2.0);
				}
				if (openToLastApp) {
					NSUInteger index = gestureCancelled ? currentIndex : startingIndex;
					[pageController setOffsetToIndex:index animated:NO];
					[iconController setOffsetToIndex:index animated:NO];
				}
			} completion:^(BOOL finished) {
				if (gestureCancelled) {
					suppressAnimation = YES;
					[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
					suppressAnimation = NO;
					[[UIApplication sharedApplication] endIgnoringInteractionEvents];
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
						if (isAppSwitcherShowing()) {
						[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
						}
						});
				}
			}];
		}
CompletionTag3:
		if (completion) {
			completion();
		}
		[backlightController setIdleTimerDisabled:NO forReason:kUmino];
	} else {
		%orig;
	}
	if (ignoreGesture) {
		ignoreGesture = NO;
		umino = ControlCenter;
	}
}

%end

%hook SBFAnimationFactory

- (NSTimeInterval)duration
{
	return suppressAnimation ? 0.0 : %orig;
}

%end

%hook BSAnimationSettings

- (NSTimeInterval)duration
{
	return suppressAnimation ? 0.0 : %orig;
}

%end

%hook SBFAnimationFactorySettings

-(BOOL)slowAnimations
{
	return suppressAnimation ? YES : %orig;
}

-(CGFloat)slowDownFactor
{
	return suppressAnimation ? 0.000001 : %orig;
}

%end

%hook UIView

+ (void)_animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options factory:(SBFAnimationFactory *)factory animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
	if (suppressAnimation) {
		duration = 0.0;
	}
	%orig;
}

%end

%hook SBUIController

- (BOOL)clickedMenuButton
{
	if (!closeAllAppsGestureView->_done) {
		[closeAllAppsGestureView touchesCancelled:nil withEvent:nil];
		return YES;
	} else {
		return %orig;
	}
}

- (BOOL)_activateAppSwitcher
{
	UminoIsPortrait(YES);
	UminoIsMinimalStyle(YES);
	if (centerBehavior == Auxo && umino == ControlCenter) {
		umino = Auxo;
		continuePresentation = YES;
		[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
		return %orig;
	} else {
		return %orig;
	}
}

- (BOOL)shouldShowNotificationCenterTabControlOnFirstSwipe
{
	if (phone && umino == Auxo && UminoIsMinimalStyle(NO) && !reachabilityMode) {
		return YES;
	} else {
		return %orig;
	}
}

- (BOOL)shouldShowControlCenterTabControlOnFirstSwipe
{
	if (!disabledInCurrentApp()) {
		return NO;
	} else {
		return %orig;
	}
}

- (BOOL)shouldUseAmbiguousControlCenterActivation
{
	if (!disabledInCurrentApp()) {
		return NO;
	} else {
		return %orig;
	}
}

- (BOOL)allowSystemGestureType:(NSUInteger)type atLocation:(CGPoint)location
{
	BOOL allow = %orig;
	if ((type == 1 << 6) && umino == Auxo && isAppSwitcherShowing() && location.y > 0) {
		allow = NO;
	}
	return allow;
}

- (void)handleShowControlCenterSystemGesture:(SBOffscreenSwipeGestureRecognizer *)recognizer
{
	if (licenseStatus == Invalid && recognizer.state == UIGestureRecognizerStateBegan) {
		usageCount++;
		if (usageCount == 10) {
			UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:localizedString(@"PIRATE_TITLE") message:localizedString(@"PIRATE_MESSAGE") delegate:uiController cancelButtonTitle:localizedString(@"CANCEL") otherButtonTitles:localizedString(@"OPEN_CYDIA"), nil];
			[alertView show];
			return;
		} else if (usageCount >= 20) {
			UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:uiController cancelButtonTitle:localizedString(@"CANCEL") otherButtonTitles:localizedString(@"OPEN_CYDIA"), nil];
			UIImageView *imageView = [[UIImageView alloc]initWithImage:imageResource(@"iamsad")];
			[alertView _setAccessoryView:imageView];
			[alertView show];
			usageCount = 0;
			return;
		}
	}
	%orig;
	activeGestureRecognizer = recognizer;
}

- (void)_showControlCenterGestureBeganWithLocation:(CGPoint)location
{
	umino = ControlCenter;
	UminoIsPortrait(YES);
	if (!controlCenterController.isUILocked && !controlCenterController.isPresented && !disabledInCurrentApp() && ![frontMostApplication()._stateSettings boolForStateSetting:16]) {
		if (location.x < cornerWidth()) {
			umino = leftBehavior;
		} else if (location.x > screenWidth() - cornerWidth()) {
			umino = rightBehavior;
		} else {
			umino = centerBehavior;
		}
		if (umino == HomeScreen && isAtHomeScreen()) {
			umino = LockScreen;
		}
	}
	if (umino == HomeScreen) {
		SBApplication *frontApp = frontMostApplication();
		homeScreenGestureView = [(SBGestureViewVendor *)[NSClassFromString(@"SBGestureViewVendor")sharedInstance]viewForApp:frontApp gestureType:1 includeStatusBar:YES];
		[self _installSystemGestureView:homeScreenGestureView forKey:frontApp.bundleIdentifier forGesture:1];
		[(SBWallpaperController *)[NSClassFromString(@"SBWallpaperController") sharedInstance]beginRequiringWithReason:@"Auxo-HomeScreen"];
		[frontApp notifyResignActiveForReason:5];
		forceAnimation = YES;
	} else if (umino == LockScreen) {
		dimWindow.alpha = 0;
		dimWindow.hidden = NO;
	} else {
		%orig;
	}
}

- (void)_showControlCenterGestureChangedWithLocation:(CGPoint)location velocity:(CGPoint)velocity duration:(NSTimeInterval)duration
{
	if (umino == HomeScreen) {
		CGFloat height = screenHeight();
		float progress = MIN((height - location.y) / (height / 2.0), 1.0);
		CGFloat scale = MIN(MAX(1 - progress, 0.02), 1.0);
		void (^block)() = ^{
			homeScreenGestureView.transform = CGAffineTransformMakeScale(scale, scale);
		};
		if (forceAnimation) {
			forceAnimation = NO;
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:NULL];
		} else {
			block();
		}
	} else if (umino == LockScreen) {
		CGFloat height = screenHeight();
		float progress = MIN((height - location.y) / (height / 2.0), 1.0);
		dimWindow.alpha = progress;
	} else {
		%orig;
	}
}

- (void)_showControlCenterGestureEndedWithLocation:(CGPoint)location velocity:(CGPoint)velocity
{
	if (umino == HomeScreen) {
		BOOL backToHomescreen = velocity.y <= 0.0;
		SBApplication *frontApp = frontMostApplication();
		void (^block)() = ^{
			CGFloat scale = backToHomescreen ? 0.001 : 1.0;
			homeScreenGestureView.transform = CGAffineTransformMakeScale(scale, scale);
		};
		void (^completion)(BOOL) = ^(BOOL finished) {
			[[(FBSceneManager *)[NSClassFromString(@"FBSceneManager") sharedInstance]sceneWithIdentifier:frontApp.bundleIdentifier].contextHostManager disableHostingForRequester:@"SBUISystemGestureSuspendAppRequester"];
			[self _clearInstalledSystemGestureViewForKey:frontApp.bundleIdentifier];
			[frontApp notifyResumeActiveForReason:5];
			if (backToHomescreen) {
				FBWorkspaceEvent *event = [NSClassFromString(@"FBWorkspaceEvent") eventWithName:@"Auxo-HomeScreen" handler:^{
					[frontApp setObject:@YES forDeactivationSetting:20];
					[frontApp setObject:@NO forDeactivationSetting:2];
					SBAppToAppWorkspaceTransaction *transaction = [[NSClassFromString(@"UminoAppToAppWorkspaceTransaction") alloc]initWithAlertManager:workspace.alertManager exitedApp:frontApp];
					[workspace setCurrentTransaction:transaction];
				}];
				[(FBWorkspaceEventQueue *)[NSClassFromString(@"FBWorkspaceEventQueue") sharedInstance] executeOrAppendEvent:event];
				[self tearDownIconListAndBar];
				[self restoreContentAndUnscatterIconsAnimated:YES];
			}
		};
		if (backToHomescreen) {
			CGFloat height = screenHeight();
			float progress = MIN((height - location.y) / (height / 2.0), 1.0);
			NSTimeInterval timeLeft = (0.5 * height / velocity.y) * (1 - progress);
			[UIView animateWithDuration:MIN(timeLeft, 0.4) delay:0.0 options:0 animations:block completion:completion];
		} else {
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:block completion:completion];
		}
		umino = ControlCenter;
		//BKSHIDServicesSystemGesturesNoLongerPossible();
	} else if (umino == LockScreen) {
		BOOL lock = velocity.y <= 0.0;
		if (lock) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				[lockscreenManager lockUIFromSource:3 withOptions:nil];
			});
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				[backlightController _lockScreenDimTimerFired];
				dimWindow.hidden = YES;
			});
		} else {
			[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
				dimWindow.alpha = 0.0;
			} completion:^(BOOL finished){
				dimWindow.hidden = YES;
			}];
		}
		umino = ControlCenter;
	} else {
		%orig;
	}
}

- (void)_showControlCenterGestureCancelled
{
	if (umino == HomeScreen) {
		umino = ControlCenter;
		//BKSHIDServicesSystemGesturesNoLongerPossible();
		BKSHIDServicesCancelTouchesOnMainDisplay();
	} else if (umino == LockScreen) {
		umino = ControlCenter;
		dimWindow.hidden = YES;
	} else {
		%orig;
	}
}

- (void)_showControlCenterGestureFailed
{
	if (umino == HomeScreen) {
		umino = ControlCenter;
		//BKSHIDServicesSystemGesturesNoLongerPossible();
		BKSHIDServicesCancelTouchesOnMainDisplay();
	} else if (umino == LockScreen) {
		umino = ControlCenter;
		dimWindow.hidden = YES;
	} else {
		%orig;
	}
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.cancelButtonIndex != buttonIndex) {
		[[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"cydia://package/com.a3tweaks.auxo3"]];
	}
}

%end

%hook SpringBoard

- (BOOL)isMenuDoubleTapAllowed
{
	return disableHomeDoubleClick ? NO : %orig;
}

%end

%subclass UminoAppToAppWorkspaceTransaction : SBAppToAppWorkspaceTransaction

											  -(void)_didComplete
{
	%orig;
	[(SBWallpaperController *)[NSClassFromString(@"SBWallpaperController") sharedInstance]endRequiringWithReason:@"Auxo-HomeScreen"];
}

%end

%subclass UminoCCAirStuffSectionController : SBCCAirStuffSectionController

											 - (UIView *)view
{
	SBCCButtonLikeSectionSplitView *view = (SBCCButtonLikeSectionSplitView *)%orig;
	if (![view isKindOfClass:NSClassFromString(@"UminoCCButtonLikeSectionSplitView")]) {
		object_setClass(view, NSClassFromString(@"UminoCCButtonLikeSectionSplitView"));
	}
	return view;
}

- (void)viewDidLoad
{
	%orig;
	CHIvar((SBCCButtonLikeSectionSplitView *)self.view, _separatorWidth, CGFloat) = 1.0;
	if (phone && (!widescreen || !UminoIsPortrait(NO))) {
		self.airPlayEnabled = YES;
	}
}

- (void)controlCenterWillPresent
{
	%orig;
	[self.view layoutSubviews];
}

- (void)setAirPlayEnabled:(BOOL)enabled
{
	if (phone && (!widescreen || !UminoIsPortrait(NO))) {
		enabled = YES;
	}
	%orig;
}

- (void)_showAirPlayView:(id)sender
{
	if (phone) {
		MPAudioVideoRoutingViewController *viewController = [[MPAudioVideoRoutingViewController alloc]init];
		viewController.delegate = self;
		objc_setAssociatedObject(self, kAssociatedObjectKey, viewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		CGRect startFrame = CGRectMake(0, 0, screenWidth(), screenHeight()), endFrame = startFrame;
		startFrame.origin.y += startFrame.size.height;
		viewController.view.frame = startFrame;
		[contentView addSubview:viewController.view];
		[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			viewController.view.frame = endFrame;
		} completion:^(BOOL finished) {
			}];
	} else {
		%orig;
	}
}

- (void)_dismissAirplayControllerAnimated:(BOOL)animated
{
	if (phone) {
		UIViewController *viewController = objc_getAssociatedObject(self, kAssociatedObjectKey);
		if (viewController) {
			CGRect startFrame = viewController.view.frame, endFrame = startFrame;
			endFrame.origin.y += endFrame.size.height;
			[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
				viewController.view.frame = endFrame;
			} completion:^(BOOL finished) {
				[viewController.view removeFromSuperview];
				objc_setAssociatedObject(self, kAssociatedObjectKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			}];
		} else {
			%orig;
		}
	} else {
		%orig;
	}
}

%new
- (void)viewControllerRequestsDismissal:(UIViewController *)viewController
{
	[self _dismissAirplayControllerAnimated:YES];
}

%end

%subclass UminoCCButtonLikeSectionSplitView : SBCCButtonLikeSectionSplitView

											  - (SBCCButtonLikeSectionView *)leftSection
{
	SBCCButtonLikeSectionView *view = %orig;
	if (![view isKindOfClass:NSClassFromString(@"UminoCCButtonLikeSectionView")]) {
		object_setClass(view, NSClassFromString(@"UminoCCButtonLikeSectionView"));
	}
	return view;
}

- (SBCCButtonLikeSectionView *)rightSection
{
	SBCCButtonLikeSectionView *view = %orig;
	if (![view isKindOfClass:NSClassFromString(@"UminoCCButtonLikeSectionView")]) {
		object_setClass(view, NSClassFromString(@"UminoCCButtonLikeSectionView"));
	}
	return view;
}

- (void)setRightSectionHidden:(BOOL)hidden animated:(BOOL)animated
{
	%orig;
	BOOL hideLabel = NO;
	if (UminoIsPortrait(NO)) {
		hideLabel = !hidden;
	} else {
		hideLabel = YES;
	}
	if (self.leftSection) {
		objc_setAssociatedObject(self.leftSection, kAssociatedObjectKey, @(hideLabel), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[self.leftSection setNeedsLayout];
	}
	if (self.rightSection) {
		objc_setAssociatedObject(self.rightSection, kAssociatedObjectKey, @(hideLabel), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		[self.rightSection setNeedsLayout];
	}
}

- (CGRect)_separatorFrame
{
	CGRect bounds = self.bounds;
	if (UminoIsPortrait(NO)) {
		return CGRectMake(%orig.origin.x, -bounds.size.height, 1.0, bounds.size.height * 2.0);
	} else {
		return CGRectMake(88.0, -bounds.size.height, 1.0, bounds.size.height * 2.0);
	}
}

- (void)layoutSubviews
{
	if (UminoIsPortrait(NO)) {
		if (UminoIsMinimalStyle(NO) || reachabilityMode) {
			CGRect bounds = self.bounds;
			static const CGFloat margin = 26.0, padding = 12.0, height = 45.0;
			CGFloat y = (bounds.size.height - height) / 2;
			if (CHIvar(self, _rightHidden, BOOL)) {
				CGFloat width = bounds.size.width - margin * 2;
				self.leftSection.frame = CGRectMake(margin, y, width, height);
				self.rightSection.frame = CGRectMake(bounds.size.width + margin, y, width, height);
			} else {
				CGFloat width = (bounds.size.width - margin * 2 - padding) / 2;
				self.leftSection.frame = CGRectMake(margin, y, width, height);
				self.rightSection.frame = CGRectMake(bounds.size.width - margin - width, y, width, height);
			}
		} else {
			%orig;
		}
	} else {
		CGRect bounds = self.bounds;
		self.leftSection.frame = CGRectMake(0.0, 0.0, 88.0, bounds.size.height);
		self.rightSection.frame = CGRectMake(bounds.size.width - 88.0, 0.0, 88.0, bounds.size.height);
	}
}

%end

%subclass UminoCCButtonLikeSectionView : SBCCButtonLikeSectionView

										 - (BOOL)_shouldUseButtonAppearance
{
	return (UminoIsPortrait(NO) && (UminoIsMinimalStyle(NO) || reachabilityMode));
}

- (UIRectCorner)roundCorners
{
	return UIRectCornerAllCorners;
}

- (UIImage *)_backgroundImageWithRoundCorners:(UIRectCorner)corners
{
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(10, 10)].CGPath);
	CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillPath(context);
	UIImage *backgroundImage = [UIGraphicsGetImageFromCurrentImageContext() resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 15.0, 15.0, 15.0) resizingMode:UIImageResizingModeStretch];
	UIGraphicsEndImageContext();
	return backgroundImage;
}

- (void)layoutSubviews
{
	%orig;
	if ([objc_getAssociatedObject(self, kAssociatedObjectKey) boolValue]) {
		CGRect bounds = self.bounds;
		CHIvar(self, _button, UIButton * const).center = CGPointMake(bounds.size.width / 2.0, bounds.size.height / 2.0);
		CHIvar(self, _label, UILabel * const).hidden = YES;
	} else {
		CHIvar(self, _label, UILabel * const).hidden = NO;
	}
}

%end

%subclass UminoCCQuickLaunchSectionController : SBCCQuickLaunchSectionController

- (UIView *)view
{
	SBCCButtonLayoutView *view = (SBCCButtonLayoutView *)%orig;
	objc_setAssociatedObject(view, kAssociatedObjectKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return view;
}

- (void)viewDidLoad
{
	quickLaunchWorkaround = YES;
	%orig;
	quickLaunchWorkaround = NO;
	if ([AVFlashlight hasFlashlight]) {
		SBControlCenterViewController * const *ccViewController = CHIvarRef(controlCenterController, _viewController, SBControlCenterViewController * const);
		if (ccViewController) {
			SBControlCenterContentView * const *ccContentView = CHIvarRef(*ccViewController, _contentView, SBControlCenterContentView * const);
			if (ccContentView) {
				SBCCQuickLaunchSectionController *quickLauncherSection = (*ccContentView).quickLaunchSection;
				id const target = CHIvar(quickLauncherSection, _modulesByID, NSMutableDictionary * const)[@"flashlight"];
				id const myTarget = CHIvar(self, _modulesByID, NSMutableDictionary * const)[@"flashlight"];
				id const *flashlight = CHIvarRef(target, _flashlight, id const);
				__strong id *myFlashlight = CHIvarRef(myTarget, _flashlight, __strong id);
				if (flashlight && myFlashlight) {
					[*myFlashlight removeObserver:myTarget forKeyPath:@"available"];
					[*myFlashlight removeObserver:myTarget forKeyPath:@"overheated"];
					[*myFlashlight removeObserver:myTarget forKeyPath:@"flashlightLevel"];
					*myFlashlight = *flashlight;
					[*myFlashlight addObserver:myTarget forKeyPath:@"available" options:0 context:NULL];
					[*myFlashlight addObserver:myTarget forKeyPath:@"overheated" options:0 context:NULL];
					[*myFlashlight addObserver:myTarget forKeyPath:@"flashlightLevel" options:0 context:NULL];
				}
			}
		}
	}
}

%end

%hook SBControlCenterButton

- (void)setGlyphImage:(UIImage *)glyphImage selectedGlyphImage:(UIImage *)selectedGlyphImage
{
	if ((quickLaunchWorkaround || self.bounds.size.height == 40) && [self isMemberOfClass:NSClassFromString(@"SBControlCenterButton")]) {
		glyphImage = [glyphImage _imageScaledToProportion:0.76 interpolationQuality:kCGInterpolationDefault];
		selectedGlyphImage = [selectedGlyphImage _imageScaledToProportion:0.76 interpolationQuality:kCGInterpolationDefault];
	}
	%orig;
}

- (void)_setBackgroundImage:(UIImage *)bgImage naturalHeight:(CGFloat)height
{
	if ((quickLaunchWorkaround || self.bounds.size.height == 40) && [self isMemberOfClass:NSClassFromString(@"SBControlCenterButton")]) {
		static UIImage * (^ const getBackgroundImage)(UIColor *) = ^(UIColor *backgroundColor) {
			static CGFloat const width = 60.0;
			static CGFloat const height = 40.0;
			static CGFloat const cornerRadius = 9.0;
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO, [UIScreen mainScreen].scale);
			CGContextRef context = UIGraphicsGetCurrentContext();
			CGPathRef path = CGPathCreateWithRoundedRect(CGRectInset(CGRectMake(0.0, 0.0, width, height), 0.0, 0.0), cornerRadius, cornerRadius, NULL);
			CGContextAddPath(context, path);
			CGPathRelease(path);
			CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
			CGContextFillPath(context);
			UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			return backgroundImage;
		};
		static UIImage *backgroundImage;
		static dispatch_once_t once_token;
		dispatch_once(&once_token, ^{
			backgroundImage = getBackgroundImage(CHIvar(self, _backgroundEffectView, UIView * const) ? [UIColor whiteColor] : [UIColor colorWithWhite:0 alpha:0.08]);
		});
		bgImage = backgroundImage;
		height = 40;
	}
	%orig;
}

%end

%subclass UminoBrightnessHUDView : SBBrightnessHUDView

								   - (BOOL)displaysLabel
{
	return YES;
}

%end

%hook SBOffscreenSwipeGestureRecognizer

-(id)initForOffscreenEdge:(NSUInteger)edge
{
	SBOffscreenSwipeGestureRecognizer *recognizer = %orig;
	if (edge == 4) {
		_UIScreenEdgePanRecognizerEdgeSettings *edgeSettings = recognizer.settings.edgeSettings;
		edgeSettings.hysteresis = 0.0;
		edgeSettings.maximumSwipeDuration = 1.0;
		switch (sensitivity) {
			case 1:
				edgeSettings.bottomEdgeRegionSize = 20.0;
				break;
			case 2:
				edgeSettings.bottomEdgeRegionSize = 30.0;
				break;
			default:
				break;
		}
	}
	return recognizer;
}

%end

%hook MCProfileConnection

- (BOOL)isControlCenterAllowedInApps
{
	return YES;
}

%end

%hook SBControlCenterViewController

- (void)section:(SBControlCenterSectionViewController *)section updateStatusText:(NSString *)text reason:(NSString *)reason
{
	%orig;
	if (flipcontrolcenterWorkaround) {
		[(id<SBControlCenterSectionViewControllerDelegate>)(phone ? controlCenterTopView : controlCenterOriginalView) section:section updateStatusText:text reason:reason];
	}
}

- (void)section:(SBControlCenterSectionViewController *)section publishStatusUpdate:(SBControlCenterStatusUpdate *)update
{
	SBControlCenterStatusUpdate *updateCopy = [[NSClassFromString(@"SBControlCenterStatusUpdate") alloc]init];
	updateCopy.type = update.type;
	updateCopy.statusStrings = update.statusStrings;
	updateCopy.reason = update.reason;
	%orig;
	if (flipcontrolcenterWorkaround) {
		[(id<SBControlCenterSectionViewControllerDelegate>)(phone ? controlCenterTopView : controlCenterOriginalView) section:section publishStatusUpdate:updateCopy];
	}
}

%end

%hook UILabel

- (void)_startMarquee
{
	%orig;
	for (CALayer *layer in self.layer.sublayers) {
		if ([layer isKindOfClass:NSClassFromString(@"_UILabelContentLayer")]) {
			layer.hidden = YES;
		}
	}
}

%end

%hook MPUTransportControlsView

- (void)_transportControlTap:(UIButton *)sender
{
	if ([objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue]) {
		MPUMediaControlsTitlesView *trackInformationView = controlCenterOriginalView.mediaControlsView.trackInformationView;
		[NSObject cancelPreviousPerformRequestsWithTarget:trackInformationView selector:@selector(handleArtwork:) object:@((1 << 0) + 1)];
		[NSObject cancelPreviousPerformRequestsWithTarget:trackInformationView selector:@selector(handleArtwork:) object:@((1 << 1) + 1)];
		[NSObject cancelPreviousPerformRequestsWithTarget:trackInformationView selector:@selector(handleArtwork:) object:@((1 << 2) + 1)];
		switch (sender.tag) {
			case 1:
				objc_setAssociatedObject(self, kAssociatedObjectKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
				[trackInformationView performSelector:@selector(handleArtwork:) withObject:@((1 << 2) + 1) afterDelay:1.6];
				break;
			case 4:
				if (!isMediaPlaying()) {
					[trackInformationView performSelector:@selector(handleArtwork:) withObject:@((1 << 0) + 1) afterDelay:0.1];
				}
				break;
			case 8:
				objc_setAssociatedObject(self, kAssociatedObjectKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
				[trackInformationView performSelector:@selector(handleArtwork:) withObject:@((1 << 1) + 1) afterDelay:1.6];
				break;
			default:
				objc_setAssociatedObject(self, kAssociatedObjectKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
				break;
		}
	}
	%orig;
}

%end

%hook MPUMediaControlsTitlesView

%new
- (UIImage *)__artwork
{
	static MPUNowPlayingController *nowplayingController;
	if (nowplayingController == nil) {
		nowplayingController = [[MPUNowPlayingController alloc]init];
	}
	[nowplayingController update];
	return nowplayingController.currentNowPlayingArtwork;
}

- (void)_touchControlTapped:(UIButton *)sender
{
	if ([objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue]) {
		if (sender) {
			[switcherController showArtwork:self.__artwork action:0];
		} else {
			%orig;
		}
	} else {
		%orig;
	}
}

%new
- (void)_touchControlLongPressed:(UILongPressGestureRecognizer *)recognizer
{
	if ([objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue]) {
		if (recognizer.state == UIGestureRecognizerStateBegan) {
			[self _touchControlTapped:nil];
		}
	}
}

%new
- (void)handleArtwork:(NSNumber *)action
{
	[switcherController showArtwork:self.__artwork action:action.integerValue];
	objc_setAssociatedObject(controlCenterOriginalView.mediaControlsView.transportControlsView, kAssociatedObjectKey, @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)info
{
	if ([objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue]) {
		if (![self.titleText isEqualToString:info[(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTitle]]) {
			BOOL isPreviousTrack = [objc_getAssociatedObject(controlCenterOriginalView.mediaControlsView.transportControlsView, kAssociatedObjectKey) boolValue];
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleArtwork:) object:@(+1)];
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleArtwork:) object:@(-1)];
			[self performSelector:@selector(handleArtwork:) withObject:@(isPreviousTrack ? -1 : +1) afterDelay:1.0];
		}
	}
	%orig;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	CGSize fitSize = %orig;
	if ([objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue]) {
		fitSize.height *= 3;
	}
	return fitSize;
}

%end

%hook SBAppSwitcherPeopleViewController

- (void)viewDidLoad
{
	%orig;
	[self switcherWillBePresented:NO];
	[self switcherWasDismissed:NO];
}

%end

%hook SBTodayTableHeaderView

-(BOOL)_isCachedSizeThatFitsValidForSize:(CGSize)size
{
	return phone ? NO : %orig;
}

-(CGSize)sizeThatFits:(CGSize)content
{
	CGSize size = %orig;
	if (phone) {
		if (peopleInTodayHeader && notificationCenterController.visible && !controlCenterController.isUILocked && peopleView.frame.origin.y >= 0) {
			size.height += (iphone6 ? 105 : iphone6plus ? 110 : 105);
		}
	}
	return size;
}

-(void)layoutSubviews
{
	%orig;
	if (phone) {
		if (peopleInTodayHeader && notificationCenterController.visible && !controlCenterController.isUILocked && peopleView.frame.origin.y >= 0) {
			CGRect frame = peopleView.frame;
			frame.origin.y = self.frame.size.height - frame.size.height + (iphone6 ? 20 : iphone6plus ? 25 : 10);
			peopleView.frame = frame;
			peopleView.alpha = 0.5;
			peopleView.alpha = 1;
			peopleView.hidden = NO;
			[self addSubview:peopleView];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				UIScrollView *scrollView = (UIScrollView *)peopleView;
				[scrollView.delegate scrollViewWillBeginDragging:scrollView];
				});
		} else {
			peopleView.hidden = YES;
		}
	}
}

%end

%hook FCCButtonsScrollView

- (void)showStateForSwitchWithIdentifier:(NSString *)identifier
{
	flipcontrolcenterWorkaround = YES;
	%orig;
	flipcontrolcenterWorkaround = NO;
}

- (void)reloadButtons
{
	%orig;
	if ([objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue]) {
		for (FSSwitchButton *button in CHIvar(self, buttons, NSMutableArray * const)) {
			objc_setAssociatedObject(button, kAssociatedObjectKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		}
	}
}

- (void)layoutSubviews
{
	if ([objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue]) {
		CHIvar(self, beforePadding, CGFloat) = 20.0;
		CHIvar(self, afterPadding, CGFloat) = 20.0;
		CHIvar(self, buttonSize, CGSize) = CGSizeMake(40.0, 40.0);
	}
	%orig;
}

%end

%hook FSSwitchButton

- (void)displayLayer:(CALayer *)layer
{
	if ([self.superview isKindOfClass:NSClassFromString(@"FCCButtonsScrollView")]) {
		NSString *switchIdentifier = CHIvar(self, switchIdentifier, NSString * const);
		NSBundle *templateBundle = CHIvar(self, template, NSBundle * const);
		FSSwitchPanel *sharedPanel = [NSClassFromString(@"FSSwitchPanel") sharedPanel];
		UIControlState controlState = self.state;
		FSSwitchState switchState = [sharedPanel stateForSwitchIdentifier:switchIdentifier];
		if (controlState & UIControlStateHighlighted) {
			switchState = (switchState == FSSwitchStateOn) ? FSSwitchStateOff : FSSwitchStateOn;
		}
		UIImage *image = [sharedPanel imageOfSwitchState:switchState controlState:controlState forSwitchIdentifier:switchIdentifier usingTemplate:templateBundle];
		if ([objc_getAssociatedObject(self, kAssociatedObjectKey) boolValue]) {
			image = [image _imageScaledToProportion:2.0 / 3.0 interpolationQuality:kCGInterpolationDefault];
		}
		[UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			[self setImage:image forState:UIControlStateNormal];
			[self setImage:image forState:UIControlStateHighlighted];
			[sharedPanel applyEffectsToLayer:self.layer forSwitchState:switchState controlState:controlState usingTemplate:templateBundle];
		} completion:NULL];
	} else {
		%orig;
	}
}

%end

/*
%hook PLQuickLaunchView

- (void)addQuickLaunchButtons
{
	BOOL workaround = [objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue];
	if (workaround) {
		polusWorkaround = YES;
	}
	%orig;
	polusWorkaround = NO;
}

- (void)layoutSubviews
{
	BOOL workaround = [objc_getAssociatedObject(self.superview, kAssociatedObjectKey) boolValue];
	if (workaround) {
		CHIvar(self, _buttonSize, CGSize) = CGSizeMake(60.0, 40.0);
	}
	%orig;
	if (workaround) {
		for (PLQuickLaunchButton *button in CHIvar(self, _quickLaunchButtons, NSMutableArray * const)) {
			CGPoint center = button.center;
			center.y = 20.0;
			button.center = center;
		}
	}
}

%end

%hook PLQuickLaunchButton

- (void)setGlyphImage:(UIImage *)glyphImage selectedGlyphImage:(UIImage *)selectedGlyphImage
{
	if (polusWorkaround) {
		glyphImage = [glyphImage _imageScaledToProportion:0.76 interpolationQuality:kCGInterpolationDefault];
		selectedGlyphImage = [selectedGlyphImage _imageScaledToProportion:0.76 interpolationQuality:kCGInterpolationDefault];
	}
	%orig;
}

%end
*/

%ctor
{
	@autoreleasepool {
		static void (^ const initializationStep1)(void) = ^(){
			%init;
		};
		static void (^ const initializationStep2)(void) = ^(){
			uiController = (SBUIController *)[NSClassFromString(@"SBUIController")sharedInstance];
			switcherController = CHIvar(uiController, _switcherController, SBAppSwitcherController * const);
			pageController = CHIvar(switcherController, _pageController, SBAppSwitcherPageViewController * const);
			iconController = CHIvar(switcherController, _iconController, SBAppSwitcherIconController * const);
			animationFactory = switcherController._transitionAnimationFactory;
			contentView = CHIvar(switcherController, _contentView, UIView * const);
			pageView = CHIvar(switcherController, _pageView, UIView * const);
			iconView = CHIvar(switcherController, _iconView, UIView * const);
			peopleView = CHIvar(switcherController, _peopleView, UIView * const);
			notificationCenterController = (SBNotificationCenterController *)[NSClassFromString(@"SBNotificationCenterController")sharedInstance];
			controlCenterController = (SBControlCenterController *)[NSClassFromString(@"SBControlCenterController")sharedInstance];
			backlightController = (SBBacklightController *)[NSClassFromString(@"SBBacklightController")sharedInstance];
			lockscreenManager = (SBLockScreenManager *)[NSClassFromString(@"SBLockScreenManager")sharedInstance];
			phone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
			if (phone) {
				widescreen = [UIScreen mainScreen].bounds.size.height >= 568.0;
				iphone6 = [UIScreen mainScreen].bounds.size.height == 667.0;
				iphone6plus = [UIScreen mainScreen].bounds.size.height == 736.0;
			}
			iconListView = [[UminoIconListView alloc]initWithFrame:CGRectZero handler:^(CGFloat normalizedOffset, NSInteger highlightIndex, NSTimeInterval duration){
				currentIndex = highlightIndex;
				if (CHIvar(switcherController, _appList_use_block_accessor, NSArray * const).count > 1) {
					void (^block)(void) = ^(){
						[pageController setNormalizedOffset:normalizedOffset];
						[iconController setNormalizedOffset:normalizedOffset];
					};
					if (duration > 0.0) {
						[UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:block completion:NULL];
					} else {
						block();
					}
				}
			}];
			iconListView.layer.bounds = CGRectMake(0.0, 0.0, 320.0, iconListHeight());
			iconListView.layer.anchorPoint = CGPointMake(0.5, 0.0);
			iconListView.hidden = YES;
			if (phone) {
				controlCenterTopView = [[UminoControlCenterTopView alloc]initWithFrame:CGRectZero];
				controlCenterTopView.layer.bounds = CGRectMake(0.0, 0.0, 320.0, auxoTopHeight() * 2.0);
				controlCenterTopView.layer.anchorPoint = CGPointMake(0.5, 1.0);
				controlCenterTopView.hidden = YES;
				controlCenterBottomView = [[UminoControlCenterBottomView alloc]initWithFrame:CGRectZero];
				controlCenterBottomView.layer.bounds = CGRectMake(0.0, 0.0, 320.0, auxoBottomHeight() * 2.0);
				controlCenterBottomView.layer.anchorPoint = CGPointMake(0.5, 0.0);
				controlCenterBottomView.hidden = YES;
				controlCenterBottomView.gestureHandler = ^(UIPanGestureRecognizer *recognizer) {
					if (artworkView.alpha != 0.0) {
						[switcherController hideArtwork];
					}
					CGFloat translationY = [recognizer translationInView:controlCenterBottomView].y;
					switch (recognizer.state) {
						case UIGestureRecognizerStateBegan:
							{
								[pageController setOffsetToIndex:pageController.currentPage animated:YES];
								[iconController setOffsetToIndex:pageController.currentPage animated:YES];
								break;
							}
						case UIGestureRecognizerStateChanged:
							{
								double progress = 0.0;
								CGFloat maxTranslationY = auxoBottomHeight();
								if (translationY < 0.0) {
									progress = 0.0 - 0.1 * sin(MIN(0.0 - translationY, maxTranslationY) / maxTranslationY * M_PI_2);
								} else if (translationY > maxTranslationY) {
									progress = 1.0 + 0.1 * sin(MIN(translationY - maxTranslationY, maxTranslationY) / maxTranslationY * M_PI_2);
								} else {
									progress = translationY / maxTranslationY;
								}
								progress = 1.0 - progress;
								CGFloat positionX = screenWidth() / 2.0;
								CGFloat positionY = - auxoPageOffset() * pow(progress, reachabilityMode ? 2.0 : 3.0);
								CGPoint iconViewPosition = iconExpectedPosition;
								iconViewPosition.y = screenHeight();
								iconViewPosition.y -= (iconViewPosition.y - iconExpectedPosition.y) * progress;
								[switcherController _updatePageViewScale:maxScale() * (1.0 - progress) + auxoPageScale() * progress];
								iconAlphaUpdate(progress, YES);
								wallpaperAlphaUpdate(progress, progress);
								pageView.layer.transform = CATransform3DTranslate(pageView.layer.transform, 0, positionY, 0);
								iconView.layer.position = iconViewPosition;
								controlCenterTopView.layer.position = CGPointMake(positionX, auxoTopHeight() * progress);
								controlCenterBottomView.layer.position = CGPointMake(positionX, screenHeight() - auxoBottomHeight() * progress);
								break;
							}
						case UIGestureRecognizerStateEnded:
							{
								BOOL gestureCancelled = (translationY > 0.0 && [recognizer velocityInView:controlCenterBottomView].y > 0.0);
								if (gestureCancelled) {
									[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
									if (needDismissal) {
										needDismissal = NO;
									} else {
										[[UIApplication sharedApplication] endIgnoringInteractionEvents];
										return;
									}
								} else {
									xTranslationFix = YES;
								}
								CGFloat x = screenWidth() / 2.0;
								CGFloat height = screenHeight();
								CGFloat endScale = gestureCancelled ? maxScale() : auxoPageScale();
								CGFloat endPositionY = -(gestureCancelled ? 0.0 : auxoPageOffset());
								CGFloat endTopY = gestureCancelled ? 0.0 : auxoTopHeight();
								CGFloat endBottomY = gestureCancelled ? height : height - auxoBottomHeight();
								if (gestureCancelled) {
									iconExpectedPosition.y = height;
									UIView *itemView = sliderItem(currentIndex, YES).item.view;
									if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
										[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
									}
								}
								[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
									pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(endScale, endScale, 1.0), 0.0, endPositionY, 0.0);
									iconView.layer.position = iconExpectedPosition;
									iconAlphaUpdate(gestureCancelled ? 0.0 : 1.0, YES);
									wallpaperAlphaUpdate(gestureCancelled ? 0.0 : 1.0, gestureCancelled ? 0.0 : 1.0);
									controlCenterTopView.layer.position = CGPointMake(x, endTopY);
									controlCenterBottomView.layer.position = CGPointMake(x, endBottomY);
									if (gestureCancelled) {
										pageView.layer.position = CGPointMake(x, height / 2.0);
										[pageController setOffsetToIndex:currentIndex animated:NO];
										[iconController setOffsetToIndex:currentIndex animated:NO];
									}
								} completion:^(BOOL finished) {
									if (gestureCancelled) {
										suppressAnimation = YES;
										[switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
										suppressAnimation = NO;
										[[UIApplication sharedApplication] endIgnoringInteractionEvents];
									}
								}];
								break;
							}
						default:
							{
								break;
							}
					}
				};
				controlCenterBottomView.transitionHandler = ^(id boolOrRecognizer) {
					if (!UminoIsPortrait(NO) || !minimalStyleEnabled || !reachabilityMode) {
						return;
					}
					if (activeGestureRecognizer.state == UIGestureRecognizerStateBegan || activeGestureRecognizer.state == UIGestureRecognizerStateChanged) {
						return;
					}
					if ([pageView.layer animationForKey:@"transform"]) {
						return;
					}
					CGFloat width = screenWidth(), height = screenHeight();
					void (^ block)(double x) = ^(double x) {
						CGFloat scale = auxoPageScale();
						CGFloat centerX = width / 2.0;
						CGFloat pageY = auxoReachabilityPageOffsetMin * (1 - x) + auxoReachabilityPageOffsetMax * x;
						CGFloat iconY = iconExpectedPosition.y - (auxoReachabilityIconOffsetMax - auxoReachabilityIconOffsetMin) * (x - reachabilityTransition);
						CGFloat bottomHeight = auxoReachabilityHeightMin * (1 - x) + auxoReachabilityHeightMax * x;
						pageView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(scale, scale), 0, -pageY);
						iconView.layer.position = CGPointMake(centerX, iconY);
						controlCenterBottomView.layer.position = CGPointMake(centerX, height - bottomHeight);
						dimView.frame = CGRectMake(0.0, 0.0, contentView.bounds.size.width, contentView.bounds.size.height - bottomHeight);
						artworkView.frame = CGRectMake(0.0, 0.0, width, height - bottomHeight);
					};
					if ([boolOrRecognizer isKindOfClass:NSNumber.class]) {
						BOOL forward = [boolOrRecognizer boolValue];
						[pageController setOffsetToIndex:pageController.currentPage animated:YES];
						[iconController setOffsetToIndex:pageController.currentPage animated:YES];
						[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
							block(forward ? 1.0 : 0.0);
							reachabilityTransition = forward;
							controlCenterBottomView.layer.bounds = CGRectMake(0, 0, width, (forward ? auxoReachabilityHeightMax : auxoReachabilityHeightMin) * 2.0);
							[controlCenterBottomView layoutSubviews];
						} completion:^(BOOL finished) {
							iconExpectedPosition = iconView.layer.position;
							quickLaunchAutoDismissed = YES;
							[controlCenterBottomView setQuickLauncherShowing:@(NO)];
						}];
						iconShadowUpdate(YES);
					} else if ([boolOrRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
						CGFloat translationY = [boolOrRecognizer translationInView:controlCenterBottomView].y;
						CGFloat velocityY = [boolOrRecognizer velocityInView:controlCenterBottomView].y;
						double progress = -translationY / (auxoReachabilityHeightMax - auxoReachabilityHeightMin) + reachabilityTransition;
						static const CGFloat rubber = 0.5;
						if (progress > 1.0) {
							progress = 1.0 + rubber * sin(MIN((progress - 1.0) / rubber, M_PI_2));
						} else if (progress < 0.0) {
							progress = 0.0 - rubber * sin(MIN(-progress / rubber, M_PI_2));
						}
						BOOL forward = velocityY < 0.0;
						switch ([boolOrRecognizer state]) {
							case UIGestureRecognizerStateBegan:
								{
									[pageController setOffsetToIndex:pageController.currentPage animated:YES];
									[iconController setOffsetToIndex:pageController.currentPage animated:YES];
									break;
								}
							case UIGestureRecognizerStateChanged:
								{
									block(progress);
									break;
								}
							case UIGestureRecognizerStateEnded:
								{
									[animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
										block(forward ? 1.0 : 0.0);
										reachabilityTransition = forward;
										controlCenterBottomView.layer.bounds = CGRectMake(0, 0, width, (forward ? auxoReachabilityHeightMax : auxoReachabilityHeightMin) * 2.0);
										[controlCenterBottomView layoutSubviews];
									} completion:^(BOOL finished) {
										iconExpectedPosition = iconView.layer.position;
										if (forward) {
											if ((isMediaPlaying() ? quickLaunchOptionWithMediaPlaying : quickLaunchOptionWithoutMediaPlaying) == 2) {
												if (!quickLaunchAutoDismissed) {
													quickLaunchAutoDismissed = YES;
													[controlCenterBottomView dismissQuickLauncherAfterDelay:quickLaunchAutoDismissDelay];
												}
											}
										}
									}];						
									iconShadowUpdate(YES);
									break;
								}
							default:
								{
									break;
								}
						}
					}
				};
                controlCenterBottomView.artworkHandler = ^(UIImage *artwork, NSInteger action) {
                    [switcherController showArtwork:artwork action:action];
                };
            } else {
                controlCenterOriginalView = [[UminoControlCenterOriginalView alloc]initWithFrame:CGRectZero];
                controlCenterOriginalView.layer.bounds = CGRectMake(0.0, 0.0, 1024.0, auxoBottomHeight() * 2.0);
                controlCenterOriginalView.layer.anchorPoint = CGPointMake(0.5, 0.0);
                controlCenterOriginalView.hidden = YES;
                controlCenterOriginalView.gestureHandler = ^(UIPanGestureRecognizer *recognizer) {
                    if (artworkView.alpha != 0.0) {
                        [switcherController hideArtwork];
                    }
                    CGFloat translationY = [recognizer translationInView:controlCenterOriginalView].y;
                    SBChevronView *chevronView = CHIvar(controlCenterOriginalView, _contentView, SBControlCenterContentView * const).grabberView.chevronView;
                    switch (recognizer.state) {
                        case UIGestureRecognizerStateBegan: {
                                                                [pageController setOffsetToIndex:pageController.currentPage animated:YES];
                                                                [iconController setOffsetToIndex:pageController.currentPage animated:YES];
                                                                [chevronView setState:0 animated:YES];
                                                                break;
                                                            }
                        case UIGestureRecognizerStateChanged: {
                                                                  double progress = 0.0;
                                                                  CGFloat maxTranslationY = auxoBottomHeight();
                                                                  if (translationY < 0.0) {
                                                                      progress = 0.0 - 0.1 * sin(MIN(0.0 - translationY, maxTranslationY) / maxTranslationY * M_PI_2);
                                                                  } else if (translationY > maxTranslationY) {
                                                                      progress = 1.0 + 0.1 * sin(MIN(translationY - maxTranslationY, maxTranslationY) / maxTranslationY * M_PI_2);
                                                                  } else {
                                                                      progress = translationY / maxTranslationY;
                                                                  }
                                                                  progress = 1.0 - progress;
                                                                  CGFloat positionX = screenWidth() / 2.0;
                                                                  CGFloat positionY = - auxoPageOffset() * pow(progress, reachabilityMode ? 2.0 : 3.0);
                                                                  CGPoint iconViewPosition = iconExpectedPosition;
                                                                  iconViewPosition.y = screenHeight();
                                                                  iconViewPosition.y -= (iconViewPosition.y - iconExpectedPosition.y) * progress;
                                                                  [switcherController _updatePageViewScale:maxScale() * (1.0 - progress) + auxoPageScale() * progress];
                                                                  iconAlphaUpdate(progress, YES);
                                                                  wallpaperAlphaUpdate(progress, progress);
                                                                  pageView.layer.transform = CATransform3DTranslate(pageView.layer.transform, 0, positionY, 0);
                                                                  iconView.layer.position = iconViewPosition;
                                                                  controlCenterOriginalView.layer.position = CGPointMake(positionX, screenHeight() - auxoBottomHeight() * progress);
                                                                  break;
                                                              }
                        case UIGestureRecognizerStateEnded: {
                                                                BOOL gestureCancelled = (translationY > 0.0 && [recognizer velocityInView:controlCenterOriginalView].y > 0.0);
                                                                if (gestureCancelled) {
                                                                    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
                                                                    if (needDismissal) {
                                                                        needDismissal = NO;
                                                                    } else {
                                                                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                                                        return;
                                                                    }
                                                                } else {
                                                                    xTranslationFix = YES;
                                                                }
                                                                CGFloat x = screenWidth() / 2.0;
                                                                CGFloat height = screenHeight();
                                                                CGFloat endScale = gestureCancelled ? maxScale() : auxoPageScale();
                                                                CGFloat endPositionY = -(gestureCancelled ? 0.0 : auxoPageOffset());
                                                                CGFloat endBottomY = gestureCancelled ? height : height - auxoBottomHeight();
                                                                if (gestureCancelled) {
                                                                    iconExpectedPosition.y = height;
																	UIView *itemView = sliderItem(currentIndex, YES).item.view;
																	if ([itemView isKindOfClass:NSClassFromString(@"SBAppSwitcherSnapshotView")]) {
																		[(SBAppSwitcherSnapshotView *)itemView _crossfadeToZoomUpViewIfNecessary];
																	}
																}
                                                                [animationFactory _animateWithAdditionalDelay:0.0 options:0 actions:^{
                                                                    pageView.layer.transform = CATransform3DTranslate(CATransform3DMakeScale(endScale, endScale, 1.0), 0.0, endPositionY, 0.0);
                                                                    iconView.layer.position = iconExpectedPosition;
                                                                    iconAlphaUpdate(gestureCancelled ? 0.0 : 1.0, YES);
                                                                    wallpaperAlphaUpdate(gestureCancelled ? 0.0 : 1.0, gestureCancelled ? 0.0 : 1.0);
                                                                    controlCenterOriginalView.layer.position = CGPointMake(x, endBottomY);
                                                                    [chevronView setState:gestureCancelled ? 0 : 1 animated:NO];
                                                                    if (gestureCancelled) {
                                                                        pageView.layer.position = CGPointMake(x, height / 2.0);
                                                                        [pageController setOffsetToIndex:currentIndex animated:NO];
                                                                        [iconController setOffsetToIndex:currentIndex animated:NO];
                                                                    }
                                                                } completion:^(BOOL finished) {
                                                                    if (gestureCancelled) {
                                                                        suppressAnimation = YES;
                                                                        [switcherController switcherScroller:pageController itemTapped:displayLayouts(YES)[currentIndex]];
                                                                        suppressAnimation = NO;
                                                                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                                                                    }
                                                                }];
                                                                break;
                                                            }
                        default: {
                                     break;
                                 }
                    }
                };
                _MPUSystemMediaControlsView *mediaControlsView = controlCenterOriginalView.mediaControlsView;
                if (mediaControlsView != nil) {
                    objc_setAssociatedObject(mediaControlsView, kAssociatedObjectKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                    MPUMediaControlsTitlesView *trackInformationView = mediaControlsView.trackInformationView;
                    [trackInformationView addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:trackInformationView action:@selector(_touchControlLongPressed:)]];	
                }
            }
            homeScreenIconView = [[NSClassFromString(@"UminoAppSwitcherIconView") alloc]initWithDefaultSize];
            homeScreenIconView.icon = [[NSClassFromString(@"UminoIcon")alloc]init];
            homeScreenIconView.delegate = iconController;
            dimView = [[UIView alloc]initWithFrame:CGRectMake(0.0, 0.0, 1024.0, 1024.0)];
            dimView.userInteractionEnabled = NO;
			dimWindow = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
			dimWindow.windowLevel = 2000;
			dimWindow.userInteractionEnabled = NO;
			dimWindow.backgroundColor = [UIColor blackColor];
			dimWindow.hidden = YES;
            artworkView = [[UIImageView alloc]initWithFrame:CGRectZero];
            artworkView.contentMode = UIViewContentModeScaleAspectFill;
            artworkView.clipsToBounds = YES;
            artworkView.alpha = 0.0;
            artworkView.userInteractionEnabled = YES;
            [artworkView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:switcherController action:@selector(artworkTapGesture:)]];
            [artworkView addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:switcherController action:@selector(artworkLongPressGesture:)]];
            UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:switcherController action:@selector(artworkLeftSwipeGesture:)];
            leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
            [artworkView addGestureRecognizer:leftSwipeGestureRecognizer];
            UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:switcherController action:@selector(artworkRightSwipeGesture:)];
            rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
            [artworkView addGestureRecognizer:rightSwipeGestureRecognizer];
            UISwipeGestureRecognizer *downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:switcherController action:@selector(artworkDownSwipeGesture:)];
            downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
            [artworkView addGestureRecognizer:downSwipeGestureRecognizer];
            if (phone) {
                zoomedArtworkView = [[UIImageView alloc]initWithFrame:CGRectZero];
                zoomedArtworkView.contentMode = UIViewContentModeScaleAspectFill;
                zoomedArtworkView.clipsToBounds = YES;
                zoomedArtworkView.alpha = 0.0;
            }
            closeAllAppsGestureView = [[UminoCloseAllAppsGestureView alloc]initWithFrame:CGRectZero];
            closeAllAppsGestureView.hidden = YES;
        };
        static void (^ const initializationStep3)(void) = ^(){
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, preferencesChangedCallback, (__bridge CFStringRef)kPreferencesNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, exceptionsChangedCallback, (__bridge CFStringRef)kExceptionsNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
            CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, workaroundsChangedCallback, CFSTR("jp.tom-go.GridSwitcher.loadPrefs"), NULL, CFNotificationSuspensionBehaviorCoalesce);
            preferencesChangedCallback(NULL, NULL, NULL, NULL, NULL);
            exceptionsChangedCallback(NULL, NULL, NULL, NULL, NULL);
            workaroundsChangedCallback(NULL, NULL, NULL, NULL, NULL);

            CGFloat width = screenWidth();
            CGFloat height = screenHeight();
            controlCenterTopView.layer.bounds = CGRectMake(0.0, 0.0, width, auxoTopHeight());
            controlCenterBottomView.layer.bounds = CGRectMake(0.0, 0.0, width, auxoBottomHeight());
            controlCenterTopView.layer.position = CGPointMake(width / 2.0, 0.0);
            controlCenterBottomView.layer.position = CGPointMake(width / 2.0, height);
            [contentView addSubview:controlCenterTopView];
            [contentView addSubview:controlCenterBottomView];
            [contentView addSubview:dimView];
			[[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            controlCenterTopView.hidden = NO;
            controlCenterBottomView.hidden = NO;
			dimView.hidden = NO;
			[[NSRunLoop currentRunLoop]runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
            controlCenterTopView.hidden = YES;
            controlCenterBottomView.hidden = YES;
			dimView.hidden = YES;
        };
        static void (^ const initializationStep4)(void) = ^(){
            static dispatch_queue_t queue;
            if (queue == NULL) {
                queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
            }
            dispatch_async(queue, ^{
                NSArray *license = nil;
                if (downloadLicense(&license)) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    licenseStatus = !checkLicense(license) + 1;
                    });
                } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
                    initializationStep4();
                    });
                }
                });
        };
		initializationStep1();
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8 * NSEC_PER_SEC), dispatch_get_main_queue(), initializationStep2);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 9 * NSEC_PER_SEC), dispatch_get_main_queue(), initializationStep3);
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), initializationStep4);
    }
}

__attribute__((visibility("hidden")))
@interface _Auxo : NSObject
+ (BOOL)multiCenterShowing;
+ (BOOL)isPortrait;
+ (BOOL)isMinimal;
+ (BOOL)isReachable;
+ (CGFloat)finalScale;
@end

@implementation _Auxo
+ (BOOL)multiCenterShowing { return umino == Auxo; }
+ (BOOL)isPortrait { return UminoIsPortrait(NO); }
+ (BOOL)isMinimal { return UminoIsMinimalStyle(NO); }
+ (BOOL)isReachable { return reachabilityMode; }
+ (CGFloat)finalScale { return auxoPageScale(); }
@end

