//
//  TestPlugin.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/1/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

@import AppKit;
#import "ZKSwizzle.h"
#import "_Flashlight_Bootstrap.h"
#import "_FlashlightPluginEngine.h"

#pragma mark - Swizzles
#pragma mark - SPSearchPanel

ZKSwizzleInterface(_SPSearchPanel, SPSearchPanel, NSPanel)
@implementation _SPSearchPanel

- (void)collapse {
    [_FlashlightPluginEngine shared].spotlightWantsCollapsed = YES;
    if ([[_FlashlightPluginEngine shared] shouldBeCollapsed]) {
        ZKOrig(void);
    }
}

- (void)expand {
    [_FlashlightPluginEngine shared].spotlightWantsCollapsed = NO;
    if (![[_FlashlightPluginEngine shared] shouldBeCollapsed]) {
        ZKOrig(void);
    }
}

@end

#pragma mark - SPAppDelegate

@protocol FLQuery
- (NSString *)userQueryString;
@end

ZKSwizzleInterface(_SPAppDelegate, SPAppDelegate, NSObject)
@implementation _SPAppDelegate

- (void)setQuery:(id<FLQuery>)query {
    [[_FlashlightPluginEngine shared] setQuery:[query userQueryString]];
    ZKOrig(void, query);
}

@end

#pragma mark - SPResultViewController

hook(SPResultViewController, HighSierra)
- (NSArray *) results {
    return [[_FlashlightPluginEngine shared] mergeFlashlightResultsWithSpotlightResults:ZKOrig(NSArray *)];
}
endhook

hook(SPResultViewController, Sierra)
- (void)setResults:(NSArray *)results {
    ZKOrig(void, [[_FlashlightPluginEngine shared] mergeFlashlightResultsWithSpotlightResults:results]);
}
endhook

ctor {
    (floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_12) ? ZKSwizzleGroup(Sierra) : ZKSwizzleGroup(HighSierra);
}

#pragma mark - _Flashlight_Bootstrap

@implementation _Flashlight_Bootstrap

+ (void)load {
    NSLog(@"Hello from Flashlight! (%@)", [[NSBundle bundleWithIdentifier:@"com.nateparrott.SpotlightSIMBL"] bundlePath]);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_FlashlightPluginEngine shared]; // initialize the engine, including creating the plugins directory
    });
}

@end
