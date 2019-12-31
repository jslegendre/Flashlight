//
//  SPOpenAPIResult.m
//  SpotlightSIMBL
//
//  Created by Nate Parrott on 11/2/14.
//  Copyright (c) 2014 Nate Parrott. All rights reserved.
//

#import "ZKSwizzle.h"
#import "SPOpenAPIResult.h"
#import "SFText.h"
#import "SPPreviewController.h"
#import "SPGroupHeadingResult.h"
#import <WebKit/WebKit.h>
#import "_Flashlight_Bootstrap.h"
#import <FlashlightKit/FlashlightKit.h>
#import <FlashlightKit/FlashlightIconResolution.h>
#import <objc/runtime.h>


/*
 a wrapper around objc zeroing weak references, since we can't store zeroing weak references as associated objects.
 */
@interface _Flashlight_WeakRefWrapper : NSObject

@property (nonatomic,weak) id target;
@property (nonatomic) id strongTarget;

@end

@implementation _Flashlight_WeakRefWrapper @end

@interface _SPOpenAPIResult : NSObject
@end

_Flashlight_WeakRefWrapper* __SS_SSOpenAPIResult_getCustomPreviewReference(_SPOpenAPIResult *self) {
    _Flashlight_WeakRefWrapper *ref = objc_getAssociatedObject(self, @selector(customPreviewController));
    if (!ref) {
        ref = [_Flashlight_WeakRefWrapper new];
        objc_setAssociatedObject(self, @selector(customPreviewController), ref, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return ref;
}

@interface _SPOpenAPIResult (Compile)
- (void)setTitle:(id)str;
- (FlashlightResult *)resultAssociatedObject;
@end

@implementation _SPOpenAPIResult

- (id)initWithQuery:(NSString *)query result:(FlashlightResult *)result {
    Class superclass = NSClassFromString(@"SPGroupHeadingResult");
    void (*superIMP)(id, SEL, NSString*, id, NSString*) = (void *)[superclass instanceMethodForSelector: @selector(initWithDisplayName:keyID:focusString:)];
    superIMP(self, _cmd, result.title, nil, result.title);
    [self setTitle:[SFText textWithString:result.title]];
    objc_setAssociatedObject(self, @selector(resultAssociatedObject), result, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return self;
}

- (BOOL)shouldNotBeTopHit {
    FlashlightResult *result = objc_getAssociatedObject(self, @selector(resultAssociatedObject));
    return [result.json[@"dont_force_top_hit"] boolValue];
}

- (unsigned long long)rank {
    FlashlightResult *result = objc_getAssociatedObject(self, @selector(resultAssociatedObject));
    if ([result.json[@"dont_force_top_hit"] boolValue]) {
        return 1;
    } else {
        return 0xffffffffffffffff; // for top hit
    }
}

- (NSString *)category {
    return @"MENU_EXPRESSION";
}

- (NSImage *)iconImage {
    FlashlightResult *result = objc_getAssociatedObject(self, @selector(resultAssociatedObject));
    NSImage *icon = [FlashlightIconResolution iconForPluginAtPath:result.pluginPath];
    return icon;
}

- (SPPreviewController *)sharedCustomPreviewController {
    _Flashlight_WeakRefWrapper *vcRef = __SS_SSOpenAPIResult_getCustomPreviewReference(self);
    SPPreviewController *vc = vcRef.strongTarget;
    if (vc) {
        return vc;
    } else {
        Class cls = NSClassFromString(@"SPPreviewController") ? : NSClassFromString(@"PRSPreviewController");
        vc = [[cls alloc] initWithNibName:@"SPOpenAPIPreviewViewController" bundle:[NSBundle bundleWithIdentifier:@"com.nateparrott.SpotlightSIMBL"]];
        FlashlightResultView *resultView = (id)[(id)vc view];
        FlashlightResult *result = objc_getAssociatedObject(self, @selector(resultAssociatedObject));
        resultView.result = result;
        vcRef.strongTarget = vc;
        return vc;
    }
}

- (BOOL)openWithSearchString:(id)arg1 block:(void (^)(void))block {
    FlashlightResult *result = objc_getAssociatedObject(self, @selector(resultAssociatedObject));
    
    SPPreviewController *previewVC = [self sharedCustomPreviewController];
    FlashlightResultView *resultsView = (id)previewVC.view;
    
    return [result pressEnter:resultsView errorCallback:^(NSString *error) {
        
    }];
}

@end

Class __SS_SPOpenAPIResultClass() {
    Class c = NSClassFromString(@"SPOpenAPIResult");
    if (c) return c;

    c = objc_allocateClassPair(ZKClass(SPMetadataResult), "SPOpenAPIResult", 0);
    objc_registerClassPair(c);
    
    ZKSwizzle(_SPOpenAPIResult, SPOpenAPIResult);
    
    return c;
}
