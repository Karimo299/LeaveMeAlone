#define dndClientID @"com.apple.springboard.SBDashBoardCombinedListViewController"
@class CCUICAPackageDescription, CCUIButtonModuleView, SBFLockScreenDateView, _UILegibilitySettings, DNDStateUpdate, BBBulletinRequest,SBFLockScreenAlternateDateLabel;

@interface BBBulletinRequest : NSObject
@property (nonatomic,copy) NSString* sectionID;
@property (nonatomic,copy) NSString* message;
@end

@interface SBFLockScreenDateSubtitleDateView
@property (nonatomic,retain) SBFLockScreenAlternateDateLabel * alternateDateLabel;
@end

@interface SBUILegibilityLabel : UIView
@end

@interface BBSettingsGateway : NSObject
-(id)initWithQueue:(id)arg1;
-(void)setActiveBehaviorOverrideTypesChangeHandler:(void (^)(int))block;
@end

@interface DNDState : NSObject
@property (getter=isActive,nonatomic,readonly) BOOL active;
@end

@interface DNDStateService : NSObject
+(id)serviceForClientIdentifier:(id)arg1;
-(DNDState*)queryCurrentStateWithError:(id*)arg1;
@end

@interface PSDNDSettingsDetail : NSObject
+(void)setEnabled:(BOOL)arg1 ;
+(BOOL)isEnabled;
@end

@interface _UILegibilitySettings : NSObject
@property (nonatomic,retain) UIColor * primaryColor;
@end

@interface SBFLockScreenDateView : UIView
@property (nonatomic,retain) _UILegibilitySettings * legibilitySettings;
-(void)updateFormat;
@end

NSFileManager *fileManager = [NSFileManager defaultManager];

static NSUserDefaults *prefs;
static bool enabled;
static bool dndEnabled;
static float iconHeight;
static float iconWidth;
static float iconSize;
static UIImage *dnd;
static UIImageView *dndView;
static CCUICAPackageDescription *dndPackDesc;
static CCUIButtonModuleView *dndModule;
static SBFLockScreenDateView *dateView;
static SBFLockScreenAlternateDateLabel *alternateDateLabel;

static void loadPrefs() {
	prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.karimo299.leavemealone"];
  enabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
  iconSize = [prefs objectForKey:@"iconSize"] ? [[prefs objectForKey:@"iconSize"] floatValue] : 20;
	iconHeight = [prefs objectForKey:@"iconHeight"] ? [[prefs objectForKey:@"iconHeight"] floatValue] : 0;
	iconWidth = [prefs objectForKey:@"iconWidth"] ? [[prefs objectForKey:@"iconWidth"] floatValue] : 0;
}

%group ios12
//DND Banner on IOS 12
%hook DNDNotificationsService
  -(id)initWithClientIdentifier:(id)arg1 {
    return nil;
  }
%end

//DND Status fix after respring for IOS 12
%hook DNDState
-(id)initWithActive:(BOOL)arg1 willSuppressInterruptions:(BOOL)arg2 activeModeAssertionMetadata:(id)arg3{
  static dispatch_once_t once;
  dispatch_once(&once, ^ {
    dndEnabled = arg1;
    [dateView updateFormat];
  });
  return %orig;
}
%end

%hook CCUICAPackageDescription
-(id)initWithPackageName:(id)arg1 inBundle:(id)arg2{
  if ([arg1 isEqual:@"DoNotDisturb"]) {
    dndPackDesc = %orig;
  }
  return %orig;
}
%end


%hook CCUIButtonModuleView
-(void)setGlyphPackageDescription:(CCUICAPackageDescription *)arg1 {
  %orig;
  if ([arg1 isEqual:dndPackDesc]) {
    dndModule = self;
  }
}

-(void)setGlyphState:(NSString *)arg1 {
  %orig;
  if ([self isEqual:dndModule]) {
    if ([arg1 isEqual:@"on"]) {
      dndEnabled = YES;
    } else {
      dndEnabled = NO;
    }
    [dateView updateFormat];
  }
}
%end

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

				if (dndEnabled && ![dndView.superview isEqual:self]) {
					[self addSubview:dndView];
				} else if (!dndEnabled && [dndView.superview isEqual:self]) {
					[dndView removeFromSuperview];
				}
			}
		}
	}
}
%end

%hook SBFLockScreenDateView
-(id)initWithFrame:(CGRect)arg1 {
  dateView = %orig;
  dnd = [UIImage imageWithContentsOfFile:@"/Library/leavemealone/dnd.png"];
  dndView = [[UIImageView alloc] initWithImage:[dnd imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
  return dateView;
}

-(void)setLegibilitySettings:(_UILegibilitySettings *)arg1 {
  dndView.tintColor = arg1.primaryColor;
  %orig;
}


-(void)updateFormat {
	if (enabled) {
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		alternateDateLabel = MSHookIvar<SBFLockScreenDateSubtitleDateView*>(self,"_dateSubtitleView").alternateDateLabel;
		if(alternateDateLabel && iconHeight==0) iconHeight+=25;

		if  ([[UIDevice currentDevice] orientation] == 3 || [[[UIDevice currentDevice] model] isEqual: @"iPad"]) [dndView setFrame:CGRectMake(0+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];
	 	else [dndView setFrame:CGRectMake(self.frame.size.width/2-(iconSize/2)+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];

		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Twig.dylib"]) [dndView setFrame:CGRectMake((self.frame.size.width-iconSize)+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];
		if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Jellyfish.dylib"]) [dndView setFrame:CGRectMake((self.frame.size.width-iconSize)+iconWidth,(self.frame.size.height + iconHeight + 30),iconSize,iconSize)];
		%orig;

		if (dndEnabled && ![dndView.superview isEqual:self]) {
			[self addSubview:dndView];
		} else if (!dndEnabled && [dndView.superview isEqual:self]) {
			[dndView removeFromSuperview];
		}
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

%group ios11
%hook UIView
-(void)layoutSubviews {
	%orig;
	for (UIView *aView in self.subviews) {
    if([aView isKindOfClass:[%c(SLClockDragView) class]]){
			if (dndView) return;
	    dnd = [UIImage imageWithContentsOfFile:@"/Library/leavemealone/dnd.png"];
	    dndView = [[UIImageView alloc] initWithImage:[dnd imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
	    %orig;
			if(alternateDateLabel && iconHeight==0) iconHeight+=25;
			[dndView setFrame:CGRectMake(5+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];

	    if (%c(DNDStateService))
	        dndEnabled = [[%c(DNDStateService) serviceForClientIdentifier:dndClientID] queryCurrentStateWithError:nil].active;
	    else
	        dndEnabled = [%c(PSDNDSettingsDetail) isEnabled];

	    if (dndEnabled)
	        [self addSubview:dndView];

	    BBSettingsGateway *_settingsGateway = [[NSClassFromString(@"BBSettingsGateway") alloc] initWithQueue:dispatch_get_main_queue()];
	    if ([_settingsGateway respondsToSelector:@selector(setActiveBehaviorOverrideTypesChangeHandler:)]) {
	      [_settingsGateway setActiveBehaviorOverrideTypesChangeHandler:^(int value) {
	    	if (value == 1) {
	        [self addSubview:dndView];
	      } else {
	        [dndView removeFromSuperview];
	      }
	  	}];
	  }
	}
}
}
%end

%hook SBFLockScreenDateView
-(void)setLegibilitySettings:(_UILegibilitySettings *)arg1 {
  dndView.tintColor = arg1.primaryColor;
  %orig;
}

-(void)didMoveToWindow {
	NSLog(@"h");
  if (!enabled || dndView || [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/SimpleLSiOS10.dylib"] || [fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/SimpleLSiOSiPad.dylib"]) return;
    dateView = self;
    dnd = [UIImage imageWithContentsOfFile:@"/Library/leavemealone/dnd.png"];
    dndView = [[UIImageView alloc] initWithImage:[dnd imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    %orig;
		alternateDateLabel = MSHookIvar<SBFLockScreenDateSubtitleDateView*>(self,"_dateSubtitleView").alternateDateLabel;
		if(alternateDateLabel && iconHeight==0) iconHeight+=25;

    if (!UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)|| [[[UIDevice currentDevice] model] isEqual: @"iPad"]) [dndView setFrame:CGRectMake((self.frame.size.width/2-iconSize/2)+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];
    else [dndView setFrame:CGRectMake(0+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];

    if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Twig.dylib"]) [dndView setFrame:CGRectMake((self.frame.size.width-iconSize)+iconWidth,(self.frame.size.height + iconHeight),iconSize,iconSize)];
    if ([fileManager fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Jellyfish.dylib"]) [dndView setFrame:CGRectMake((self.frame.size.width-25)+iconWidth,(self.frame.size.height + iconHeight+30),iconSize,iconSize)];

    if (%c(DNDStateService))
        dndEnabled = [[%c(DNDStateService) serviceForClientIdentifier:dndClientID] queryCurrentStateWithError:nil].active;
    else
        dndEnabled = [%c(PSDNDSettingsDetail) isEnabled];

    if (dndEnabled)
        [self addSubview:dndView];

    BBSettingsGateway *_settingsGateway = [[NSClassFromString(@"BBSettingsGateway") alloc] initWithQueue:dispatch_get_main_queue()];
    if ([_settingsGateway respondsToSelector:@selector(setActiveBehaviorOverrideTypesChangeHandler:)]) {
      [_settingsGateway setActiveBehaviorOverrideTypesChangeHandler:^(int value) {
    	if (value == 1) {
        [dateView addSubview:dndView];
      } else {
        [dndView removeFromSuperview];
      }
  	}];
  }
}

%end

@interface DNDStateUpdate : NSObject
@property (nonatomic,copy,readonly) DNDState* state;
@end

%hook DNDNotificationsService
-(void)stateService:(id)arg1 didReceiveDoNotDisturbStateUpdate:(DNDStateUpdate*)update {
    %orig;
    if (update.state.active) {
      [dateView addSubview:dndView];
    }
    else {
      [dndView removeFromSuperview];
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

//////////////////////////////////////////////////////////////////////////////////////////////////

%ctor {
  float version = [[[UIDevice currentDevice] systemVersion] floatValue];
  if (version >= 12) %init(ios12);
  if (version >= 11 && version < 12) %init(ios11);
  CFNotificationCenterAddObserver(
    CFNotificationCenterGetDarwinNotifyCenter(), NULL,
    (CFNotificationCallback)loadPrefs,
    CFSTR("com.karimo299.leavemealone/prefChanged"), NULL,
    CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
}
