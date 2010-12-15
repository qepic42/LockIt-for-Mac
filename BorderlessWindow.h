#import <Cocoa/Cocoa.h>


@interface BorderlessWindow : NSWindow {

}

- (id) initWithContentRect: (NSRect) contentRect
                 styleMask: (unsigned int) aStyle
                   backing: (NSBackingStoreType) bufferingType
                     defer: (BOOL) flag;


@end
