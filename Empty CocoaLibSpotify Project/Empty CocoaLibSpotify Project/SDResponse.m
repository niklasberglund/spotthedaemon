//
//  SDResponse.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/12/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDResponse.h"

@implementation SDResponse

- (id)initWithMessage:(NSString *)message success:(BOOL)success identifier:(NSString *)identifier type:(NSString *)type data:(NSDictionary *)data
{
    self = [super init];
    
    if (self) {
        self.identifier = identifier;
        self.message = message;
        self.success = success;
        self.type = type;
        self.data = data;
    }
    
    return self;
}


+ (SDResponse *)responseWithMessage:(NSString *)message success:(BOOL)success identifier:(NSString *)identifier type:(NSString *)type data:(NSDictionary *)data
{
    return [[SDResponse alloc] initWithMessage:message success:success identifier:identifier type:type data:data];
}


#pragma mark -
#pragma mark Shorter ones

+ (SDResponse *)responseWithMessage:(NSString *)message success:(BOOL)success
{
    return [[SDResponse alloc] initWithMessage:message success:success identifier:nil type:nil data:nil];
}


+ (SDResponse *)responseWithMessage:(NSString *)message success:(BOOL)success data:(NSDictionary *)data
{
    return [[SDResponse alloc] initWithMessage:message success:success identifier:nil type:nil data:data];
}


+ (SDResponse *)responseWithMessage:(NSString *)message success:(BOOL)success identifier:(NSString *)identifier
{
    return [[SDResponse alloc] initWithMessage:message success:success identifier:identifier type:nil data:nil];
}

@end
