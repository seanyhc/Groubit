//
//  GBCommManager.m
//  Groubit_iOS
//
//  Created by Jeffrey on 5/3/12.
//  Copyright (c) 2012 UCB MIMS. All rights reserved.
//

#import "GBCommManager.h"

@implementation GBCommManager

static GBCommManager* commManager = nil; 



+(GBCommManager*) getCommManager
{
    if(commManager == nil)
    {
        commManager = [[GBCommManager alloc] init];
    }
    return commManager;
}

@end
