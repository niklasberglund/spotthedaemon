//
//  SDCommandExecuter.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/29/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDCommandExecuter.h"

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


- (void)executeCommand:(SDCommand *)command
{
    // delegate is required
    if (!self.delegate) {
        [NSException raise:@"Missing delegate" format:@"Missing delegate. A delegate is required"];
        return;
    }
    
    NSLog(@"Executing command %@", command);
}

@end
