//
//  SDRequestResponseRecorder.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/8/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDCommand.h"

@interface SDCommandResponseRecorder : NSObject {
    NSMutableDictionary *commandResponseDict;
}

+ (SDCommandResponseRecorder *)sharedCommandResponseRecorder;

- (void)registerCommand:(SDCommand *)command;
- (void)recordResponse:(NSData *)response forCommand:(SDCommand *)command;
- (void)recordResponse:(NSData *)response forCommandString:(NSString *)commandString;
- (NSData *)responseForCommand:(SDCommand *)command;
- (NSData *)responseForCommandString:(NSString *)commandString;

@end
