//
//  WindowController.m
//  LockIt for Mac
//
//  Created by Q on 03.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccessPanelController.h"
#import "LockScreenView.h"
#import <QuartzCore/CoreAnimation.h>
#import <ScreenSaver/ScreenSaver.h>

@implementation AccessPanelController
@synthesize deviceName,devicePort,deviceUUID,deviceHostname,deviceLockDelay, uuid;

- (id) init
{
	self = [super init];
	if (self != nil) {
        
        self.uuid = [self setHostUUID];
        NSLog(@"INIT: windowCtrl");
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(displayRequestPanel:)
													 name:@"deviceSentRequest"
												   object:nil];
	}
	return self;
}

- (void)dealloc {
    [uuid release];
    [deviceName release];
    [deviceHostname release];
    [deviceUUID release];
    [devicePort release];
    [deviceLockDelay release];
    [super dealloc];
}

-(NSString *)setHostUUID{
    NSTask *getUUID;
	getUUID = [[NSTask alloc] init];
	[getUUID setLaunchPath: [[NSBundle mainBundle] pathForResource:@"getUUID" ofType:@"sh"]];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[getUUID setStandardOutput: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[getUUID launch];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *cache;
	cache = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSString *string = [cache stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    return string;
}

- (void)displayRequestPanel:(NSNotification *)notification{
    
	[window makeKeyWindow];
	[window orderFront:self];
	[window setAlphaValue:0.1];
	
	[[window contentView] setWantsLayer:YES];
    [window setFrame:[[NSScreen mainScreen] frame] display:NO animate:YES];
    
	NSRect contentFrame = [[window contentView] frame];
    CALayer *root = [[window contentView] layer];
    
    mainLayer = [CALayer layer];
    mainLayer.frame = NSRectToCGRect(contentFrame);
    mainLayer.backgroundColor = CGColorCreateGenericRGB(0.10, 0.10, 0.10, 0.50);
    [root insertSublayer:mainLayer above:0];
	
	
	
    
    int windowLevel;
    NSRect screenRect;
    
    // Capture the main display
//    if (CGDisplayCapture( kCGDirectMainDisplay ) != kCGErrorSuccess) {
 //       NSLog( @"Couldn't capture the main display!" );
        // Note: you'll probably want to display a proper error dialog here
  //  }
    
    // Get the shielding window level
    windowLevel = CGShieldingWindowLevel();
    
    // Get the screen rect of our main display
    screenRect = [[NSScreen mainScreen] frame];
    
	/*
    // Put up a new window
    window = [[NSWindow alloc] initWithContentRect:screenRect
                                             styleMask:NSBorderlessWindowMask
                                               backing:NSBackingStoreBuffered
                                                 defer:NO screen:[NSScreen mainScreen]];
    
    
    [window setLevel:windowLevel];
    
    [window setBackgroundColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.4]];
    [window setOpaque:NO];
    [window setAlphaValue:0.1];
    */
    
	NSSound *mySound = [NSSound soundNamed:@"WantAccessSound"];
    [mySound play];
    
	self.deviceName = [[notification userInfo] valueForKey:@"deviceName"];
    self.deviceHostname = [[notification userInfo] valueForKey:@"deviceHostname"];
    self.deviceUUID = [[notification userInfo] valueForKey:@"deviceUUID"];
    self.deviceLockDelay = [[notification userInfo] valueForKey:@"deviceStartLockTime"];
    self.devicePort = [[notification userInfo]valueForKey:@"devicePort"];
    
    
	NSString *request = [NSString stringWithFormat:@"%@ »%@« %@", @"Device", self.deviceName, @"want to get access of this Mac.\nIf you'll allow it can lock and unlock this Mac everytime."];
	
	[requestWindowLabel setStringValue: request];
    requestWindow.alphaValue = 0.0;
	[requestWindow.animator setAlphaValue:1.0];
    [requestWindow makeKeyAndOrderFront:self];
    [requestWindow setLevel:windowLevel];
    [requestWindow center];
	
}

-(IBAction)toggelFullscreen:(id)sender{
    [window orderOut:nil];
//    [window orderOut:self];
 //   [window makeKeyAndOrderFront:nil];
}

- (IBAction)requestWindowPushAllow:(id)sender {
    
    [window orderOut:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%i/%i/accessAllowed", self.deviceHostname, [self.devicePort integerValue],[self.uuid integerValue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
  
    [requestWindow orderOut:self];
    
}

- (IBAction)requestWindowPushDeny:(id)sender {
    
    [window orderOut:self];
    
    NSString *urlString   = [NSString stringWithFormat:@"http://%@:%i/%i/accessDenyed", self.deviceHostname, [self.devicePort integerValue],[self.uuid integerValue]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
    [requestWindow orderOut:self];
    
}

@end
