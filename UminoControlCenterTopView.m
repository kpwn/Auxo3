#import "UminoControlCenterTopView.h"
#import "Headers.h"

@interface UminoControlCenterTopView () <SBControlCenterSectionViewControllerDelegate, UIScrollViewDelegate>
@end

@implementation UminoControlCenterTopView {
    UIVisualEffectView *_backgroundView;
	UIVisualEffect *_backgroundEffect;
	UIView *_tintView;
    UIView *_contentView;
    UIScrollView *_scrollView;
    UminoCCAirStuffSectionController *_airStuffController;
    SBCCSettingsSectionController *_settingsController;
    UILabel *_statusLabel;
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
        _contentView.clipsToBounds = NO;
        [self addSubview:_backgroundView];
		[self addSubview:_tintView];
        [self addSubview:_contentView];
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.alwaysBounceHorizontal = NO;
        _scrollView.alwaysBounceVertical = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.clipsToBounds = NO;
        _scrollView.delegate = self;
        _airStuffController = [[NSClassFromString(@"UminoCCAirStuffSectionController") alloc]init];
        _airStuffController.delegate = self;
        ((SBControlCenterSectionView *)_airStuffController.view).edgePadding = 0.0;
        _settingsController = [[NSClassFromString(@"SBCCSettingsSectionController") alloc]init];
        _settingsController.delegate = self;
        ((SBControlCenterSectionView *)_settingsController.view).edgePadding = (iphone6 || iphone6plus) ? 26.0 : 16.0;
        _statusLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _statusLabel.font = [UIFont systemFontOfSize:14.0];
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.textColor = [UIColor whiteColor];
        _statusLabel.alpha = 0;
        [_contentView addSubview:_scrollView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    _backgroundView.frame = bounds;
    _tintView.frame = bounds;
    bounds.origin.y = bounds.size.height / 2.0;
    bounds.size.height /= 2.0;
    _contentView.frame = bounds;
    if (UminoIsPortrait(NO)) {
		if (reachabilityMode) {
			[_scrollView addSubview:_airStuffController.view];
			[_scrollView addSubview:_settingsController.view];
			bounds.size.height = 73.0;
			CGFloat scrollViewHeight = bounds.size.height - 0.0;
			_scrollView.frame = CGRectMake(0.0, 0.0, bounds.size.width, scrollViewHeight);
			_scrollView.contentSize = CGSizeMake(bounds.size.width, scrollViewHeight * 2.0);
			_scrollView.hidden = NO;
			_scrollView.clipsToBounds = YES;
			_airStuffController.view.hidden = NO;
			_settingsController.view.hidden = NO;
			_statusLabel.hidden = YES;
			_airStuffController.view.frame = CGRectMake(0.0, 0.0, bounds.size.width, scrollViewHeight);
			_settingsController.view.frame = CGRectMake(0.0, scrollViewHeight + 10.5, bounds.size.width, 61.0);   
			_scrollView.contentOffset = CGPointMake(0.0, scrollViewHeight);
		} else {
			if (UminoIsMinimalStyle(NO)) {
				[_contentView addSubview:_scrollView];
				[_scrollView addSubview:_airStuffController.view];
				[_scrollView addSubview:_settingsController.view];
				_scrollView.frame = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
				_scrollView.contentSize = CGSizeMake(bounds.size.width, bounds.size.height * 2.0);
				_scrollView.hidden = NO;
				_scrollView.clipsToBounds = NO;
				_airStuffController.view.hidden = NO;
				_settingsController.view.hidden = NO;
				_statusLabel.hidden = YES;
				_airStuffController.view.frame = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
				_settingsController.view.frame = CGRectMake(0.0, bounds.size.height + 10.5, bounds.size.width, 61.0);   
				_scrollView.contentOffset = CGPointMake(0.0, bounds.size.height);
			} else {
				[_contentView addSubview:_airStuffController.view];
				[_contentView addSubview:_settingsController.view];
				[_contentView addSubview:_statusLabel];
				_scrollView.hidden = YES;
				_airStuffController.view.hidden = NO;
				_settingsController.view.hidden = NO;
				_statusLabel.hidden = NO;
				_airStuffController.view.frame = CGRectMake(0.0, 0.0, bounds.size.width, 36.0);
				_settingsController.view.frame = CGRectMake(0.0, 36.0 + 10.5, bounds.size.width, 61.0);   
				_statusLabel.frame = CGRectMake(0.0, 0.0, bounds.size.width, 36.0);
			}
		}
    } else {
    	[_contentView addSubview:_airStuffController.view];
        [_contentView addSubview:_settingsController.view];
        _scrollView.hidden = YES;
    	_airStuffController.view.hidden = NO;
		_settingsController.view.hidden = NO;
        _statusLabel.hidden = YES;
        _airStuffController.view.frame = CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height);
        _settingsController.view.frame = CGRectMake(88.0, 9.0, bounds.size.width - 88.0 * 2.0, 61.0);
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
            [_airStuffController controlCenterDidDismiss];
            [_airStuffController controlCenterWillBeginTransition];
            [_airStuffController controlCenterDidFinishTransition];
            [_settingsController controlCenterDidDismiss];
            [_settingsController controlCenterWillBeginTransition];
            [_settingsController controlCenterDidFinishTransition];
            _scrollView.contentOffset = CGPointMake(0.0, _scrollView.bounds.size.height);
        } else {
            [_airStuffController controlCenterWillBeginTransition];
            [_airStuffController controlCenterDidFinishTransition];
            [_airStuffController controlCenterWillPresent];
            [_settingsController controlCenterWillBeginTransition];
            [_settingsController controlCenterDidFinishTransition];
            [_settingsController controlCenterWillPresent];
        }
    }
}

- (void)showStatusText:(NSString *)text duration:(NSTimeInterval)duration
{
    _statusLabel.text = text;
    if (UminoIsPortrait(NO) && !UminoIsMinimalStyle(NO)) {
        SBCCButtonLikeSectionSplitView *view = (SBCCButtonLikeSectionSplitView *)_airStuffController.view;
        view.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            for (SBCCButtonLikeSectionView *section in @[view.leftSection, view.rightSection]) {
                CHIvar(section, _button, UIButton * const).alpha = 0;
                CHIvar(section, _label, UILabel * const).alpha = 0;
            }
            _statusLabel.alpha = 1;
        } completion:NULL];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideStatusText) object:nil];
        [self performSelector:@selector(hideStatusText) withObject:nil afterDelay:duration];   
    } else {

    }
}

- (void)hideStatusText
{
    if (UminoIsPortrait(NO)) {
        SBCCButtonLikeSectionSplitView *view = (SBCCButtonLikeSectionSplitView *)_airStuffController.view;
        view.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            for (SBCCButtonLikeSectionView *section in @[view.leftSection, view.rightSection]) {
                CHIvar(section, _button, UIButton * const).alpha = 1;
                CHIvar(section, _label, UILabel * const).alpha = section.hidden ? 0.2 : 0.65;
            }
            _statusLabel.alpha = 0;
        } completion:NULL];
    } else {

    }
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
    [self showStatusText:text duration:1.5];
}

- (void)section:(SBControlCenterSectionViewController *)section publishStatusUpdate:(SBControlCenterStatusUpdate *)update
{
    [self showStatusText:update.statusStrings.firstObject duration:1.5];
}

@end
