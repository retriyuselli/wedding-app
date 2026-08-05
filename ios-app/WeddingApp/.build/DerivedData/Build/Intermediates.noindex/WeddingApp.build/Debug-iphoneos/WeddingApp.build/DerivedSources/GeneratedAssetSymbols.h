#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.weddingapp.ios";

/// The "SplashBackground" asset catalog color resource.
static NSString * const ACColorNameSplashBackground AC_SWIFT_PRIVATE = @"SplashBackground";

/// The "AboutAppIcon" asset catalog image resource.
static NSString * const ACImageNameAboutAppIcon AC_SWIFT_PRIVATE = @"AboutAppIcon";

/// The "AuthFloralCorner" asset catalog image resource.
static NSString * const ACImageNameAuthFloralCorner AC_SWIFT_PRIVATE = @"AuthFloralCorner";

/// The "CouplePortrait" asset catalog image resource.
static NSString * const ACImageNameCouplePortrait AC_SWIFT_PRIVATE = @"CouplePortrait";

/// The "FloralHeader" asset catalog image resource.
static NSString * const ACImageNameFloralHeader AC_SWIFT_PRIVATE = @"FloralHeader";

/// The "SplashRings" asset catalog image resource.
static NSString * const ACImageNameSplashRings AC_SWIFT_PRIVATE = @"SplashRings";

/// The "SplashScreen" asset catalog image resource.
static NSString * const ACImageNameSplashScreen AC_SWIFT_PRIVATE = @"SplashScreen";

/// The "WeddingAppCoupleLogo" asset catalog image resource.
static NSString * const ACImageNameWeddingAppCoupleLogo AC_SWIFT_PRIVATE = @"WeddingAppCoupleLogo";

#undef AC_SWIFT_PRIVATE
