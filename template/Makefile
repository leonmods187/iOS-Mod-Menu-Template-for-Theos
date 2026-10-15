ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

# 1 = Warnungen ignorieren (im CI sinnvoll, damit Warnungen den Build nicht stoppen)
IGNORE_WARNINGS = 1

# 0 = rootful, 1 = rootless
ROOTLESS = 0

ifeq ($(ROOTLESS), 1)
THEOS_PACKAGE_SCHEME = rootless
endif

TARGET = iphone:clang:latest:11.0

PROJ_COMMON_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText

KITTYMEMORY_SRC = $(wildcard KittyMemory/*.cpp)
SCLALERTVIEW_SRC = $(wildcard SCLAlertView/*.m)
MENU_SRC = Menu.mm

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ModMenu

ModMenu_CFLAGS = -fobjc-arc
ModMenu_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG

ifeq ($(IGNORE_WARNINGS),1)
  ModMenu_CFLAGS += -w
  ModMenu_CCFLAGS += -w
endif

ModMenu_FILES = Tweak.xm $(MENU_SRC) $(KITTYMEMORY_SRC) $(SCLALERTVIEW_SRC)
ModMenu_LIBRARIES += substrate
ModMenu_FRAMEWORKS = $(PROJ_COMMON_FRAMEWORKS)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MechArena || :"
