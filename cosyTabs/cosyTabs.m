//
//  cosyTabs.m
//  cosyTabs
//
//  Created by inket on 19/07/2012.
//  Copyright (c) 2012 inket. Licensed under GNU GPL v3.0. See LICENSE for details.
//

#import "cosyTabs.h"

#define MAX_TAB_WIDTH 250 // Maximum tab width in Safari 5 is 250px, amirite?

// Change these values to control the tab title margins
#define TAB_TITLE_LEFT_MARGIN NSIntegerMax
#define TAB_TITLE_RIGHT_MARGIN NSIntegerMax

static cosyTabs* plugin = nil;

@implementation NSObject (cosyTabs)

#pragma mark Controlling tab width

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

#pragma mark Controlling tab title margins

- (void)new__updateTitleTextFieldFrame {
    [self new__updateTitleTextFieldFrame];
    
    NSTextField* titleTextField = [self valueForKey:@"titleTextField"];

    if ([[titleTextField attributedStringValue] size].width+15 > MAX_TAB_WIDTH)
    {
        // Title is going to be truncated, let's just make it as wide as possible while using the custom margins

        NSRect currentFrame = [titleTextField frame];

        // Selected tabs are drawn wider than regular ones; Take that into account
        CGFloat addedRightMargin = [(NSButton*)self state] == NSOnState ? 4 : 0;
        CGFloat addedLeftMargin = [(NSButton*)self state] == NSOnState ? 6 : 0;
        
        // Get the needed margin values
        CGFloat leftMargin = TAB_TITLE_LEFT_MARGIN != NSIntegerMax ? TAB_TITLE_LEFT_MARGIN + addedLeftMargin : currentFrame.origin.x;
        CGFloat originalRightMargin = [[titleTextField superview] frame].size.width - (currentFrame.size.width - currentFrame.origin.x);
        CGFloat rightMargin = TAB_TITLE_RIGHT_MARGIN != NSIntegerMax ? TAB_TITLE_RIGHT_MARGIN + addedRightMargin : originalRightMargin;
        
        // Resize the textfield
        CGFloat newWidth = [[titleTextField superview] frame].size.width - leftMargin - rightMargin;
        [titleTextField setFrame:NSMakeRect(leftMargin, currentFrame.origin.y, newWidth, currentFrame.size.height)];
    }
    
    
    // Move the Close button to the top of the hierarchy so it can be clicked
    NSButton* closeButton = [self valueForKey:@"closeButton"];
    NSButton* tabCell = [(NSButton*)self cell];
    [(NSButton*)self addSubview:closeButton positioned:NSWindowAbove relativeTo:tabCell];
}

- (void)new_setState:(id)arg1 {
    [self new_setState:arg1];

    if ([self respondsToSelector:@selector(_updateTitleTextFieldFrame)])
        [self performSelector:@selector(_updateTitleTextFieldFrame) withObject:nil];
}

- (void)new_setTitle:(id)arg1 {
    [self new_setTitle:arg1];

    if ([self respondsToSelector:@selector(_updateTitleTextFieldFrame)])
        [self performSelector:@selector(_updateTitleTextFieldFrame) withObject:nil];
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
    
    if (TAB_TITLE_LEFT_MARGIN != NSIntegerMax || TAB_TITLE_RIGHT_MARGIN != NSIntegerMax)
    {
        class = NSClassFromString(@"AttachedTabButton");
        new = class_getInstanceMethod(class, @selector(new__updateTitleTextFieldFrame));
        old = class_getInstanceMethod(class, @selector(_updateTitleTextFieldFrame));
        method_exchangeImplementations(new, old);
        
        new = class_getInstanceMethod(class, @selector(new_setState:));
        old = class_getInstanceMethod(class, @selector(setState:));
        method_exchangeImplementations(new, old);
        
        new = class_getInstanceMethod(class, @selector(new_setTitle:));
        old = class_getInstanceMethod(class, @selector(setTitle:));
        method_exchangeImplementations(new, old);
    }
    
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
