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
        [[SDCommandResponseRecorder sharedCommandResponseRecorder] registerCommand:command];
        [[SDCommandResponseRecorder sharedCommandResponseRecorder] onResponseForCommand:command callBlock:^(NSData *response) {
            NSLog(@"GOT RESPONSE");
            NSLog(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
            
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
    else if ([command.commandString isEqualToString:@"status"]) {
        [self executeStatusCommandFromSocket:socket];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}


/*
 SP_CONNECTION_STATE_LOGGED_OUT
 User not yet logged in.
 
 SP_CONNECTION_STATE_OFFLINE
 User is logged in but in offline mode.
 
 SP_CONNECTION_STATE_LOGGED_IN
 Logged in against a Spotify access point.
 
 SP_CONNECTION_STATE_DISCONNECTED
 Was logged in, but has now been disconnected.
 
 SP_CONNECTION_STATE_UNDEFINED
 */
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

@end
