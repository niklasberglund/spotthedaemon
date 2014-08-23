//
//  SDAlbum.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>
#import "SDArtist.h"

@interface SDAlbum : NSObject
{
    SPAlbum *clsAlbum; // CocoaLibSpotify album object
}

- (NSString *)name;
- (SDArtist *)artist;

@end
