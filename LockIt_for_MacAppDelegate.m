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
        NSLog(@"manueller Start");
	}
	return self;
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"Klassen mit alloc&init starten…");
	dataModel = [[DataModel alloc]init];
    NSLog(@"DataModel: fertig…");
    windowCtrl = [[AccessPanelController alloc]init];
    NSLog(@"AccessPanelController: fertig…");
    prefModel = [[PreferencesModel alloc]init];
    NSLog(@"PreferencesModel: fertig…");
    lockState = [[LockState alloc]init];
    NSLog(@"LockState: fertig…");
	netService = [[NetworkService alloc]init];
    NSLog(@"NetworkService: fertig…");
	httpServer = [[HTTPServer alloc] init];
    NSLog(@"HTTPServer: fertig…");
	[httpServer setType:@"_lockitmac._tcp."];
    NSLog(@"Alles: fertig");
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

