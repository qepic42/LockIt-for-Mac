//
//  LockScreenView.h
//  LockIt for Mac
//
//  Created by Q on 14.10.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

@interface LockScreenView : NSObject {

    
    IBOutlet NSWindow *mainWindow;
    IBOutlet NSTextField *currentTime;
	IBOutlet NSTextField *lockDeviceSloagen;
    IBOutlet NSTextField *countdownLabel;
	NSWindow *fullscreenWindow;
    NSTimer *clockTimer; 
	NSTimer *lockDelayTimer;
}

-(void)showWindow;
-(void)tick:(NSTimer *)theTimer;
-(void)startTimer;
-(IBAction)toggelFullscreen:(id)sender;
-(void)leaveFullscreen;
-(void)enterFullscreen:(NSTimer *)timer;
-(void)setupEnterMode:(NSNotification *)notification;
-(void)setupLeaveMode;

@end

