//
//  DataModel.m
//  LockIt for Mac
//
//  Created by Q on 13.11.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "DataModel.h"
#import "LockItHTTPConnection.h"

@implementation DataModel
@synthesize dataArray, response, devInfoDict, searchArray, uuid;


- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        self.dataArray = [[NSMutableArray alloc]init];
        
        self.uuid = [self setHostUUID];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addDevice:)
                                                     name:@"addDevice"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeDevice:)
                                                     name:@"removeDevice"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(getDeviceFromUUID:)
                                                     name:@"getDeviceFromUUID"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sendAllClients:)
                                                     name:@"getAllClients"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(sendUUID:)
													 name:@"getUUID"
												   object:nil]; 
        
    }
    
    return self;
}

-(NSString *)setHostUUID{
    NSString *cache = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *string = [cache stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    return string;
}

-(void)sendUUID:(NSNotification *)notification{
     NSLog(@"Data- UUID: %@",self.uuid);
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.uuid forKey:@"uuid"];
   
    NSNotificationCenter * center;
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"broadcastUUID"
                          object:self
                        userInfo:dict];
}


- (void)addDevice:(NSNotification *)notification{
    
    NSDictionary *deviceInfoDict = [notification userInfo];
    
    [self.dataArray addObject:deviceInfoDict];
    
}

-(void)removeDevice:(NSNotification *)notification{
    
    NSDictionary *deviceInfoDict = [notification userInfo];
    
    NSDictionary *currentDict = [[NSDictionary alloc]init];
    
    NSInteger position = 0;
    
    for(currentDict in self.dataArray){
        
        if([[currentDict objectForKey:@"deviceName"] isEqualTo:[deviceInfoDict objectForKey:@"deviceName"]]){
            position = [self.dataArray indexOfObject:currentDict];
            
            break;
        }
        
        
    }
    
 //   [self.dataArray removeObjectAtIndex:position];
    
}

-(void)sendAllClients:(NSNotification *)notification{
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dataArray, @"dataArray",nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"sendAllClients"
                          object:self
                        userInfo:dict];
    
}


- (void)getDeviceFromUUID:(NSNotification *)notification{ 

    NSString *UUID =  [[notification userInfo] valueForKey:@"uuid"];
    
    devInfoDict = [[NSDictionary alloc]init];
    
    NSDictionary *currentDict = [[NSDictionary alloc]init];
    
    for(currentDict in self.dataArray){
        
        NSString *deviceName = [currentDict objectForKey:@"deviceName"];
        NSString *deviceHostName = [currentDict objectForKey:@"deviceHostname"];
        NSString *deviceUUID = [currentDict objectForKey:@"deviceUUID"];
        NSNumber *devicePort = [currentDict objectForKey:@"devicePort"];
        NSNumber *deviceStartLockTime = [currentDict objectForKey:@"deviceStartLockTime"];
        
        if([deviceUUID isEqualToString:UUID]){
            devInfoDict = [NSDictionary dictionaryWithObjectsAndKeys:deviceName, @"deviceName", deviceHostName, @"deviceHostname", devicePort, @"devicePort", deviceUUID, @"deviceUUID", deviceStartLockTime, @"deviceStartLockTime", nil];
            
            break;
            
        }else{
            NSLog(@"UUIDs: \n%@\n%@",deviceUUID, UUID);
            continue;
            
        }
        
    }
    
    [[LockItHTTPConnection alloc]init];
    
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"returnTargetDict"
                          object:self
                        userInfo:devInfoDict];
    
    [currentDict retain];
    
}


- (void)dealloc {
    // Clean-up code here.
    
    [uuid release];
    [connection release];
    [devInfoDict release];
    [searchArray release];
    [response release];
    [dataArray release];
    [super dealloc];
}

@end
