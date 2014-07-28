//
//  SDCommandServer.m
//  Empty CocoaLibSpotify Project
//
//  Created by Niklas Berglund on 7/2/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDCommandServer.h"

@implementation SDCommandServer


- (id)init
{
    return [self initWithPort:[NSNumber numberWithInt:DEFAULT_PORT]];
}


- (id)initWithPort:(NSNumber *)port
{
    self = [super init];
    
    if (self) {
        self->activeSockets = [NSMutableArray array];
        self.port = port;
    }
    
    return self;
}


- (void)start
{
    self->listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSLog(@"%@", self->listenSocket);
    
    NSError *startListenError;
    
    //BOOL startSuccess = [self->listenSocket acceptOnInterface:@"loopback" port:[self.port intValue] error:&startListenError];
    BOOL startSuccess = [self->listenSocket acceptOnPort:[self.port intValue] error:&startListenError];
    
    if (!startSuccess) {
        NSLog(@"error");
    }
    
    NSLog(@"listening on port %i", [self.port intValue]);
    NSLog(@"%@", startListenError);
}


- (void)socket:(GCDAsyncSocket *)sender didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"accepting socket");
    NSMutableDictionary *socketDict = [NSMutableDictionary dictionaryWithObjects:@[newSocket, [NSMutableData data]] forKeys:@[@"socket", @"data"]];
    [self->activeSockets addObject:socketDict];
    NSLog(@"accepted socket %@", newSocket);
    
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:60.0 tag:0];
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    NSDictionary *currentSocketDict;
    
    for (NSDictionary *socketDict in [self->activeSockets copy]) {
        if ([socketDict objectForKey:@"socket"] == sock) {
            currentSocketDict = socketDict;
            [self->activeSockets removeObject:socketDict];
        }
    }
    
    if (error) {
        NSLog(@"ERROR: Socket disconnected with error");
        NSLog(@"%@", error);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"%@", host);
}


- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"read partial data of length %lu", (unsigned long)partialLength);
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSMutableData *socketData;
    
    NSLog(@"looking for this socket's data");
    for (NSMutableDictionary *socketDict in [self->activeSockets copy]) {
        if ([socketDict objectForKey:@"socket"] == sock) {
            socketData = [socketDict objectForKey:@"data"];
            
            if (socketData == nil) {
                socketData = [[NSMutableData alloc] init];
                [socketDict setValue:socketData forKey:@"data"];
            }
            else {
                [socketData appendData:data];
            }
        }
    }
    
    // if it's nil at this point then something is wrong
    if (socketData == nil) {
        NSLog(@"ERROR: socketData is nil. cannot read data from socket");
        return;
    }
    
    NSString *dataString = [[NSString alloc] initWithData:socketData encoding:NSUTF8StringEncoding];
    
    
    NSArray *commands = [self extractCommandsFromString:dataString];
    NSLog(@"extracted commands:");
    NSLog(@"%@", commands);
    
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:60.0 tag:0];
}


- (NSArray *)extractCommandsFromString:(NSString *)dataString
{
    if ([dataString rangeOfString:[NSString stringWithFormat:@"%c", COMMAND_START_BYTE]].location != NSNotFound) {
        NSMutableArray *separatedCommands = [[NSMutableArray alloc] init];
        
        NSArray *separatedByStartByte = [dataString componentsSeparatedByString:[NSString stringWithFormat:@"%c", COMMAND_START_BYTE]];
        
        for (NSString *separatedString in separatedByStartByte) {
            int endByteIndex = (int)[separatedString rangeOfString:[NSString stringWithFormat:@"%c", COMMAND_END_BYTE]].location;
            
            if (endByteIndex == -1) { // not a command
                continue;
            }
            
            NSString *commandString = [separatedString substringToIndex:endByteIndex];
            [separatedCommands addObject:[SDCommand commandFromString:commandString]];
        }
        
        return separatedCommands;
    }
    else {
        return @[];
    }
}


@end
