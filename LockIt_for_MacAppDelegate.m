//
//  LockIt_for_MacAppDelegate.m
//  LockIt for Mac
//
//  Created by Q on 25.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LockIt_for_MacAppDelegate.h"
#import "NetworkService.h"
#import "AccessPanelController.h"
#import "HTTPServer.h"
#import "LockItHTTPConnection.h"
#import "LockScreenView.h"
#import "DataModel.h"
#import "LockState.h"
#import "PreferencesModel.h"

@implementation LockIt_for_MacAppDelegate

@synthesize window;

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self applicationDidFinishLaunching:nil];
	}
	return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
	dataModel = [[DataModel alloc]init];
    windowCtrl = [[AccessPanelController alloc]init];
    prefModel = [[PreferencesModel alloc]init];
    lockState = [[LockState alloc]init];
	netService = [[NetworkService alloc]init];
	httpServer = [[HTTPServer alloc] init];
	[httpServer setType:@"_lockitmac._tcp."];
	[httpServer setConnectionClass:[LockItHTTPConnection class]];
	NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
	[httpServer setDocumentRoot:[NSURL fileURLWithPath:webPath]];
    
	NSError *error;
	BOOL success = [httpServer start:&error];
	
	if(!success)
	{
		NSLog(@"Error starting HTTP Server: %@", error);
	} 
    
}

- (void) dealloc
{
    [prefModel release];
    [lockState release];
	[windowCtrl release];
	[dataModel release];
	[netService release];
	[httpServer release];
	[super dealloc];
}


@end

