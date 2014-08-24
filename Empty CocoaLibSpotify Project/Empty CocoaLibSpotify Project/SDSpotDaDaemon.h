//
//  SDSpotDaDaemon.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/21/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaLumberjack.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface SDSpotDaDaemon : NSObject

+ (BOOL)isSpotifyUri:(NSString *)string;

@end
