//
//  SDSpotify.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/7/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface SDSpotifyPlayer : NSObject<SPSessionDelegate>

+ (SDSpotifyPlayer *)sharedPlayer;

- (void)loginUser:(NSString *)username password:(NSString *)password;

@end
