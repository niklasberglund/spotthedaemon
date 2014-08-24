//
//  NSObject+description.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/24/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (description)

- (NSString *)descriptionWithMembers:(NSDictionary *)memberVariables;

@end
