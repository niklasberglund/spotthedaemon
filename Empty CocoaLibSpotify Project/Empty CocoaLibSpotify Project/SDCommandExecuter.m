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
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
}

@end
