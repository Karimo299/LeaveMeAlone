#import <notify.h>
@class SBFLockScreenAlternateDateLabel;

@interface SBFLockScreenDateSubtitleDateView
@property (nonatomic,retain) SBFLockScreenAlternateDateLabel * alternateDateLabel;
@end

@interface BBSettingsGateway : NSObject
-(id)initWithQueue:(id)arg1;
-(void)setActiveBehaviorOverrideTypesChangeHandler:(void (^)(int))block;
@end

@interface DNDState : NSObject
-(NSArray *)activeModeIdentifiers;
@property (getter=isActive,nonatomic,readonly) BOOL active;
@end

@interface _UILegibilitySettings : NSObject
@property (nonatomic,retain) UIColor * primaryColor;
@end

@interface SBFLockScreenDateView : UIView
@property (nonatomic,retain) _UILegibilitySettings * legibilitySettings;
@end


NSFileManager *fileManager = [NSFileManager defaultManager];

static bool enabled;
static bool color;
static bool hideDND;
static bool dndEnabled;
static bool bedtime;
static float iconHeight;
static float iconWidth;
static float iconSize;
static UIImage *dnd;
static UIImage *dndBed;
static UIImageView *dndView;
static SBFLockScreenDateView *dateView;
static SBFLockScreenAlternateDateLabel *alternateDateLabel;
