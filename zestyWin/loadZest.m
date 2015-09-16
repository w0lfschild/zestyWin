//
//  loadZest.m
//  zestyWin
//
//  Created by Wolfgang Baird on 9/14/15.
//  Copyright © 2015 Wolfgang Baird. All rights reserved.
//

#import "ZKSwizzle.h"
#import "loadZest.h"
@import AppKit;

@interface loadZest : NSObject
@end

loadZest *plugin;
NSInteger osx_ver;
NSUserDefaults *shared = nil;
NSMutableArray *userPrefs;
bool enabled;

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
    osx_ver = [[NSProcessInfo processInfo] operatingSystemVersion].minorVersion;
    
    if (osx_ver > 9) {
        NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        [plugin zest_setupPrefs];
        enabled = true;
        if ([userPrefs containsObject:bundleIdentifier])
            enabled = false;
//        NSLog(@"%@", bundleIdentifier);
//        NSLog(@"%hhd", [userPrefs containsObject:bundleIdentifier]);
//        NSLog(@"%@", userPrefs);
        if (enabled)
        {
            NSLog(@"OS X 10.%ld, zestyWin loaded...", (long)osx_ver);
            NSApplication *application = [NSApplication sharedApplication];
            if (application.windows)
            {
                for (NSWindow *win in application.windows)
                {
                    Class vibrantClass=NSClassFromString(@"NSVisualEffectView");
                    if (vibrantClass)
                    {
                        NSVisualEffectView *vibrant=[[vibrantClass alloc] initWithFrame:[[win contentView] bounds]];
                        [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
                        [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
                        [vibrant setIdentifier:@"cView"];
                        if (![win.contentView.subviews containsObject:vibrant])
                            [[win contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
                    }
                }
            }
        }
    }
}

-(void)zest_setKey:(NSString*)key {
    if (![userPrefs containsObject:key])
    {
        NSLog(@"Adding key: %@", key);
        [userPrefs addObject:key];
    }
}

-(void)zest_setupPrefs {
    if (!shared) {
        shared = [[NSUserDefaults alloc] initWithSuiteName:@"com.w0lf.zestyWin"];
        userPrefs = [[NSMutableArray alloc] initWithArray:[[shared dictionaryRepresentation] allKeys]];
        NSLog(@"%@", userPrefs);
    }
    
    [plugin zest_setKey:@"com.apple.iTunes"];
    [plugin zest_setKey:@"com.apple.Terminal"];
    [plugin zest_setKey:@"com.apple.TextEdit"];
    [plugin zest_setKey:@"com.sublimetext.2"];
    [plugin zest_setKey:@"com.sublimetext.3"];
}

@end

@interface NSWindow (zest)
- (id)init;
@end

ZKSwizzleInterface(_zest_NSWindow, NSWindow, NSResponder);
@implementation _zest_NSWindow

- (void)becomeKeyWindow {
    ZKOrig(void);
//    NSLog(@"c");
    if (enabled)
    {
        Class vibrantClass=NSClassFromString(@"NSVisualEffectView");
        if (vibrantClass)
        {
            NSWindow *this = (NSWindow*)self;
            NSVisualEffectView *vibrant=[[vibrantClass alloc] initWithFrame:[[this contentView] bounds]];
            [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
            [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
            [vibrant setIdentifier:@"cView"];
            bool addzest = true;
            for (NSView *aVeiw in this.contentView.subviews)
            {
                if ([[aVeiw identifier] isEqualToString:@"cView"])
                    addzest = false;
            }
            if (addzest)
            {
                NSLog(@"Adding blur to %@", self);
                [[this contentView] addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
            }
        }
    }
}
//-(void)

@end

