//
//  SDCommandServer.h
//  Empty CocoaLibSpotify Project
//
//  Created by Niklas Berglund on 7/2/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "SDCommand.h"
#import "SDCommandExecuter.h"
#import "SDCommandExecuterDelegate.h"


#define DEFAULT_PORT 4030


@interface SDCommandServer : NSObject<GCDAsyncSocketDelegate, SDCommandExecuterDelegate>
{
    GCDAsyncSocket *listenSocket;
    NSMutableArray *activeSockets;
    dispatch_queue_t socketQueue;
    
    SDCommandExecuter *commandExecuter;
}

@property (nonatomic, strong) NSNumber *port;

- (id)initWithPort:(NSNumber *)port;
- (void)start;

@end
