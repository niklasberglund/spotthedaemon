//
//  AppDelegate.m
//  Empty CocoaLibSpotify Project
//
//  Created by Daniel Kennett on 02/08/2012.
/*
 Copyright (c) 2011, Spotify AB
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Spotify AB nor the names of its contributors may
 be used to endorse or promote products derived from this software
 without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL SPOTIFY AB BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
 OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 This project is a simple project that does nothing but set up a basic CocoaLibSpotify
 application. This can be used to quickly get started with a new project that uses CocoaLibSpotify.
 */

#import "AppDelegate.h"
#import <CocoaLibSpotify/CocoaLibSpotify.h>


@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self->spotifyPlayer = [SDSpotifyPlayer sharedPlayer];
    self->commandServer = [[SDCommandServer alloc] init];
    [self->commandServer start];
    
    self->settingsViewController = [[SDSettingsWindowController alloc] initWithWindowNibName:@"SDSettingsWindowController"];
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	// When quitting, you should logout and wait for logout completion before terminating.
	/*if ([SPSession sharedSession].connectionState == SP_CONNECTION_STATE_LOGGED_OUT ||
		[SPSession sharedSession].connectionState == SP_CONNECTION_STATE_UNDEFINED)
		return NSTerminateNow;

	[[SPSession sharedSession] logout:^{
		[[NSApplication sharedApplication] replyToApplicationShouldTerminate:YES];
	}];*/
	return NSTerminateLater;
}

- (void)awakeFromNib
{
    // set up status item and it's menu
    self->statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self->statusItem.title = @"S";
    self->statusItem.menu = self.statusMenu;
    self->statusItem.highlightMode = YES;
}

#pragma mark -
#pragma mark Status menu actions

- (IBAction)displaySettings:(id)sender {
    [self->settingsViewController showWindow:nil];
}

- (IBAction)quitApplication:(id)sender {
    [NSApp terminate:self];
}

@end
