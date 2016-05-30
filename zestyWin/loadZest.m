//
//  loadZest.m
//  zestyWin
//
//  Created by Wolfgang Baird on 9/14/15.
//  Copyright © 2015 - 2016 Wolfgang Baird. All rights reserved.
//

@import AppKit;

@interface loadZest : NSObject
@end

loadZest *plugin;
NSUserDefaults *sharedPrefs;
NSDictionary *sharedDict;
bool enabled = true;
Class vibrantClass = nil;

@implementation loadZest

+ (loadZest*) sharedInstance
{
    static loadZest* plugin = nil;
    if (plugin == nil)
        plugin = [[loadZest alloc] init];
    return plugin;
}

+ (void)load {
    plugin = [loadZest sharedInstance];
    NSInteger osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    if (osx_ver > 9) {
        vibrantClass=NSClassFromString(@"NSVisualEffectView");
        if (vibrantClass)
        {
            [plugin zest_setupPrefs];
            if ([sharedDict objectForKey:[[NSBundle mainBundle] bundleIdentifier]] == [NSNumber numberWithUnsignedInteger:0])
                enabled = false;
            if (enabled)
            {
                NSLog(@"OS X 10.%ld, zestyWin loaded...", (long)osx_ver);
                for (NSWindow *win in [NSApplication sharedApplication].windows)
                    [plugin zest_addView:win];
                [[NSNotificationCenter defaultCenter] addObserver:plugin
                                                         selector:@selector(_addView:)
                                                             name:NSWindowDidBecomeKeyNotification
                                                           object:nil];
            }
 
        }
    }
}

- (void)_addView:(NSNotification *)notification {
    [plugin zest_addView:[notification object]];
}

- (void)zest_addView:(NSWindow*)theWindow {
    if (enabled)
    {
        // Something else that can be foreced but just looks aweful 90% of the time
        // theWindow.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        // theWindow.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        // [theWindow invalidateShadow];
        bool addzest = true;
        for (NSView *aVeiw in theWindow.contentView.subviews)
            if ([[aVeiw identifier] isEqualToString:@"cView"]) {
                addzest = false;
                break;
            }
        if (addzest)
        {
            NSVisualEffectView *vibrant=[[vibrantClass alloc] initWithFrame:[[theWindow contentView] bounds]];
            [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
            [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
            [vibrant setIdentifier:@"cView"];
            [[theWindow contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
        }
    }
}

-(void)zest_setKey:(NSString*)key {
    if ([sharedDict objectForKey:key] == nil)
        [sharedPrefs setInteger:0 forKey:key];
}

-(void)zest_setupPrefs {
    if (!sharedPrefs)
    {
        sharedPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"org.w0lf.zestyWin"];
        sharedDict = [sharedPrefs dictionaryRepresentation];
    }
    // Blacklist
    [plugin zest_setKey:@"com.apple.finder"];
    [plugin zest_setKey:@"com.apple.iTunes"];
    [plugin zest_setKey:@"com.apple.Terminal"];
    [plugin zest_setKey:@"com.sublimetext.2"];
    [plugin zest_setKey:@"com.sublimetext.3"];
    [plugin zest_setKey:@"com.apple.dt.Xcode"];
    [plugin zest_setKey:@"com.apple.notificationcenterui"];
    [plugin zest_setKey:@"com.google.Chrome.canary"];
    [plugin zest_setKey:@"com.apple.TextEdit"];
    [plugin zest_setKey:@"org.w0lf.cDock"];
    [sharedPrefs synchronize];
}

@end