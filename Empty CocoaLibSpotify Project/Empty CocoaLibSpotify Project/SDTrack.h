//
//  SDTrack.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "SDAlbum.h"

@interface SDTrack : NSObject
{
    SPTrack *clsTrack; // CocoaLibSpotify track object
}

- (NSString *)name;
- (NSArray *)artists;
- (SDAlbum *)album;
- (NSString *)spotifyURI;
- (BOOL)isStarred;

@end
