//
//  LockState.m
//  LockIt for Mac
//
//  Created by Q on 04.12.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "LockState.h"

@implementation LockState
@synthesize deviceName,devicePort,deviceUUID,deviceHostname,deviceLockDelay, macIsLocked, hostUUID, UUID;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        
		self.UUID = [self setHostUUID];
		
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getLockState:)
													 name:@"sendLockState"
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setLockState:)
													 name:@"lockState"
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setLockState:)
													 name:@"lockScreen"
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setLockState:)
													 name:@"unlockScreen"
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(sendLockState:)
													 name:@"sendAllClients"
												   object:nil];
        
    }
    
    return self;
}

-(NSString *)setHostUUID{
   /* NSTask *getUUID;
    getUUID = [[NSTask alloc] init];
    [getUUID setLaunchPath: [[NSBundle mainBundle] pathForResource:@"getUUID" ofType:@"sh"]];
    
    
    //--------------------------->>>
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [getUUID setStandardOutput: pipe];
    //<<<-----------------------------
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [getUUID launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *cache;
    cache = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSString *string = [cache stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    [getUUID terminate];
    [pipe release];
    
    return string;
    
    */
    
    NSString *cache = [[NSProcessInfo processInfo] globallyUniqueString];
    NSString *string = [cache stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    return string;
}

-(void)getLockState:(NSNotification *)notification{
    NSNotificationCenter * center;
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"getLockState"
                          object:self
                        userInfo:[notification userInfo]];
}

-(void)setLockState:(NSNotification *)notification{
    self.macIsLocked = [[[notification userInfo]objectForKey:@"lockState"] boolValue];
    
    NSNotificationCenter * center;
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"getAllClients"
                          object:self
                        userInfo:[[notification userInfo]objectForKey:@"deviceInfoDict"]];
    
}

-(void)sendLockState:(NSNotification *)notification{
    
    NSDictionary *currentDict = [[NSDictionary alloc]init];
    
    for(currentDict in [[notification userInfo]objectForKey:@"dataArray"]){
        
        self.deviceName = [currentDict valueForKey:@"deviceName"];
        self.deviceHostname = [currentDict valueForKey:@"deviceHostname"];
        self.deviceUUID = [currentDict valueForKey:@"deviceUUID"];
        self.deviceLockDelay = [currentDict valueForKey:@"deviceStartLockTime"];
        self.devicePort = [currentDict valueForKey:@"devicePort"];
        
        if (self.macIsLocked == YES){
            NSString *urlString = [NSString stringWithFormat:@"http://%@:%i/%i/isLocked",self.deviceHostname, [self.devicePort integerValue], [self.UUID integerValue]];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
            
            NSLog(@"is locked");
        }else{
            NSString *urlString = [NSString stringWithFormat:@"http://%@:%i/%i/isNotLocked", self.deviceHostname, [self.devicePort integerValue],[self.UUID integerValue]];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
            [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
            
            NSLog(@"is not locked");
        }

        
    }
    
        
    [currentDict release];
}

- (void)dealloc {
    // Clean-up code here.
    
	[UUID release];
	
    [deviceName release];
    [deviceHostname release];
    [deviceUUID release];
    [devicePort release];
    [deviceLockDelay release];
    
    [super dealloc];
}

@end
