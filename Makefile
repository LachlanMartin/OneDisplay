# SPDX-License-Identifier: MIT

APP_NAME = OneDisplay
BUNDLE_ID = com.lachlanmartin.onedisplay
RESOURCES_DIR = Resources
APP_BUNDLE = $(APP_NAME).app
DIST_DIR = dist
VERSION ?= $(shell grep -A1 CFBundleShortVersionString $(RESOURCES_DIR)/Info.plist | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
DMG_NAME ?= $(APP_NAME)-$(VERSION).dmg

# Distribution config — pass these via env or CI secrets
DEV_ID ?= Developer ID Application: YOUR_NAME (TEAM_ID)
APPLE_ID ?=
TEAM_ID ?=
APPLE_ID_PASSWORD ?=

.PHONY: all build bundle icon run clean dist dmg notarize staple release

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

# Developer ID signing with Hardened Runtime (required for notarization)
dist: bundle
	codesign --force --options runtime --deep --sign "$(DEV_ID)" $(APP_BUNDLE)

# Drag-to-Applications DMG
dmg: dist
	rm -rf $(DIST_DIR) $(DMG_NAME)
	mkdir -p $(DIST_DIR)
	cp -R $(APP_BUNDLE) $(DIST_DIR)/
	ln -s /Applications $(DIST_DIR)/Applications
	hdiutil create -volname "$(APP_NAME)" -srcfolder $(DIST_DIR) -ov -format UDZO $(DMG_NAME)
	rm -rf $(DIST_DIR)

# Submit DMG for Apple notarization
notarize: dmg
	xcrun notarytool submit $(DMG_NAME) \
		--apple-id "$(APPLE_ID)" \
		--team-id "$(TEAM_ID)" \
		--password "$(APPLE_ID_PASSWORD)" \
		--wait

# Staple notarization ticket to DMG
staple: notarize
	xcrun stapler staple $(DMG_NAME)

# Full release pipeline
release: staple
	@echo "✓ Release ready: $(DMG_NAME)"

icon:
	swift Scripts/gen-icon.swift
	iconutil -c icns OneDisplay.iconset -o $(RESOURCES_DIR)/OneDisplay.icns
	rm -rf OneDisplay.iconset

run: bundle
	open $(APP_BUNDLE)

clean:
	rm -rf $(APP_BUNDLE) $(DIST_DIR) $(DMG_NAME) *.dmg .build
