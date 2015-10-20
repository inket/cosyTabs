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

#pragma mark - Controlling tab width

#pragma mark Safari 9+

- (unsigned long long)new_visibleTabIndexAtPoint:(struct CGPoint)point
                                  stackingRegion:(unsigned long long *)arg2
               ignorePointsOutsideOfLayoutBounds:(BOOL)arg3 {
    unsigned long long originalResult = [self new_visibleTabIndexAtPoint:point
                                                          stackingRegion:arg2
                                       ignorePointsOutsideOfLayoutBounds:arg3];
    
    if (originalResult == 0)
    {
        BOOL pinnedTabsNonExistent = (NSInteger)[self performSelector:@selector(_numberOfPinnedTabsForLayout)] == 0;
        BOOL singleTab = (NSInteger)[self performSelector:@selector(_numberOfTabsForLayout)] == 1;
        
        if (pinnedTabsNonExistent && singleTab && point.x > MAX_TAB_WIDTH)
        {
            return LONG_LONG_MAX; // ULONG_LONG_MAX -> Crash!
        }
    }

    return originalResult;
}

- (void)new_setButtonWidthForTitleLayout:(double)arg1 animated:(BOOL)arg2 {
    if (arg1 > MAX_TAB_WIDTH) arg1 = MAX_TAB_WIDTH;
    
    [self new_setButtonWidthForTitleLayout:arg1 animated:arg2];
}

#pragma mark Safari 8+

- (void)new_trackMouseEventsForEvent:(NSEvent*)datEvent onTabAtIndex:(NSInteger)tabIndex {
    // Capture click events in the tab bar
    
    if ([datEvent clickCount] == 2)
    {
        if (tabIndex == 0)
        {
            NSView* v = (NSView*)self;
            
            for (NSView* view in [v subviews]) {
                if ([view isKindOfClass:[NSClassFromString(@"ScrollableTabBarViewButton") class]])
                {
                    NSView* previousView = [[v subviews] objectAtIndex:[[v subviews] indexOfObject:view]-1];
                    NSPoint windowLocation = [datEvent locationInWindow];
                    NSPoint viewLocation = [previousView convertPoint:windowLocation fromView:nil];
                    if (NSPointInRect(viewLocation, [previousView bounds]))
                    {
                        NSButton* newTabButton = (NSButton*)view;
                        [[NSClassFromString(@"NSApplication") sharedApplication] sendAction:newTabButton.action to:newTabButton.target from:newTabButton];
                        return;
                    }
                    
                    break;
                }
            }
        }
        else
        {
            @try {
                [self new_trackMouseEventsForEvent:datEvent onTabAtIndex:tabIndex];
            }
            @catch (NSException *exception) {
                if ([[exception name] isEqualToString:NSRangeException])
                {
                    NSView* v = (NSView*)self;
                    
                    for (NSView* view in [v subviews]) {
                        if ([view isKindOfClass:[NSClassFromString(@"ScrollableTabBarViewButton") class]])
                        {
                            NSButton* newTabButton = (NSButton*)view;
                            [[NSClassFromString(@"NSApplication") sharedApplication] sendAction:newTabButton.action to:newTabButton.target from:newTabButton];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    @try {
        [self new_trackMouseEventsForEvent:datEvent onTabAtIndex:tabIndex];
    }
    @catch (NSException *exception) {
        if (![[exception name] isEqualToString:NSRangeException])
        {
            @throw exception;
        }
    }
}

- (CGFloat)new_buttonWidthForNumberOfButtons:(NSInteger)n inWidth:(CGFloat)w remainderWidth:(CGFloat)rw {
    NSInteger x = [self new_buttonWidthForNumberOfButtons:n inWidth:w remainderWidth:rw];
    if (x > MAX_TAB_WIDTH) return MAX_TAB_WIDTH;
    return x;
}

- (BOOL)new_shouldLayOutButtonsToAlignWithWindowCenter {
    return NO;
}

#pragma mark Safari 7 <=

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

#pragma mark - Controlling tab title margins

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
    NSButtonCell* tabCell = [(NSButton*)self cell];
    [(NSButton*)self addSubview:closeButton positioned:NSWindowAbove relativeTo:(NSView*)tabCell];
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
    BOOL safari9 = [cosyTabs isSafari9];
    BOOL safari8 = [cosyTabs isSafari8];
    
    if (safari8 || safari9)
    {
        Class class = NSClassFromString(safari9 ? @"TabBarView" : @"ScrollableTabBarView");
        
        Method new = class_getInstanceMethod(class, @selector(new_buttonWidthForNumberOfButtons:inWidth:remainderWidth:));
        Method old = class_getInstanceMethod(class, @selector(_buttonWidthForNumberOfButtons:inWidth:remainderWidth:));
        method_exchangeImplementations(new, old);
        
        new = class_getInstanceMethod(class, @selector(new_shouldLayOutButtonsToAlignWithWindowCenter));
        old = class_getInstanceMethod(class, @selector(_shouldLayOutButtonsToAlignWithWindowCenter));
        method_exchangeImplementations(new, old);
        
        if (safari9)
        {
            new = class_getInstanceMethod(class, @selector(new_visibleTabIndexAtPoint:stackingRegion:ignorePointsOutsideOfLayoutBounds:));
            old = class_getInstanceMethod(class, @selector(_visibleTabIndexAtPoint:stackingRegion:ignorePointsOutsideOfLayoutBounds:));
            method_exchangeImplementations(new, old);
            
            class = NSClassFromString(@"TabButton");
            new = class_getInstanceMethod(class, @selector(new_setButtonWidthForTitleLayout:animated:));
            old = class_getInstanceMethod(class, @selector(setButtonWidthForTitleLayout:animated:));
            method_exchangeImplementations(new, old);
        }
        else
        {
            new = class_getInstanceMethod(class, @selector(new_trackMouseEventsForEvent:onTabAtIndex:));
            old = class_getInstanceMethod(class, @selector(_trackMouseEventsForEvent:onTabAtIndex:));
            method_exchangeImplementations(new, old);
        }
    }
    else // Safari 7
    {
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
    }
    
    // Resize already-open tabs, surrounded by a try-catch as a precaution. Thanks to @gbroochian for the suggestion.
    @try {
        for (NSWindow* window in [[NSClassFromString(@"NSApplication") sharedApplication] windows])
        {
            if ([window isKindOfClass:NSClassFromString(@"BrowserWindow")])
            {
                if (safari9)
                {
                    id tabBarView = [[window windowController] performSelector:@selector(tabBarView)];
                    [tabBarView performSelector:@selector(layout)];
                }
                else
                {
                    NSArray *orderedTabViewItems = [window performSelector:@selector(orderedTabViewItems)];
                    id firstTabBarViewItem = [orderedTabViewItems firstObject];
                    
                    // Safari 8
                    if ([firstTabBarViewItem respondsToSelector:@selector(scrollableTabBarView)])
                    {
                        id scrollableTabBarView = [firstTabBarViewItem performSelector:@selector(scrollableTabBarView)];
                        [scrollableTabBarView performSelector:@selector(tabViewDidChangeNumberOfTabViewItems:) withObject:nil];
                    }
                    // Safari 7<=
                    else if ([firstTabBarViewItem respondsToSelector:@selector(tabBarView)])
                    {
                        id tabBarView = [firstTabBarViewItem performSelector:@selector(tabBarView)];
                        [tabBarView performSelector:@selector(refreshButtons)];
                    }
                }

            }
        }
    }
    @catch (NSException* exception) {
        NSLog(@"Caught cosyTabs exception: %@", exception);
    }
}

+ (BOOL)isSafari9 {
    NSBundle* bundle = NSBundle.mainBundle;
    if ([bundle respondsToSelector:@selector(shortVersion)])
    {
        NSString* version = [bundle performSelector:@selector(shortVersion)];
        return [version hasPrefix:@"9."];
    }
    
    return NO;
}

+ (BOOL)isSafari8 {
    return NSClassFromString(@"ScrollableTabBarView") != nil;
}

@end
