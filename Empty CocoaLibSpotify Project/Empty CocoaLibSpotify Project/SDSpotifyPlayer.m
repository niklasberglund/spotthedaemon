//
//  SDSpotify.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/7/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDSpotifyPlayer.h"
#import "SDCommandResponseRecorder.h"
#import "SDResponse.h"

#include "appkey.c"

#define SP_LIBSPOTIFY_DEBUG_LOGGING 0


@implementation SDSpotifyPlayer

- (id)init
{
    self = [super init];
    
    if (self) {
        self.spotifySession = [SPSession sharedSession];
        
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
        
        [SPAsyncLoading waitUntilLoaded:[SPSession sharedSession] timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
            self.playbackManager = [[SPPlaybackManager alloc] initWithPlaybackSession:[SPSession sharedSession]];
            
            NSLog(@"loaded SPSession");
        }];
        
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


- (void)loginUser:(NSString *)username password:(NSString *)password
{
    [[SPSession sharedSession] attemptLoginWithUserName:username password:password];
}


- (void)logout
{
    [[SPSession sharedSession] logout:^{
        SDResponse *response = [SDResponse responseWithMessage:@"Logged out" success:YES];
        
        [[SDCommandResponseRecorder sharedCommandResponseRecorder] recordResponse:response forCommandString:@"logout"];
    }];
}


- (void)playTrack:(NSURL *)trackUrl
{
    [[SPSession sharedSession] trackForURL:trackUrl callback:^(SPTrack *track) {
        if (track != nil) {
            [SPAsyncLoading waitUntilLoaded:track timeout:60.0 then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
                NSLog(@"loadedItems: %@", loadedItems);
                NSLog(@"notLoadedItems: %@", notLoadedItems);
                NSLog(@"isLoaded: %@", [track isLoaded] ? @"YES" : @"NO");
                
                [self.playbackManager playTrack:track callback:^(NSError *error) {
                    NSLog(@"Error with playback: %@", error);
                }];
            }];
        }
        else {
            // error
        }
    }];
}


- (void)pause
{
    [SPSession sharedSession].playing = NO;
}


- (void)createPlaylistWithName:(NSString *)name callback:(void (^)(SPPlaylist *))block
{
    SPPlaylistContainer *playlistContainer = [[SPSession sharedSession] userPlaylists];
    
    [SPAsyncLoading waitUntilLoaded:playlistContainer timeout:60.0 then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
        [playlistContainer createPlaylistWithName:name callback:^(SPPlaylist *createdPlaylist) {
            block(createdPlaylist);
        }];
    }];
}


- (BOOL)isLoggedOn
{
    if ([[SPSession sharedSession] user] == nil) {
        return NO;
    }
    else {
        return YES;
    }
}


- (BOOL)isPlaying
{
    return [[SPSession sharedSession] isPlaying];
}


- (SDUser *)currentUser
{
    SPUser *spUser = [[SPSession sharedSession] user];
    return [[SDUser alloc] initWithObject:spUser];
}


#pragma mark -
#pragma mark SPSessionDelegate Methods

-(void)sessionDidLoginSuccessfully:(SPSession *)aSession {
	// Called after a successful login.
    
    SDResponse *response = [SDResponse responseWithMessage:@"Login successful" success:YES];
    [[SDCommandResponseRecorder sharedCommandResponseRecorder] recordResponse:response forCommandString:@"login"];
}

-(void)session:(SPSession *)aSession didFailToLoginWithError:(NSError *)error {
	// Called after a failed login.
    NSLog(@"ERROR: Login failed with error: %@", error);
    
    NSDictionary *responseData = @{ @"error" : [error localizedDescription] };
    SDResponse *response = [SDResponse responseWithMessage:@"Login failed" success:NO data:responseData];
    [[SDCommandResponseRecorder sharedCommandResponseRecorder] recordResponse:response forCommandString:@"login"];
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
