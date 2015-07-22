
TWEAK_NAME = Auxo3
BUNDLE_NAME = Auxo3Preferences

Auxo3_FILES = Tweak.xm UminoIconListView.m UminoIconView.m UminoIconHighlightView.m UminoControlCenterTopView.m UminoControlCenterBottomView.m UminoControlCenterOriginalView.m
Auxo3_FRAMEWORKS = UIKit CoreGraphics QuartzCore MediaPlayer AVFoundation
Auxo3_PRIVATE_FRAMEWORKS = SpringBoardUI BackBoardServices GraphicsServices MediaPlayerUI Celestial MediaRemote RadioUI
Auxo3_LIBRARIES = MobileGestalt
Auxo3_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries
Auxo3_LOGOSFLAGS = -c generator=internal

Auxo3Preferences_FILES = UminoPreferences.m
Auxo3Preferences_FRAMEWORKS = UIKit CoreGraphics Social MessageUI
Auxo3Preferences_PRIVATE_FRAMEWORKS = Preferences
Auxo3Preferences_INSTALL_PATH = /Library/PreferenceBundles

export TARGET = simulator:clang
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 8.0
export ADDITIONAL_OBJCFLAGS = -fobjc-arc
export IPHONE_SIMULATOR_ROOT = /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk
#export SCHEMA = debug

default: all package install
	install.exec "killall -9 SpringBoard"
#default: all
#	killall SpringBoard

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/bundle.mk
