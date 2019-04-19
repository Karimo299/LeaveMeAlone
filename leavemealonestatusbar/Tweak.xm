#import "../Headers.h"

NSMutableDictionary *prefs;

static void loadPrefs() {
	 prefs = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.karimo299.leavemealone.plist"];
	enabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	color = [prefs objectForKey:@"color"] ? [[prefs objectForKey:@"color"] boolValue] : YES;
  hideDND = [prefs objectForKey:@"hideDND"] ? [[prefs objectForKey:@"hideDND"] boolValue] : YES;
}

%group ios11
%hook UIStatusBar
-(void)forceUpdateData:(BOOL)arg1 {
  if (enabled && color) {
    BBSettingsGateway *_settingsGateway = [[NSClassFromString(@"BBSettingsGateway") alloc] initWithQueue:dispatch_get_main_queue()];
    if ([_settingsGateway respondsToSelector:@selector(setActiveBehaviorOverrideTypesChangeHandler:)]) {
      [_settingsGateway setActiveBehaviorOverrideTypesChangeHandler:^(int value) {
        if (value == 1) {
          [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/dndEnabled" contents:nil attributes:nil];
          [self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
        } else {
          [fileManager removeItemAtPath:@"/var/mobile/Library/Preferences/dndEnabled" error:nil];
          [self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
        }
        notify_post("com.karimo299.leavemealone");
      }];
    }
    int regToken;
    notify_register_dispatch("com.karimo299.leavemealone", &regToken, dispatch_get_main_queue(), ^(int token) {
      if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/dndEnabled"]) {
				[self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
      } else {
        [self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
      }
    });
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/dndEnabled"]) {
			[self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
		} else {
			[self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
		}
  }
  return %orig;
}
%end

%hook UIStatusBar_Modern
-(void)forceUpdateData:(BOOL)arg1 {
  if (enabled && color) {
    BBSettingsGateway *_settingsGateway = [[NSClassFromString(@"BBSettingsGateway") alloc] initWithQueue:dispatch_get_main_queue()];
    if ([_settingsGateway respondsToSelector:@selector(setActiveBehaviorOverrideTypesChangeHandler:)]) {
      [_settingsGateway setActiveBehaviorOverrideTypesChangeHandler:^(int value) {
        if (value == 1) {
          [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/dndEnabled" contents:nil attributes:nil];
          [self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
        } else {
          [fileManager removeItemAtPath:@"/var/mobile/Library/Preferences/dndEnabled" error:nil];
          [self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
        }
        notify_post("com.karimo299.leavemealone");
      }];
    }
    int regToken;
    notify_register_dispatch("com.karimo299.leavemealone", &regToken, dispatch_get_main_queue(), ^(int token) {
      if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/dndEnabled"]) {
        [self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
      } else {
        [self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
      }
    });
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/dndEnabled"]) {
			[self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
		} else {
			[self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
		}
  }
  return %orig;
}
%end
%end

%group ios12
%hook UIStatusBar
-(void)forceUpdateData:(BOOL)arg1 {
  if (enabled && color) {
    int regToken;
    notify_register_dispatch("com.karimo299.leavemealone", &regToken, dispatch_get_main_queue(), ^(int token) {
			if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/dndEnabled"]) {
				[self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
      } else {
        [self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
      }
    });
		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/dndEnabled"]) {
			[self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
		} else {
			[self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
		}
  }
  return %orig;
}
%end

%hook UIStatusBar_Modern
-(void)forceUpdateData:(BOOL)arg1 {
  if (enabled && color) {
    int regToken;
    notify_register_dispatch("com.karimo299.leavemealone", &regToken, dispatch_get_main_queue(), ^(int token) {
      if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/dndEnabled"]) {
        [self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
      } else {
        [self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
      }
    });
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/dndEnabled"]) {
      [self setBackgroundColor:[UIColor colorWithRed:0.51 green:0.41 blue:1.00 alpha:1.0]];
    } else {
      [self setBackgroundColor:[UIColor colorWithWhite:255 alpha:0]];
    }
  }
  return %orig;
}
%end
%end

%group tweak
%hook SBStatusBarStateAggregator
   -(void)updateStatusBarItem:(int)arg1 {
     if (hideDND) {
       if (arg1 > 2) %orig;
     } else {
       %orig;
     }
  }
%end
%end

%ctor {
  float version = [[[UIDevice currentDevice] systemVersion] floatValue];
  if (version >= 12) %init(ios12);
  if (version >= 11 && version < 12) %init(ios11);
  %init(tweak);
  CFNotificationCenterAddObserver(
    CFNotificationCenterGetDarwinNotifyCenter(), NULL,
    (CFNotificationCallback)loadPrefs,
    CFSTR("com.karimo299.leavemealone/prefChanged"), NULL,
    CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
}
