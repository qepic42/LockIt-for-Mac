//
//  LockScreenView.m
//  LockIt for Mac
//
//  Created by Q on 14.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "NetworkService.h"
#import "DataModel.h"
#import "Growl/GrowlApplicationBridge.h"

@implementation NetworkService
@synthesize response, requestWindow, deviceInfo, otherSender, uuid;

- (id) init {
	self = [super init];
	if (self != nil) {
        [self getHostUUID];
		serviceBrowser = [[NSNetServiceBrowser alloc] init];
		[serviceBrowser setDelegate:self];
		[serviceBrowser searchForServicesOfType:@"_lockitiphone._tcp." inDomain:@""];
		self.response = [NSMutableData data];
        
        [GrowlApplicationBridge setGrowlDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setHostUUID)
													 name:@"setUUID"
												   object:nil];
		
	}
	return self;
}

-(void)sendGrowlNotifications:(NSString *)title: (NSString *)dexcription: (NSString *)notificationName{
	
    [GrowlApplicationBridge notifyWithTitle:title
                                description:dexcription
                           notificationName:notificationName
                                   iconData:nil
                                   priority:1
                                   isSticky:NO
                               clickContext:nil]; 
    
}

- (NSDictionary*) registrationDictionaryForGrowl{
    
    NSArray* defaults = 
    [NSArray arrayWithObjects:@"Go on/off", @"Go on/off detail", nil];
    
    NSArray* all = 
    [NSArray arrayWithObjects:@"Go on/off", @"Go on/off detail", nil];
    
    NSDictionary* growlRegDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  defaults, GROWL_NOTIFICATIONS_DEFAULT,all,
                                  GROWL_NOTIFICATIONS_ALL, nil];
    
    return growlRegDict;
}

- (NSImage*) applicationIconForGrowl
{
    NSString* imageName =
    [[NSBundle mainBundle]pathForResource:@"Extra Bonjour" ofType:@"png"];
	
    NSImage* tempImage = 
    [[[NSImage alloc] initWithContentsOfFile:imageName]autorelease];
    return tempImage;
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
 
- (void) dealloc {
    [uuid release];
    [otherSender release];
	[serviceBrowser release];
    [deviceInfo release];
	
	self.response = nil;
    self.requestWindow = nil;

	[super dealloc];
}

// Error handling code
- (void)handleError:(NSNumber *)error {
    NSLog(@"An error occurred. Error code = %d", [error intValue]);
    // Handle error here
}

#pragma mark -
#pragma mark NetServices delegate methods
// Sent when browsing begins
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
	// Show a spinning wheel or something else
}

// Sent when browsing stops
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
	// Stop the spinning wheel
}

// Sent if browsing fails
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
			 didNotSearch:(NSDictionary *)errorDict {
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
}

// Sent when a service appears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
		   didFindService:(NSNetService *)aNetService
			   moreComing:(BOOL)moreComing {
    
//	NSLog(@"Found NetService: %@", [aNetService name]);
	
	NSString *cache1 = [NSString stringWithFormat:@"%@ %@", [aNetService name], @"connected"];
//	NSString *cache2 = [NSString stringWithFormat:@"%@ %@\n%@\n%@", [aNetService name], @"connected", [aNetService hostName], [aNetService port]];
	
	[self sendGrowlNotifications:[aNetService name] :cache1 :@"Go on/off"];
 //   [self sendGrowlNotifications:[aNetService name] :cache2 :@"Go on/off detail"];
	
	[aNetService setDelegate:self];
	[aNetService resolveWithTimeout:2];
	[aNetService retain];
}

// Sent when a service disappears
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser
		 didRemoveService:(NSNetService *)aNetService
			   moreComing:(BOOL)moreComing {
	
	NSString *cache1 = [NSString stringWithFormat:@"%@ %@", [aNetService name], @"disconnected"];
	
	[self sendGrowlNotifications:[aNetService name] :cache1 :@"Go on/off"];
    
//	NSLog(@"Lost  NetService: %@", [aNetService name]);
    
    NSDictionary *devInfo  = [NSDictionary dictionaryWithObjectsAndKeys:[aNetService name], @"deviceName", nil];
    
    NSNotificationCenter * center;
	center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:@"removeDevice"
						  object:self
						userInfo:devInfo];
    
}

// NetService is now ready to be used
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    
    NSString *urlString   = [NSString stringWithFormat:@"http://%@:%i/%@/identify", [sender hostName], [sender port], self.uuid];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    self.otherSender = sender;
	
	}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
    [self handleError:[errorDict objectForKey:NSNetServicesErrorCode]];
    NSLog(@"fail: DID NOT RESOLVE!");
    NSString *cache1 = [NSString stringWithFormat:@"%@\n%@",@"Error to connect to an client",[[errorDict objectForKey:NSNetServicesErrorCode] localizedDescription]] ;
    [self sendGrowlNotifications:@"Error" :cache1 :@"Go on/off"];
	[sender release];
}


#pragma mark -
#pragma mark NSConnection delegate methods

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)urlResponse {
	[self.response setLength:0];
}

- (void)connection:(NSURLConnection *)connection
	didReceiveData:(NSData *)data {
	// Received another block of data. Appending to existing data
    [self.response appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
	// An error occured
    NSLog(@"%@",[error localizedDescription]);
    NSString *cache1 = [NSString stringWithFormat:@"%@\n%@",@"Error to connect to an client",[error localizedDescription]] ;
	NSLog(@"%@",[error localizedDescription]);
	[self sendGrowlNotifications:@"Error" :cache1 :@"Go on/off"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Once this method is invoked, "serverResponse" contains the complete result
	NSPropertyListFormat format;
    
    NSDictionary *dict =  [NSPropertyListSerialization propertyListFromData:self.response mutabilityOption:0 format:&format errorDescription:nil];
    
    NSDictionary *devInfo  = [NSDictionary dictionaryWithObjectsAndKeys:[otherSender name], @"deviceName", [otherSender hostName], @"deviceHostname", [NSNumber numberWithInteger:[otherSender port]], @"devicePort", [dict objectForKey:@"uuid"], @"deviceUUID", nil];
    
    NSNotificationCenter * center;
	center = [NSNotificationCenter defaultCenter];
	[center postNotificationName:@"addDevice"
						  object:self
						userInfo:devInfo];
    
    
}


@end
