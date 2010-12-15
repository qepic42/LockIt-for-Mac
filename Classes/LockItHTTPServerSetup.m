//
//  LockItHTTPServerSetup.m
//  LockIt for Mac
//
//  Created by Q on 01.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LockItHTTPServerSetup.h"
#import "HTTPServer.h"
#import "LockItHTTPConnection.h"

@implementation LockItHTTPServerSetup

- (void)startWebServer{
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

@end
