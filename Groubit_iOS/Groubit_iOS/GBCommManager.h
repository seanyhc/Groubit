//
//  GBCommManager.h
//  Groubit_iOS
//
//  Created by Jeffrey on 5/3/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GBCommManager : NSObject

typedef enum{
    kBroadcastChannel,
    kVisibleUserChannel,
    kInvisibleUserChannel
} GBChannelType;


+ (GBCommManager*) getCommManager;


- (void) sendNotification: (NSString*) userID withChannelType: (GBChannelType) channelType withMessage :(NSString*) message ;

- (void) onReceiveNotification;

@end
