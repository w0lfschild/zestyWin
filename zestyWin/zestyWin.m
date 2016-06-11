//
//  zestyWin.m
//  zestyWin
//
//  Created by Wolfgang Baird on 9/14/15.
//  Copyright © 2015 - 2016 Wolfgang Baird. All rights reserved.
//

@import AppKit;
#import <objc/runtime.h>

@interface zestyWin : NSObject
@end

zestyWin                *plugin;
static NSUserDefaults   *sharedPrefs = nil;
static NSDictionary     *sharedDict = nil;
static Class            vibrantClass = nil;
static void             *isActive = &isActive;

@implementation zestyWin

+ (zestyWin*) sharedInstance
{
    static zestyWin* plugin = nil;
    if (plugin == nil)
        plugin = [[zestyWin alloc] init];
    return plugin;
}

+ (void)load {
    plugin = [zestyWin sharedInstance];
    NSInteger osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    if (osx_ver > 9) {
        vibrantClass=NSClassFromString(@"NSVisualEffectView");
        if (vibrantClass)
        {
            [plugin zest_initializePrefs];
            if (![sharedDict objectForKey:[[NSBundle mainBundle] bundleIdentifier]])
            {
                for (NSWindow *win in [[NSApplication sharedApplication] windows])
                    [plugin zest_addVisualEffectView:win];
                [[NSNotificationCenter defaultCenter] addObserver:plugin
                                                         selector:@selector(zest_WindowDidBecomeKey:)
                                                             name:NSWindowDidBecomeKeyNotification
                                                           object:nil];
                NSLog(@"OS X 10.%ld, zestyWin loaded...", (long)osx_ver);
            }
        }
    }
}

- (void)zest_WindowDidBecomeKey:(NSNotification *)notification {
    [plugin zest_addVisualEffectView:[notification object]];
}

- (void)zest_addVisualEffectView:(NSWindow*)theWindow {
    if (!objc_getAssociatedObject(theWindow, isActive))
    {
        NSVisualEffectView *vibrant=[[vibrantClass alloc] initWithFrame:[[theWindow contentView] bounds]];
        [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [vibrant setIdentifier:@"cView"];
        [[theWindow contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
        objc_setAssociatedObject(theWindow, isActive, [NSNumber numberWithBool:true], OBJC_ASSOCIATION_RETAIN);
    }
}

-(void)zest_initializePrefs {
    if (!sharedPrefs)
    {
        sharedPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"org.w0lf.zestyWin"];
        sharedDict = [sharedPrefs dictionaryRepresentation];
    }
    // Blacklist
    NSArray *blacklist = @[ @"com.apple.finder", @"com.apple.iTunes", @"com.apple.Terminal", @"com.sublimetext.2", @"com.sublimetext.3", @"com.apple.dt.Xcode", @"com.apple.notificationcenterui", @"com.google.Chrome.canary", @"com.google.Chrome", @"com.apple.TextEdit", @"org.w0lf.cDock"];
    for (id item in blacklist)
        if ([sharedDict objectForKey:item] == nil)
            [sharedPrefs setInteger:0 forKey:item];
    [sharedPrefs synchronize];
}

@end