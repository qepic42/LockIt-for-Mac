#import "BorderlessWindow.h"

@implementation BorderlessWindow

- (id) initWithContentRect: (NSRect) contentRect
                 styleMask: (unsigned int) aStyle
                   backing: (NSBackingStoreType) bufferingType
                     defer: (BOOL) flag
{
    if (![super initWithContentRect: contentRect styleMask: NSBorderlessWindowMask backing: bufferingType defer: flag]) return nil;
	[self setBackgroundColor: [NSColor clearColor]];
	[self setOpaque:NO];
    
    return self;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

@end
