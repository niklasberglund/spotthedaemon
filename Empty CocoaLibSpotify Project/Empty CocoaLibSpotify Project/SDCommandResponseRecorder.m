//
//  SDRequestResponseRecorder.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/8/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDCommandResponseRecorder.h"

@implementation SDCommandResponseRecorder

- (id)init
{
    self = [super init];
    
    if (self) {
        self->commandResponseDict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


+ (SDCommandResponseRecorder *)sharedCommandResponseRecorder
{
    static SDCommandResponseRecorder *singleton;
    
    if (singleton == nil) {
        singleton = [[SDCommandResponseRecorder alloc] init];
    }
    
    return singleton;
}


- (void)registerCommand:(SDCommand *)command
{
    [self registerCommandString:command.commandString];
}


- (void)registerCommandString:(NSString *)commandString
{
    NSMutableDictionary *thisDict = [[NSMutableDictionary alloc] init];
    [self->commandResponseDict setObject:thisDict forKey:commandString];
}


- (void)recordResponse:(NSData *)response forCommand:(SDCommand *)command
{
    [self recordResponse:response forCommandString:command.commandString];
}

- (void)recordResponse:(NSData *)response forCommandString:(NSString *)commandString
{
    NSMutableDictionary *thisDict = [self->commandResponseDict objectForKey:commandString];
    
    if (thisDict == nil) {
        NSLog(@"ERROR"); // TODO: error handling
        return;
    }
    
    ResponseBlock responseCallbackBlock = [thisDict objectForKey:@"response"];
    if (responseCallbackBlock != nil) {
        responseCallbackBlock(response);
    }
    
    [thisDict setValue:response forKey:@"response"];
    
    [self->commandResponseDict setObject:thisDict forKey:commandString];
}


- (NSData *)responseForCommand:(SDCommand *)command
{
    return [self responseForCommandString:command.commandString];
}


- (NSData *)responseForCommandString:(NSString *)commandString
{
    NSMutableDictionary *thisDict = [self->commandResponseDict objectForKey:commandString];
    
    return [thisDict valueForKey:@"response"];
}


- (void)onResponseForCommand:(SDCommand *)command callBlock:(void (^)(NSData *))block
{
    [self onResponseForCommandString:command.commandString callBlock:block];
}


- (void)onResponseForCommandString:(NSString *)commandString callBlock:(void (^)(NSData *))block
{
    NSMutableDictionary *thisDict = [self->commandResponseDict objectForKey:commandString];
    
    [thisDict setValue:block forKey:@"block"];
}

@end
