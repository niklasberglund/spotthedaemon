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
    NSString *commandArgumentsString; // command and arguments
    
    if ([commandString rangeOfString:[SDCommand identifierSeparator]].location != NSNotFound) {
        NSArray *separatedByIdentfierSeparator = [commandString componentsSeparatedByString:[SDCommand identifierSeparator]];
        self.identifier = [[separatedByIdentfierSeparator objectAtIndex:0] intValue];
        
        commandArgumentsString = [separatedByIdentfierSeparator objectAtIndex:1];
    }
    else { // no identifier specified
        commandArgumentsString = commandString;
    }
    
    NSArray *components = [commandArgumentsString componentsSeparatedByString:[SDCommand argumentSeparator]];
    
    self.command = [components firstObject];
    
    if (components.count > 1) { // arguments, if there are any
        NSMutableArray *mutableCompontents = [components mutableCopy];
        [mutableCompontents removeObjectAtIndex:0];
        self.arguments = (NSArray *)mutableCompontents;
    }
    
    NSLog(@"%@", components);
    
    NSDictionary *dict = [[NSDictionary alloc] init];
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
}

+ (NSString *)startSeparator
{
    return @"$";
}


+ (NSString *)endSeparator
{
    return @"#";
}


+ (NSString *)identifierSeparator
{
    return @"§";
}


+ (NSString *)argumentSeparator
{
    return @"|";
}

@end

