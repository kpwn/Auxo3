#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CaptainHook.h>
#import <Flipswitch/Flipswitch.h>
#import "UminoControlCenterTopView.h"
#import "UminoControlCenterBottomView.h"
#import "UminoControlCenterOriginalView.h"

@interface UIApplication (Private_Auxo)
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspended;
@end

@interface UIWindow (Private_Auxo)
+ (UIWindow *)keyWindow;
@end

@interface UIScrollView (Private_Auxo) <UIGestureRecognizerDelegate>
@property(nonatomic,readonly) UIPanGestureRecognizer *panGestureRecognizer;
- (CGFloat)_rubberBandOffsetForOffset:(CGFloat)offset maxOffset:(CGFloat)max minOffset:(CGFloat)min range:(CGFloat)range outside:(BOOL *)outside;
- (void)_prepareToPageWithHorizontalVelocity:(CGFloat)vX verticalVelocity:(CGFloat)vY;
- (void)_endPanNormal:(BOOL)normal;
@end

@interface UIImage (Private_Auxo)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(NSInteger)format scale:(CGFloat)scale;
- (UIImage *)_imageScaledToProportion:(CGFloat)proportion interpolationQuality:(CGInterpolationQuality)quality;
@end

@interface UILabel (Private_Auxo)
- (void)setMarqueeEnabled:(BOOL)enabled;
- (void)setMarqueeRunning:(BOOL)running;
@end

@interface UIAlertView (Private_Auxo)
- (void)_setAccessoryView:(UIView *)view;
@end

@interface UIVisualEffectView (Private_Auxo)
- (void)setEffect:(UIVisualEffect *)effect;
@end

@interface UIPanGestureRecognizer (Private_Auxo)
- (void)_setCanPanHorizontally:(BOOL)horizontally;
- (void)_setCanPanVertically:(BOOL)vertically;
@end

@interface UIKeyboard : UIView
+ (BOOL)isOnScreen;
@end

@interface CALayer (Private_Auxo)
@property BOOL allowsGroupBlending;
@end

@interface _UIBackdropViewSettings : NSObject
+ (id)settingsForStyle:(NSInteger)style;
+ (id)settingsForStyle:(NSInteger)style graphicsQuality:(NSInteger)quality;
//+ (id)settingsForPrivateStyle:(NSInteger)style;
//+ (id)settingsForPrivateStyle:(NSInteger)style graphicsQuality:(NSInteger)quality;
+ (id)darkeningTintColor;
@end

@interface _UIBackdropView : UIView
@property (assign,nonatomic) NSTimeInterval appliesOutputSettingsAnimationDuration;
@property (nonatomic,copy) NSString *groupName;
@property (nonatomic,retain) _UIBackdropViewSettings *inputSettings;
@property (nonatomic,retain) _UIBackdropViewSettings *outputSettings;
- (id)initWithStyle:(NSInteger)style;
//- (id)initWithPrivateStyle:(NSInteger)style;
- (id)initWithSettings:(_UIBackdropViewSettings *)settings;
- (void)setBlurQuality:(NSString *)quality;
@end

@interface UminoCloseAllAppsGestureView : UIView
@end

@interface SBIcon : NSObject
@end

@interface UminoIcon : SBIcon
@end

@interface SBIconModel : NSObject
- (SBIcon *)applicationIconForBundleIdentifier:(NSString *)identifier;
@end

@interface SBIconController : NSObject
+ (SBIconController *)sharedInstance;
- (SBIconModel *)model;
- (BOOL)hasAnimatingFolder;
@end

@interface SBIconImageView : UIView {
	UIImageView *_overlayView;
}
@property (assign,nonatomic) CGFloat overlayAlpha;
@end

@interface UminoIconImageView : SBIconImageView
- (UIView *)alternateIconView;
@end

@protocol SBIconViewDelegate;

@interface SBIconView : UIView
@property (nonatomic,retain) SBIcon *icon;
@property (assign,nonatomic) id<SBIconViewDelegate> delegate;
@property (assign,nonatomic) CGFloat iconImageAlpha;
@property (assign,nonatomic) CGFloat iconAccessoryAlpha;
@property (assign,nonatomic) CGFloat iconLabelAlpha;
@property (nonatomic,getter=isHighlighted) BOOL highlighted;
- (id)initWithDefaultSize;
- (SBIconImageView *)_iconImageView;
@end

@protocol SBIconViewDelegate <NSObject>
@optional
- (void)iconHandleLongPress:(SBIconView *)iconView;
- (void)iconTouchBegan:(SBIconView *)iconView;
- (void)icon:(SBIconView *)iconView touchMoved:(id)touch;
- (void)icon:(SBIconView *)iconView touchEnded:(BOOL)end;
- (BOOL)iconShouldAllowTap:(SBIconView *)iconView;
- (void)iconTapped:(SBIconView *)iconView;
- (BOOL)icon:(SBIconView *)iconView canReceiveGrabbedIcon:(id)icon;
- (void)iconCloseBoxTapped:(SBIconView *)iconView;
- (BOOL)iconViewDisplaysBadges:(SBIconView *)iconView;
- (BOOL)iconViewDisplaysCloseBox:(SBIconView *)iconView;
- (CGFloat)iconLabelWidth;
- (void)icon:(SBIconView *)iconView openFolder:(id)folder animated:(BOOL)animated;
@end

@interface SBAppSwitcherIconView : SBIconView
@end

@interface UminoAppSwitcherIconView : SBAppSwitcherIconView
- (UminoIconImageView *)_iconImageView;
@end

@interface SBActivationSettings : NSObject
@end

@interface SBDeactivationSettings : NSObject
@end

@interface SBStateSettings : NSObject
- (BOOL)boolForStateSetting:(unsigned)settings;
@end

@interface SBApplication : NSObject
@property (setter=_setActivationSettings:,nonatomic,copy) SBActivationSettings *_activationSettings;
@property (setter=_setDeactivationSettings:,nonatomic,copy) SBDeactivationSettings *_deactivationSettings;
@property (setter=_setStateSettings:,nonatomic,copy) SBStateSettings *_stateSettings;
- (NSString *)bundleIdentifier;
- (NSString *)displayName;
- (void)notifyResignActiveForReason:(NSInteger)reason;
- (void)notifyResumeActiveForReason:(NSInteger)reason;
- (void)setFlag:(long long)flag forActivationSetting:(unsigned int)setting;
- (void)setFlag:(long long)flag forDeactivationSetting:(unsigned int)setting;
- (void)setObject:(id)object forActivationSetting:(unsigned int)setting;
- (void)setObject:(id)object forDeactivationSetting:(unsigned int)setting;
@end

@interface SBApplicationController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)identifier;
@end

@interface SpringBoard : UIApplication
+ (SpringBoard *)sharedApplication;
- (SBApplication *)_accessibilityFrontMostApplication;
- (UIInterfaceOrientation)_frontMostAppOrientation;
- (void)_reloadDemoAndDebuggingDefaultsAndCapabilities;
@end

@interface SBFAnimationFactory : NSObject
- (void)_animateWithAdditionalDelay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options actions:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;
@end

@interface SBAppSwitcherScrollView : UIScrollView
@end

typedef struct {
    NSInteger startStyle;
    NSInteger endStyle;
    CGFloat transitionFraction;
} SBWallpaperEffectViewTransitionState;

@interface SBWallpaperEffectView : UIView
-(void)setTransitionState:(SBWallpaperEffectViewTransitionState)state;
@end

@protocol SBAppSwitcherPageContentView <NSObject>
@end

@interface SBAppSwitcherSnapshotView : UIView <SBAppSwitcherPageContentView>
- (void)_crossfadeToZoomUpViewIfNecessary;
@end

@interface SBAppSwitcherHomePageCellView : UIView <SBAppSwitcherPageContentView> {
    SBWallpaperEffectView *_wallpaperView;
}
@end

@interface SBAppSwitcherPageView : UIView
@property (nonatomic,retain) UIView<SBAppSwitcherPageContentView> *view;
@end

@interface SBAppSwitcherItemScrollView : UIScrollView
@property (nonatomic,retain) SBAppSwitcherPageView *item;
@end

@interface SBAppSwitcherPageViewController : UIViewController {
    NSMutableArray *_displayLayouts;
	NSMutableDictionary *_items;
	void (^ _scrollDoneBlock)(void);
}
@property(assign,nonatomic) CGFloat normalizedOffset;
- (void)setOffsetToIndex:(NSUInteger)index animated:(BOOL)animated;
- (NSUInteger)currentPage;
- (BOOL)isScrolling;
- (CGFloat)normalizedOffsetOfIndex:(NSUInteger)index;
- (void)setNormalizedOffset:(CGFloat)offset;
- (CGPoint)_centerOfIndex:(NSUInteger)index;
- (void)_updateVisiblePageViews;
- (CGFloat)_halfWidth;
@end

@interface SBAppSwitcherIconController : UIViewController <SBIconViewDelegate> {
    NSMutableArray *_appList;
    UIView *_iconContainer;
    NSMutableDictionary *_iconViews;
    NSMutableArray *_iconViewCenters;
}
- (void)setOffsetToIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)setNormalizedOffset:(CGFloat)offset;
- (SBAppSwitcherIconView *)_iconViewForIndex:(NSUInteger)index;
- (CGRect)_iconFaultRectForIndex:(NSUInteger)index;
- (CGPoint)_adjustedCenter:(CGPoint)center forIconView:(SBAppSwitcherIconView *)view;
- (void)_updateVisibleIconViewsWithPadding:(BOOL)padding;
@end

@interface UminoAppSwitcherIconRootView : UIView
@end

@protocol SBAppSwitcherControllerDelegate;

@interface SBDisplayItem : NSObject
@property(readonly, nonatomic) NSString *displayIdentifier;
@property(readonly, nonatomic) NSString *type;
@end

@interface SBDisplayLayout : NSObject
@property(readonly, nonatomic) NSArray *displayItems;
@end

@interface SBAppSwitcherSettings : NSObject
@end

@interface SBAppSwitcherController : UIViewController {
	SBAppSwitcherPageViewController *_pageController;
	SBAppSwitcherIconController *_iconController;
    UIView *_contentView;
	UIView *_pageView;
    UIView *_peopleView;
    NSMutableArray *_appList_use_block_accessor;
	SBDisplayLayout* _switcherContinuityApp_use_block_accessor;
	SBAppSwitcherSettings *_settings;
}
@property (assign,nonatomic) id<SBAppSwitcherControllerDelegate> delegate;
@property (copy, nonatomic) SBDisplayLayout *startingDisplayLayout;
- (BOOL)allowShowHide;
- (void)_accessAppListState:(void (^)(NSArray *layouts))block;
- (SBFAnimationFactory *)_transitionAnimationFactory;
- (CGRect)_nominalPageViewFrame;
- (CGFloat)_scaleForFullscreenPageView;
- (CGFloat)_switcherThumbnailVerticalPositionOffset;
- (void)_updatePageViewScale:(CGFloat)scale;
- (void)_updatePageViewScale:(CGFloat)scale xTranslation:(CGFloat)x;
- (void)_bringIconViewToFront;
- (BOOL)switcherScroller:(SBAppSwitcherPageViewController *)scroller displayItemWantsToBeKeptInViewHierarchy:(SBDisplayItem *)item;
- (BOOL)switcherScroller:(SBAppSwitcherPageViewController *)scroller isDisplayItemRemovable:(SBDisplayItem *)item;
- (void)switcherScroller:(SBAppSwitcherPageViewController *)scroller displayItemWantsToBeRemoved:(SBDisplayItem *)item;
- (void)switcherScroller:(SBAppSwitcherPageViewController *)scroller itemTapped:(SBDisplayLayout *)item;
@end

@interface SBAppSwitcherController (Umino)
- (void)showArtwork:(UIImage *)image action:(NSInteger)action;
- (void)hideArtwork;
@end

@protocol SBAppSwitcherControllerDelegate
@required
- (void)appSwitcher:(SBAppSwitcherController *)appSwitcher wantsToActivateDisplayLayout:(SBDisplayLayout *)layout displayIDsToURLs:(NSDictionary *)urls displayIDsToActions:(NSDictionary *)actions;
- (void)appSwitcherWantsToDismissImmediately:(SBAppSwitcherController *)appSwitcher;
- (void)appSwitcherNeedsToReload:(SBAppSwitcherController *)appSwitcher;
@end

@interface SBSearchGesture : NSObject
@property (getter=isActivated,nonatomic,readonly) BOOL activated;
+ (id)sharedInstance;
@end

@interface SBUIController : NSObject {
	SBAppSwitcherController *_switcherController;
}
+ (id)sharedInstance;
- (BOOL)handleMenuDoubleTap;
- (BOOL)clickedMenuButton;
- (BOOL)isAppSwitcherShowing;
- (BOOL)_activateAppSwitcher;
- (void)dismissSwitcherAnimated:(BOOL)animated;
- (void)_hideControlCenterGrabber;
- (void)_installSystemGestureView:(UIView *)view forKey:(NSString *)key forGesture:(NSUInteger)gesture;
- (void)_clearInstalledSystemGestureViewForKey:(NSString *)key;
- (void)restoreContentAndUnscatterIconsAnimated:(BOOL)animated;
- (void)stopRestoringIconList;
- (void)tearDownIconListAndBar;
@end

@interface SBAppSwitcherPeopleViewController : UIViewController
-(void)switcherWasDismissed:(BOOL)arg;
-(void)switcherWillBePresented:(BOOL)arg;
@end

@interface SBNotificationCenterViewController : UIViewController
- (id)_todayViewControllerCreateIfNecessary:(BOOL)arg1;
@end

@interface SBNotificationCenterController : NSObject
@property (nonatomic,retain,readonly) SBNotificationCenterViewController * viewController;
@property (getter=isVisible,nonatomic,readonly) BOOL visible;
+ (id)sharedInstance;
@end

@interface SBTodayTableHeaderView : UIView
@end

@interface SBTodayViewController : UIViewController
- (SBTodayTableHeaderView *)todayTableHeaderView;
@end

@interface BSEventQueueEvent : NSObject
+ (id)eventWithName:(NSString *)name handler:(void(^)())handler;
@end

@interface FBWorkspaceEvent : BSEventQueueEvent
@end

@interface FBWorkspaceEventQueue : NSObject
+ (id)sharedInstance;
- (void)executeOrAppendEvent:(FBWorkspaceEvent *)event;
@end

@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (void)lockUIFromSource:(int)source withOptions:(NSDictionary *)options;
@end

@interface SBAlertManager : NSObject
- (id)activeAlert;
@end

@interface SBWorkspaceTransaction : NSObject
@end

@interface SBToAppWorkspaceTransaction : SBWorkspaceTransaction
@end

@interface SBAppToAppWorkspaceTransaction : SBToAppWorkspaceTransaction
- (id)initWithAlertManager:(SBAlertManager *)manager from:(SBApplication *)from to:(SBApplication *)to withResult:(id)handler;
- (id)initWithAlertManager:(SBAlertManager *)manager exitedApp:(SBApplication *)exitedApp;
@end

@interface BKSWorkspace : NSObject
- (id)topApplication;
@end

@interface SBWorkspace : NSObject
@property(readonly, assign, nonatomic) SBAlertManager *alertManager;
@property(readonly, assign, nonatomic) BKSWorkspace *bksWorkspace;
@property(retain, nonatomic) SBWorkspaceTransaction *currentTransaction;
- (id)_applicationForBundleIdentifier:(id)bundleIdentifier frontmost:(BOOL)frontmost;
@end

@interface FBWindowContextManager : NSObject
@end

@interface FBWindowContextHostManager : NSObject
- (void)disableHostingForRequester:(NSString *)requester;
@end

@interface FBScene : NSObject
@property (nonatomic,retain,readonly) FBWindowContextManager *contextManager;
@property (nonatomic,retain,readonly) FBWindowContextHostManager *contextHostManager;
@end

@interface FBSceneManager : NSObject
+ (id)sharedInstance;
- (FBScene *)sceneWithIdentifier:(id)arg1 ;
@end

@interface SBWallpaperController : NSObject
+ (id)sharedInstance;
- (void)beginRequiringWithReason:(NSString *)reason;
- (void)endRequiringWithReason:(NSString *)reason;
@end

@protocol SBControlCenterObserver <NSObject>
@required
- (void)controlCenterWillPresent;
- (void)controlCenterDidDismiss;
- (void)controlCenterWillBeginTransition;
- (void)controlCenterDidFinishTransition;
@optional
- (void)controlCenterWillFinishTransitionOpen:(BOOL)open withDuration:(NSTimeInterval)duration;
@end

@protocol SBControlCenterSectionViewControllerDelegate;

@interface SBControlCenterSectionViewController : UIViewController <SBControlCenterObserver>
@property(assign,nonatomic) id<SBControlCenterSectionViewControllerDelegate> delegate;
- (UIView *)view;
@end

@interface SBControlCenterStatusUpdate : NSObject // iOS 7.1
@property(nonatomic) NSInteger type;
@property(copy, nonatomic) NSArray *statusStrings;
@property(copy, nonatomic) NSString *reason;
@end

@protocol SBControlCenterSectionViewControllerDelegate <NSObject>
@required
- (void)noteSectionEnabledStateDidChange:(SBControlCenterSectionViewController *)section;
- (void)sectionWantsControlCenterDismissal:(SBControlCenterSectionViewController *)section;
- (void)section:(SBControlCenterSectionViewController *)section updateStatusText:(NSString *)text reason:(NSString *)reason; // iOS 7.0
- (void)section:(SBControlCenterSectionViewController *)section publishStatusUpdate:(SBControlCenterStatusUpdate *)update; // iOS 7.1
@end

@interface SBCCSettingsSectionController : SBControlCenterSectionViewController
@end

@interface SBCCBrightnessSectionController : SBControlCenterSectionViewController
@end

@class MPUSystemMediaControlsViewController;

@interface SBCCMediaControlsSectionController : SBControlCenterSectionViewController {
    MPUSystemMediaControlsViewController *_systemMediaViewController;
}
@end

@class MPAudioVideoRoutingViewController, SFAirDropDiscoveryController;

@interface SBCCAirStuffSectionController : SBControlCenterSectionViewController {
	MPAudioVideoRoutingViewController *_airPlayViewController;
	SFAirDropDiscoveryController *_airDropDiscoveryController;
}
@property(assign, nonatomic) BOOL airPlayEnabled;
@property(assign, nonatomic) BOOL airDropEnabled;
- (void)_dismissAirplayControllerAnimated:(BOOL)animated;
@end

@interface SBCCQuickLaunchSectionController : SBControlCenterSectionViewController
@end

@interface UminoCCAirStuffSectionController : SBCCAirStuffSectionController
@end

@interface UminoCCQuickLaunchSectionController : SBCCQuickLaunchSectionController
@end

@interface SBControlCenterSeparatorView : UIView
@end

@interface SBControlCenterSectionView : UIView
@property (assign, nonatomic) CGFloat edgePadding;
@end

@interface SBCCButtonLikeSectionView : UIControl {
    UIButton *_button;
    UILabel *_label;
}
@property (assign,nonatomic) UIRectCorner roundCorners;
- (void)setText:(NSString *)text;
- (void)_updateEffects;
@end

@interface UminoCCButtonLikeSectionView : SBCCButtonLikeSectionView
@end

@interface SBCCButtonLikeSectionSplitView : SBControlCenterSectionView {
    SBControlCenterSeparatorView *_separatorView;
    CGFloat _separatorWidth;
}
- (SBCCButtonLikeSectionView *)leftSection;
- (SBCCButtonLikeSectionView *)rightSection;
- (void)_relayoutAnimated:(BOOL)animated;
- (CGRect)_separatorFrame;
@end

@interface UminoCCButtonLikeSectionSplitView : SBCCButtonLikeSectionSplitView
@end

@interface SBCCButtonLayoutView : SBControlCenterSectionView
- (NSArray *)buttons;
@end

@interface SBUIControlCenterButton : UIButton
- (void)setGlyphImage:(UIImage *)glyphImage selectedGlyphImage:(UIImage *)selectedGlyphImage;
- (void)setBackgroundImage:(UIImage *)image;
@end

@interface SBControlCenterButton : SBUIControlCenterButton
@end

@interface SBChevronView : UIView
- (void)setState:(NSInteger)state animated:(BOOL)animated;
@end

@interface SBUIControlCenterVisualEffect : UIVisualEffect
+ (UIVisualEffect *)effectWithStyle:(NSInteger)style;
@end

@interface SBControlCenterGrabberView : UIView
- (SBChevronView *)chevronView;
- (void)updateStatusText:(NSString *)text reason:(NSString *)reason;
- (void)presentStatusUpdate:(SBControlCenterStatusUpdate *)update;
@end

@interface SBControlCenterContentView : UIView <SBControlCenterObserver>
@property (nonatomic,retain) SBControlCenterGrabberView *grabberView;
@property (nonatomic,retain) SBCCSettingsSectionController *settingsSection;
@property (nonatomic,retain) SBCCBrightnessSectionController *brightnessSection;
@property (nonatomic,retain) SBCCMediaControlsSectionController *mediaControlsSection;
@property (nonatomic,retain) SBCCAirStuffSectionController *airplaySection;
@property (nonatomic,retain) SBCCQuickLaunchSectionController *quickLaunchSection;
- (NSArray *)_allSections;
- (void)updateEnabledSections;
@end

@interface SBControlCenterViewController : UIViewController {
	SBControlCenterContentView *_contentView;
}
- (CGFloat)contentHeightForOrientation:(UIInterfaceOrientation)orientation;
@end

@interface SBControlCenterController : UIViewController {
	SBControlCenterViewController *_viewController;
}
@property(assign,getter=isUILocked,nonatomic) BOOL UILocked;
@property(assign,getter=isPresented,nonatomic) BOOL presented;
+ (id)sharedInstance;
- (void)beginTransitionWithTouchLocation:(CGPoint)location;
- (void)updateTransitionWithTouchLocation:(CGPoint)location velocity:(CGPoint)velocity;
- (void)endTransitionWithVelocity:(CGPoint)velocity completion:(void(^)(void))completion;
- (void)cancelTransition;
@end

@interface SBGestureViewVendor : NSObject
+ (id)sharedInstance;
- (id)viewForApp:(SBApplication *)application gestureType:(NSUInteger)type includeStatusBar:(BOOL)flag;
@end

@interface SBMediaController : NSObject
@property (assign,getter=isRingerMuted,nonatomic) BOOL ringerMuted;
+ (id)sharedInstance;
- (SBApplication *)nowPlayingApplication;
- (NSDictionary *)_nowPlayingInfo;
- (BOOL)hasTrack;
- (BOOL)isPlaying;
@end

@interface SBHUDView : UIView
@property (assign, nonatomic) int level;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) UIImage *image;
@property (assign, nonatomic) BOOL showsProgress;
@property (assign, nonatomic) float progress;
@end

@interface SBBrightnessHUDView : SBHUDView
@end

@interface UminoBrightnessHUDView : SBBrightnessHUDView
@end

@interface SBHUDController : NSObject
+ (id)sharedHUDController;
- (SBHUDView *)visibleHUDView;
- (void)hideHUDView;
- (SBHUDView *)visibleOrFadingHUDView;
- (void)presentHUDView:(SBHUDView *)view;
- (void)presentHUDView:(SBHUDView *)view autoDismissWithDelay:(NSTimeInterval)delay;
- (void)reorientHUDIfNeeded:(BOOL)animated;
@end

@interface SBRingerHUDController : NSObject
+ (void)activate:(int)arg1;
@end

@interface SBVolumeHUDView : SBHUDView
@end

@interface SBBacklightController : NSObject
+ (id)sharedInstance;
- (void)setIdleTimerDisabled:(BOOL)disabled forReason:(NSString *)reason;
- (void)_lockScreenDimTimerFired;
@end

@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (void)addAlwaysHiddenCategory:(NSString *)category;
- (void)removeAlwaysHiddenCategory:(NSString *)category;
@end

@interface _UIScreenEdgePanRecognizerEdgeSettings : NSObject
@property(assign,nonatomic) double hysteresis;
@property(assign,nonatomic) double maximumSwipeDuration;
@property(assign,nonatomic) double bottomEdgeRegionSize;
@end

@interface _UIScreenEdgePanRecognizerSettings : NSObject
@property(nonatomic,retain) _UIScreenEdgePanRecognizerEdgeSettings *edgeSettings;
@end

@interface SBOffscreenSwipeGestureRecognizer : NSObject
@property(nonatomic,readonly) UIGestureRecognizerState state;
@property(nonatomic,readonly) CGPoint centroidPoint;
@property(nonatomic,readonly) CGPoint movementVelocityInPointsPerSecond;
@property(nonatomic,retain) _UIScreenEdgePanRecognizerSettings *settings;
@end

#if __cplusplus
extern "C" {
#endif
    typedef struct BKSDisplayBrightnessTransaction *BKSDisplayBrightnessTransactionRef;
    BKSDisplayBrightnessTransactionRef BKSDisplayBrightnessTransactionCreate(CFAllocatorRef allocator);
    float BKSDisplayBrightnessGetCurrent();
    void BKSDisplayBrightnessSet(float level, int __unknown_1);
    void BKSDisplayBrightnessSetAutoBrightnessEnabled(Boolean enabled);
	void BKSHIDServicesSystemGesturesNoLongerPossible();
	void BKSHIDServicesCancelTouchesOnMainDisplay();
#if __cplusplus
}
#endif

#if __cplusplus
extern "C" {
#endif
    void GSSendAppPreferencesChanged(CFStringRef bundleID, CFStringRef key);
#if __cplusplus
}
#endif

#if __cplusplus
extern "C" {
#endif
	CFPropertyListRef MGCopyAnswer(CFStringRef property);
#if __cplusplus
}
#endif

@interface AVSystemController : NSObject
+ (id)sharedAVSystemController;
- (BOOL)getVolume:(float*)volume forCategory:(NSString *)category;
- (BOOL)setVolumeTo:(float)volume forCategory:(NSString *)category;
@end

@class MPAVController;
@protocol MPVolumeControllerDelegate;

@interface MPVolumeController : NSObject
@property (assign, nonatomic) id<MPVolumeControllerDelegate> delegate;
@property (nonatomic, readonly) float volumeValue;
@property (assign, nonatomic) BOOL muted;
@property (nonatomic, retain) MPAVController *player;
@property (nonatomic, copy) NSString *volumeAudioCategory;
@property (nonatomic, readonly) BOOL volumeWarningEnabled;
@property (nonatomic, readonly) int volumeWarningState;
@property (nonatomic, readonly) float EUVolumeLimit;
- (float)setVolumeValue:(float)value;
- (void)updateVolumeValue;
- (void)updateVolumeWarningState;
@end

@protocol MPVolumeControllerDelegate <NSObject>
@optional
- (void)volumeController:(MPVolumeController *)controller volumeValueDidChange:(float)value;
- (void)volumeController:(MPVolumeController *)controller volumeWarningStateDidChange:(int)state;
- (void)volumeController:(MPVolumeController *)controller mutedStateDidChange:(BOOL)muted;
- (void)volumeController:(MPVolumeController *)controller EUVolumeLimitDidChange:(float)limit;
- (void)volumeController:(MPVolumeController *)controller EUVolumeLimitEnforcedDidChange:(BOOL)enforced;
@end

@interface MPAudioVideoRoutingViewController : UIViewController
@property (assign, nonatomic) id delegate;
+ (BOOL)hasWirelessDisplayRoutes;
- (void)_doneAction:(id)sender;
@end

@protocol MPUNowPlayingDelegate;

@interface MPUNowPlayingController : NSObject {
	NSDictionary *_currentNowPlayingInfo;
}
@property (assign, nonatomic) id<MPUNowPlayingDelegate> delegate;
@property (nonatomic, readonly) NSDictionary *currentNowPlayingInfo;
@property (nonatomic, readonly) UIImage *currentNowPlayingArtwork;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) NSString *nowPlayingAppDisplayID;
@property (nonatomic, readonly) NSTimeInterval currentElapsed;
@property (nonatomic, readonly) NSTimeInterval currentDuration;
@property (assign, nonatomic) NSTimeInterval timeInformationUpdateInterval;
- (void)update;
- (void)startUpdating;
- (void)stopUpdating;
@end

@protocol MPUNowPlayingDelegate <NSObject>
@optional
- (void)nowPlayingControllerDidBeginListeningForNotifications:(MPUNowPlayingController *)controller;
- (void)nowPlayingControllerDidStopListeningForNotifications:(MPUNowPlayingController *)controller;
- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingInfoDidChange:(NSDictionary *)info;
- (void)nowPlayingController:(MPUNowPlayingController *)controller playbackStateDidChange:(BOOL)playing;
- (void)nowPlayingController:(MPUNowPlayingController *)controller nowPlayingApplicationDidChange:(NSString *)application;
- (void)nowPlayingController:(MPUNowPlayingController *)controller elapsedTimeDidChange:(NSTimeInterval)elapsed;
@end

@protocol MPUChronologicalProgressViewDelegate;

@interface MPUChronologicalProgressView : UIView
@property (nonatomic) BOOL scrubbingEnabled;
@property (nonatomic) BOOL showTimeLabels;
@property (nonatomic) NSTimeInterval currentTime;
@property (nonatomic) NSTimeInterval totalDuration;
@property (readonly, nonatomic) int style;
@property (nonatomic, assign) id<MPUChronologicalProgressViewDelegate> delegate;
@property (readonly, nonatomic) CGRect trackRect;
- (id)initWithStyle:(int)style;
@end

@protocol MPUChronologicalProgressViewDelegate <NSObject>
@optional
- (void)progressViewDidBeginScrubbing:(MPUChronologicalProgressView *)progressView;
- (void)progressViewDidEndScrubbing:(MPUChronologicalProgressView *)progressView;
- (void)progressView:(MPUChronologicalProgressView *)progressView didScrubToCurrentTime:(NSTimeInterval)time;
@end

@interface MPUTransportControlsView : UIView
- (UIButton *)_leftButton;
- (UIButton *)_middleButton;
- (UIButton *)_rightButton;
- (void)_transportControlTap:(UIButton *)sender;
@end

@interface MPUNowPlayingTitlesView : UIView
@property (nonatomic,copy) NSString *titleText;
@property (nonatomic,copy) NSString *albumText;
@property (nonatomic,copy) NSString *artistText;
@end

@interface MPUMediaControlsTitlesView : MPUNowPlayingTitlesView
- (void)_touchControlTapped:(UIControl *)sender;
- (void)updateTrackInformationWithNowPlayingInfo:(NSDictionary *)info;
@end

@interface MPUMediaControlsTitlesView (Umino)
- (void)handleArtwork:(NSNumber *)action;
- (UIImage *)__artwork;
@end

@interface MPUMediaControlsVolumeView : UIView
@end

@interface _MPUSystemMediaControlsView : UIView
@property (nonatomic,retain) MPUTransportControlsView *transportControlsView;
@property (nonatomic,retain) MPUChronologicalProgressView *timeInformationView;
@property (nonatomic,retain) MPUMediaControlsTitlesView *trackInformationView;
@property (nonatomic,retain) MPUMediaControlsVolumeView *volumeView;
@end

@interface MPUSystemMediaControlsViewController : UIViewController {
    _MPUSystemMediaControlsView *_mediaControlsView;
}
@end

#if __cplusplus
extern "C" {
#endif
    extern CFStringRef kMRMediaRemoteNowPlayingInfoTitle;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoArtist;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoAlbum;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoArtworkData;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoElapsedTime;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoDuration;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsMusicApp;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsRewind15Seconds;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsFastForward15Seconds;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsIsLiked;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoSupportsIsBanned;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsLiked;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsBanned;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoIsInWishList;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoUniqueIdentifier;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRadioStationIdentifier;
    extern CFStringRef kMRMediaRemoteNowPlayingInfoRadioStationHash;
    extern CFStringRef kMRMediaRemoteOptionSkipInterval;
    extern CFStringRef kMRMediaRemoteOptionTrackID;
    extern CFStringRef kMRMediaRemoteOptionStationID;
    extern CFStringRef kMRMediaRemoteOptionStationHash;
    extern CFStringRef kMRMediaRemoteCommandInfoIsActiveKey;
    extern CFStringRef kMRMediaRemoteOptionIsNegative;
    typedef NS_ENUM(NSInteger, MRCommand) {
        kMRPlay = 0,
        kMRPause = 1,
        kMRTogglePlayPause = 2,
        kMRStop = 3,
        kMRNextTrack = 4,
        kMRPreviousTrack = 5,
        kMRToggleShuffle = 6,
        kMRToggleRepeat = 7,
        kMRStartForwardSeek = 8,
        kMREndForwardSeek = 9,
        kMRStartBackwardSeek = 10,
        kMREndBackwardSeek = 11,
        kMRSkipFifteenSeconds = 17,
        kMRGoBackFifteenSeconds = 18,
        kMRLikeTrack = 21,
        kMRBanTrack = 22,
        kMRBookmarkTrack = 23,
    };
    Boolean MRMediaRemoteSendCommand(MRCommand command, id userInfo);
    void MRMediaRemoteSetElapsedTime(NSTimeInterval elapsedTime);
	void MRMediaRemoteCopySupportedCommands(dispatch_queue_t queue, void(^block)(NSArray *));
	MRCommand MRMediaRemoteCommandInfoGetCommand(id commandInfo);
	Boolean MRMediaRemoteCommandInfoGetEnabled(id commandInfo);
	CFTypeRef MRMediaRemoteCommandInfoCopyValueForKey(id commandInfo, CFStringRef key);
#if __cplusplus
}
#endif

typedef NS_ENUM(NSInteger, SFAirDropDiscoverableMode) {
	SFAirDropDiscoverableModeOff,
	SFAirDropDiscoverableModeContactsOnly,
	SFAirDropDiscoverableModeEveryone
};

@interface SFAirDropDiscoveryController : NSObject {
	SFAirDropDiscoverableMode _discoverableMode;
}
@end

@protocol UIModalItemDelegate;

@interface _UIModalItem : NSObject
@property (assign, nonatomic) id<UIModalItemDelegate> delegate;
+ (id)modalItemWithType:(NSInteger)type title:(id)title message:(id)message buttonTitles:(id)buttonTitles completion:(id)completionBlock;
@end

@protocol UIModalItemDelegate <NSObject>
@optional
- (void)willPresentModalItem:(_UIModalItem *)modalItem;
- (void)didPresentModalItem:(_UIModalItem *)modalItem;
- (BOOL)modalItem:(_UIModalItem *)modalItem shouldDismissForButtonAtIndex:(NSInteger)index;
- (void)modalItem:(_UIModalItem *)modalItem willDismissWithButtonIndex:(NSInteger)index;
- (void)modalItem:(_UIModalItem *)modalItem didDismissWithButtonIndex:(NSInteger)index;
- (BOOL)modalItemShouldEnableFirstOtherButton:(_UIModalItem *)modalItem;
@end

@interface UIViewController (UIModalItem)
- (void)presentModalItem:(_UIModalItem *)modalItem animated:(BOOL)animated;
- (void)updateModaltem:(_UIModalItem *)modalItem animated:(BOOL)animated;
- (void)dismissModalItem:(_UIModalItem *)modalItem withTappedButtonIndex:(NSInteger)index animated:(BOOL)animated;
@end

@protocol RUTrackActionsDelegate;

@protocol RUTrackActioning <NSObject>
@property (copy, nonatomic) NSString *songText;
@property (copy, nonatomic) NSString *artistText;
@property (retain, nonatomic) UIImage *artworkImage;
@property (assign, nonatomic) id<RUTrackActionsDelegate> trackActionsDelegate;
@property (assign, nonatomic) NSInteger enabledActions;
@property (assign, nonatomic) NSInteger onActions;
@property (readonly, nonatomic) NSInteger cancelIndex;
@property (readonly, nonatomic) CGSize contentSize;
@required
+ (CGSize)artworkSize;
- (NSInteger)actionForButtonIndex:(NSInteger)index;
@end

@protocol RUTrackActionsDelegate <NSObject>
@optional
- (void)trackActioningObject:(id<RUTrackActioning>)trackActioningObject didSelectAction:(NSInteger)action atIndex:(NSInteger)index;
- (void)trackActioningObjectDidChangeContentSize:(id<RUTrackActioning>)trackActioningObject;
@end

@interface RUTrackActionsModalItem : _UIModalItem <RUTrackActioning> // 1 nil nil nil nil
@end

@interface AVFlashlight : NSObject
+ (BOOL)hasFlashlight;
@end

typedef NS_ENUM(NSInteger, PSCellType) {
    PSGroupCell,
    PSLinkCell,
    PSLinkListCell,
    PSListItemCell,
    PSTitleValueCell,
    PSSliderCell,
    PSSwitchCell,
    PSStaticTextCell,
    PSEditTextCell,
    PSSegmentCell,
    PSGiantIconCell,
    PSGiantCell,
    PSSecureEditTextCell,
    PSButtonCell,
    PSEditTextViewCell,
};

@interface PSSpecifier : NSObject {
@public
    id target;
    SEL getter;
    SEL setter;
    SEL action;
    Class detailControllerClass;
    PSCellType cellType;
    Class editPaneClass;
    UIKeyboardType keyboardType;
    UITextAutocapitalizationType autoCapsType;
    UITextAutocorrectionType autoCorrectionType;
    int textFieldType;
@private
    NSString* _name;
    NSArray* _values;
    NSDictionary* _titleDict;
    NSDictionary* _shortTitleDict;
    id _userInfo;
    NSMutableDictionary* _properties;
}
@property(retain) NSMutableDictionary* properties;
@property(retain) NSString* identifier;
@property(retain) NSString* name;
@property(retain) id userInfo;
@property(retain) id titleDictionary;
@property(retain) id shortTitleDictionary;
@property(retain) NSArray* values;
+(id)preferenceSpecifierNamed:(NSString*)title target:(id)target set:(SEL)set get:(SEL)get detail:(Class)detail cell:(PSCellType)cell edit:(Class)edit;
+(PSSpecifier*)groupSpecifierWithName:(NSString*)title;
+(PSSpecifier*)emptyGroupSpecifier;
+(UITextAutocapitalizationType)autoCapsTypeForString:(PSSpecifier*)string;
+(UITextAutocorrectionType)keyboardTypeForString:(PSSpecifier*)string;
-(id)propertyForKey:(NSString*)key;
-(void)setProperty:(id)property forKey:(NSString*)key;
-(void)removePropertyForKey:(NSString*)key;
-(void)loadValuesAndTitlesFromDataSource;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles;
-(void)setValues:(NSArray*)values titles:(NSArray*)titles shortTitles:(NSArray*)shortTitles;
-(void)setupIconImageWithPath:(NSString*)path;
-(NSString*)identifier;
-(void)setTarget:(id)target;
-(void)setKeyboardType:(UIKeyboardType)type autoCaps:(UITextAutocapitalizationType)autoCaps autoCorrection:(UITextAutocorrectionType)autoCorrection;
@end

@interface PSViewController : UIViewController
@property(readonly, retain) PSSpecifier *specifier;
@end

@interface PSListController : PSViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *_specifiers;
    UITableView *_table;
}
@property(retain) NSArray *specifiers;
- (id)initForContentSize:(CGSize)size;
- (UITableView *)table;
- (PSSpecifier *)specifierForID:(NSString *)identifier;
- (NSArray *)specifiersInGroup:(NSInteger)group;
- (void)insertSpecifier:(PSSpecifier *)specifier afterSpecifier:(PSSpecifier *)afterSpecifier animated:(BOOL)animated;
- (void)insertContiguousSpecifiers:(NSArray *)specifiers afterSpecifier:(PSSpecifier *)afterSpecifier animated:(BOOL)animated;
- (void)insertContiguousSpecifiers:(NSArray *)specifiers atIndex:(NSInteger)index animated:(BOOL)animated;
- (void)removeSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (void)removeContiguousSpecifiers:(NSArray *)specifiers animated:(BOOL)animated;
- (void)reloadSpecifier:(PSSpecifier *)specifier animated:(BOOL)animated;
- (NSInteger)indexForIndexPath:(NSIndexPath *)indexPath;
- (BOOL)getGroup:(NSInteger *)group row:(NSInteger *)row ofSpecifier:(PSSpecifier *)specifier;
- (void)reloadSpecifiers;
@end

@interface PSListItemsController : PSListController
@end

@interface PSTableCell : UITableViewCell
@property(nonatomic,retain) PSSpecifier *specifier;
@property(assign,nonatomic) PSCellType type;
@property(assign,getter=isChecked,nonatomic) BOOL checked;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier;
- (void)refreshCellContentsWithSpecifier:(PSSpecifier *)specifier;
@end

@interface FSSwitchButton : UIButton
@end

@interface FCCButtonsScrollView : UIScrollView {
    NSMutableArray *buttons;
    NSBundle *templateBundle;
    CGFloat beforePadding;
    CGFloat afterPadding;
    CGSize buttonSize;
}
- (void)showStateForSwitchWithIdentifier:(NSString *)identifier;
- (void)layoutSubviews;
- (void)reloadButtons;
- (void)unloadButtons;
@end

@interface PLContainerView : SBCCButtonLayoutView
@end

@interface PLQuickLaunchView : UIView {
    CGSize _buttonSize;
    NSMutableArray *_quickLaunchButtons;
}
@end

@interface PLQuickLaunchButton : SBUIControlCenterButton
@end

#define kUmino @"com.a3tweaks.auxo3"
#define kResourcesBundlePath @"/Library/PreferenceBundles/Auxo3Preferences.bundle"
#define kPreferencesPlist @"/var/mobile/Library/Preferences/com.a3tweaks.auxo3.plist"
#define kPreferencesNotification @"com.a3tweaks.auxo3.preferencesChanged"
#define kExceptionsPlist @"/var/mobile/Library/Preferences/com.a3tweaks.auxo3.exceptions.plist"
#define kExceptionsNotification @"com.a3tweaks.auxo3.exceptionsChanged"
#define kMultiCenterKey @"MultiCenter"
#define kQuickSwitcherKey @"QuickSwitcher"
#define kHotCornersKey @"HotCorners"
#define kReachabilityModeKey @"ReachabilityMode"
#define kMinimalControlCenterEnabledKey @"MinimalControlCenterEnabled"
#define kMinimalControlCenterConditionKey @"MinimalControlCenterCondition"
#define kOpenToLastAppKey @"OpenToLastApp"
#define kOpenToLastAppWithQSKey @"OpenToLastAppWithQS"
#define kQuickLauncherNotPlayingKey @"QuickLauncherNotPlaying"
#define kQuickLauncherIsPlayingKey @"QuickLauncherIsPlaying"
#define kQuickLauncherAutoDismissDelayKey @"QuickLauncherAutoDismissDelay"
#define kSliderActionsBrightnessKey @"SliderActionsBrightness"
#define kSliderActionsVolumeKey @"SliderActionsVolume"
#define kSliderActionsDisableHUDKey @"SliderActionsDisableHUD"
#define kAlbumArtworkAutoDisplayKey @"AlbumArtworkAutoDisplay"
#define kAlbumArtworkAutoDismissDelayKey @"AlbumArtworkAutoDismissDelay"
#define kCloseAllAppsNoConfirmationKey @"CloseAllAppsNoConfirmation"
#define kCloseAllAppsBackToHomeScreenKey @"CloseAllAppsBackToHomeScreen"
#define kCloseAllAppsExcludeNowPlayingKey @"CloseAllAppsExcludeNowPlaying"
#define kCloseAllAppsExceptionsKey @"CloseAllAppsExceptions"
#define kUnlimitedQuickSwitcherKey @"UnlimitedQuickSwitcher"
#define kAccessHomeScreenKey @"AccessHomeScreen"
#define kAccessAppSwitcherKey @"AccessAppSwitcher"
#define kInvertHotCornersKey @"InvertHotCorners"
#define kPeopleInTodayKey @"PeopleInToday"
#define kDisableHomeDoubleClickKey @"DisableHomeDoubleClick"
#define kDisableWithKeyboardKey @"DisableWithKeyboard"

#if __cplusplus
extern "C" {
#endif
    extern BOOL phone;
    extern BOOL widescreen;
    extern BOOL iphone6;
    extern BOOL iphone6plus;
	extern BOOL reachabilityMode;
	extern UminoControlCenterTopView *controlCenterTopView;
	extern UminoControlCenterBottomView *controlCenterBottomView;
	extern UminoControlCenterOriginalView *controlCenterOriginalView;
    BOOL UminoIsPortrait(BOOL update);
    BOOL UminoIsMinimalStyle(BOOL update);
#if __cplusplus
}
#endif

CHInline static CGFloat screenWidth()
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    return (UminoIsPortrait(NO) ? mainScreen.bounds.size.width : mainScreen.bounds.size.height);
}

CHInline static CGFloat screenHeight()
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    return (UminoIsPortrait(NO) ? mainScreen.bounds.size.height : mainScreen.bounds.size.width);
}

CHInline static UIImage *imageResource(NSString *name)
{
    return [UIImage imageNamed:name inBundle:[NSBundle bundleWithPath:kResourcesBundlePath]];
}

CHInline static NSString *localizedString(NSString *string)
{
	return [[NSBundle bundleWithPath:kResourcesBundlePath]localizedStringForKey:string value:string table:nil];
}

CHInline static id getPreferences(NSString *key)
{
    id value = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPlist][key];
    if (value == nil) {
    	if ([key isEqualToString:kMultiCenterKey]) {
            value = @(YES);
        } else if ([key isEqualToString:kQuickSwitcherKey]) {
            value = @(YES);
        } else if ([key isEqualToString:kHotCornersKey]) {
            value = @(YES);
        } else if ([key isEqualToString:kReachabilityModeKey]) {
			value = @(YES);
        } else if ([key isEqualToString:kMinimalControlCenterEnabledKey]) {
            value = @(YES);
        } else if ([key isEqualToString:kMinimalControlCenterConditionKey]) {
            value = @(1);
		} else if ([key isEqualToString:kOpenToLastAppKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kQuickLauncherNotPlayingKey]) {
            value = @(0);
        } else if ([key isEqualToString:kQuickLauncherIsPlayingKey]) {
            value = @(0);
        } else if ([key isEqualToString:kQuickLauncherAutoDismissDelayKey]) {
            value = @(3);
        } else if ([key isEqualToString:kSliderActionsBrightnessKey]) {
			value = @(2);
		} else if ([key isEqualToString:kSliderActionsVolumeKey]) {
			value = @(2);
		} else if ([key isEqualToString:kSliderActionsDisableHUDKey]) {
			value = @(NO);
		} else if ([key isEqualToString:kAlbumArtworkAutoDisplayKey]) {
            value = @(6);
        } else if ([key isEqualToString:kAlbumArtworkAutoDismissDelayKey]) {
            value = @(1);
        } else if ([key isEqualToString:kCloseAllAppsNoConfirmationKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kCloseAllAppsBackToHomeScreenKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kCloseAllAppsExcludeNowPlayingKey]) {
            value = @(YES);
        } else if ([key isEqualToString:kCloseAllAppsExceptionsKey]) {
            value = @{};
        } else if ([key isEqualToString:kUnlimitedQuickSwitcherKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kAccessHomeScreenKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kAccessAppSwitcherKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kInvertHotCornersKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kPeopleInTodayKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kDisableHomeDoubleClickKey]) {
            value = @(NO);
        } else if ([key isEqualToString:kDisableWithKeyboardKey]) {
            value = @(NO);
        }
    }
    return value;
}

CHInline static void setPreferences(NSString *key, id value)
{
    NSMutableDictionary *preferences = [NSMutableDictionary dictionary];
    [preferences addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kPreferencesPlist]];
    [preferences setObject:value forKey:key];
    [preferences writeToFile:kPreferencesPlist atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)kPreferencesNotification, NULL, NULL, TRUE);
}

CHInline static id getPreferencesAppList(NSString *key, NSString *application) {
    NSDictionary *values = getPreferences(key);
    if ([values isKindOfClass:NSDictionary.class]) {
        return values[application];
    } else {
        setPreferences(key, nil);
        return nil;
    }
}

CHInline static void setPreferencesAppList(NSString *key, NSString *application, id value) {
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    [values addEntriesFromDictionary:getPreferences(key)];
    values[application] = value;
    setPreferences(key, values);
}

CHInline static BOOL getExceptions(NSString *application)
{
	return [[NSDictionary dictionaryWithContentsOfFile:kExceptionsPlist][application] boolValue];
}

CHInline static void setExceptions(NSString *application, BOOL enabled)
{
	NSMutableDictionary *preferences = [NSMutableDictionary dictionary];
    [preferences addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:kExceptionsPlist]];
    [preferences setObject:@(enabled) forKey:application];
    [preferences writeToFile:kExceptionsPlist atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)kExceptionsNotification, NULL, NULL, TRUE);
}
