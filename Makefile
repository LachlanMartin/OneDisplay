APP_NAME = OneDisplay
BUNDLE_ID = com.lachlanmartin.onedisplay
RESOURCES_DIR = Resources
APP_BUNDLE = $(APP_NAME).app

.PHONY: all build bundle icon run clean

all: bundle

build:
	swift build -c release

BIN_PATH = $(shell swift build --show-bin-path -c release)

bundle: build
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp "$(BIN_PATH)/$(APP_NAME)" $(APP_BUNDLE)/Contents/MacOS/
	cp $(RESOURCES_DIR)/Info.plist $(APP_BUNDLE)/Contents/
	cp $(RESOURCES_DIR)/OneDisplay.icns $(APP_BUNDLE)/Contents/Resources/
	cp $(RESOURCES_DIR)/laptop-icon-input.png $(APP_BUNDLE)/Contents/Resources/
	codesign --force --deep --sign - $(APP_BUNDLE)

icon:
	swift Scripts/gen-icon.swift
	iconutil -c icns OneDisplay.iconset -o $(RESOURCES_DIR)/OneDisplay.icns
	rm -rf OneDisplay.iconset

run: bundle
	open $(APP_BUNDLE)

clean:
	swift build --clean
	rm -rf $(APP_BUNDLE)
