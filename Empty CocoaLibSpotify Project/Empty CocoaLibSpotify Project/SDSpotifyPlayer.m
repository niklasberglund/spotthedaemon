//
//  SDSpotify.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/7/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDSpotifyPlayer.h"

#include "appkey.c"

#define SP_LIBSPOTIFY_DEBUG_LOGGING 0


@implementation SDSpotifyPlayer

- (id)init
{
    self = [super init];
    
    if (self) {
        NSString *userAgent = [[[NSBundle mainBundle] infoDictionary] valueForKey:(__bridge NSString *)kCFBundleIdentifierKey];
        NSData *appKey = [NSData dataWithBytes:&g_appkey length:g_appkey_size];
        
        NSError *error = nil;
        [SPSession initializeSharedSessionWithApplicationKey:appKey
                                                   userAgent:userAgent
                                               loadingPolicy:SPAsyncLoadingManual
                                                       error:&error];
        if (error != nil) {
            NSLog(@"CocoaLibSpotify init failed: %@", error);
            abort();
        }
        
        [[SPSession sharedSession] setDelegate:self];
    }
    
    return self;
}


+ (SDSpotifyPlayer *)sharedPlayer
{
    static SDSpotifyPlayer *singletonInstance = nil;
    
    if (singletonInstance == nil) {
        singletonInstance = [[SDSpotifyPlayer alloc] init];
    }
    
    return singletonInstance;
}

#pragma mark -
#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession {
	// Called after a successful login.
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
	// Called after a failed login.
    [NSApp presentError:error
         modalForWindow:self.window
               delegate:nil
     didPresentSelector:nil
            contextInfo:nil];
}

-(void)sessionDidLogOut:(SPSession *)aSession; {
	// Called after a logout has been completed.
}

-(void)session:(SPSession *)aSession didGenerateLoginCredentials:(NSString *)credential forUserName:(NSString *)userName {
    
	// Called when login credentials are created. If you want to save user logins, uncomment the code below.
    
	/*
	 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	 NSMutableDictionary *storedCredentials = [[defaults valueForKey:@"SpotifyUsers"] mutableCopy];
     
	 if (storedCredentials == nil)
	 storedCredentials = [NSMutableDictionary dictionary];
     
	 [storedCredentials setValue:credential forKey:userName];
	 [defaults setValue:storedCredentials forKey:@"SpotifyUsers"];
	 */
}

-(void)session:(SPSession *)aSession didEncounterNetworkError:(NSError *)error; {
	if (SP_LIBSPOTIFY_DEBUG_LOGGING != 0)
		NSLog(@"CocoaLS NETWORK ERROR: %@", error);
}

-(void)session:(SPSession *)aSession didLogMessage:(NSString *)aMessage; {
	if (SP_LIBSPOTIFY_DEBUG_LOGGING != 0)
		NSLog(@"CocoaLS DEBUG: %@", aMessage);
}

-(void)sessionDidChangeMetadata:(SPSession *)aSession; {
	// Called when metadata has been updated somewhere in the
	// CocoaLibSpotify object model. You don't normally need to do
	// anything here. KVO on the metadata you're interested in instead.
}

-(void)session:(SPSession *)aSession recievedMessageForUser:(NSString *)aMessage; {
	// Called when the Spotify service wants to relay a piece of information to the user.
	[[NSAlert alertWithMessageText:aMessage
					 defaultButton:@"OK"
				   alternateButton:@""
					   otherButton:@""
		 informativeTextWithFormat:@"This message was sent to you from the Spotify service."] runModal];
}

@end
