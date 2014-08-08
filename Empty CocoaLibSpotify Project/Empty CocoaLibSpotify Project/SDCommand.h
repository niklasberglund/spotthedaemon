//
//  SDCommand.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+jsonString.h"

@interface SDCommand : NSObject

@property (nonatomic) int identifier;
@property (nonatomic, strong) NSString *commandString;
@property (nonatomic, strong) NSArray *arguments;

- (id)initCommandFromString:(NSString *)rawCommandString;
+ (id)commandFromString:(NSString *)rawCommandString;

+ (NSString *)startSeparator;
+ (NSString *)endSeparator;
+ (NSString *)identifierSeparator;
+ (NSString *)argumentSeparator;

@end
