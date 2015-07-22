#import "UminoControlCenterOriginalView.h"
#import "Headers.h"

@interface UminoControlCenterOriginalView () <SBControlCenterSectionViewControllerDelegate>
@end

@implementation UminoControlCenterOriginalView {
    UIVisualEffectView *_backgroundView;
	UIVisualEffect *_backgroundEffect;
	UIView *_tintView;
	SBControlCenterContentView *_contentView;
    _MPUSystemMediaControlsView *_mediaControlsView;
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
        _contentView = [[NSClassFromString(@"SBControlCenterContentView") alloc]initWithFrame:CGRectZero];
        [self addSubview:_backgroundView];
		[self addSubview:_tintView];
        [self addSubview:_contentView];
        _contentView.settingsSection = [[NSClassFromString(@"SBCCSettingsSectionController") alloc]init];
        _contentView.settingsSection.delegate = self;
        _contentView.brightnessSection = [[NSClassFromString(@"SBCCBrightnessSectionController") alloc]init];
        _contentView.brightnessSection.delegate = self;
        _contentView.mediaControlsSection = [[NSClassFromString(@"SBCCMediaControlsSectionController") alloc]init];
        _contentView.mediaControlsSection.delegate = self;
        _contentView.airplaySection = [[NSClassFromString(@"SBCCAirStuffSectionController") alloc]init];
        _contentView.airplaySection.delegate = self;
        _contentView.quickLaunchSection = [[NSClassFromString(@"SBCCQuickLaunchSectionController") alloc]init];
        _contentView.quickLaunchSection.delegate = self;
        [_contentView updateEnabledSections];
        UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(gestureRecognized:)];
	    [gestureRecognizer _setCanPanHorizontally:NO];
	    [gestureRecognizer _setCanPanVertically:YES];
        [_contentView.grabberView addGestureRecognizer:gestureRecognizer];
        MPUSystemMediaControlsViewController *mediaViewController = CHIvar(_contentView.mediaControlsSection, _systemMediaViewController, MPUSystemMediaControlsViewController * const);
        if (mediaViewController != nil) {
            _mediaControlsView = CHIvar(mediaViewController, _mediaControlsView, _MPUSystemMediaControlsView * const);    
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    _backgroundView.frame = bounds;
    _tintView.frame = bounds;
    bounds.size.height /= 2.0;
    _contentView.frame = bounds;
    [_contentView setNeedsLayout];
}

- (void)setHidden:(BOOL)hidden
{
	[_backgroundView setEffect:hidden ? nil : _backgroundEffect];
    if (self.hidden == hidden) {
        [super setHidden:hidden];    
    } else {
        [super setHidden:hidden];
        if (hidden) {
        	[_contentView controlCenterDidDismiss];
            [_contentView controlCenterWillBeginTransition];
            [_contentView controlCenterDidFinishTransition];
        	for (SBControlCenterSectionViewController *viewController in _contentView._allSections) {
        		[viewController controlCenterDidDismiss];
	            [viewController controlCenterWillBeginTransition];
	            [viewController controlCenterDidFinishTransition];
        	}
        } else {
        	[_contentView controlCenterWillBeginTransition];
            [_contentView controlCenterDidFinishTransition];
            [_contentView controlCenterWillPresent];
        	for (SBControlCenterSectionViewController *viewController in _contentView._allSections) {
        		[viewController controlCenterWillBeginTransition];
	            [viewController controlCenterDidFinishTransition];
	            [viewController controlCenterWillPresent];
			}
        }
    }
}

- (void)gestureRecognized:(UIPanGestureRecognizer *)recognizer
{
	if (_gestureHandler) {
		_gestureHandler(recognizer);
	}
}

- (_MPUSystemMediaControlsView *)mediaControlsView
{
    return _mediaControlsView;
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
    [_contentView.grabberView updateStatusText:text reason:reason];
}

- (void)section:(SBControlCenterSectionViewController *)section publishStatusUpdate:(SBControlCenterStatusUpdate *)update
{
    [_contentView.grabberView presentStatusUpdate:update];
}

@end
