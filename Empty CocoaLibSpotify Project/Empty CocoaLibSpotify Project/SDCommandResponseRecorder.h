//
//  SDRequestResponseRecorder.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/8/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCommand.h"
#import "SDResponse.h"

typedef void (^ResponseBlock)(SDResponse *response);

@interface SDCommandResponseRecorder : NSObject {
    NSMutableDictionary *commandResponseDict;
}

+ (SDCommandResponseRecorder *)sharedCommandResponseRecorder;

- (void)registerCommand:(SDCommand *)command;
- (void)registerCommandString:(NSString *)commandString;
- (void)recordResponse:(SDResponse *)response forCommand:(SDCommand *)command;
- (void)recordResponse:(SDResponse *)response forCommandString:(NSString *)commandString;
- (NSData *)responseForCommand:(SDCommand *)command;
- (NSData *)responseForCommandString:(NSString *)commandString;
- (void)onResponseForCommand:(SDCommand *)command callBlock:(void (^)(NSData *response))block;
- (void)onResponseForCommandString:(NSString *)commandString callBlock:(void (^)(NSData *response))block;

@end
