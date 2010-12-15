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
@synthesize commandString, lockDelayString, lockedUUID, hostUUID, macIsLocked;

- (id)init {
    if ((self = [super init])) {
        
        self.hostUUID = [self setHostUUID];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(sendCommands:)
													 name:@"returnTargetDict"
												   object:nil];
    }
    return self;
}

-(NSString *)setHostUUID{
    NSTask *getUUID;
	getUUID = [[NSTask alloc] init];
	[getUUID setLaunchPath: [[NSBundle mainBundle] pathForResource:@"getUUID" ofType:@"sh"]];
	
	NSPipe *pipe;
	pipe = [NSPipe pipe];
	[getUUID setStandardOutput: pipe];
	
	NSFileHandle *file;
	file = [pipe fileHandleForReading];
	
	[getUUID launch];
	
	NSData *data;
	data = [file readDataToEndOfFile];
	
	NSString *cache;
	cache = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    NSString *string = [cache stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    return string;
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
	
    self.hostUUID = [self setHostUUID];
    
    NSString *error = nil;
	HTTPDataResponse* response = nil;
	
	NSString *command = [path substringFromIndex:1];
    NSArray *listItems = [path componentsSeparatedByString:@"/"];
    NSString *uuid = [listItems objectAtIndex:1];
    
    self.commandString = command;
    self.lockDelayString = [listItems objectAtIndex:2];
    
    NSLog(@"Command: %@",self.commandString);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:command 
																   forKey:@"command"];
    
    NSRange isLocked = [self.commandString  rangeOfString:@"identify"];
    if  (isLocked.location != NSNotFound){
        
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        self.macIsLocked = [prefs boolForKey:@"lockState"];
        
     //   NSLog(@"BOOL = %d", (int)self.macIsLocked);
        
        [dict setObject:[NSNumber numberWithBool:self.macIsLocked] forKey:@"lockState"];
        [dict setObject:self.hostUUID
				 forKey:@"uuid"];
        
    }else{
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setObject:self.commandString forKey:@"command"];
        [prefs setObject:self.lockDelayString forKey:@"lockDelayString"];
        [prefs synchronize];
        
        NSDictionary *uuidDict = [NSDictionary dictionaryWithObject:uuid forKey:@"uuid"];
        
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
//    if ([[notification userInfo] count] == 0){
//        NSLog(@"Non bonjour client alert!!");
//    }else{
        
        
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
        
        
//    }
    
    
}



- (void)dealloc {
    [hostUUID release];
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
