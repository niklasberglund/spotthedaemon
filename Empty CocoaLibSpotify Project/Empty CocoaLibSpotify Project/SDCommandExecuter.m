//
//  SDCommandExecuter.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/29/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDCommandExecuter.h"
#import "SDSpotifyPlayer.h"
#import "SDCommandResponseRecorder.h"

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
    
    if ([command.commandString isEqualToString:@"login"]) {
        [self executeLoginCommandFromSocket:socket commandObject:command];
    }
    else if ([command.commandString isEqualToString:@"status"]) {
        [self executeStatusCommandFromSocket:socket];
    }
    else if ([command.commandString isEqualToString:@"logout"]) {
        [self executeLogoutCommandFromSocket:socket commandObject:command];
    }
    else if ([command.commandString isEqualToString:@"play"]) {
        [self executePlayCommandFromSocket:socket command:command];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}


- (void)executeLoginCommandFromSocket:(GCDAsyncSocket *)socket commandObject:(SDCommand *)command
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


- (void)executeLogoutCommandFromSocket:(GCDAsyncSocket *)socket commandObject:(SDCommand *)command
{
    [[SDCommandResponseRecorder sharedCommandResponseRecorder] registerCommand:command];
    [[SDCommandResponseRecorder sharedCommandResponseRecorder] onResponseForCommand:command callBlock:^(NSData *response) {
        [socket writeData:response withTimeout:60.0 tag:0];
        [socket disconnectAfterWriting];
    }];
    
    [[SDSpotifyPlayer sharedPlayer] logout];
}


- (void)executeStatusCommandFromSocket:(GCDAsyncSocket *)socket
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
    NSString *trackString = [[command arguments] objectAtIndex:0];
    NSLog(@"'%@'", trackString);
    NSURL *trackUrl = [NSURL URLWithString:trackString];
    [[SDSpotifyPlayer sharedPlayer] playTrack:trackUrl];
}

@end
