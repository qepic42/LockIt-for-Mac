//
//  LockState.h
//  LockIt for Mac
//
//  Created by Q on 04.12.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface LockState : NSObject {
@private
    
    BOOL macIsLocked;
    int hostUUID;
    
	NSString *UUID;
	
    NSString *deviceName;
    NSString *deviceHostname;
    NSString *deviceUUID;
    NSNumber *devicePort;
    NSNumber *deviceLockDelay;
    
}

@property int hostUUID;
@property BOOL macIsLocked;
@property (nonatomic,retain)NSString *UUID;
@property (nonatomic,retain)NSString *deviceName;
@property (nonatomic,retain)NSString *deviceHostname;
@property (nonatomic,retain)NSString *deviceUUID;
@property (nonatomic,retain)NSNumber *devicePort;
@property (nonatomic,retain)NSNumber *deviceLockDelay;

-(NSString *)setHostUUID;
-(void)getLockState:(NSNotification *)notification;
-(void)setLockState:(NSNotification *)notification;
-(void)sendLockState:(NSNotification *)notification;

@end
