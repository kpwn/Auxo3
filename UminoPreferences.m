#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <MessageUI/MessageUI.h>
#import <AppList/AppList.h>
#import "Headers.h"

__attribute__((visibility("hidden")))
@interface UminoPreferencesController : PSListController <MFMailComposeViewControllerDelegate>
@end

__attribute__((visibility("hidden")))
@interface UminoPreferencesOptionsController : PSListController
@end

__attribute__((visibility("hidden")))
@interface UminoPreferencesQuickLauncherController : PSListController
@end

__attribute__((visibility("hidden")))
@interface UminoPreferencesSliderActionsController : PSListController
@end

__attribute__((visibility("hidden")))
@interface UminoPreferencesAlbumArtworkController : PSListController
@end

__attribute__((visibility("hidden")))
@interface UminoPreferencesCloseAllAppsController : PSListController
@end

__attribute__((visibility("hidden")))
@interface UminoPreferencesExceptionsController : PSListController
@end

__attribute__((visibility("hidden")))
@interface UminoPreferencesProfileController : PSViewController <UITableViewDataSource, UITableViewDelegate>
@end

__attribute__((visibility("hidden")))
@interface UminoPreferencesProfileCell : UITableViewCell
- (void)loadImage:(NSString *)imageName nameText:(NSString *)nameText handleText:(NSString *)handleText infoText:(NSString *)infoText;
@end

CHInline static NSArray *applistSpecifiers(id target, NSString *systemAppsGroupName, NSString *userAppsGroupName) {
    NSMutableArray *specifiers = [NSMutableArray array];
    ALApplicationList *applicationList = [NSClassFromString(@"ALApplicationList") sharedApplicationList];
    NSDictionary *applications = applicationList.applications;
    NSArray *hiddenApplications = @[@"com.apple.AdSheet", @"com.apple.AdSheetPhone", @"com.apple.AdSheetPad", @"com.apple.DataActivation", @"com.apple.DemoApp", @"com.apple.fieldtest", @"com.apple.iosdiagnostics", @"com.apple.iphoneos.iPodOut", @"com.apple.TrustMe", @"com.apple.WebSheet", @"com.apple.springboard", @"com.apple.purplebuddy", @"com.apple.datadetectors.DDActionsService", @"com.apple.FacebookAccountMigrationDialog", @"com.apple.iad.iAdOptOut", @"com.apple.ios.StoreKitUIService", @"com.apple.TextInput.kbd", @"com.apple.MailCompositionService", @"com.apple.mobilesms.compose", @"com.apple.quicklook.quicklookd", @"com.apple.ShoeboxUIService", @"com.apple.social.remoteui.SocialUIService", @"com.apple.WebViewService", @"com.apple.gamecenter.GameCenterUIService", @"com.apple.appleaccount.AACredentialRecoveryDialog", @"com.apple.CompassCalibrationViewService", @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI", @"com.apple.PassbookUIService", @"com.apple.uikit.PrintStatus", @"com.apple.Copilot", @"com.apple.MusicUIService", @"com.apple.AccountAuthenticationDialog", @"com.apple.MobileReplayer", @"com.apple.SiriViewService"];
    void (^addSpecifier)(NSString *, NSUInteger, BOOL *) = ^(NSString *identifier, NSUInteger index, BOOL *stop) {
        if ([hiddenApplications containsObject:identifier]) {
            return;
        }
        PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:applications[identifier]
                                                                target:target
                                                                   set:NULL
                                                                   get:NULL
                                                                detail:Nil
                                                                  cell:PSListItemCell
                                                                  edit:Nil];
        [specifier setIdentifier:identifier];
        [specifiers addObject:specifier];
    };
    [specifiers addObject:[PSSpecifier groupSpecifierWithName:systemAppsGroupName]];
    [[[applicationList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = TRUE"]].allKeys sortedArrayUsingSelector:@selector(compare:)] enumerateObjectsUsingBlock:addSpecifier];
    [specifiers addObject:[PSSpecifier groupSpecifierWithName:userAppsGroupName]];
    [[[applicationList applicationsFilteredUsingPredicate:[NSPredicate predicateWithFormat:@"isSystemApplication = FALSE"]].allKeys sortedArrayUsingSelector:@selector(compare:)] enumerateObjectsUsingBlock:addSpecifier];
    return specifiers;
}

@implementation UminoPreferencesController {
	NSArray *_uminoSpecifiers;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.navigationItem.titleView = [[UIImageView alloc]initWithImage:imageResource(@"Logo")];
	UIButton *heartButton = [[UIButton alloc]initWithFrame:CGRectZero];
	[heartButton setImage:imageResource(@"Heart") forState:UIControlStateNormal];
	[heartButton sizeToFit];
	[heartButton addTarget:self action:@selector(heartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:heartButton];
	CGFloat width = self.view.bounds.size.width;
	UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 114)];
	headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, width, 53)];
	titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	titleLabel.text = @"Auxo 3";
	titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:45];
	titleLabel.textColor = [UIColor blackColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.shadowColor = [UIColor whiteColor];
	titleLabel.shadowOffset = CGSizeMake(0, 1);
	titleLabel.numberOfLines = 1;
	UILabel *creditLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10 + 53, width, 34)];
	creditLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	creditLabel.text = localizedString(@"CREDIT");
	creditLabel.font = [UIFont systemFontOfSize:14];
	creditLabel.textColor = [UIColor grayColor];
	creditLabel.textAlignment = NSTextAlignmentCenter;
	creditLabel.numberOfLines = 2;
	[headerView addSubview:titleLabel];
	[headerView addSubview:creditLabel];
	self.table.tableHeaderView = headerView;
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		if (_uminoSpecifiers == nil) {
			PSSpecifier *specifier1_0 = [PSSpecifier emptyGroupSpecifier];
			[specifier1_0 setProperty:localizedString(@"MULTICENTER_FOOTER") forKey:@"footerText"];
			PSSpecifier *specifier1_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"MULTICENTER")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier1_1 setIdentifier:kMultiCenterKey];
	    	[specifier1_1 setProperty:imageResource(@"Multi-Center") forKey:@"iconImage"];

			PSSpecifier *specifier2_0 = [PSSpecifier emptyGroupSpecifier];
			PSSpecifier *specifier2_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"QUICKSWITCHER")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier2_1 setIdentifier:kQuickSwitcherKey];
	    	[specifier2_1 setProperty:imageResource(@"QuickSwitcher") forKey:@"iconImage"];

	    	PSSpecifier *specifier3_0 = [PSSpecifier emptyGroupSpecifier];
			PSSpecifier *specifier3_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"HOTCORNERS")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier3_1 setIdentifier:kHotCornersKey];
	    	[specifier3_1 setProperty:imageResource(@"HotCorners") forKey:@"iconImage"];
	    	
			PSSpecifier *specifier4_0 = [PSSpecifier emptyGroupSpecifier];
			PSSpecifier *specifier4_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"ADVANCED_OPTIONS")
																	   target:self
				                                                          set:NULL
				                                                          get:NULL
				                                                       detail:UminoPreferencesOptionsController.class
				                                                         cell:PSLinkCell
				                                                         edit:Nil];
	        [specifier4_1 setProperty:imageResource(@"Configuration") forKey:@"iconImage"];

			PSSpecifier *specifier5_0 = [PSSpecifier emptyGroupSpecifier];
			PSSpecifier *specifier5_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"THE_CREATORS")
																	   target:self
				                                                          set:NULL
				                                                          get:NULL
				                                                       detail:UminoPreferencesProfileController.class
				                                                         cell:PSLinkCell
				                                                         edit:Nil];
			[specifier5_1 setProperty:imageResource(@"Creators") forKey:@"iconImage"];

			PSSpecifier *specifier6_0 = [PSSpecifier emptyGroupSpecifier];
			PSSpecifier *specifier6_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"A3TWEAKS_SUPPORT")
																	   target:self
				                                                          set:NULL
				                                                          get:NULL
				                                                       detail:Nil
				                                                         cell:PSLinkCell
				                                                         edit:Nil];
			[specifier6_1 setProperty:imageResource(@"Support") forKey:@"iconImage"];
			specifier6_1->action = @selector(supportSpecifierAction:);

			_uminoSpecifiers = @[specifier1_0, specifier1_1,
							 	 specifier2_0, specifier2_1,
							   	 specifier3_0, specifier3_1,
								 specifier4_0, specifier4_1,
								 specifier5_0, specifier5_1,
								 specifier6_0, specifier6_1];	
		}
		_specifiers = _uminoSpecifiers.copy;
	}
	return _specifiers;
}

- (id)getPreferences:(PSSpecifier *)specifier
{
	NSString *key = specifier.identifier;
	return getPreferences(key);
}

- (void)setPreferences:(id)value specifier:(PSSpecifier *)specifier
{
	setPreferences(specifier.identifier, value);
	[self updateSpecifiers:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateSpecifiers:NO];
}

- (void)reloadSpecifiers
{
	[super reloadSpecifiers];
	[self updateSpecifiers:NO];	
}

- (void)updateSpecifiers:(BOOL)animated
{
	PSSpecifier *specifier2_0 = _uminoSpecifiers[2];
	PSSpecifier *specifier3_0 = _uminoSpecifiers[4];

	BOOL multiCenter = [getPreferences(kMultiCenterKey) boolValue];

	NSString *footerText2_0 = multiCenter
							  ? localizedString(@"QUICKSWITCHER_FOOTER_1")
							  : localizedString(@"QUICKSWITCHER_FOOTER_2");
	if (![[specifier2_0 propertyForKey:@"footerText"]isEqualToString:footerText2_0]) {
		[specifier2_0 setProperty:footerText2_0 forKey:@"footerText"];
		[self reloadSpecifier:specifier2_0 animated:animated];
	}
	NSString *footerText3_0 = multiCenter
							  ? localizedString(@"HOTCORNERS_FOOTER_1")
							  : localizedString(@"HOTCORNERS_FOOTER_2");
	if (![[specifier3_0 propertyForKey:@"footerText"]isEqualToString:footerText3_0]) {
		[specifier3_0 setProperty:footerText3_0 forKey:@"footerText"];
		[self reloadSpecifier:specifier3_0 animated:animated];
	}
}

- (void)heartButtonAction:(UIButton *)sender
{
    SLComposeViewController *composeSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [composeSheet setInitialText:localizedString(@"SHARE_TEXT")];
    [(UIViewController *)self presentViewController:composeSheet animated:YES completion:nil];
}

- (void)supportSpecifierAction:(PSSpecifier *)specifier
{
	/*MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc]init];
	mailComposeViewController.mailComposeDelegate = self;
	[mailComposeViewController setSubject:@"Auxo Support"];
	[mailComposeViewController setToRecipients:@[@"auxo3@a3tweaks.com"]];
	//NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	//for (NSString *key in @[@"UniqueDeviceID", @"ProductVersion", @"ProductType", @"DiskUsage", @"DeviceColor", @"CPUArchitecture"]) {
		//dictionary[key] = CFBridgingRelease(MGCopyAnswer((__bridge CFStringRef)key)) ? : [NSNull null];
	//}
	dictionary[@"Packages"] = [NSString stringWithContentsOfFile:@"/var/lib/dpkg/status" encoding:NSUTF8StringEncoding error:nil] ? : [NSNull null];
	dictionary[@"Preferences"] = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPlist] ? : [NSNull null];
	NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
	[mailComposeViewController addAttachmentData:data mimeType:@"application/x-plist" fileName:@"Auxo.plist"];
	[self presentViewController:mailComposeViewController animated:YES completion:NULL]; */
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{              
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end

@implementation UminoPreferencesOptionsController {
	NSArray *_uminoSpecifiers;
}

+ (void)initialize
{
	[[NSBundle bundleWithPath:@"/System/Library/PreferenceBundles/AppList.bundle"]load];
    [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/PolusSettings.bundle"]load];
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		if (_uminoSpecifiers == nil) {
	    	PSSpecifier *specifier1_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier1_0 setProperty:localizedString(@"REACHABLE_DISPLAY_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier1_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"REACHABLE_DISPLAY")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier1_1 setIdentifier:kReachabilityModeKey];

			PSSpecifier *specifier2_0 = [PSSpecifier emptyGroupSpecifier];
			PSSpecifier *specifier2_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"MINIMAL_DISPLAY")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier2_1 setIdentifier:kMinimalControlCenterEnabledKey];
	    	PSSpecifier *specifier2_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"ALWAYS")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier2_2 setUserInfo:@{@"identifier": kMinimalControlCenterConditionKey, @"value": @(0)}];
	    	PSSpecifier *specifier2_3 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"NO_MEDIA")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier2_3 setUserInfo:@{@"identifier": kMinimalControlCenterConditionKey, @"value": @(1 << 0)}];
	    	PSSpecifier *specifier2_4 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"NO_AIRPLAY")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier2_4 setUserInfo:@{@"identifier": kMinimalControlCenterConditionKey, @"value": @(1 << 1)}];
	    	PSSpecifier *specifier2_5 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"NO_AIRDROP")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier2_5 setUserInfo:@{@"identifier": kMinimalControlCenterConditionKey, @"value": @(1 << 2)}];

	    	PSSpecifier *specifier3_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier3_0 setProperty:localizedString(@"OPEN_TO_LAST_APP_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier3_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"OPEN_TO_LAST_APP")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier3_1 setIdentifier:kOpenToLastAppKey];
	    	PSSpecifier *specifier3_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"OPEN_TO_LAST_APP_QUICK_SWITCHER")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier3_2 setIdentifier:kOpenToLastAppWithQSKey];

	    	PSSpecifier *specifier4_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier4_0 setProperty:localizedString(@"QUICK_LAUNCHER_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier4_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"QUICK_LAUNCHER")
																	   target:self
				                                                          set:NULL
				                                                          get:NULL
				                                                       detail:UminoPreferencesQuickLauncherController.class
				                                                         cell:PSLinkCell
				                                                         edit:Nil];

            PSSpecifier *specifier5_0 = [PSSpecifier emptyGroupSpecifier];
            [specifier5_0 setProperty:localizedString(@"SLIDER_ACTIONS_FOOTER") forKey:@"footerText"];
            PSSpecifier *specifier5_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"SLIDER_ACTIONS")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:UminoPreferencesSliderActionsController.class
                                                                         cell:PSLinkCell
                                                                         edit:Nil];

            PSSpecifier *specifier6_0 = [PSSpecifier emptyGroupSpecifier];
            [specifier6_0 setProperty:localizedString(@"ALBUM_ARTWORK_FOOTER") forKey:@"footerText"];
            PSSpecifier *specifier6_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"ALBUM_ARTWORK")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:UminoPreferencesAlbumArtworkController.class
                                                                         cell:PSLinkCell
                                                                         edit:Nil];

            PSSpecifier *specifier7_0 = [PSSpecifier emptyGroupSpecifier];
            [specifier7_0 setProperty:localizedString(@"CLOSE_ALL_APPS_FOOTER") forKey:@"footerText"];
            PSSpecifier *specifier7_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"CLOSE_ALL_APPS")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:UminoPreferencesCloseAllAppsController.class
                                                                         cell:PSLinkCell
                                                                         edit:Nil];

			PSSpecifier *specifier8_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier8_0 setProperty:localizedString(@"UNLIMITED_QUICK_SWITCHER_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier8_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"UNLIMITED_QUICK_SWITCHER")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier8_1 setIdentifier:kUnlimitedQuickSwitcherKey];

			PSSpecifier *specifier9_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier9_0 setProperty:localizedString(@"ACCESS_HOME_SCREEN_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier9_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"ACCESS_HOME_SCREEN")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier9_1 setIdentifier:kAccessHomeScreenKey];

			PSSpecifier *specifier10_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier10_0 setProperty:localizedString(@"ACCESS_APP_SWITCHER_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier10_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"ACCESS_APP_SWITCHER")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier10_1 setIdentifier:kAccessAppSwitcherKey];

	    	PSSpecifier *specifier11_0 = [PSSpecifier emptyGroupSpecifier];
	    	PSSpecifier *specifier11_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"INVERT_HOT_CORNERS")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier11_1 setIdentifier:kInvertHotCornersKey];

	    	PSSpecifier *specifier12_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier12_0 setProperty:localizedString(@"EXCEPTIONS_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier12_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"EXCEPTIONS")
																	   target:self
				                                                          set:NULL
				                                                          get:NULL
				                                                       detail:UminoPreferencesExceptionsController.class
				                                                         cell:PSLinkCell
				                                                         edit:Nil];

	    	PSSpecifier *specifier13_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier13_0 setProperty:localizedString(@"MOVE_CONTACTS_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier13_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"MOVE_CONTACTS")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier13_1 setIdentifier:kPeopleInTodayKey];

	    	PSSpecifier *specifier14_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier14_0 setProperty:localizedString(@"DISABLE_DOUBLE_CLICK_HOME_FOOTER") forKey:@"footerText"];
	    	PSSpecifier *specifier14_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"DISABLE_DOUBLE_CLICK_HOME")
				                                                       target:self
				                                                          set:@selector(setPreferences:specifier:)
				                                                          get:@selector(getPreferences:)
				                                                       detail:Nil
				                                                         cell:PSSwitchCell
				                                                         edit:Nil];
			[specifier14_1 setIdentifier:kDisableHomeDoubleClickKey];

	    	PSSpecifier *specifier15_0 = [PSSpecifier emptyGroupSpecifier];
	    	[specifier15_0 setProperty:localizedString(@"POLUS_FOOTER") forKey:@"footerText"];
            Class detailClass15_1 = NSClassFromString(@"PolusPrefsController");
            PSSpecifier *specifier15_1 = [PSSpecifier preferenceSpecifierNamed:@"Polus"
										    			                target:self
				                                                           set:NULL
				                                                           get:NULL
                                                                        detail:detailClass15_1
				                                                          cell:PSLinkCell
				                                                          edit:Nil];
            [specifier15_1 setProperty:@"Polus" forKey:@"label"];
	    	[specifier15_1 setProperty:imageResource(@"Polus") forKey:@"iconImage"];
            if (detailClass15_1 == NULL) {
                [specifier15_1 setProperty:@(YES) forKey:@"enabled"];
                specifier15_1->action = @selector(polusAction:);
            }

			_uminoSpecifiers = @[specifier1_0, specifier1_1,
							 	 specifier2_0, specifier2_1, specifier2_2, specifier2_3, specifier2_4, specifier2_5,
								 specifier3_0, specifier3_1, specifier3_2,
								 specifier4_0, specifier4_1,
                                 specifier5_0, specifier5_1,
                                 specifier6_0, specifier6_1,
								 specifier7_0, specifier7_1,
								 specifier8_0, specifier8_1,
								 specifier9_0, specifier9_1,
								 specifier10_0, specifier10_1,
                                 specifier11_0, specifier11_1,
                                 specifier12_0, specifier12_1,
                                 specifier13_0, specifier13_1,
                                 specifier14_0, specifier14_1,
								 specifier15_0, specifier15_1];
		}
		_specifiers = _uminoSpecifiers.copy;
	}
	return _specifiers;
}

- (id)getPreferences:(PSSpecifier *)specifier
{
	NSString *key = (NSString *)specifier;
	if ([specifier isKindOfClass:PSSpecifier.class]) {
		key = specifier.identifier;
	}
	return getPreferences(key);
}

- (void)setPreferences:(id)value specifier:(PSSpecifier *)specifier
{
	NSString *key = (NSString *)specifier;
	if ([specifier isKindOfClass:PSSpecifier.class]) {
		key = specifier.identifier;
	}
	setPreferences(key, value);
	[self updateSpecifiers:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateSpecifiers:NO];
}

- (void)reloadSpecifiers
{
	[super reloadSpecifiers];
	[self updateSpecifiers:NO];	
}

- (void)updateSpecifiers:(BOOL)animated
{
	PSSpecifier *specifier1_1 = _uminoSpecifiers[1];
	PSSpecifier *specifier2_0 = _uminoSpecifiers[2];
	PSSpecifier *specifier2_1 = _uminoSpecifiers[3];
	PSSpecifier *specifier2_2 = _uminoSpecifiers[4];
	PSSpecifier *specifier2_3 = _uminoSpecifiers[5];
	PSSpecifier *specifier2_4 = _uminoSpecifiers[6];
	PSSpecifier *specifier2_5 = _uminoSpecifiers[7];
	PSSpecifier *specifier3_1 = _uminoSpecifiers[9];
	PSSpecifier *specifier3_2 = _uminoSpecifiers[10];
	PSSpecifier *specifier4_1 = _uminoSpecifiers[12];
	PSSpecifier *specifier5_1 = _uminoSpecifiers[14];
	PSSpecifier *specifier6_1 = _uminoSpecifiers[16];
	PSSpecifier *specifier7_1 = _uminoSpecifiers[18];
	PSSpecifier *specifier8_1 = _uminoSpecifiers[20];
	PSSpecifier *specifier9_1 = _uminoSpecifiers[22];
	PSSpecifier *specifier10_1 = _uminoSpecifiers[24];
	PSSpecifier *specifier11_0 = _uminoSpecifiers[25];
	PSSpecifier *specifier11_1 = _uminoSpecifiers[26];
	PSSpecifier *specifier12_1 = _uminoSpecifiers[28];
	PSSpecifier *specifier13_1 = _uminoSpecifiers[30];
    NSArray *specifier1_0_1 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(0, 2)];
	NSArray *specifier2_0_5 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(2, 6)];
	NSArray *specifier2_2_5 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(4, 4)];
    NSArray *specifier4_0_1 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(11, 2)];
    NSArray *specifier5_0_1 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(13, 2)];
    NSArray *specifier8_0_1 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(19, 2)];
	NSArray *specifier13_0_1 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(29, 2)];

	BOOL phone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
	BOOL widescreen = phone ? [UIScreen mainScreen].bounds.size.height >= 568.0 : NO;
	//BOOL iphone6 = phone ? [UIScreen mainScreen].bounds.size.height == 667.0 : NO;
	//BOOL iphone6plus = phone ? [UIScreen mainScreen].bounds.size.height == 736.0 : NO;
	BOOL multiCenter = [getPreferences(kMultiCenterKey) boolValue];
	BOOL quickSwitcher = [getPreferences(kQuickSwitcherKey) boolValue];
	BOOL hotCorners = [getPreferences(kHotCornersKey) boolValue];
	BOOL minimalControlCenter = widescreen ? [getPreferences(kMinimalControlCenterEnabledKey) boolValue] : YES;
	BOOL reachableControlCenter = widescreen ? [getPreferences(kReachabilityModeKey) boolValue] : NO;
	BOOL openToLast = [getPreferences(kOpenToLastAppKey) boolValue];

	if (quickSwitcher && multiCenter) {
		setPreferences(kAccessAppSwitcherKey, @NO);
	}
	if (minimalControlCenter && reachableControlCenter) {
		setPreferences(kMinimalControlCenterConditionKey, @([getPreferences(kMinimalControlCenterConditionKey) integerValue] & ~((1 << 1) | (1 << 2))));
	}
	if (!multiCenter) {
		setPreferences(kPeopleInTodayKey, @NO);
	}

	if (![[specifier1_1 propertyForKey:@"enabled"] isEqual:@(multiCenter)]) {
		[specifier1_1 setProperty:@(multiCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier1_1 animated:animated];
	}
	if (![[specifier2_1 propertyForKey:@"enabled"] isEqual:@(multiCenter)]) {
		[specifier2_1 setProperty:@(multiCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier2_1 animated:animated];
	}
	if (![[specifier2_2 propertyForKey:@"enabled"] isEqual:@(multiCenter && minimalControlCenter)]) {
		[specifier2_2 setProperty:@(multiCenter && minimalControlCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier2_2 animated:animated];
	}
	if (![[specifier2_3 propertyForKey:@"enabled"] isEqual:@(multiCenter && minimalControlCenter)]) {
		[specifier2_3 setProperty:@(multiCenter && minimalControlCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier2_3 animated:animated];
	}
	if (![[specifier2_4 propertyForKey:@"enabled"] isEqual:@(multiCenter && minimalControlCenter && !reachableControlCenter)]) {
		[specifier2_4 setProperty:@(multiCenter && minimalControlCenter && !reachableControlCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier2_4 animated:animated];
	}
	if (![[specifier2_5 propertyForKey:@"enabled"] isEqual:@(multiCenter && minimalControlCenter && !reachableControlCenter)]) {
		[specifier2_5 setProperty:@(multiCenter && minimalControlCenter && !reachableControlCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier2_5 animated:animated];
	}
	if (![[specifier3_1 propertyForKey:@"enabled"] isEqual:@(multiCenter || quickSwitcher || hotCorners)]) {
		[specifier3_1 setProperty:@(multiCenter || quickSwitcher || hotCorners) forKey:@"enabled"];
		[self reloadSpecifier:specifier3_1 animated:animated];
	}
	if (![[specifier3_2 propertyForKey:@"enabled"] isEqual:@(multiCenter || quickSwitcher || hotCorners)]) {
		[specifier3_2 setProperty:@(multiCenter || quickSwitcher || hotCorners) forKey:@"enabled"];
		[self reloadSpecifier:specifier3_2 animated:animated];
	}
	if (![[specifier4_1 propertyForKey:@"enabled"] isEqual:@(multiCenter && !(minimalControlCenter && reachableControlCenter))]) {
		[specifier4_1 setProperty:@(multiCenter && !(minimalControlCenter && reachableControlCenter)) forKey:@"enabled"];
		[self reloadSpecifier:specifier4_1 animated:animated];
	}
	if (![[specifier5_1 propertyForKey:@"enabled"] isEqual:@(multiCenter)]) {
		[specifier5_1 setProperty:@(multiCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier5_1 animated:animated];
	}
	if (![[specifier6_1 propertyForKey:@"enabled"] isEqual:@(multiCenter)]) {
		[specifier6_1 setProperty:@(multiCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier6_1 animated:animated];
	}
	if (![[specifier7_1 propertyForKey:@"enabled"] isEqual:@(multiCenter)]) {
		[specifier7_1 setProperty:@(multiCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier7_1 animated:animated];
	}
	if (![[specifier8_1 propertyForKey:@"enabled"] isEqual:@(quickSwitcher)]) {
		[specifier8_1 setProperty:@(quickSwitcher) forKey:@"enabled"];
		[self reloadSpecifier:specifier8_1 animated:animated];
	}
	if (![[specifier9_1 propertyForKey:@"enabled"] isEqual:@(quickSwitcher)]) {
		[specifier9_1 setProperty:@(quickSwitcher) forKey:@"enabled"];
		[self reloadSpecifier:specifier9_1 animated:animated];
	}
	if (![[specifier10_1 propertyForKey:@"enabled"] isEqual:@(quickSwitcher && !multiCenter)]) {
		[specifier10_1 setProperty:@(quickSwitcher && !multiCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier10_1 animated:animated];
	}
	if (![[specifier11_1 propertyForKey:@"enabled"] isEqual:@(hotCorners)]) {
		[specifier11_1 setProperty:@(hotCorners) forKey:@"enabled"];
		[self reloadSpecifier:specifier11_1 animated:animated];
	}
	if (![[specifier12_1 propertyForKey:@"enabled"] isEqual:@(multiCenter || quickSwitcher || hotCorners)]) {
		[specifier12_1 setProperty:@(multiCenter || quickSwitcher || hotCorners) forKey:@"enabled"];
		[self reloadSpecifier:specifier12_1 animated:animated];
	}
	if (![[specifier13_1 propertyForKey:@"enabled"] isEqual:@(multiCenter)]) {
		[specifier13_1 setProperty:@(multiCenter) forKey:@"enabled"];
		[self reloadSpecifier:specifier13_1 animated:animated];
	}
	if (widescreen) {
		if (minimalControlCenter) {
			if (![_specifiers containsObject:specifier2_2_5.firstObject]) {
				[self insertContiguousSpecifiers:specifier2_2_5 afterSpecifier:specifier2_1 animated:animated];
			}
		} else {
			if ([_specifiers containsObject:specifier2_2_5.firstObject]) {
				[self removeContiguousSpecifiers:specifier2_2_5 animated:animated];
			}
		}
	} else {
		if ([_specifiers containsObject:specifier1_0_1.firstObject]) {
			[self removeContiguousSpecifiers:specifier1_0_1 animated:animated];
		}
		if ([_specifiers containsObject:specifier2_0_5.firstObject]) {
			[self removeContiguousSpecifiers:specifier2_0_5 animated:animated];
		}
	}
	if (!phone) {
		if ([_specifiers containsObject:specifier4_0_1.firstObject]) {
			[self removeContiguousSpecifiers:specifier4_0_1 animated:animated];
		}
		if ([_specifiers containsObject:specifier5_0_1.firstObject]) {
			[self removeContiguousSpecifiers:specifier5_0_1 animated:animated];
		}
        if ([_specifiers containsObject:specifier8_0_1.firstObject]) {
            [self removeContiguousSpecifiers:specifier8_0_1 animated:animated];
        }
        if ([_specifiers containsObject:specifier13_0_1.firstObject]) {
            [self removeContiguousSpecifiers:specifier13_0_1 animated:animated];
        }
	}
	if (openToLast) {
		if (![_specifiers containsObject:specifier3_2]) {
			[self insertSpecifier:specifier3_2 afterSpecifier:specifier3_1 animated:animated];
		}
	} else {
        if ([_specifiers containsObject:specifier3_2]) {
            [self removeSpecifier:specifier3_2 animated:animated];
        }
	}

	NSString *footerText2_0 = (minimalControlCenter && reachableControlCenter)
							  ? localizedString(@"MINIMAL_DISPLAY_FOOTER_1")
							  : localizedString(@"MINIMAL_DISPLAY_FOOTER_2");
	if (![[specifier2_0 propertyForKey:@"footerText"]isEqualToString:footerText2_0]) {
		[specifier2_0 setProperty:footerText2_0 forKey:@"footerText"];
		[self reloadSpecifier:specifier2_0 animated:animated];
	}
	NSString *footerText11_0 = quickSwitcher
							   ? localizedString(@"INVERT_HOT_CORNERS_FOOTER_1")
							   : localizedString(@"INVERT_HOT_CORNERS_FOOTER_2");
	if (![[specifier11_0 propertyForKey:@"footerText"]isEqualToString:footerText11_0]) {
		[specifier11_0 setProperty:footerText11_0 forKey:@"footerText"];
		[self reloadSpecifier:specifier11_0 animated:animated];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	NSDictionary *userInfo = specifier.userInfo;
	NSString *identifier = [userInfo isKindOfClass:NSDictionary.class] ? userInfo[@"identifier"] : nil;
	if ([identifier isEqualToString:kMinimalControlCenterConditionKey]) {
		NSInteger preferenceValue = [getPreferences(identifier) integerValue];
		NSInteger itemValue = [userInfo[@"value"] integerValue];
		BOOL checked = NO;
		if (itemValue == 0) {
			checked = (preferenceValue == itemValue);
		} else {
			checked = (preferenceValue & itemValue);
		}
		cell.checked = checked;
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
	PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	NSDictionary *userInfo = specifier.userInfo;
	NSString *identifier = [userInfo isKindOfClass:NSDictionary.class] ? userInfo[@"identifier"] : nil;
	if ([identifier isEqualToString:kMinimalControlCenterConditionKey]) {
		NSInteger preferenceValue = [getPreferences(identifier) integerValue];
		NSInteger itemValue = [userInfo[@"value"] integerValue];
		NSInteger updatedValue = preferenceValue;
		if (itemValue == 0) {
			updatedValue = itemValue;
		} else {
			updatedValue = (preferenceValue & itemValue) ? (preferenceValue & ~itemValue) : (preferenceValue | itemValue);
		}
		if (preferenceValue != updatedValue) {
			setPreferences(identifier, @(updatedValue));
			for (PSSpecifier *specifier in [self specifiersInGroup:indexPath.section]) {
				[self reloadSpecifier:specifier animated:YES];
			}
		}
    }
}

- (void)polusAction:(PSSpecifier *)specifier
{
  [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"cydia://package/com.a3tweaks.polus"]];
}

@end

@implementation UminoPreferencesQuickLauncherController {
	NSArray *_uminoSpecifiers;
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		if (_uminoSpecifiers == nil) {
			PSSpecifier *specifier1_0 = [PSSpecifier groupSpecifierWithName:localizedString(@"WHEN_NO_MEDIA")];
			PSSpecifier *specifier1_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"DISPLAY")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier1_1 setUserInfo:@{@"identifier": kQuickLauncherNotPlayingKey, @"value": @(1)}];
	    	PSSpecifier *specifier1_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"NO_DISPLAY")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier1_2 setUserInfo:@{@"identifier": kQuickLauncherNotPlayingKey, @"value": @(0)}];
	    	PSSpecifier *specifier1_3 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AUTO_DISMISS")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier1_3 setUserInfo:@{@"identifier": kQuickLauncherNotPlayingKey, @"value": @(2)}];

	    	PSSpecifier *specifier2_0 = [PSSpecifier groupSpecifierWithName:localizedString(@"WHEN_MEDIA")];
			PSSpecifier *specifier2_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AUTO_DISMISS")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier2_1 setUserInfo:@{@"identifier": kQuickLauncherIsPlayingKey, @"value": @(2)}];
	    	PSSpecifier *specifier2_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"NO_DISPLAY")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier2_2 setUserInfo:@{@"identifier": kQuickLauncherIsPlayingKey, @"value": @(0)}];
	    	PSSpecifier *specifier2_3 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"DISPLAY")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier2_3 setUserInfo:@{@"identifier": kQuickLauncherIsPlayingKey, @"value": @(1)}];

	    	PSSpecifier *specifier3_0 = [PSSpecifier groupSpecifierWithName:localizedString(@"AUTO_DISMISS")];
	    	PSSpecifier *specifier3_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AFTER_1_SECOND")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier3_1 setUserInfo:@{@"identifier": kQuickLauncherAutoDismissDelayKey, @"value": @(1)}];
			PSSpecifier *specifier3_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AFTER_3_SECONDS")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier3_2 setUserInfo:@{@"identifier": kQuickLauncherAutoDismissDelayKey, @"value": @(3)}];
	    	PSSpecifier *specifier3_3 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AFTER_5_SECONDS")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
            [specifier3_3 setUserInfo:@{@"identifier": kQuickLauncherAutoDismissDelayKey, @"value": @(5)}];
	    	PSSpecifier *specifier3_4 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AFTER_8_SECONDS")
					                                                        target:self
					                                                           set:NULL
				                                                          	   get:NULL
					                                                        detail:Nil
					                                                          cell:PSListItemCell
					                                                          edit:Nil];
	    	[specifier3_4 setUserInfo:@{@"identifier": kQuickLauncherAutoDismissDelayKey, @"value": @(8)}];

			_uminoSpecifiers = @[specifier1_0, specifier1_1, specifier1_2, specifier1_3,
							 	 specifier2_0, specifier2_1, specifier2_2, specifier2_3,
								 specifier3_0, specifier3_1, specifier3_2, specifier3_3, specifier3_4];
		}
		_specifiers = _uminoSpecifiers.copy;
	}
	return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateSpecifiers:NO];
}

- (void)reloadSpecifiers
{
	[super reloadSpecifiers];
	[self updateSpecifiers:NO];	
}

- (void)updateSpecifiers:(BOOL)animated
{
	PSSpecifier *specifier2_3 = _uminoSpecifiers[7];
	NSArray *specifier3_0_4 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(8, 5)];

	NSInteger quickLauncherNotPlaying = [getPreferences(kQuickLauncherNotPlayingKey) integerValue];
	NSInteger quickLauncherIsPlaying = [getPreferences(kQuickLauncherIsPlayingKey) integerValue];

	if (quickLauncherNotPlaying == 2 || quickLauncherIsPlaying == 2) {
		if (![_specifiers containsObject:specifier3_0_4.firstObject]) {
			[self insertContiguousSpecifiers:specifier3_0_4 afterSpecifier:specifier2_3 animated:animated];
		}
	} else {
		if ([_specifiers containsObject:specifier3_0_4.firstObject]) {
			[self removeContiguousSpecifiers:specifier3_0_4 animated:animated];
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	NSDictionary *userInfo = specifier.userInfo;
	NSString *identifier = [userInfo isKindOfClass:NSDictionary.class] ? userInfo[@"identifier"] : nil;
	if ([identifier isEqualToString:kQuickLauncherNotPlayingKey] || [identifier isEqualToString:kQuickLauncherIsPlayingKey] || [identifier isEqualToString:kQuickLauncherAutoDismissDelayKey]) {
		NSInteger preferenceValue = [getPreferences(identifier) integerValue];
		NSInteger itemValue = [userInfo[@"value"] integerValue];
		cell.checked = (preferenceValue == itemValue);
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	NSDictionary *userInfo = specifier.userInfo;
	NSString *identifier = [userInfo isKindOfClass:NSDictionary.class] ? userInfo[@"identifier"] : nil;
	if ([identifier isEqualToString:kQuickLauncherNotPlayingKey] || [identifier isEqualToString:kQuickLauncherIsPlayingKey] || [identifier isEqualToString:kQuickLauncherAutoDismissDelayKey]) {
		NSInteger preferenceValue = [getPreferences(identifier) integerValue];
		NSInteger itemValue = [userInfo[@"value"] integerValue];
		if (preferenceValue != itemValue) {
			setPreferences(identifier, @(itemValue));
			for (PSSpecifier *specifier in [self specifiersInGroup:indexPath.section]) {
				[self reloadSpecifier:specifier animated:YES];
			}
			[self updateSpecifiers:YES];
		}
	}
}

@end

@implementation UminoPreferencesSliderActionsController {
    NSArray *_uminoSpecifiers;
}

- (NSArray *)specifiers
{
    if (_specifiers == nil) {
        if (_uminoSpecifiers == nil) {
			PSSpecifier *specifier1_0 = [PSSpecifier groupSpecifierWithName:localizedString(@"TAP_BRIGHTNESS_SLIDER")];
            PSSpecifier *specifier1_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"TOGGLE_AUTO_BRIGHTNESS")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier1_1 setUserInfo:@{@"identifier": kSliderActionsBrightnessKey, @"value": @(2)}];
            PSSpecifier *specifier1_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"SET_BRIGHTNESS_MIN")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier1_2 setUserInfo:@{@"identifier": kSliderActionsBrightnessKey, @"value": @(0)}];
            PSSpecifier *specifier1_3 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"SET_BRIGHTNESS_MAX")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier1_3 setUserInfo:@{@"identifier": kSliderActionsBrightnessKey, @"value": @(1)}];
            
			PSSpecifier *specifier2_0 = [PSSpecifier groupSpecifierWithName:localizedString(@"TAP_VOLUME_SLIDER")];
            PSSpecifier *specifier2_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"TOGGLE_VOLUME_CATEGORY")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier2_1 setUserInfo:@{@"identifier": kSliderActionsVolumeKey, @"value": @(2)}];
            PSSpecifier *specifier2_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"SET_VOLUME_MIN")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier2_2 setUserInfo:@{@"identifier": kSliderActionsVolumeKey, @"value": @(0)}];
            PSSpecifier *specifier2_3 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"SET_VOLUME_MAX")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier2_3 setUserInfo:@{@"identifier": kSliderActionsVolumeKey, @"value": @(1)}];

			PSSpecifier *specifier3_0 = [PSSpecifier emptyGroupSpecifier];
			PSSpecifier *specifier3_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"DISABLE_SLIDER_HUD")
																	   target:self
																		  set:@selector(setPreferences:specifier:)
																		  get:@selector(getPreferences:)
																	   detail:Nil
																		 cell:PSSwitchCell
																		 edit:Nil];
			[specifier3_1 setIdentifier:kSliderActionsDisableHUDKey];

            _uminoSpecifiers = @[specifier1_0, specifier1_1, specifier1_2, specifier1_3,
                                 specifier2_0, specifier2_1, specifier2_2, specifier2_3,
								 specifier3_0, specifier3_1];
        }
        _specifiers = _uminoSpecifiers.copy;
    }
    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateSpecifiers:NO];
}

- (id)getPreferences:(PSSpecifier *)specifier
{
	return getPreferences(specifier.identifier);
}

- (void)setPreferences:(id)value specifier:(PSSpecifier *)specifier
{
	setPreferences(specifier.identifier, value);
}

- (void)reloadSpecifiers
{
	[super reloadSpecifiers];
	[self updateSpecifiers:NO];	
}

- (void)updateSpecifiers:(BOOL)animated
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	NSDictionary *userInfo = specifier.userInfo;
	NSString *identifier = [userInfo isKindOfClass:NSDictionary.class] ? userInfo[@"identifier"] : nil;
	NSInteger preferenceValue = [getPreferences(identifier) integerValue];
	NSInteger itemValue = [userInfo[@"value"] integerValue];
	cell.checked = (preferenceValue == itemValue);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	NSDictionary *userInfo = specifier.userInfo;
	NSString *identifier = [userInfo isKindOfClass:NSDictionary.class] ? userInfo[@"identifier"] : nil;
	NSInteger preferenceValue = [getPreferences(identifier) integerValue];
	NSInteger itemValue = [userInfo[@"value"] integerValue];
	if (preferenceValue != itemValue) {
		setPreferences(identifier, @(itemValue));
		for (PSSpecifier *specifier in [self specifiersInGroup:indexPath.section]) {
			[self reloadSpecifier:specifier animated:YES];
		}
	}
}

@end

@implementation UminoPreferencesAlbumArtworkController {
    NSArray *_uminoSpecifiers;
}

- (NSArray *)specifiers
{
    if (_specifiers == nil) {
        if (_uminoSpecifiers == nil) {
            PSSpecifier *specifier1_0 = [PSSpecifier groupSpecifierWithName:localizedString(@"AUTO_DISPLAY")];
            PSSpecifier *specifier1_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"ON_PLAY")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier1_1 setUserInfo:@{@"identifier": kAlbumArtworkAutoDisplayKey, @"value": @(1 << 0)}];
            PSSpecifier *specifier1_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"ON_NEXT")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier1_2 setUserInfo:@{@"identifier": kAlbumArtworkAutoDisplayKey, @"value": @(1 << 1)}];
            PSSpecifier *specifier1_3 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"ON_PREVIOUS")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier1_3 setUserInfo:@{@"identifier": kAlbumArtworkAutoDisplayKey, @"value": @(1 << 2)}];
            
            PSSpecifier *specifier2_0 = [PSSpecifier groupSpecifierWithName:localizedString(@"AUTO_DISMISS")];
            PSSpecifier *specifier2_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AFTER_1_SECOND")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier2_1 setUserInfo:@{@"identifier": kAlbumArtworkAutoDismissDelayKey, @"value": @(1)}];
            PSSpecifier *specifier2_2 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AFTER_3_SECONDS")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier2_2 setUserInfo:@{@"identifier": kAlbumArtworkAutoDismissDelayKey, @"value": @(3)}];
            PSSpecifier *specifier2_3 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AFTER_5_SECONDS")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier2_3 setUserInfo:@{@"identifier": kAlbumArtworkAutoDismissDelayKey, @"value": @(5)}];
            PSSpecifier *specifier2_4 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AFTER_8_SECONDS")
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:Nil
                                                                         cell:PSListItemCell
                                                                         edit:Nil];
            [specifier2_4 setUserInfo:@{@"identifier": kAlbumArtworkAutoDismissDelayKey, @"value": @(8)}];

            _uminoSpecifiers = @[specifier1_0, specifier1_1, specifier1_2, specifier1_3,
                                 specifier2_0, specifier2_1, specifier2_2, specifier2_3, specifier2_4];
        }
        _specifiers = _uminoSpecifiers.copy;
    }
    return _specifiers;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self updateSpecifiers:NO];
}

- (void)reloadSpecifiers
{
	[super reloadSpecifiers];
	[self updateSpecifiers:NO];	
}

- (void)updateSpecifiers:(BOOL)animated
{
    PSSpecifier *specifier1_3 = _uminoSpecifiers[3];
    NSArray *specifier2_0_4 = [_uminoSpecifiers subarrayWithRange:NSMakeRange(4, 5)];

    NSInteger albumArtworkAutoDisplay = [getPreferences(kAlbumArtworkAutoDisplayKey) integerValue];

    if (albumArtworkAutoDisplay > 0) {
        if (![_specifiers containsObject:specifier2_0_4.firstObject]) {
            [self insertContiguousSpecifiers:specifier2_0_4 afterSpecifier:specifier1_3 animated:animated];
        }
    } else {
        if ([_specifiers containsObject:specifier2_0_4.firstObject]) {
            [self removeContiguousSpecifiers:specifier2_0_4 animated:animated];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	NSDictionary *userInfo = specifier.userInfo;
	NSString *identifier = [userInfo isKindOfClass:NSDictionary.class] ? userInfo[@"identifier"] : nil;
    if ([identifier isEqualToString:kAlbumArtworkAutoDisplayKey]) {
		NSInteger preferenceValue = [getPreferences(identifier) integerValue];
		NSInteger itemValue = [userInfo[@"value"] integerValue];
		cell.checked = (preferenceValue & itemValue);
    } else if ([identifier isEqualToString:kAlbumArtworkAutoDismissDelayKey]) {
		NSInteger preferenceValue = [getPreferences(identifier) integerValue];
		NSInteger itemValue = [userInfo[@"value"] integerValue];
		cell.checked = (preferenceValue == itemValue);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	NSDictionary *userInfo = specifier.userInfo;
	NSString *identifier = [userInfo isKindOfClass:NSDictionary.class] ? userInfo[@"identifier"] : nil;
	if ([identifier isEqualToString:kAlbumArtworkAutoDisplayKey]) {
		NSInteger preferenceValue = [getPreferences(identifier) integerValue];
		NSInteger itemValue = [userInfo[@"value"] integerValue];
		NSInteger updatedValue = preferenceValue;
		if (itemValue == 0) {
			updatedValue = itemValue;
		} else {
			updatedValue = (preferenceValue & itemValue) ? (preferenceValue & ~itemValue) : (preferenceValue | itemValue);
		}
		if (preferenceValue != updatedValue) {
			setPreferences(identifier, @(updatedValue));
			for (PSSpecifier *specifier in [self specifiersInGroup:indexPath.section]) {
				[self reloadSpecifier:specifier animated:YES];
			}
			[self updateSpecifiers:YES];
		}
	} else if ([identifier isEqualToString:kAlbumArtworkAutoDismissDelayKey]) {
		NSInteger preferenceValue = [getPreferences(identifier) integerValue];
		NSInteger itemValue = [userInfo[@"value"] integerValue];
		if (preferenceValue != itemValue) {
			setPreferences(identifier, @(itemValue));
			for (PSSpecifier *specifier in [self specifiersInGroup:indexPath.section]) {
				[self reloadSpecifier:specifier animated:YES];
			}
		}
	}
}

@end

@implementation UminoPreferencesCloseAllAppsController

- (NSArray *)specifiers
{
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [NSMutableArray array];

        PSSpecifier *specifier1_0 = [PSSpecifier emptyGroupSpecifier];
        [specifier1_0 setProperty:localizedString(@"AUTO_CLOSE_ALL_APPS_FOOTER") forKey:@"footerText"];
        PSSpecifier *specifier1_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"AUTO_CLOSE_ALL_APPS")
                                                                   target:self
                                                                      set:@selector(setPreferences:specifier:)
                                                                      get:@selector(getPreferences:)
                                                                   detail:Nil
                                                                     cell:PSSwitchCell
                                                                     edit:Nil];
        [specifier1_1 setIdentifier:kCloseAllAppsNoConfirmationKey];
            
        PSSpecifier *specifier2_0 = [PSSpecifier emptyGroupSpecifier];
        [specifier2_0 setProperty:localizedString(@"GO_HOME_UPON_CLOSE_ALL_FOOTER") forKey:@"footerText"];
        PSSpecifier *specifier2_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"GO_HOME_UPON_CLOSE_ALL")
                                                                   target:self
                                                                      set:@selector(setPreferences:specifier:)
                                                                      get:@selector(getPreferences:)
                                                                   detail:Nil
                                                                     cell:PSSwitchCell
                                                                     edit:Nil];
        [specifier2_1 setIdentifier:kCloseAllAppsBackToHomeScreenKey];

        PSSpecifier *specifier3_0 = [PSSpecifier emptyGroupSpecifier];
        [specifier3_0 setProperty:localizedString(@"EXCLUDE_CURRENTLY_PLAYING_FOOTER") forKey:@"footerText"];
        PSSpecifier *specifier3_1 = [PSSpecifier preferenceSpecifierNamed:localizedString(@"EXCLUDE_CURRENTLY_PLAYING")
                                                                   target:self
                                                                      set:@selector(setPreferences:specifier:)
                                                                      get:@selector(getPreferences:)
                                                                   detail:Nil
                                                                     cell:PSSwitchCell
                                                                     edit:Nil];
        [specifier3_1 setIdentifier:kCloseAllAppsExcludeNowPlayingKey];

        [specifiers addObjectsFromArray:@[specifier1_0, specifier1_1,
                                          specifier2_0, specifier2_1,
                                          specifier3_0, specifier3_1]];
        [specifiers addObjectsFromArray:applistSpecifiers(self, localizedString(@"EXCLUDE_FROM_CLOSE_ALL"), nil)];

        _specifiers = specifiers;
    }
    return _specifiers;
}

- (id)getPreferences:(PSSpecifier *)specifier
{
	return getPreferences(specifier.identifier);
}

- (void)setPreferences:(id)value specifier:(PSSpecifier *)specifier
{
	setPreferences(specifier.identifier, value);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	if (indexPath.section > 2) {
		PSSpecifier *specifier = cell.specifier;
		NSString *application = specifier.identifier;
        cell.checked = [getPreferencesAppList(kCloseAllAppsExceptionsKey, application) boolValue];
		if ([specifier propertyForKey:@"iconImage"] == nil) {
			[specifier setProperty:[[NSClassFromString(@"ALApplicationList") sharedApplicationList] iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:application] forKey:@"iconImage"];
			[cell refreshCellContentsWithSpecifier:specifier];
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	if (indexPath.section > 2) {
		PSTableCell *cell = (PSTableCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];	
		NSString *application = cell.specifier.identifier;
		cell.checked = !cell.checked;
        setPreferencesAppList(kCloseAllAppsExceptionsKey, application, @(cell.checked));
	}	
}

@end

@implementation UminoPreferencesExceptionsController

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specifiers = [NSMutableArray array];

		/*
		PSSpecifier *specifier1_0 = [PSSpecifier emptyGroupSpecifier];
		PSSpecifier *specifier1_1 = [PSSpecifier preferenceSpecifierNamed:@"Disable with Keyboard"
			                                                       target:self
			                                                          set:@selector(setPreferences:specifier:)
			                                                          get:@selector(getPreferences:)
			                                                       detail:Nil
			                                                         cell:PSSwitchCell
			                                                         edit:Nil];
		[specifier1_1 setIdentifier:kDisableWithKeyboardKey];
		*/

		//[specifiers addObjectsFromArray:@[specifier1_0, specifier1_1]];
        [specifiers addObjectsFromArray:applistSpecifiers(self, nil, nil)];

    	_specifiers = specifiers;
	}
	return _specifiers;
}

- (id)getPreferences:(PSSpecifier *)specifier
{
	return getPreferences(specifier.identifier);
}

- (void)setPreferences:(id)value specifier:(PSSpecifier *)specifier
{
	setPreferences(specifier.identifier, value);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	if (indexPath.section >= 0) {
		PSSpecifier *specifier = cell.specifier;
		NSString *application = specifier.identifier;
		cell.checked = getExceptions(application);
		if ([specifier propertyForKey:@"iconImage"] == nil) {
			[specifier setProperty:[[NSClassFromString(@"ALApplicationList") sharedApplicationList] iconOfSize:ALApplicationIconSizeSmall forDisplayIdentifier:application] forKey:@"iconImage"];
			[cell refreshCellContentsWithSpecifier:specifier];
		}
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	if (indexPath.section >= 0) {
		PSTableCell *cell = (PSTableCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];	
		NSString *application = cell.specifier.identifier;
		cell.checked = !cell.checked;
		setExceptions(application, cell.checked);
	}	
}

@end

@implementation UminoPreferencesProfileController

- (void)loadView
{
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    self.view = tableView;
}

- (NSString *)title
{
    return self.specifier.name;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseIdentifier = @"UminoPreferencesProfileCell";
    UminoPreferencesProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier] ? : [[UminoPreferencesProfileCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    switch (indexPath.section) {
        case 0:
            [cell loadImage:@"Sentry" nameText:@"Sentry" handleText:@"(@Sentry_NC)" infoText:@"Visual Interaction Designer,\nAuxo, Apex, AltKB, Aplo,\nFounder of A³tweaks."];
            break;
        case 1:
            [cell loadImage:@"Qusic" nameText:@"Qusic" handleText:@"(@QusicS)" infoText:@"Don't be afraid.\nI know it's not easy."];
            break;
        case 2:
            [cell loadImage:nil nameText:nil handleText:nil infoText:nil];
            cell.textLabel.text = localizedString(@"FOLLOW_A3TWEAKS");
            cell.imageView.image = imageResource(@"Logo");
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section < 2 ? 106 : 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return indexPath.section < 2 ? 106 : 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *handleString = nil;
    switch (indexPath.section) {
        case 0:
            handleString = @"Sentry_NC";
            break;
        case 1:
            handleString = @"QusicS";
            break;
        case 2:
            handleString = @"A3tweaks";
            break;
       	default:
            return;
    }
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *tweetbotUrl = [NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:handleString]];
    if ([application canOpenURL:tweetbotUrl]) {
        [application openURL:tweetbotUrl];
        return;
    }
    NSURL *twitterUrl = [NSURL URLWithString:[@"twitter:///user?screen_name=" stringByAppendingString:handleString]];
	if ([application canOpenURL:twitterUrl]) {
		[application openURL:twitterUrl];
		return;
	}
    NSURL *webUrl = [NSURL URLWithString:[@"http://twitter.com/" stringByAppendingString:handleString]];
    [application openURL:webUrl];
}

@end

@implementation UminoPreferencesProfileCell {
	UIImageView *_avatarView;
	UIImageView *_twitterView;
	UILabel *_nameLabel;
	UILabel *_infoLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
	if (self) {
		_avatarView = [[UIImageView alloc]initWithFrame:CGRectZero];
		_avatarView.layer.cornerRadius = 30;
		_avatarView.clipsToBounds = YES;
		_twitterView = [[UIImageView alloc]initWithFrame:CGRectZero];
		_twitterView.image = imageResource(@"Twitter");
		_nameLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_nameLabel.textColor = [UIColor blackColor];
		_infoLabel = [[UILabel alloc]initWithFrame:CGRectZero];
		_infoLabel.font = [UIFont systemFontOfSize:14];
		_infoLabel.textColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
		_infoLabel.numberOfLines = 3;
		_infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
		UIView *contentView = self.contentView;
		[contentView addSubview:_avatarView];
		[contentView addSubview:_twitterView];
		[contentView addSubview:_nameLabel];
		[contentView addSubview:_infoLabel];
	}
	return self;
}

- (void)layoutSubviews
{
	static CGRect (^ const roundedRect)(CGFloat, CGFloat, CGFloat, CGFloat) = ^(CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
		CGFloat scale = [UIScreen mainScreen].scale;
		CGFloat inverseScale = 1.0f / scale;
		CGRect result;
		result.origin.x = roundf(x * scale) * inverseScale;
		result.size.width = roundf((x + width) * scale) * inverseScale - result.origin.x;
		result.origin.y = roundf(y * scale) * inverseScale;
		result.size.height = roundf((y + height) * scale) * inverseScale - result.origin.y;
		return result;
	};
	[super layoutSubviews];
	CGRect bounds = self.contentView.bounds;
	_avatarView.frame = roundedRect(9, 18, 60, 60);
	_twitterView.frame = roundedRect(bounds.size.width - 14, (bounds.size.height - 15) / 2.0, 19, 15);
	_nameLabel.frame = roundedRect(79, 18, _twitterView.frame.origin.x - 79, 22);
	_infoLabel.frame = roundedRect(79, 37.5, _twitterView.frame.origin.x - 79, 55);
}

- (void)loadImage:(NSString *)imageName nameText:(NSString *)nameText handleText:(NSString *)handleText infoText:(NSString *)infoText
{
	if (imageName != nil) {
		_avatarView.image = imageResource(imageName);
	} else {
		_avatarView.image = nil;
	}
	if (nameText != nil && handleText != nil) {
		NSMutableAttributedString *text = [[NSMutableAttributedString alloc]init];
		[text appendAttributedString:[[NSAttributedString alloc]initWithString:nameText attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18]}]];
		[text appendAttributedString:[[NSAttributedString alloc]initWithString:@" " attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}]];
	    [text appendAttributedString:[[NSAttributedString alloc]initWithString:handleText attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}]];
		_nameLabel.attributedText = text;	
	} else {
		_nameLabel.text = nil;
	}
	_infoLabel.text = infoText;
}

@end
