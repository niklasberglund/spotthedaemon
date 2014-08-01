//
//  SDCommandExecuterDelegate.h
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 7/29/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SDCommandExecuterDelegate <NSObject>

- (void)finishedExecutingCommand:(SDCommand *) withResponse:(NSString *)responseString;

@end
