//
//  SDUser.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLibSpotify/CocoaLibSpotify.h>

@interface SDUser : NSObject<SPAsyncLoading>
{
    SPUser *clsUser; // CocoaLibSpotify user object
}

@property (readonly, nonatomic, getter = isLoaded) BOOL loaded;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *spotifyUri;

- (id)initWithObject:(SPUser *)userObject;

@end
