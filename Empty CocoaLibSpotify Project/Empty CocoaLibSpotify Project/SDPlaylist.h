//
//  SDPlaylist.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "SDUser.h"

@interface SDPlaylist : NSObject
{
    SPPlaylist *clsPlaylist; // CocoaLibSpotify playlist object
}

- (id)initWithPlaylistObject:(SPPlaylist *)playlist;

- (NSString *)name;
- (SDUser *)owner;
- (NSArray *)subscribers;
- (BOOL)isLoaded;
- (BOOL)isCollaborative;

@end
