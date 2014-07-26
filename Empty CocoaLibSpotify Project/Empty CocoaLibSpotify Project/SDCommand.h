//
//  SDCommand.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDCommand : NSObject

@property (nonatomic, strong) NSString *command;
@property (nonatomic, strong) NSArray *arguments;

- (id)initCommandFromString:(NSString *)commandString;

@end
