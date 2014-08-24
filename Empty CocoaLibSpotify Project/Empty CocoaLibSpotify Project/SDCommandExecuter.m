//
//  SDCommandExecuter.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/29/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDCommandExecuter.h"
#import "SDSpotDaDaemon.h"
#import "SDSpotifyPlayer.h"
#import "SDCommandResponseRecorder.h"
#import "SDCommandServer.h"

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

@implementation SDCommandExecuter

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    
    if (self) {
        self.delegate = delegate;
    }
    
    return self;
}


+ (SDCommandExecuter *)commandExecuterWithDelegate:(id)delegate
{
    return [[SDCommandExecuter alloc] initWithDelegate:delegate];
}


- (void)executeCommand:(SDCommand *)command fromSocket:(GCDAsyncSocket *)socket
{
    // delegate is required
    if (!self.delegate) {
        [NSException raise:@"Missing delegate" format:@"Missing delegate. A delegate is required"];
        return;
    }
    
    NSLog(@"Executing command %@", command);
    
    NSString *selectorString = [NSString stringWithFormat:@"execute%@CommandFromSocket:command:", [command.commandString capitalizedString]];
    
    SEL executeCommandSelector = NSSelectorFromString(selectorString);
    if ([self respondsToSelector:executeCommandSelector]) {
        [self performSelector:executeCommandSelector withObject:socket withObject:command];
    }
    else {
        DDLogError(@"No such command for selector %@", selectorString);
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}


- (void)executeLoginCommandFromSocket:(GCDAsyncSocket *)socket command:(SDCommand *)command
{
    [[SDCommandResponseRecorder sharedCommandResponseRecorder] registerCommand:command];
    [[SDCommandResponseRecorder sharedCommandResponseRecorder] onResponseForCommand:command callBlock:^(NSData *response) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishedExecutingCommand:withResponse:)]) {
            [self.delegate finishedExecutingCommand:command withResponse:response];
        }
        else {
            
        }
    }];
    
    NSString *username = [command.arguments objectAtIndex:0];
    NSString *password = [command.arguments objectAtIndex:1];
    [[SDSpotifyPlayer sharedPlayer] loginUser:username password:password];
}


- (void)executeLogoutCommandFromSocket:(GCDAsyncSocket *)socket command:(SDCommand *)command
{
    [[SDCommandResponseRecorder sharedCommandResponseRecorder] registerCommand:command];
    [[SDCommandResponseRecorder sharedCommandResponseRecorder] onResponseForCommand:command callBlock:^(NSData *response) {
        [socket writeData:response withTimeout:60.0 tag:0];
        [socket disconnectAfterWriting];
    }];
    
    [[SDSpotifyPlayer sharedPlayer] logout];
}


- (void)executeStatusCommandFromSocket:(GCDAsyncSocket *)socket command:(SDCommand *)command
{
    NSMutableDictionary *responseDataDict = [[NSMutableDictionary alloc] init];
    
    sp_connectionstate connectionState = [[SPSession sharedSession] connectionState];
    NSString *connectionStateString;
    
    switch (connectionState) {
        case SP_CONNECTION_STATE_LOGGED_OUT:
            connectionStateString = @"Logged out";
            break;
        
        case SP_CONNECTION_STATE_LOGGED_IN:
            connectionStateString = @"Logged in";
            break;
        
        case SP_CONNECTION_STATE_OFFLINE:
            connectionStateString = @"Offline but logged in";
            break;
        
        case SP_CONNECTION_STATE_DISCONNECTED:
            connectionStateString = @"Was logged in, but now disconnected";
            break;
        
        case SP_CONNECTION_STATE_UNDEFINED:
            connectionStateString = @"Undefined state";
            break;
            
        default:
            break;
    }
    
    
    [responseDataDict setObject:[NSNumber numberWithInt:connectionState] forKey:@"connection_state_identifier"];
    SDResponse *response = [SDResponse responseWithMessage:connectionStateString success:nil data:responseDataDict];
    
    [socket writeData:[response json] withTimeout:60.0 tag:0];
    [socket disconnectAfterWriting];
}


- (void)executePlayCommandFromSocket:(GCDAsyncSocket *)socket command:(SDCommand *)command
{
    if ([[SDSpotifyPlayer sharedPlayer] isLoggedOn] == NO) {
        SDResponse *response = [SDResponse responseWithMessage:@"Not logged on" success:NO];
        [SDCommandServer writeResponse:response onSocket:socket];
        return;
    }
    
    if ([[SDSpotifyPlayer sharedPlayer] isPlaying] == YES) {
        SDResponse *response = [SDResponse responseWithMessage:@"Already playing" success:NO];
        [SDCommandServer writeResponse:response onSocket:socket];
        return;
    }
    
    [SPSession sharedSession].playing = YES;
    SDResponse *response = [SDResponse responseWithMessage:@"Playing" success:YES];
    [SDCommandServer writeResponse:response onSocket:socket];
}


- (void)executeTrackCommandFromSocket:(GCDAsyncSocket *)socket command:(SDCommand *)command
{
    NSString *subcommand = [command.arguments objectAtIndex:0];
    
    if ([subcommand isEqualToString:@"play"]) {
        NSString *trackString = [[command arguments] objectAtIndex:1];
        NSLog(@"'%@'", trackString);
        NSURL *trackUrl = [NSURL URLWithString:trackString];
        [[SDSpotifyPlayer sharedPlayer] playTrack:trackUrl];
    }
}


- (void)executePlaylistCommandForSocket:(GCDAsyncSocket *)socket command:(SDCommand *)command
{
    NSString *subcommand = [command.arguments objectAtIndex:0];
    
    if ([subcommand isEqualToString:@"create"]) {
        NSString *name = [command.arguments objectAtIndex:1];
        
        [[SDSpotifyPlayer sharedPlayer] createPlaylistWithName:name callback:^(SPPlaylist *playlist) {
            NSLog(@"created playlist %@", playlist);
        }];
    }
}


- (void)executePauseCommandFromSocket:(GCDAsyncSocket *)socket command:(SDCommand *)command
{
    if ([[SDSpotifyPlayer sharedPlayer] isLoggedOn] == NO) {
        SDResponse *response = [SDResponse responseWithMessage:@"Not logged on" success:NO];
        [SDCommandServer writeResponse:response onSocket:socket];
        return;
    }
    
    if ([[SDSpotifyPlayer sharedPlayer] isPlaying] == NO) {
        SDResponse *response = [SDResponse responseWithMessage:@"Not playing anything" success:NO];
        [SDCommandServer writeResponse:response onSocket:socket];
        return;
    }
    
    [[SDSpotifyPlayer sharedPlayer] pause];
    SDResponse *response = [SDResponse responseWithMessage:@"Paused playback" success:YES];
    [SDCommandServer writeResponse:response onSocket:socket];
}


- (void)executeUserCommandFromSocket:(GCDAsyncSocket *)socket command:(SDCommand *)command
{
    if (command.arguments.count == 0) {
        SDUser *currentUser = [[SDSpotifyPlayer sharedPlayer] currentUser];
        
        [SPAsyncLoading waitUntilLoaded:currentUser timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
            if ([loadedItems containsObject:currentUser]) { // success
                NSDictionary *dataDict = @{
                                           @"display_name" : currentUser.name,
                                           @"username" : currentUser.userName
                                           };
                
                SDResponse *response = [SDResponse responseWithMessage:@"Current user info" success:YES data:dataDict];
                [SDCommandServer writeResponse:response onSocket:socket];
            }
            else { // fail
                SDResponse *response = [SDResponse responseWithMessage:@"Failed to load user info" success:NO];
                [SDCommandServer writeResponse:response onSocket:socket];
            }
        }];
        NSLog(@"%@", currentUser);
    }
    else {
        
    }
}

@end
