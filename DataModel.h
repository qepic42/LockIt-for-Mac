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
    
}

@property (nonatomic, retain) NSString *uuid;
@property (nonatomic, retain) NSMutableData *response;
@property (retain, nonatomic) NSMutableArray *dataArray;
@property (retain,nonatomic) NSMutableArray *searchArray;
@property (retain,nonatomic) NSDictionary *devInfoDict;

-(void)addDevice:(NSNotification *)notification;
-(void)removeDevice:(NSNotification *)notification;
-(void)getDeviceFromUUID:(NSNotification *)notification;
-(NSString *)setHostUUID;
-(void)sendUUID;

@end
