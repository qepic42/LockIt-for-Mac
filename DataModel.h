//
//  DataModel.h
//  LockIt for Mac
//
//  Created by Q on 13.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@interface DataModel : NSObject {
    NSMutableArray *dataArray;
    NSMutableArray *searchArray;
    NSMutableData *response;
    NSDictionary *devInfoDict;
    NSString *uuid;
    NSURLConnection *connection;
    NSString *lastCommand;
    
}

@property (nonatomic,retain) NSString *uuid;
@property (nonatomic,retain) NSMutableData *response;
@property (nonatomic,retain) NSMutableArray *dataArray;
@property (nonatomic,retain) NSMutableArray *searchArray;
@property (nonatomic,retain) NSDictionary *devInfoDict;
@property (nonatomic,retain) NSString *lastCommand;

-(void)addDevice:(NSNotification *)notification;
-(void)removeDevice:(NSNotification *)notification;
-(void)getDeviceFromUUID:(NSNotification *)notification;
-(NSString *)setHostUUID;
-(void)sendUUID:(NSNotification *)notification;
-(void)receivingCommand:(NSNotification *)notification;
-(void)sendCommand:(NSNotification *)notification;

@end
