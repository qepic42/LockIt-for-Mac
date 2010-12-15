//
//  PreferencesModel.h
//  LockIt for Mac
//
//  Created by Q on 04.12.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PreferencesModel : NSObject {
@private
    BOOL macIsLocked;
}

@property BOOL macIsLocked;

-(void)getLockState:(NSNotification *)notification;
-(void)changeLockState:(NSNotification *)notification;

@end
