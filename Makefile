ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = MapStep
MapStep_FILES = Tweak.xm
MapStep_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk


