//
//  SDUser.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface SDUser : NSObject
{
    SPUser *clsUser; // CocoaLibSpotify user object
}

- (NSString *)name;
- (NSString *)userName;
- (NSString *)spotifyURI;
- (BOOL)isLoaded;

@end
