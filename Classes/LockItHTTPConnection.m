//
//  LockItHTTPConnection.m
//  LockIt for Mac
//
//  Created by Q on 03.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LockItHTTPConnection.h"
#import "HTTPResponse.h"
#import "DDNumber.h"
#import "AccessPanelController.h"
#import "NetworkService.h"
#import "DataModel.h"
@implementation LockItHTTPConnection
@synthesize commandString, lockDelayString, lockedUUID, uuid, macIsLocked;

- (id)init {
    if ((self = [super init])) {        
        NSLog(@"LockItHTTPConnection: init");
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(sendCommands:)
													 name:@"returnTargetDict"
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setHostUUID:)
													 name:@"broadcastUUID"
												   object:nil]; 
        [self getHostUUID];
    }
    return self;
}


-(void)setHostUUID:(NSNotification *)notification{
    self.uuid = [[notification userInfo]objectForKey:@"uuid"];
}

-(void)getHostUUID{
    NSNotificationCenter * center;
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"getUUID"
                          object:self];
}

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	// Add support for POST
	
	if([method isEqualToString:@"POST"])
	{
		if([path isEqualToString:@"/post.html"])
		{
			// Let's be extra cautious, and make sure the upload isn't 5 gigs
			
			BOOL result = NO;
			
			CFStringRef contentLengthStr = CFHTTPMessageCopyHeaderFieldValue(request, CFSTR("Content-Length"));
			
			UInt64 contentLength;
			if([NSNumber parseString:(NSString *)contentLengthStr intoUInt64:&contentLength])
			{
				result = contentLength < 50;
			}
			
			if(contentLengthStr) CFRelease(contentLengthStr);
			return result;
		}
	}
	
	return [super supportsMethod:method atPath:path];
}

/**
 * Overrides HTTPConnection's method
 **/
- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)relativePath
{
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:relativePath];
}

/**
 * Overrides HTTPConnection's method
 **/
- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendCommands:)
                                                 name:@"returnTargetDict"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setHostUUID:)
                                                 name:@"recieveUUID"
                                               object:nil]; 
    
    while (self.uuid == 0){
//        NSLog(@"LockItHTTPConnection: UUID is still 0! %@",self.uuid);
      [self getHostUUID];  
    }
    NSLog(@"LockItHTTPConnection: UUID: %@",self.uuid);
    
    NSString *error = nil;
	HTTPDataResponse* response = nil;
	
	NSString *command = [path substringFromIndex:1];
    NSArray *listItems = [path componentsSeparatedByString:@"/"];
    NSString *clientUUID = [listItems objectAtIndex:2];
    
    self.commandString = command;
    self.lockDelayString = [listItems objectAtIndex:2];
    
    NSLog(@"LockItHTTPConnection: Command: %@",self.commandString);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:command 
																   forKey:@"command"];
    
    NSRange isLocked = [self.commandString  rangeOfString:@"identify"];
    if  (isLocked.location != NSNotFound){
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        self.macIsLocked = [prefs boolForKey:@"lockState"];
        
        if (self.macIsLocked == 0){
            NSLog(@"LockItHTTPConnection: Mac is not locked");
        }else{
            NSLog(@"LockItHTTPConnection: Mac is locked!!");
        }
        
        [dict setObject:[NSNumber numberWithBool:self.macIsLocked] forKey:@"lockState"];
        [dict setObject:self.uuid forKey:@"uuid"];
        
    }else{
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.commandString forKey:@"command"];
        [prefs setObject:self.lockDelayString forKey:@"lockDelayString"];
        [prefs synchronize];
        
        NSDictionary *uuidDict = [NSDictionary dictionaryWithObject:clientUUID forKey:@"uuid"];
        
        NSNotificationCenter * center;
        center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"getDeviceFromUUID"
                              object:self
                            userInfo:uuidDict];

    }
    
	NSData* data = [NSPropertyListSerialization dataFromPropertyList:dict
															  format:NSPropertyListXMLFormat_v1_0
													errorDescription:&error];
	
	if (error) {
		NSLog(@"%@", error);
		[error release]; // see documentation for this!
	} else {
		response = [[[HTTPDataResponse alloc] initWithData:data] autorelease];
	}
    
	return response;
}


- (void)sendCommands:(NSNotification *)notification{
    
    // Get device Infos from notification
    NSDictionary *deviceInfoDict = [notification userInfo];
    
    // Get prefs
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.commandString = [prefs stringForKey:@"command"];
    self.lockDelayString = [prefs stringForKey:@"lockDelayString"];
    self.macIsLocked = [prefs boolForKey:@"lockState"];
    
    NSLog(@"Command: %@",self.commandString);
    
    // Check for hacks
    if ([[notification userInfo] count] == 0){
        NSLog(@"Non bonjour client alert!!");
    }else{
        
        
        // Lock Command
        NSRange lockCommand = [self.commandString  rangeOfString:@"lock"];
        if  (lockCommand.location != NSNotFound){
            
            NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init]autorelease];
            NSNumber *lockDelay = [formatter numberFromString:self.lockDelayString];
            
            NSDictionary *mergedDicts = [NSDictionary dictionaryWithObjectsAndKeys:lockDelay, @"lockDelay", deviceInfoDict, @"deviceInfoDict", [NSNumber numberWithBool:YES], @"lockState", nil];
            
            self.lockedUUID = [deviceInfoDict objectForKey:@"deviceUUID"];
            
            NSLog(@"lock in: %@min",self.lockDelayString);
            NSNotificationCenter * center;
            center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"lockScreen"
                                  object:self
                                userInfo:mergedDicts];
            
            self.macIsLocked = YES;
            
            [prefs setBool:self.macIsLocked forKey:@"lockState"];
            [prefs synchronize];
            
        }
        
        
        // Access Command
        NSRange accessCommand = [self.commandString  rangeOfString:@"wantAccess"];
        if  (accessCommand.location != NSNotFound){
            
            NSNotificationCenter * center;
            center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"deviceSentRequest"
                                  object:self
                                userInfo:deviceInfoDict];
            
        }
        
        
        // Unlock Command
        NSRange unlockCommand = [self.commandString  rangeOfString:@"release"];
        if  (unlockCommand.location != NSNotFound){
            
            if([self.lockedUUID isEqualToString:[deviceInfoDict objectForKey:@"deviceUUID"]]){
                
                 NSDictionary *mergedDicts = [NSDictionary dictionaryWithObjectsAndKeys:deviceInfoDict, @"deviceInfoDict", [NSNumber numberWithBool:NO], @"lockState", nil];
                
                NSNotificationCenter * center;
                center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:@"unlockScreen"
                                      object:self
                                    userInfo:mergedDicts];
                
                self.macIsLocked = NO;
                
                [prefs setBool:self.macIsLocked forKey:@"lockState"];
                [prefs synchronize];
                
            }else{
                NSLog(@"UUID blocked");
            }
            
            
            
        }
        
        
    }
    
    
}



- (void)dealloc {
    NSLog(@"LockItHTTPConnection: dealloc!");
    [uuid release];
    [lockedUUID release];
    [lockDelayString release];
    [commandString release];
    [super dealloc];
}


/**
 * Overrides HTTPConnection's method
 **/
- (void)processDataChunk:(NSData *)postDataChunk
{
	BOOL result = CFHTTPMessageAppendBytes(request, [postDataChunk bytes], [postDataChunk length]);
	
	if(!result)
	{
		NSLog(@"Couldn't append bytes!");
	}
}

@end
