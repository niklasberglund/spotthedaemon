//
//  NSDictionary+jsonString.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/27/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (jsonString)

- (NSString *)jsonString;
- (NSString *)jsonStringPretty;


@end
