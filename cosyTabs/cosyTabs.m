//
//  cosyTabs.m
//  cosyTabs
//
//  Created by inket on 19/07/2012.
//  Copyright (c) 2012 inket. Licensed under GNU GPL v3.0. See LICENSE for details.
//

#import "cosyTabs.h"
#define MAX_TAB_WIDTH 250 // Maximum tab width in Safari 5 is 250px, amirite?

static cosyTabs* plugin = nil;

@implementation NSObject (cosyTabs)

- (double)new_availableWidthForButtonsWhenUnclipped {
    unsigned long long numberOfTabs = (unsigned long long)[self performSelector:@selector(numberOfTabs)];
    
    double defaultAvailableWidth = [self new_availableWidthForButtonsWhenUnclipped];
    double customAvailableWidth = (double)(MAX_TAB_WIDTH*numberOfTabs);

    if (defaultAvailableWidth <= customAvailableWidth)
        return defaultAvailableWidth;
    
    return customAvailableWidth;
}

- (void)new_tabViewDidChangeNumberOfTabViewItems:(id)arg1 {
    [self new_tabViewDidChangeNumberOfTabViewItems:arg1];
    
    [self performSelector:@selector(refreshButtons)];
}

@end


@implementation cosyTabs

#pragma mark SIMBL methods and loading

+ (cosyTabs*)sharedInstance {
	if (plugin == nil)
		plugin = [[cosyTabs alloc] init];
	
	return plugin;
}

+ (void)load {
	[[cosyTabs sharedInstance] loadPlugin];
	NSLog(@"cosyTabs loaded.");
}

- (void)loadPlugin {
	Class class = NSClassFromString(@"TabBarView");
    
    Method new = class_getInstanceMethod(class, @selector(new_availableWidthForButtonsWhenUnclipped));
    Method old = class_getInstanceMethod(class, @selector(_availableWidthForButtonsWhenUnclipped));
    method_exchangeImplementations(new, old);
    
    new = class_getInstanceMethod(class, @selector(new_tabViewDidChangeNumberOfTabViewItems:));
    old = class_getInstanceMethod(class, @selector(tabViewDidChangeNumberOfTabViewItems:));
    method_exchangeImplementations(new, old);
    
    // Resize already-open tabs, surrounded by a try-catch as a precaution. Thanks to @gbroochian for the suggestion.
    @try {
        for (NSWindow* window in [[NSClassFromString(@"NSApplication") sharedApplication] windows])
        {
            if ([window isKindOfClass:NSClassFromString(@"BrowserWindow")])
            {
                NSArray *orderedTabViewItems = [window performSelector:@selector(orderedTabViewItems)];
                [[[orderedTabViewItems firstObject] performSelector:@selector(tabBarView)] performSelector:@selector(refreshButtons)];
            }
        }
    }
    @catch (NSException* exception) {
        NSLog(@"Caught cosyTabs exception: %@", exception);
    }
}

@end
