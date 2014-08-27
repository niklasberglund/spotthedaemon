//
//  SDUser.m
//  SpotDaDaemon
//
//  Created by Niklas Berglund on 8/23/14.
//  Copyright (c) 2014 Your Company. All rights reserved.
//

#import "SDUser.h"
#import "NSObject+description.h"

@implementation SDUser

- (id)initWithObject:(SPUser *)userObject
{
    self = [super init];
    
    if (self) {
        self->clsUser = userObject;
        
        [SPAsyncLoading waitUntilLoaded:self->clsUser timeout:kSPAsyncLoadingDefaultTimeout then:^(NSArray *loadedItems, NSArray *notLoadedItems) {
            self.name = [self->clsUser displayName];
            self.userName = [self->clsUser canonicalName];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //self.loaded = YES;
            });
        }];
    }
    
    return self;
}


- (NSString *)description
{
    return [self descriptionWithMembers:@{
        @"name" : self.name,
        @"userName" : self.userName
    }];
}

@end
