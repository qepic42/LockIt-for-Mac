//
//  LockIt_for_MacAppDelegate.h
//  LockIt for Mac
//
//  Created by Q on 25.09.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkService.h"
#import "HTTPServer.h"
#import "LockItHTTPConnection.h"
#import "LockScreenView.h"
#import "DataModel.h"
#import "PreferencesModel.h"
#import "LockState.h"

@class HTTPServer, AccessPanelController;

@interface LockIt_for_MacAppDelegate : NSObject  {

	NetworkService *netService;
	AccessPanelController *windowCtrl;
	LockItHTTPConnection *lockItCon;
	LockScreenView *lockScreen;
	DataModel *dataModel;
	HTTPServer *httpServer;
    LockState *lockState;
    PreferencesModel *prefModel;
    
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end

