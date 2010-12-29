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
        self.macIsLocked = NO;
        [self addAllNotificationObersers];
    }
    return self;
}


// Save data to NSUserDefaults
-(void)saveData:(NSNotification *)notification{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[[notification userInfo]objectForKey:@"saveObject"] forKey:[[notification userInfo]objectForKey:@"saveString"]];
    [prefs synchronize];
}

// Send LockSate by NSNotification
-(void)getLockState:(NSNotification *)notification{
    NSDictionary *mergedDicts = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:self.macIsLocked], @"lockState", [notification userInfo], @"deviceInfoDict",nil];
    
    NSNotificationCenter * center;
    center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"lockState"
                          object:self
                        userInfo:mergedDicts];
}

// Change LockState by NSNotification
-(void)changeLockState:(NSNotification *)notification{
    self.macIsLocked = [[[notification userInfo]objectForKey:@"lockState"] boolValue];
}

// Add NSNotificationObservers
-(void)addAllNotificationObersers{
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveData:)
                                                 name:@"saveData"
                                               object:nil];
}

- (void)dealloc {
    
    [super dealloc];
}

@end
