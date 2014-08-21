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
        
        self->commandExecuter = [SDCommandExecuter commandExecuterWithDelegate:self];
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
    NSMutableDictionary *socketDict = [NSMutableDictionary dictionaryWithObjects:@[newSocket, [NSMutableData data], [[NSMutableArray alloc] init]] forKeys:@[@"socket", @"data", @"commands"]];
    [self->activeSockets addObject:socketDict];
    NSLog(@"accepted socket %@", newSocket);
    
    //[newSocket readDataWithTimeout:60.0 tag:123];
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
    
    NSLog(@"%@", self->activeSockets);
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
    
    //[sock writeData:[@"TEST" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:60.0 tag:0];
    
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
    
    for (SDCommand *extractedCommand in commands) {
        [self registerCommand:extractedCommand forSocket:sock];
        [self->commandExecuter executeCommand:extractedCommand fromSocket:sock];
    }
    
    NSLog(@"%@", commands);
    NSLog(@"DATA: %@", [[NSString alloc] initWithData:socketData encoding:NSUTF8StringEncoding]);
    
    //[sock readDataWithTimeout:60.0 tag:123];
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:60.0 tag:0];
}


- (NSArray *)extractCommandsFromString:(NSString *)dataString
{
    if ([dataString rangeOfString:[SDCommand startSeparator]].location != NSNotFound) {
        NSMutableArray *separatedCommands = [[NSMutableArray alloc] init];
        
        NSArray *separatedByStartByte = [dataString componentsSeparatedByString:[SDCommand startSeparator]];
        
        for (NSString *separatedString in separatedByStartByte) {
            int endByteIndex = (int)[separatedString rangeOfString:[SDCommand endSeparator]].location;
            
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


- (void)finishedExecutingCommand:(SDCommand *)command withResponse:(NSData *)response
{
    NSLog(@"finished executing command");
    NSLog(@"%@", command);
    NSLog(@"%@", [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]);
    NSLog(@"");
    
    GCDAsyncSocket *socket = [self socketForCommand:command];
    
    [socket writeData:response withTimeout:60.0 tag:0];
    [socket disconnectAfterWriting];
}


#pragma mark -
#pragma mark Socket, data, command functions

- (void)addActiveSocket:(GCDAsyncSocket *)socket
{
    NSMutableDictionary *socketDict = [NSMutableDictionary dictionaryWithObjects:@[socket, [NSMutableData data], [[NSMutableArray alloc] init]] forKeys:@[@"socket", @"data", @"commands"]];
    [self->activeSockets addObject:socketDict];
}


- (void)removeActiveSocket:(GCDAsyncSocket *)socket
{
    for (NSDictionary *socketDict in [self->activeSockets copy]) {
        if ([socketDict objectForKey:@"socket"] == socket) {
            [self->activeSockets removeObject:socketDict];
        }
    }
}


- (void)registerCommand:(SDCommand *)command forSocket:(GCDAsyncSocket *)socket
{
    for (NSDictionary *socketDict in [self->activeSockets copy]) {
        GCDAsyncSocket *currentSocket = (GCDAsyncSocket *)[socketDict valueForKey:@"socket"];
        
        if (currentSocket == socket) {
            NSMutableArray *commands = (NSMutableArray *)[socketDict objectForKey:@"commands"];
            [commands addObject:command];
        }
    }
}


- (GCDAsyncSocket *)socketForCommand:(SDCommand *)command
{
    for (NSDictionary *socketDict in [self->activeSockets copy]) {
        NSArray *thisDictCommands = (NSArray *)[socketDict objectForKey:@"commands"];
        
        for (SDCommand *currentCommand in thisDictCommands) {
            if (currentCommand == command) { // match
                GCDAsyncSocket *socket = [socketDict objectForKey:@"socket"];
                return socket;
            }
        }
    }
    
    // not found
    NSLog(@"%@", self->activeSockets);
    NSLog(@"%@", command);
    NSLog(@"ERROR: no socket found for command");
    
    return nil;
}


- (NSMutableData *)dataForSocket:(GCDAsyncSocket *)socket
{
    NSMutableData *data;
    
    for (NSMutableDictionary *socketDict in [self->activeSockets copy]) {
        if ([socketDict objectForKey:@"socket"] == socket) {
            return data;
        }
    }
    
    return nil;
}


- (NSMutableDictionary *)dictForCommand:(SDCommand *)command
{
    for (NSMutableDictionary *currentDict in [self->activeSockets copy]) {
        NSArray *currentDictCommands = [currentDict objectForKey:@"commands"];
        
        for (SDCommand *currentCommand in currentDictCommands) {
            if (currentCommand == command) {
                return currentDict;
            }
        }
    }
    
    return nil;
}


- (NSMutableData *)dataForCommand:(SDCommand *)command
{
    for (NSMutableDictionary *currentDict in [self->activeSockets copy]) {
        NSArray *currentDictCommands = [currentDict objectForKey:@"commands"];
        
        for (SDCommand *currentCommand in currentDictCommands) {
            if (currentCommand == command) {
                return (NSMutableData *)[currentDict objectForKey:@"data"];
            }
        }
    }
    
    return nil;
}


@end
