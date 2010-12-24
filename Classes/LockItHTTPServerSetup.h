//
//  LockItHTTPServerSetup.h
//  LockIt for Mac
//
//  Created by Q on 01.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPServer;
@interface LockItHTTPServerSetup : NSObject {
	HTTPServer *httpServer;
}

-(void)startWebServer;

@end
