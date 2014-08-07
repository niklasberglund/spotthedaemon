//
//  SDSpotify.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/7/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDSpotifyPlayer.h"

#include "appkey.c"

@implementation SDSpotifyPlayer

- (id)init
{
    self = [super init];
    
    if (self) {
        NSString *userAgent = [[[NSBundle mainBundle] infoDictionary] valueForKey:(__bridge NSString *)kCFBundleIdentifierKey];
        NSData *appKey = [NSData dataWithBytes:&g_appkey length:g_appkey_size];
        
        NSError *error = nil;
        [SPSession initializeSharedSessionWithApplicationKey:appKey
                                                   userAgent:userAgent
                                               loadingPolicy:SPAsyncLoadingManual
                                                       error:&error];
        if (error != nil) {
            NSLog(@"CocoaLibSpotify init failed: %@", error);
            abort();
        }
        
        [[SPSession sharedSession] setDelegate:self];
    }
    
    return self;
}


+ (SDSpotifyPlayer *)sharedPlayer
{
    static SDSpotifyPlayer *singletonInstance = nil;
    
    if (singletonInstance == nil) {
        singletonInstance = [[SDSpotifyPlayer alloc] init];
    }
    
    return singletonInstance;
}

@end
