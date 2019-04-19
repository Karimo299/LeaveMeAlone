#import "Headers.h"

static NSUserDefaults *prefs;

static void loadPrefs() {
	prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.karimo299.leavemealone"];
	enabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
	color = [prefs objectForKey:@"color"] ? [[prefs objectForKey:@"color"] boolValue] : YES;
  hideDND = [prefs objectForKey:@"hideDND"] ? [[prefs objectForKey:@"hideDND"] boolValue] : YES;
  iconSize = [prefs objectForKey:@"iconSize"] ? [[prefs objectForKey:@"iconSize"] floatValue] : 20;
	iconHeight = [prefs objectForKey:@"iconHeight"] ? [[prefs objectForKey:@"iconHeight"] floatValue] : 0;
	iconWidth = [prefs objectForKey:@"iconWidth"] ? [[prefs objectForKey:@"iconWidth"] floatValue] : 0;
}

//DND Banner on IOS 12
%group ios12
%hook DNDNotificationsService
  -(id)initWithClientIdentifier:(id)arg1 {
    return nil;
  }
%end

  %hook DNDState
  	-(id)initWithActive:(BOOL)arg1 willSuppressInterruptions:(BOOL)arg2 activeModeAssertionMetadata:(id)arg3 {
  		dndEnabled = %orig.active;
      [prefs setBool:dndEnabled forKey:@"dndEnabled"];
      notify_post("com.karimo299.leavemealone");
  		bedtime = ([[%orig activeModeIdentifiers] containsObject:@"com.apple.donotdisturb.mode.bedtime"]);
  		return %orig;
  	}
  %end
  %end

%group tweak
%hook UIView
-(void)layoutSubviews {
	%orig;
	for (UIView *aView in self.subviews) {
    if([aView isKindOfClass:[%c(SLClockDragView) class]]){
			if (enabled) {
				[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
				if(alternateDateLabel && iconHeight==0) iconHeight+=25;

				[dndView setFrame:CGRectMake(5+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];
				%orig;
        int regToken; // The registration token
        notify_register_dispatch("com.karimo299.leavemealone", &regToken, dispatch_get_main_queue(), ^(int token) {
          dndBed = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LeaveMeAlone/bedtime.png"];
          dnd = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LeaveMeAlone/dnd.png"];
          if (bedtime) {
            if (dndView.superview)[dndView removeFromSuperview];
            dndView = [[UIImageView alloc] initWithImage:[dndBed imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
          } else {
            if (dndView.superview)[dndView removeFromSuperview];
            dndView = [[UIImageView alloc] initWithImage:[dnd imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
          }
          bool black = [[NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.xcxiao.simplels.plist"] objectForKey:@"useBlack"] ? [[[NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.xcxiao.simplels.plist"] objectForKey:@"useBlack"] boolValue] : NO;
          if (black) {
            dndView.tintColor = [UIColor blackColor];
          } else {
            dndView.tintColor = [UIColor whiteColor];
          }
          if (dndEnabled && !dndView.superview) {
            [self addSubview:dndView];
            [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/dndEnabled" contents:nil attributes:nil];
          } else if (!dndEnabled) {
            [dndView removeFromSuperview];
            [fileManager removeItemAtPath:@"/var/mobile/Library/Preferences/dndEnabled" error:nil];
          }
        });
      }
		}
	}
}
%end

%hook SBFLockScreenDateView
-(id)initWithFrame:(CGRect)arg1 {
  dateView = %orig;
  BBSettingsGateway *_settingsGateway = [[NSClassFromString(@"BBSettingsGateway") alloc] initWithQueue:dispatch_get_main_queue()];
  if ([_settingsGateway respondsToSelector:@selector(setActiveBehaviorOverrideTypesChangeHandler:)]) {
    [_settingsGateway setActiveBehaviorOverrideTypesChangeHandler:^(int value) {
    if (value == 1) {
      dndEnabled = YES;
    } else {
      dndEnabled = NO;
    }
  }];
  }
  return dateView;
}

-(void)updateFormat {
	if (enabled && ![fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/SimpleLSiOS10.dylib"]) {
    int regToken; // The registration token
    notify_register_dispatch("com.karimo299.leavemealone", &regToken, dispatch_get_main_queue(), ^(int token) {
      dndBed = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LeaveMeAlone/bedtime.png"];
      dnd = [UIImage imageWithContentsOfFile:@"/var/mobile/Library/LeaveMeAlone/dnd.png"];
      if (bedtime) {
        if (dndView.superview)[dndView removeFromSuperview];
        dndView = [[UIImageView alloc] initWithImage:[dndBed imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
      } else {
        if (dndView.superview)[dndView removeFromSuperview];
        dndView = [[UIImageView alloc] initWithImage:[dnd imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
      }
      dndView.tintColor = self.legibilitySettings.primaryColor;
      [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
  		alternateDateLabel = MSHookIvar<SBFLockScreenDateSubtitleDateView*>(self,"_dateSubtitleView").alternateDateLabel;
  		if(alternateDateLabel && iconHeight==0) iconHeight+=25;

  		if  ([[UIDevice currentDevice] orientation] == 3 || [[[UIDevice currentDevice] model] isEqual: @"iPad"]) [dndView setFrame:CGRectMake(0+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];
  	 	else [dndView setFrame:CGRectMake(self.frame.size.width/2-(iconSize/2)+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];

  		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Twig.dylib"]) [dndView setFrame:CGRectMake((self.frame.size.width-iconSize)+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];
  		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Jellyfish.dylib"]) [dndView setFrame:CGRectMake((self.frame.size.width-iconSize)+iconWidth,(self.frame.size.height + iconHeight + 30),iconSize,iconSize)];
      if (dndEnabled && !dndView.superview) {
        [self addSubview:dndView];
        [fileManager createFileAtPath:@"/var/mobile/Library/Preferences/dndEnabled" contents:nil attributes:nil];
      } else if (!dndEnabled) {
        [dndView removeFromSuperview];
        [fileManager removeItemAtPath:@"/var/mobile/Library/Preferences/dndEnabled" error:nil];
      }
    });
		%orig;
	}
}
 %end

%hook NCNotificationListCollectionView
- (void)setFrame:(CGRect)arg1 {
	arg1.origin.y = arg1.origin.y + 20 + iconHeight;
	%orig(arg1);
}
%end
%end

%ctor {
  float version = [[[UIDevice currentDevice] systemVersion] floatValue];
  if (version >= 12) %init(ios12);
  %init(tweak);
  CFNotificationCenterAddObserver(
    CFNotificationCenterGetDarwinNotifyCenter(), NULL,
    (CFNotificationCallback)loadPrefs,
    CFSTR("com.karimo299.leavemealone"), NULL,
    CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
}
