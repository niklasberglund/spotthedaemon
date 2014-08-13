//
//  SDResponse.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/12/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDResponse : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic) BOOL success;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *data;

- (id)initWithMessage:(NSString *)message success:(BOOL)success identifier:(NSString *)identifier type:(NSString *)type data:(NSDictionary *)data;
+ (SDResponse *)responseWithMessage:(NSString *)message success:(BOOL)success identifier:(NSString *)identifier type:(NSString *)type data:(NSDictionary *)data;
+ (SDResponse *)responseWithMessage:(NSString *)message success:(BOOL)success;
+ (SDResponse *)responseWithMessage:(NSString *)message success:(BOOL)success identifier:(NSString *)identifier;

@end
