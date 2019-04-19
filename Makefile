ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LeaveMeAlone
LeaveMeAlone_FILES = Tweak.xm
LeaveMeAlone_EXTRA_FRAMEWORKS += Cephei
include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

internal-stage::
	mkdir -p "$(THEOS_STAGING_DIR)/var/mobile/Library/LeaveMeAlone"
	cp Resources/* "$(THEOS_STAGING_DIR)/var/mobile/Library/LeaveMeAlone"

SUBPROJECTS += leavemealone
SUBPROJECTS += leavemealonestatusbar
include $(THEOS_MAKE_PATH)/aggregate.mk
