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
    [self->commandResponseDict setObject:nil forKey:command.command];
}


- (void)recordResponse:(NSData *)response forCommand:(SDCommand *)command
{
    [self->commandResponseDict setObject:response forKey:command.command];
}

- (void)recordResponse:(NSData *)response forCommandString:(NSString *)commandString
{
    [self->commandResponseDict setObject:response forKey:commandString];
}


- (NSData *)responseForCommand:(SDCommand *)command
{
    return [self->commandResponseDict objectForKey:command.command];
}


- (NSData *)responseForCommandString:(NSString *)commandString
{
    return [self->commandResponseDict objectForKey:commandString];
}

@end
