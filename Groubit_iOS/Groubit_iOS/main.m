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
    // integration with Parse (groubit@gmail.com)
    [Parse setApplicationId:@"wfZ5wJOQM1ILr4wAgxt8MA5egLOCqGd7yOSQc4Uz" 
                  clientKey:@"6iJsrI2eWRNd5yzLX4anTo2UBOvulkB7n1XmNieI"];

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];

    return retVal;
}
