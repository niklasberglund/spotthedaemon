//
//  NSDictionary+jsonString.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/27/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "NSDictionary+jsonString.h"

@implementation NSDictionary (jsonString)

+ (NSString *)jsonString
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    
    if (error) {
        NSLog(@"ERROR: JSON conversion failed with error: %@", error);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString *)jsonStringPretty
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"ERROR: JSON conversion failed with error: %@", error);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
