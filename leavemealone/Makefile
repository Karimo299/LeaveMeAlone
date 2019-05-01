ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = LeaveMeAlone
LeaveMeAlone_FILES = LMARootListController.m
LeaveMeAlone_INSTALL_PATH = /Library/PreferenceBundles
LeaveMeAlone_FRAMEWORKS = UIKit
LeaveMeAlone_EXTRA_FRAMEWORKS += CepheiPrefs
LeaveMeAlone_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LeaveMeAlone.plist$(ECHO_END)
