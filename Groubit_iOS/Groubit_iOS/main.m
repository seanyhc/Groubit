//
//  main.m
//  Groubit_iOS
//
//  Created by Sean Chen on 12/28/11.
//  Copyright 2011 UCB MIMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

int main(int argc, char *argv[])
{
    
    // integration with Parse
    [Parse setApplicationId:@"KwfoO8E0DZsWkXXtapCBu6l4R6pYOwIpFPJg6uDa" 
                  clientKey:@"EED0hRQoJWknMCwBvACtZQtsXmpgLIGNdkXhXW2U"];
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    
    return retVal;
}