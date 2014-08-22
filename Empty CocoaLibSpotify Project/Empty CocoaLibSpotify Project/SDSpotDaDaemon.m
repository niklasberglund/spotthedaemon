//
//  SDSpotDaDaemon.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/21/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDSpotDaDaemon.h"

@implementation SDSpotDaDaemon

+ (BOOL)isSpotifyUri:(NSString *)string
{
    NSArray *separatedComponents = [string componentsSeparatedByString:@":"];
    
    if (separatedComponents.count == 3) {
        if ([[separatedComponents firstObject] isEqualToString:@"spotify"]){
            return YES;
        }
    }
    else {
        return NO;
    }
}

@end
