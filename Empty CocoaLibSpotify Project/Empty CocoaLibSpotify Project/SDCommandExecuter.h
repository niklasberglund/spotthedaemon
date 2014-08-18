//
//  SDCommandExecuter.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/29/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCommand.h"
#import "SDCommandExecuterDelegate.h"
#import "GCDAsyncSocket.h"

@interface SDCommandExecuter : NSObject

@property (nonatomic, weak) NSObject<SDCommandExecuterDelegate> *delegate;

- (id)initWithDelegate:(id)delegate;
+ (SDCommandExecuter *)commandExecuterWithDelegate:(id)delegate;

- (void)executeCommand:(SDCommand *)command fromSocket:(GCDAsyncSocket *)socket;

@end
