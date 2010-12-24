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
@synthesize dataArray, response, devInfoDict, searchArray, uuid, lastCommand;

// Init this class
- (id)init {
    if ((self = [super init])) {
        
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(sendCommand:)
													 name:@"returnTargetDict"
												   object:nil]; 
        
    }
    
    return self;
}

// Get the UUID of current process and make it able for http
-(NSString *)setHostUUID{
    NSString *cache = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *string = [cache stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    return string;
}

// Send own UUI by NSNotification
-(void)sendUUID:(NSNotification *)notification{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:self.uuid forKey:@"uuid"];
   
    NSNotificationCenter * center;
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"recieveUUID"
                          object:self
                        userInfo:dict];
}

// Receive any http-request to clients by NSNotifications and send the 'get data by UUID' notification
-(void)receivingCommand:(NSNotification *)notification{
    NSString *command = [[notification userInfo] objectForKey:@"command"];
    NSString *deviceUUID = [[notification userInfo] objectForKey:@"uuid"];
    
    self.lastCommand = command;
    NSLog(@"lastCommand: %@",command);
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys: deviceUUID, @"uuid", nil];
    
    NSNotificationCenter * center;
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"getDeviceFromUUID"
                          object:self
                        userInfo:dict];
    
}

// Send any http-request to clients command from here in order to minimize errors
-(void)sendCommand:(NSNotification *)notification{
    NSString *deviceHostname = [[notification userInfo] objectForKey:@"deviceHostname"];
    NSNumber *devicePort = [[notification userInfo] objectForKey:@"devicePort"];
    NSLog(@"lastCommand: %@",self.lastCommand);
    NSString *urlString = [NSString stringWithFormat:@"http://%@:%i/%@/%@", deviceHostname, [devicePort integerValue],self.uuid,self.lastCommand];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

// Add device when in bonjour range to dataArray
- (void)addDevice:(NSNotification *)notification{
    NSDictionary *deviceInfoDict = [notification userInfo];
    [self.dataArray addObject:deviceInfoDict];
}

// Remove Device when out of bonjour range from dataArray
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
    
    // DOESNT WORK: CRASH!
 //   [self.dataArray removeObjectAtIndex:position];
    
}

// Send all data from dataArray with NSNotification
-(void)sendAllClients:(NSNotification *)notification{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dataArray, @"dataArray",nil];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"sendAllClients"
                          object:self
                        userInfo:dict];
}

// Send dict with data of an entry of the dataArray which matches the given UUID
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

// Release memory
- (void)dealloc {
    [lastCommand release];
    [uuid release];
    [connection release];
    [devInfoDict release];
    [searchArray release];
    [response release];
    [dataArray release];
    [super dealloc];
}

@end
