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
#import "LockItHTTPServerSetup.h"
#import "GrowlImplementation.h"

@implementation LockIt_for_MacAppDelegate

@synthesize window;

- (id) init
{
	self = [super init];
	if (self != nil) {
        growl = [[GrowlImplementation alloc]init];
		dataModel = [[DataModel alloc]init];
        windowCtrl = [[AccessPanelController alloc]init];
        prefModel = [[PreferencesModel alloc]init];
        lockState = [[LockState alloc]init];
        netService = [[NetworkService alloc]init];
        lockItCon = [[LockItHTTPConnection alloc]init];
        setupServerClass = [[LockItHTTPServerSetup alloc]init];
        [setupServerClass startWebServer];
        
        [GrowlImplementation sendGrowlNotifications:@"LockIt" :@"LockIt for Mac started" :@"General notifications":@""];
	}
	return self;
}

- (void) dealloc
{
    [growl release];
    [lockItCon release];
    [setupServerClass release]; 
    [prefModel release];
    [lockState release];
	[windowCtrl release];
	[dataModel release];
	[netService release];
	[httpServer release];
	[super dealloc];
}


@end

