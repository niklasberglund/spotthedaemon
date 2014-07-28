//
//  SDCommand.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDCommand.h"

@implementation SDCommand

- (id)initCommandFromString:(NSString *)commandString
{
    self = [super init];
    
    if (self) {
        [self populateFromString:commandString];
    }
    
    return self;
}


+ (id)commandFromString:(NSString *)commandString
{
    return [[self alloc] initCommandFromString:commandString];
}


- (void)populateFromString:(NSString *)commandString
{
    NSArray *components = [commandString componentsSeparatedByString:(NSString *)COMMAND_SEPARATOR_CHARACTER];
    
    NSLog(@"%@", components);
    
    NSDictionary *dict = [[NSDictionary alloc] init];
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
}

@end
