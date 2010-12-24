//
//  GrowlImplementation.h
//  LockIt for Mac
//
//  Created by Q on 24.12.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Growl/GrowlApplicationBridge.h"

@interface GrowlImplementation : NSObject<GrowlApplicationBridgeDelegate>  {

}

+(void)sendGrowlNotifications:(NSString *)title: (NSString *)description: (NSString *)notificationName: (NSString *)imagePath;

@end
