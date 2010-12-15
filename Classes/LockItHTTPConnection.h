//
//  LockItHTTPConnection.h
//  LockIt for Mac
//
//  Created by Q on 03.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HTTPConnection.h"
#import "DataModel.h"

@interface LockItHTTPConnection : HTTPConnection {
    
    NSString *commandString;
    NSString *lockDelayString;
    NSString *lockedUUID;
    NSString *hostUUID;
    BOOL macIsLocked;
    
    DataModel *dataModel;

}

@property (nonatomic,retain)NSString *commandString;
@property (nonatomic,retain)NSString *lockDelayString;
@property (nonatomic,retain)NSString *lockedUUID;
@property (nonatomic,retain)NSString *hostUUID;
@property BOOL macIsLocked;

-(NSString *)setHostUUID;
-(void)sendCommands:(NSNotification *)notification;

@end
