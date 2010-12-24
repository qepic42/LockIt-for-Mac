//
//  GrowlImplementation.m
//  LockIt for Mac
//
//  Created by Q on 24.12.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "GrowlImplementation.h"
#import "Growl/GrowlApplicationBridge.h"

@implementation GrowlImplementation

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
    
    return self;
}


// Class method to send a notification by Growl
+(void)sendGrowlNotifications:(NSString *)title: (NSString *)description: (NSString *)notificationName: (NSString *)imagePath{
    
    if ([imagePath isEqualToString: @""]){
        NSLog(@"No image available");
         
        [GrowlApplicationBridge notifyWithTitle:title
                                    description:description
                               notificationName:notificationName
                                       iconData:nil
                                       priority:1
                                       isSticky:NO
                                   clickContext:nil]; 
        
    }else{
        NSImage *icon = [NSImage imageNamed:imagePath];
        NSData *data = icon.TIFFRepresentation;
        
        [GrowlApplicationBridge notifyWithTitle:title
                                    description:description
                               notificationName:notificationName
                                       iconData:data
                                       priority:1
                                       isSticky:NO
                                   clickContext:nil]; 
    }
    
}

// Growl implementation methods
- (NSDictionary*) registrationDictionaryForGrowl{
    
    NSArray* defaults = 
    [NSArray arrayWithObjects:@"Connect/Disconnect notifications",@"General notifications",@"HTTP-Request notifications", nil];
    
    NSArray* all = 
    [NSArray arrayWithObjects:@"Connect/Disconnect notifications",@"General notifications", nil];
    
    NSDictionary* growlRegDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  defaults, GROWL_NOTIFICATIONS_DEFAULT,all,
                                  GROWL_NOTIFICATIONS_ALL, nil];
    
    return growlRegDict;
}

- (NSImage*)applicationIconForGrowl{
    NSString* imageName =
    [[NSBundle mainBundle]pathForResource:@"Extra Bonjour" ofType:@"png"];
	
    NSImage* tempImage = 
    [[[NSImage alloc] initWithContentsOfFile:imageName]autorelease];
    return tempImage;
}


- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

@end
