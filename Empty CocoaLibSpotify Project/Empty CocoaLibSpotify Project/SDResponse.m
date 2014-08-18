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


#pragma mark -
#pragma mark JSON
- (NSData *)json
{
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    [jsonDict setValue:self.identifier forKey:@"identifier"];
    [jsonDict setValue:[NSNumber numberWithBool:self.success] forKey:@"success"];
    [jsonDict setValue:self.message forKey:@"message"];
    [jsonDict setValue:self.type forKey:@"type"];
    [jsonDict setValue:self.data forKey:@"data"];
    
    NSLog(@"%@", jsonDict);
    
    return [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:nil];
}


#pragma mark -
#pragma mark Misc
- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; identifier = %@;message = %@; success = %@; type = %@; data = %@>", [self class], self,
            self.identifier, self.message, self.success ? @"YES" : @"NO", self.type, self.data];
}

@end
