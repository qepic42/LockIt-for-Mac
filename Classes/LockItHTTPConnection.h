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
    NSString *uuid;
    BOOL macIsLocked;
    
    DataModel *dataModel;

}

@property (nonatomic,retain)NSString *commandString;
@property (nonatomic,retain)NSString *lockDelayString;
@property (nonatomic,retain)NSString *lockedUUID;
@property (nonatomic,retain)NSString *uuid;
@property BOOL macIsLocked;

-(void)sendCommands:(NSNotification *)notification;
//-(void)setHostUUID:(NSNotification *)notification;
//-(void)getHostUUID;
-(NSString *)setHostUUID;

@end
