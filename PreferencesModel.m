//
//  PreferencesModel.m
//  LockIt for Mac
//
//  Created by Q on 04.12.10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "PreferencesModel.h"


@implementation PreferencesModel
@synthesize macIsLocked;

- (id)init {
    if ((self = [super init])) {
        // Initialization code here.
        self.macIsLocked = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(changeLockState:)
													 name:@"changeLockState"
												   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(getLockState:)
													 name:@"getLockState"
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(changeLockState:)
													 name:@"lockScreen"
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(changeLockState:)
													 name:@"unlockScreen"
												   object:nil];
    }
    
    return self;
}

-(void)getLockState:(NSNotification *)notification{
    
    NSDictionary *mergedDicts = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:self.macIsLocked], @"lockState", [notification userInfo], @"deviceInfoDict",nil];
    
    NSNotificationCenter * center;
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"lockState"
                          object:self
                        userInfo:mergedDicts];
    
}

-(void)changeLockState:(NSNotification *)notification{
    self.macIsLocked = [[[notification userInfo]objectForKey:@"lockState"] boolValue];
    
}

- (void)dealloc {
    // Clean-up code here.
    
    [super dealloc];
}

@end
