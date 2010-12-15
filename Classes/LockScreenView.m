//
//  LockScreenView.m
//  LockIt for Mac
//
//  Created by Q on 14.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


// kUIOptionDisableSessionTerminate, kUIModeContentHidden, kUIModeContentSuppressed, kUIModeAllHidden, kUIOptionDisableProcessSwitch, kUIOptionDisableSessionTerminate

#import "LockScreenView.h"
#import "FullscreenWindow.h"


@implementation LockScreenView


- (id)init {
    if ((self = [super init])) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setupEnterMode:)
													 name:@"lockScreen"
												   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(setupLeaveMode)
													 name:@"unlockScreen"
												   object:nil];
         
    }
    
    return self;
}

-(void)setupEnterMode:(NSNotification *)notification{
	
//	NSLog(@"Enter Fullscreen");
//	[NSMenu setMenuBarVisible:NO];
//	[mainWindow makeKeyAndOrderFront:self];
	
	NSDictionary *deviceInfoDict = [[notification userInfo]objectForKey:@"deviceInfoDict"];
    NSNumber *lockDelay = [[notification userInfo]objectForKey:@"lockDelay"];
	
	NSString *deviceName = [deviceInfoDict objectForKey:@"deviceName"];
	NSString *cache = [NSString stringWithFormat:@"%@ %@",@"waiting for unlock request from",deviceName ];
	
	if (lockDelay == 0) {
		[self enterFullscreen:nil];
		[self startTimer];
		[lockDeviceSloagen setStringValue:cache];
	}else {
		
		int lockDelayInt = [lockDelay intValue];
		lockDelayInt = lockDelayInt*60;
//		NSLog(@"LockDelayInt: %i",lockDelayInt);
		
		lockDelayTimer = [NSTimer scheduledTimerWithTimeInterval:lockDelayInt target:self selector: 
						  @selector(enterFullscreen:) userInfo:nil repeats:NO];
		[self startTimer];
		[lockDeviceSloagen setStringValue:cache];
	}
	
}

	
-(void)setupLeaveMode{
    // HIER KOMMT EIN MERGED DICT AN!
	
//	NSLog(@"Leave Fullscreen");
	
	[self leaveFullscreen];	

	
}


- (void)startTimer{
    
//    NSLog(@"startTimer");
    
    clockTimer = [NSTimer scheduledTimerWithTimeInterval: 1 target:self selector: 
              @selector(tick:) userInfo:nil repeats:YES];
    [clockTimer fire];
    
}

- (void)tick:(NSTimer *)theTimer{
    
    NSCalendarDate *theDate;
    theDate = [NSCalendarDate date];
    
    NSString *time = [theDate descriptionWithCalendarFormat:
                      @"%H:%M:%S"timeZone:nil locale:[[NSUserDefaults standardUserDefaults] 
                                                      dictionaryRepresentation]];
    
    [currentTime setStringValue:time];
    
}

-(void)enterFullscreen:(NSTimer *)timer{
	if (fullscreenWindow){}
	else{
        
        SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableAppleMenu
                        | kUIOptionDisableProcessSwitch
                        | kUIOptionDisableForceQuit);
		
		[mainWindow deminiaturize:nil];
/*		
		if ([[mainWindow screen] isEqual:[[NSScreen screens] objectAtIndex:0]])
		{
			[NSMenu setMenuBarVisible:NO];
		}
*/		
		[NSMenu setMenuBarVisible:NO];
		
		fullscreenWindow = [[FullscreenWindow alloc]
							initWithContentRect:[mainWindow contentRectForFrameRect:[mainWindow frame]]
							styleMask:NSBorderlessWindowMask
							backing:NSBackingStoreBuffered
							defer:YES];
		
		NSView *contentView = [[[mainWindow contentView] retain] autorelease];
		[mainWindow setContentView:[[[NSView alloc] init] autorelease]];
		
		[fullscreenWindow setLevel:NSFloatingWindowLevel];
		[fullscreenWindow setContentView:contentView];
		[fullscreenWindow setTitle:[mainWindow title]];
		[fullscreenWindow makeKeyAndOrderFront:nil];
        
        int windowLevel;
        windowLevel = CGShieldingWindowLevel();
        [fullscreenWindow setLevel:windowLevel];
		
		[fullscreenWindow
		 setFrame:
		 [fullscreenWindow
		  frameRectForContentRect:[[mainWindow screen] frame]]
		 display:YES
		 animate:YES];
		
		[NSMenu setMenuBarVisible:NO];
		
		SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableAppleMenu
                        | kUIOptionDisableProcessSwitch
                        | kUIOptionDisableForceQuit);
		
	}
	
}

-(void)leaveFullscreen{
	
	NSRect newFrame = [fullscreenWindow frameRectForContentRect:
					   [mainWindow contentRectForFrameRect:[mainWindow frame]]];
	[fullscreenWindow
	 setFrame:newFrame
	 display:YES
	 animate:YES];
	
	NSView *contentView = [[[fullscreenWindow contentView] retain] autorelease];
	[fullscreenWindow setContentView:[[[NSView alloc] init] autorelease]];
	
	[mainWindow setContentView:contentView];
	[mainWindow makeKeyAndOrderFront:nil];
	
	[fullscreenWindow close];
	fullscreenWindow = nil;
	
	if ([[mainWindow screen] isEqual:[[NSScreen screens] objectAtIndex:0]])
	{
		[NSMenu setMenuBarVisible:YES];
	}
	[mainWindow orderOut:self];
	
}



-(IBAction)toggelFullscreen:(id)sender{
    if (fullscreenWindow)
	{
		NSRect newFrame = [fullscreenWindow frameRectForContentRect:
                           [mainWindow contentRectForFrameRect:[mainWindow frame]]];
		[fullscreenWindow
         setFrame:newFrame
         display:YES
         animate:YES];
        
		NSView *contentView = [[[fullscreenWindow contentView] retain] autorelease];
		[fullscreenWindow setContentView:[[[NSView alloc] init] autorelease]];
        
		[mainWindow setContentView:contentView];
		[mainWindow makeKeyAndOrderFront:nil];
        
		[fullscreenWindow close];
		fullscreenWindow = nil;
        
		if ([[mainWindow screen] isEqual:[[NSScreen screens] objectAtIndex:0]])
		{
			[NSMenu setMenuBarVisible:YES];
		}
        [mainWindow orderOut:self];
	}
	else
	{
		[mainWindow deminiaturize:nil];
        
		if ([[mainWindow screen] isEqual:[[NSScreen screens] objectAtIndex:0]])
		{
			[NSMenu setMenuBarVisible:NO];
		}
        
        [NSMenu setMenuBarVisible:NO];
		
		fullscreenWindow = [[FullscreenWindow alloc]
                            initWithContentRect:[mainWindow contentRectForFrameRect:[mainWindow frame]]
                            styleMask:NSBorderlessWindowMask
                            backing:NSBackingStoreBuffered
                            defer:YES];
		
		NSView *contentView = [[[mainWindow contentView] retain] autorelease];
		[mainWindow setContentView:[[[NSView alloc] init] autorelease]];
		
		[fullscreenWindow setLevel:NSFloatingWindowLevel];
		[fullscreenWindow setContentView:contentView];
		[fullscreenWindow setTitle:[mainWindow title]];
		[fullscreenWindow makeKeyAndOrderFront:nil];
        
		[fullscreenWindow
         setFrame:
         [fullscreenWindow
          frameRectForContentRect:[[mainWindow screen] frame]]
         display:YES
         animate:YES];
		
//		SetSystemUIMode();
		
		
//		[mainWindow orderOut:nil];
	}
}

-(void)showWindow{
    
    if (fullscreenWindow)
	{
  //      OSStatus SetSystemUIMode(SystemUIMode inMode,SystemUIOptions inOptions);
        
//		OSStatus SetSystemUIMode(SetSystemUIMode kUIModeAllHidden);
        
        
		NSRect newFrame = [fullscreenWindow frameRectForContentRect:
                           [mainWindow contentRectForFrameRect:[mainWindow frame]]];
		[fullscreenWindow
         setFrame:newFrame
         display:YES
         animate:YES];
        
		NSView *contentView = [[[fullscreenWindow contentView] retain] autorelease];
		[fullscreenWindow setContentView:[[[NSView alloc] init] autorelease]];
        
		[mainWindow setContentView:contentView];
        
		[fullscreenWindow close];
		fullscreenWindow = nil;
        
		if ([[mainWindow screen] isEqual:[[NSScreen screens] objectAtIndex:0]])
		{
			[NSMenu setMenuBarVisible:YES];
		}
	}
	else
	{
        
		[mainWindow deminiaturize:nil];
        
		if ([[mainWindow screen] isEqual:[[NSScreen screens] objectAtIndex:0]])
		{
			[NSMenu setMenuBarVisible:NO];
		}
		
		fullscreenWindow = [[FullscreenWindow alloc]
                            initWithContentRect:[mainWindow contentRectForFrameRect:[mainWindow frame]]
                            styleMask:NSBorderlessWindowMask
                            backing:NSBackingStoreBuffered
                            defer:YES];
		
		NSView *contentView = [[[mainWindow contentView] retain] autorelease];
		[mainWindow setContentView:[[[NSView alloc] init] autorelease]];
		
		[fullscreenWindow setLevel:NSFloatingWindowLevel];
		[fullscreenWindow setContentView:contentView];
		[fullscreenWindow setTitle:@"LockIt for Mac"];
		[fullscreenWindow makeKeyAndOrderFront:nil];
        
		[fullscreenWindow
         setFrame:
         [fullscreenWindow
          frameRectForContentRect:[[mainWindow screen] frame]]
         display:YES
         animate:YES];
		
		[mainWindow orderOut:self];
	}

}

@end
