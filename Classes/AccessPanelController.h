//
//  WindowController.h
//  LockIt for Mac
//
//  Created by Q on 03.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LockIt_for_MacAppDelegate.h"

@class LockIt_for_MacAppDelegate;

@interface AccessPanelController : NSWindowController {
    IBOutlet NSPanel *requestWindow;
    IBOutlet id requestWindowLabel;
	IBOutlet NSTextField *lockLabel;
    IBOutlet NSWindow *mainWindow;
    
    IBOutlet NSWindow *window;
    CALayer *mainLayer;
    
    NSString *deviceName;
    NSString *deviceHostname;
    NSString *deviceUUID;
    NSNumber *devicePort;
    NSNumber *deviceLockDelay;
    NSWindow *transparentWindow;
    NSString *uuid;
	
	LockIt_for_MacAppDelegate *appDelegate;
	NSWindow *lockWindow;
}
- (void)displayRequestPanel:(NSNotification *)notification;
-(NSString *)setHostUUID;

- (IBAction)requestWindowPushAllow:(id)sender;
- (IBAction)requestWindowPushDeny:(id)sender;

-(IBAction)toggelFullscreen:(id)sender;

@property (nonatomic,retain)NSString *deviceName;
@property (nonatomic,retain)NSString *deviceHostname;
@property (nonatomic,retain)NSString *deviceUUID;
@property (nonatomic,retain)NSNumber *devicePort;
@property (nonatomic,retain)NSNumber *deviceLockDelay;
@property (nonatomic,retain)NSString *uuid;


@end
