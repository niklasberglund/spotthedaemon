//
//  SDCommand.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDCommand.h"
#import "SDSpotDaDaemon.h"

@implementation SDCommand

- (id)initCommandFromString:(NSString *)rawCommandString
{
    self = [super init];
    
    if (self) {
        [self populateFromString:rawCommandString];
    }
    
    return self;
}


+ (id)commandFromString:(NSString *)rawCommandString
{
    return [[self alloc] initCommandFromString:rawCommandString];
}


- (void)populateFromString:(NSString *)rawCommandString
{
    NSString *commandArgumentsString; // command and arguments
    
    if ([rawCommandString rangeOfString:[SDCommand identifierSeparator]].location != NSNotFound) {
        NSArray *separatedByIdentfierSeparator = [rawCommandString componentsSeparatedByString:[SDCommand identifierSeparator]];
        self.identifier = [[separatedByIdentfierSeparator objectAtIndex:0] intValue];
        
        commandArgumentsString = [separatedByIdentfierSeparator objectAtIndex:1];
    }
    else { // no identifier specified
        commandArgumentsString = rawCommandString;
    }
    
    NSArray *components = [commandArgumentsString componentsSeparatedByString:[SDCommand argumentSeparator]];
    
    self.commandString = [components firstObject];
    
    if (components.count > 1) { // arguments, if there are any
        NSMutableArray *mutableCompontents = [components mutableCopy];
        [mutableCompontents removeObjectAtIndex:0];
        self.arguments = (NSArray *)mutableCompontents;
        
        NSMutableArray *valuesTemp = [[NSMutableArray alloc] init];
        NSMutableArray *subcommandsTemp = [[NSMutableArray alloc] init];
        
        for (NSString *arg in self.arguments) {
            if ([SDCommand isCommand:arg]) {
                [subcommandsTemp addObject:arg];
            }
            else { // treat as value if it's not a command
                [valuesTemp addObject:arg];
            }
        }
        
        self.values = (NSArray *)valuesTemp;
        self.subcommandStrings = (NSArray *)subcommandsTemp;
    }
    
    NSLog(@"%@", self);
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


+ (NSArray *)recognizedCommands
{
    return @[
        @"login",
        @"logout",
        @"play",
        @"pause",
        @"next",
        @"previous",
        @"status",
        @"track",
        @"playlist",
        @"create"
    ];
}


+ (BOOL)isCommand:(NSString *)string
{
    return [[SDCommand recognizedCommands] containsObject:string];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; identifier = %i;command = %@; arguments = %@; subcommands = %@; values = %@>", [self class], self,
            self.identifier, self.commandString, self.arguments, self.subcommandStrings, self.values];
}

@end

